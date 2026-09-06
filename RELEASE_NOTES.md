WAJetsam-ServiceExtensionFix 1.8.2

- Fixes a Settings app crash that could occur when scrolling to the tweak entry on some iOS 16 devices.
- Simplifies the PreferenceLoader entry to the standard `bundle`, `cell`, `detail`, `icon`, `isController` and `label` fields.
- Removes the duplicate `controller` and `iconImage` properties and the hard-coded `/var/jb` icon path.
- Renames the remaining project files and Settings bundle to match `WAJetsam-ServiceExtensionFix`.
- Keeps `WatusiExpiryFix` under that name so it remains easy to identify and allow in Choicy.
- Keeps the proven WatusiTools `checkExpiryDate` patch unchanged.
- Keeps support for both `libWatusiTools.dylib` and `libWatusiToolsSL.dylib`.
- Keeps the WhatsApp ServiceExtension memory floor at 40 MB.
- Keeps the clickable GitHub Repository link in Settings.
- Keeps Sileo's `Reboot Device` finish action after installation.
- Includes no diagnostic logging, trace dylib, observer daemon, report/status or collector tools.

If you use Choicy, make sure `WatusiExpiryFix` is allowed for `net.whatsapp.WhatsApp.ServiceExtension` and is not blocked.
