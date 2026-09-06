WAJetsam-ServiceExtensionFix 1.8.4

- Fixes the tweak icon not appearing in the main iOS Settings list.
- Restores the PreferenceLoader `icon` entry to the real rootless path: `/var/jb/Library/PreferenceLoader/Preferences/WAJetsamServiceExtensionFix.png`.
- Keeps the simplified crash-safe PreferenceLoader entry from 1.8.2: no duplicate `controller` key and no `iconImage` key.
- Keeps the correctly sized 29 px, 58 px (@2x) and 87 px (@3x) Settings icon files from 1.8.3.
- Keeps the proven WatusiTools `checkExpiryDate` patch unchanged.
- Keeps support for both `libWatusiTools.dylib` and `libWatusiToolsSL.dylib`.
- Keeps the WhatsApp ServiceExtension memory floor at 40 MB.
- Keeps the clickable GitHub Repository link in Settings.
- Keeps Sileo's `Reboot Device` finish action after installation.
- Includes no diagnostic logging, trace dylib, observer daemon, report/status or collector tools.

If you use Choicy, make sure `WatusiExpiryFix` is allowed for `net.whatsapp.WhatsApp.ServiceExtension` and is not blocked.
