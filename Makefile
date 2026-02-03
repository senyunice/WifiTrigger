export THEOS_PACKAGE_SCHEME = rootless
TARGET := iphone:latest:15.0
ARCHS := arm64 arm64e

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = WifiTrigger

WifiTrigger_FILES = Tweak.x
WifiTrigger_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk

SUBPROJECTS += Prefs
include $(THEOS_MAKE_PATH)/aggregate.mk