include /ioc/tools/driver.makefile
include $(HOME)/epics/modules/makeUtils/latest/utils.mk

BUILDCLASSES=Linux

ARCH_FILTER=RHEL%

install-gitinfo: foo

.PHONY: foo

foo:
	echo ##########################################################
