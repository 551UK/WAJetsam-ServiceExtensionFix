WAJetsam-ServiceExtensionFix 1.8.3

- Restores the tweak icon in the main iOS Settings list.
- Uses the existing icon artwork and packages it at proper Settings sizes instead of using the oversized 128 px source directly.
- Adds 29 px, 58 px (@2x) and 87 px (@3x) Settings icon variants so it displays at the correct physical size across Retina devices.
- Keeps the simplified PreferenceLoader entry from 1.8.2 to avoid the Settings scrolling crash.
- Keeps the proven WatusiTools `checkExpiryDate` patch unchanged.
- Keeps support for both `libWatusiTools.dylib` and `libWatusiToolsSL.dylib`.
- Keeps the WhatsApp ServiceExtension memory floor at 40 MB.
- Keeps the clickable GitHub Repository link in Settings.
- Keeps Sileo's `Reboot Device` finish action after installation.
- Includes no diagnostic logging, trace dylib, observer daemon, report/status or collector tools.

If you use Choicy, make sure `WatusiExpiryFix` is allowed for `net.whatsapp.WhatsApp.ServiceExtension` and is not blocked.
