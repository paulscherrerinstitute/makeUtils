HERE:=$(dir $(lastword $(MAKEFILE_LIST)))

# We can't add to VERSIONCHECKFILES after including driver.makefile
# because this variable is already expanded in 'driver.makefile'
# when checking the version.
# We can't predefine it here either because driver.makefile initializes
# to empty. Thus, we use this hack to make sure our makefile snippets
# are checked...
SOURCES_hack=$(wildcard *.mk)

include /ioc/tools/driver.makefile
include $(HERE)utils.mk

MKSRCS+=utils.mk makeUtils_version.mk

$(MODULE_LOCATION)/%.mk: %.mk
	$(INSTALL) -D -m 0644 $< $@

$(MODULE_LOCATION)/../latest/utils.mk: latest-utils.mk
	$(INSTALL) -D -m 0644 $< $@

MKINSTALLS+=$(addprefix $(MODULE_LOCATION)/,$(MKSRCS) ../latest/utils.mk)

#BUILDCLASSES=Linux
#ARCH_FILTER=RHEL%

$(PRJ)_version.mk: utils.mk

ifdef INSTALL_MODULE_TOP_RULE
$(INSTALL_MODULE_TOP_RULE) $(MKINSTALLS)
endif

ifndef BUILDRULE
BUILDRULE=build::
endif

instdebug:
	echo "LIBVERSION $(LIBVERSION)"
	echo "MODULE_LOCATION $(MODULE_LOCATION)"

#$(BUILDRULE) check-makepass

check-makepass:
	@if [ -z "$(MAKE_PASS)" ] ; then echo "ERROR: MAKE_PASS undefined"; exit 1; fi
	@echo "MAKE_PASS: $(MAKE_PASS)"

.PHONY: instdebug check-makepass


foo:
	echo '$(LIBVERSION)'
	echo '$(call CONVERT_VERSION_NUMBER,test,4)'
