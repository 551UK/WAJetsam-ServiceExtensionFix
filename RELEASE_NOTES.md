WAJetsam-ServiceExtensionFix 2.0

- Built from the clean v1.8.2 codebase.
- Fixes the Settings preference page layout by using the same proven PreferenceLoader/bundle arrangement as Replaced Screen & Battery.
- Uses the WhatsApp icon from the tweak as proper 29x29, 58x58 and 87x87 preference-bundle resources.
- Simplifies the preference-page navigation title so the page does not depend on loading a custom title-view icon.
- Keeps the 40 MB WhatsApp ServiceExtension memory floor unchanged.
- Keeps the WatusiTools checkExpiryDate patch unchanged, including support for libWatusiTools.dylib and libWatusiToolsSL.dylib.
- Keeps the GitHub Repository button in Settings.
- Keeps the reboot finish action after installation.

If you use Choicy, make sure WatusiExpiryFix is allowed for net.whatsapp.WhatsApp.ServiceExtension and is not blocked.
