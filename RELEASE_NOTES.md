WAJetsam-ServiceExtensionFix 2.0.1

Fixes the missing Settings icon in 2.0:
- Packages the exact icon filename requested by PreferenceLoader inside the preference bundle.
- Includes the previously missing bundle Info.plist using Theos RESOURCE_FILES.
- Uses the checked-in 29x29, 58x58 (@2x), and 87x87 (@3x) icons without overwriting them during the build.
- Checks the extracted DEB for bundle metadata, executable, icon reference, PNG integrity, dimensions, and matching source artwork before publishing.

The WhatsApp/Watusi patch code and preference controls are unchanged.
After installing, complete the package manager's restart action and reopen Settings.
