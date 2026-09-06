export TARGET = iphone:clang:14.5:14.5
export ARCHS = arm64 arm64e

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = WAJetsamServiceExtensionFix WatusiExpiryFix

WAJetsamServiceExtensionFix_FILES = WAJetsamServiceExtensionFix.x
WAJetsamServiceExtensionFix_CFLAGS = -fobjc-arc -Wall -Wextra -I$(THEOS_PROJECT_DIR)
WAJetsamServiceExtensionFix_FRAMEWORKS = Foundation
WAJetsamServiceExtensionFix_LIBRARIES = proc

WatusiExpiryFix_FILES = WatusiExpiryFix.m
WatusiExpiryFix_CFLAGS = -fobjc-arc -Wall -Wextra -I$(THEOS_PROJECT_DIR)
WatusiExpiryFix_FRAMEWORKS = Foundation

SUBPROJECTS += WAJetsamServiceExtensionFixPrefs

include $(THEOS_MAKE_PATH)/tweak.mk
include $(THEOS_MAKE_PATH)/aggregate.mk

# PreferenceLoader resolves the Settings-list icon relative to
# Library/PreferenceLoader/Preferences. Stage dedicated copies there so the
# entry works correctly on rootless builds after Theos applies /var/jb.
after-stage::
	$(ECHO_NOTHING)mkdir -p "$(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences"$(ECHO_END)
	$(ECHO_NOTHING)cp "$(THEOS_PROJECT_DIR)/WAJetsamServiceExtensionFixPrefs/Resources/icon.png" "$(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/WAJetsamServiceExtensionFix.png"$(ECHO_END)
	$(ECHO_NOTHING)cp "$(THEOS_PROJECT_DIR)/WAJetsamServiceExtensionFixPrefs/Resources/icon@2x.png" "$(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/WAJetsamServiceExtensionFix@2x.png"$(ECHO_END)
	$(ECHO_NOTHING)cp "$(THEOS_PROJECT_DIR)/WAJetsamServiceExtensionFixPrefs/Resources/icon@3x.png" "$(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/WAJetsamServiceExtensionFix@3x.png"$(ECHO_END)
