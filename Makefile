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
