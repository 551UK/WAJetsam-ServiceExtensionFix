WAJetsam-ServiceExtensionFix 1.8.5

- Fixes the Settings icon by copying the same working PreferenceLoader layout used by Replaced-Screen-Battery.
- The PreferenceLoader entry now uses `icon.png` instead of an external `/var/jb/...` path.
- Packages `icon.png`, `icon@2x.png` and `icon@3x.png` inside `WAJetsamServiceExtensionFixPrefs.bundle/Resources`.
- Uses 29 px, 58 px (@2x) and 87 px (@3x) icon variants generated from the existing WhatsApp-style tweak icon.
- Keeps the simplified crash-safe PreferenceLoader entry: no duplicate `controller` key and no `iconImage` key.
- Keeps the proven WatusiTools `checkExpiryDate` patch unchanged.
- Keeps support for both `libWatusiTools.dylib` and `libWatusiToolsSL.dylib`.
- Keeps the WhatsApp ServiceExtension memory floor at 40 MB.
- Keeps the clickable GitHub Repository link in Settings.
- Keeps Sileo's `Reboot Device` finish action after installation.
- Includes no diagnostic logging, trace dylib, observer daemon, report/status or collector tools.

If you use Choicy, make sure `WatusiExpiryFix` is allowed for `net.whatsapp.WhatsApp.ServiceExtension` and is not blocked.
