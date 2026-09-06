"""Verify the icon lookup target in an extracted rootless DEB before release."""
import hashlib
import plistlib
import struct
import sys
import zlib
from pathlib import Path


def verify(root):
    source = Path(__file__).resolve().parents[1]
    loader = root / 'Library/PreferenceLoader/Preferences'
    entry = plistlib.loads((loader / 'WAJetsamServiceExtensionFix.plist').read_bytes())['entry']
    bundle = root / 'Library/PreferenceBundles' / (entry['bundle'] + '.bundle')
    info = plistlib.loads((bundle / 'Info.plist').read_bytes())
    assert info['NSPrincipalClass'] == entry['detail']
    assert info['CFBundleExecutable'] == entry['bundle']
    assert (bundle / info['CFBundleExecutable']).stat().st_size > 0
    assert info['CFBundleIdentifier'] == 'com.551.wajetsamserviceextensionfixprefs'
    icon = Path(entry['icon'])
    assert icon.name == str(icon) and icon.suffix == '.png'
    for scale in (1, 2, 3):
        suffix = '' if scale == 1 else f'@{scale}x'
        name = f'{icon.stem}{suffix}.png'
        path = bundle / name
        data = path.read_bytes()
        assert data[:8] == b'\x89PNG\r\n\x1a\n', path
        assert struct.unpack('>II', data[16:24]) == (29 * scale, 29 * scale), path
        offset, compressed, ended = 8, bytearray(), False
        while offset < len(data):
            length = struct.unpack('>I', data[offset:offset + 4])[0]
            kind = data[offset + 4:offset + 8]
            payload = data[offset + 8:offset + 8 + length]
            crc = struct.unpack('>I', data[offset + 8 + length:offset + 12 + length])[0]
            assert zlib.crc32(kind + payload) & 0xffffffff == crc, path
            if kind == b'IDAT':
                compressed.extend(payload)
            if kind == b'IEND':
                ended = True
            offset += 12 + length
        assert ended and any(zlib.decompress(compressed)), path
        original = source / 'WAJetsamServiceExtensionFixPrefs/Resources' / name
        assert data == original.read_bytes(), path
        assert data == (loader / name).read_bytes(), path
        assert path.stat().st_mode & 0o444 == 0o444, path
        print(f'PASS {path}: {29 * scale}x{29 * scale}, source SHA256 {hashlib.sha256(data).hexdigest()}')
    print('PASS: PreferenceLoader icon resolves inside its named bundle; Info.plist and executable present.')


if __name__ == '__main__':
    verify(Path(sys.argv[1]))
