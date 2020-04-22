HERE:=$(dir $(lastword $(MAKEFILE_LIST)))

include /ioc/tools/driver.makefile
include $(HERE)utils.mk

MKSRCS+=utils.mk

$(MODULE_LOCATION)/%.mk: %.mk
	$(INSTALL) -D -m 0644 $< $@

$(MODULE_LOCATION)/../latest/utils.mk: latest-utils.mk
	$(INSTALL) -D -m 0644 $< $@

VERSIONCHECKFILES+=$(wildcard *.mk)

MKINSTALLS+=$(addprefix $(MODULE_LOCATION)/,$(MKSRCS) ../latest/utils.mk)

#BUILDCLASSES=Linux
#ARCH_FILTER=RHEL%

ifdef INSTALL_MODULE_TOP_RULE
$(INSTALL_MODULE_TOP_RULE) $(MKINSTALLS)
endif

.PHONY: instdebug

instdebug:
	echo "LIBVERSION $(LIBVERSION)"
	echo "MODULE_LOCATION $(MODULE_LOCATION)"
