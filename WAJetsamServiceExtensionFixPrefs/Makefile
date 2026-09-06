export TARGET = iphone:clang:14.5:14.5
export ARCHS = arm64 arm64e

include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = WAJetsamServiceExtensionFixPrefs
WAJetsamServiceExtensionFixPrefs_FILES = WAJRootListController.m
WAJetsamServiceExtensionFixPrefs_FRAMEWORKS = Foundation CoreFoundation UIKit
WAJetsamServiceExtensionFixPrefs_PRIVATE_FRAMEWORKS = Preferences
WAJetsamServiceExtensionFixPrefs_INSTALL_PATH = /Library/PreferenceBundles
WAJetsamServiceExtensionFixPrefs_INFOPLIST_FILE = Info.plist
WAJetsamServiceExtensionFixPrefs_RESOURCE_FILES = Resources/icon.png
WAJetsamServiceExtensionFixPrefs_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/bundle.mk
