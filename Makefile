export TARGET = iphone:clang:14.5:14.5
export ARCHS = arm64 arm64e

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = WatusiServiceDiag WatusiExpiryFix

WatusiServiceDiag_FILES = Tweak.x
WatusiServiceDiag_CFLAGS = -fobjc-arc -Wall -Wextra -I$(THEOS_PROJECT_DIR)
WatusiServiceDiag_FRAMEWORKS = Foundation
WatusiServiceDiag_LIBRARIES = proc

WatusiExpiryFix_FILES = ExpiryFix.m
WatusiExpiryFix_CFLAGS = -fobjc-arc -Wall -Wextra -I$(THEOS_PROJECT_DIR)
WatusiExpiryFix_FRAMEWORKS = Foundation

SUBPROJECTS += WatusiServiceFixPrefs

include $(THEOS_MAKE_PATH)/tweak.mk
include $(THEOS_MAKE_PATH)/aggregate.mk
