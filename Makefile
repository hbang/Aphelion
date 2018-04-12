export TARGET=:clang
THEOS_BUILD_DIR = debs
include theos/makefiles/common.mk
APPLICATION_NAME = Aphelion
Aphelion_FILES = $(wildcard Aphelion/*m) $(wildcard JSONKit/*m)
Aphelion_FRAMEWORKS = UIKit Foundation Twitter Social Accounts
Aphelion_CFLAGS = -include Aphelion/Aphelion-Prefix.pch -DTHEOS
include theos/makefiles/application.mk
#Written by hand by Aehmlo <3
