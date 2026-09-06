WAJetsam&ServiceExtensionFIx 1.8.0 is the renamed clean release of the proven WhatsApp ServiceExtension fix.

- Keeps the proven `checkExpiryDate` signature patch unchanged.
- Supports both `libWatusiTools.dylib` and `libWatusiToolsSL.dylib`.
- Keeps the WhatsApp ServiceExtension memory floor at 40 MB.
- Includes no diagnostic logging, trace dylib, observer daemon, report/status or collector tools.
- Includes a Settings page with a WhatsApp-style icon and an Enable Patch switch.
- Uses a new package identity and conflicts/replaces the old `com.551.watusiservicediag` package to prevent duplicate injection.

After installing, perform a Dopamine userspace reboot. If Choicy has a custom WhatsApp ServiceExtension configuration, allow `WatusiExpiryFix`.
