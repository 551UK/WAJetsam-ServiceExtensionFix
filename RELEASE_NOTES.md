WAJetsam-ServiceExtensionFix 1.8.1

- Corrects the tweak name everywhere to `WAJetsam-ServiceExtensionFix`.
- Keeps the proven `checkExpiryDate` signature patch unchanged.
- Supports both `libWatusiTools.dylib` and `libWatusiToolsSL.dylib`.
- Keeps the WhatsApp ServiceExtension memory floor at 40 MB.
- Adds a clickable GitHub Repository link in Settings.
- Adds the repository as package Homepage metadata.
- Requests Sileo's `Reboot Device` finish action after installation instead of a respring action.
- Includes no diagnostic logging, trace dylib, observer daemon, report/status or collector tools.

If you use Choicy, make sure `WatusiExpiryFix` is allowed for `net.whatsapp.WhatsApp.ServiceExtension` and is not blocked.
