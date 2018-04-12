TARGET = :clang
THEOS_BUILD_DIR = debs

include theos/makefiles/common.mk

APPLICATION_NAME = Aphelion
Aphelion_FILES = $(wildcard Aphelion/*.m) $(wildcard headers/*/*.m)
Aphelion_FRAMEWORKS = UIKit CoreGraphics Twitter Accounts QuartzCore
Aphelion_CFLAGS = -I./headers -include Aphelion/Aphelion-Prefix.pch -DTHEOS

include theos/makefiles/application.mk

# Written by hand by Aehmlo <3

after-install::
ifeq ($(shell uname -p),arm)
	killall Aphelion || true
	@sleep 0.2
	sblaunch ws.hbang.Aphelion || true
else
	install.exec "killall Aphelion; sleep 0.2; sblaunch ws.hbang.Aphelion || true"
endif
