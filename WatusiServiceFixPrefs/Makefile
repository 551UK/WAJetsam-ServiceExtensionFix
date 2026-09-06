export TARGET = iphone:clang:14.5:14.5
export ARCHS = arm64 arm64e

include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = WatusiServiceFixPrefs
WatusiServiceFixPrefs_FILES = WSFRootListController.m
WatusiServiceFixPrefs_FRAMEWORKS = Foundation CoreFoundation UIKit
WatusiServiceFixPrefs_PRIVATE_FRAMEWORKS = Preferences
WatusiServiceFixPrefs_INSTALL_PATH = /Library/PreferenceBundles
WatusiServiceFixPrefs_INFOPLIST_FILE = Info.plist
WatusiServiceFixPrefs_RESOURCE_FILES = Resources/icon.png
WatusiServiceFixPrefs_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/bundle.mk
