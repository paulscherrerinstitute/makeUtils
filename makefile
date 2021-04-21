HERE:=$(dir $(lastword $(MAKEFILE_LIST)))

# We can't add to VERSIONCHECKFILES after including driver.makefile
# because this variable is already expanded in 'driver.makefile'
# when checking the version.
# We can't predefine it here either because driver.makefile initializes
# to empty. Thus, we use this hack to make sure our makefile snippets
# are checked...
SOURCES_hack=$(wildcard *.mk)

EXCLUDE_VERSIONS=3.13

include /ioc/tools/driver.makefile
include $(HERE)utils.mk

MKSRCS+=utils.mk make-subdirs.mk

MKSRCS_ALL+=$(MKSRCS) makeUtils_version.mk

$(MODULE_LOCATION)/%.mk: %.mk
	$(INSTALL) -D -m 0644 $< $@

$(MODULE_LOCATION)/../latest/include-latest.mk: include-latest.mk
	$(INSTALL) -D -m 0644 $< $@

$(MODULE_LOCATION)/../latest/%.mk: $(MODULE_LOCATION)/../latest/include-latest.mk
	$(RM) $@
	ln -s include-latest.mk $@

MKINSTALLS+=$(addprefix $(MODULE_LOCATION)/,$(MKSRCS_ALL) $(addprefix ../latest/,$(MKSRCS) include-latest.mk))

#BUILDCLASSES=Linux
#ARCH_FILTER=RHEL7%

$(PRJ)_version.mk: $(MKSRCS)

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

#clean:: clean-local

clean-local:
	$(RM) makeUtils_version.mk

.PHONY: instdebug check-makepass clean clean-local
