#
# Include this file after including 'driver.makefile'
#
# include $(EPICS_MODULES)/makeUtils/latest/utils.mk
#
# instead of 'latest' you may substitute a specific
# version.
#


# record where we are
_MAKE_UTILS_HERE:=$(dir $(lastword $(MAKEFILE_LIST)))

include $(_MAKE_UTILS_HERE)makeUtils_version.mk

#
# Find highest version in a path
#
# call with two arguments: prefix, suffix
# either of which may be empty.
#
# Returns the path with the highest version number
#
# { prefix  / }  version { / suffix }
#
define LATEST_VERSION_PATH
$(firstword $(shell ls -rvd $(addsuffix /,$1)+(+([0-9].)+([0-9]))$(addprefix /,$2)))
endef

#
# Call LATEST_VERSION_PATH(prefix,suffix)
# and extract the version string.
#
define LATEST_VERSION
$(patsubst $(addsuffix /,$1)%,%,$(patsubst %$(addprefix /,$2),%,$(call LATEST_VERSION_PATH,$1,$2)))
endef

ifndef INSTALL
INSTALL=install
endif

#
# Define a variable that communicates the 'pass' of driver.makefile
#
ifndef MAKE_PASS
ifndef EPICSVERSION
MAKE_PASS=1
else ifndef T_A
MAKE_PASS=2
else ifeq ($(filter O.%,$(notdir $(CURDIR))),)
MAKE_PASS=3
else
MAKE_PASS=4
endif
endif # ifndef MAKE_PASS

# Convert a version string (numericals separated by dots)
# into a single number (which is is easier to compare)
#
# call this function with ( version_string, max_level )
#
# the 'max_level' indicates how many levels (major, minor, ...)
# are included in the numerical value. Levels are 'separated'
# by factors of 100.
#
# E.g., $(call CONVERT_VERSION_TO_NUMBER, 1.2.3, 2)
# yields:
#
#    102
#
define CONVERT_VERSION_TO_NUMBER
$(shell echo '$1' | awk 'BEGIN{ FS="." }/^([0-9]+[.])*[0-9]+$$/{ v = 0; m = NF < $2 ? NF : $2; for (i=1; i<=m; i=i+1) v = 100*v + $$i; for (   ; i<= $2;  i=i+1) v = 100*v; print v; }')
endef

define CONVERT_VERSION_TO_LIST
$(shell echo '$1' | awk 'BEGIN{ FS="." }/^([0-9]+[.])*[0-9]+$$/{ m = NF < $2 ? NF : $2; sep=""; for (i=1; i<=m; i=i+1) { printf("%s%i ",sep,$$i); sep=" "; } for (   ; i<= $2;  i=i+1) { printf("%s0",sep); sep=" "; } printf("\n"); }')
endef


# If you want to install something into
# the module's top area (e.g., docs) then
# use
#
# ifdef INSTALL_MODULE_TOP_RULE
# $(INSTALL_MODULE_TOP_RULE) $(myinstalldeps)
# endif
#
# If you want to install into the top of
# every EPICS version use INSTALL_EPICS_TOP_RULE
#
# Finally, to install into the arch-dependent
# directory use INSTALLRULE (provided by driver.makefile)
#

ifeq ($(MAKE_PASS),1)
INSTALL_MODULE_TOP_RULE=install::
endif

ifeq ($(MAKE_PASS),2)
INSTALL_EPICS_TOP_RULE=install::
endif

ifndef GIT
GIT=git
endif

GIT_VERSION:=$(shell ( $(GIT) --version >& /dev/null && $(GIT) --version | sed -e 's/\([^0-9]*\)\([0-9]\+[.][0-9]\+\).*/\2/' ) || echo 0.0)

define BC_EVALUATE
$(shell echo '$1' | bc -l)
endef

# git on some platforms is too old
ifneq ($(call BC_EVALUATE,$(GIT_VERSION) >= 1.8),1)
GIT=/opt/psi/Tools/git/2.22.0/bin/git
endif

# Assemble some info from git
GIT_COMMIT=$(shell $(GIT) rev-parse HEAD)
GIT_BRANCH=$(shell $(GIT) rev-parse --symbolic-full-name HEAD@{upstream})
GIT_REMOTE=$(shell $(GIT) ls-remote --get-url)

#
# Create a README.gitinfo file in the installation area
#

ifdef INSTALL_MODULE_TOP_RULE
$(INSTALL_MODULE_TOP_RULE) install-gitinfo
endif

# User may set this to an empty value before including utils.mk
# in order to avoid installing the gitinfo file
#
# MODULE_GITINFO:=
# MODULE_GITINFO+=

ifndef MODULE_GITINFO
MODULE_GITINFO = $(MODULE_LOCATION)/README.gitinfo
endif

%.gitinfo: .FORCE
	mkdir -p $(MODULE_LOCATION)
	$(RM) $@
	echo "Git Commit:"     >> $@
	echo "  $(GIT_COMMIT)" >> $@
	echo "Branch:"         >> $@
	echo "  $(GIT_BRANCH)" >> $@
	echo "From Remote:"    >> $@
	echo "  $(GIT_REMOTE)" >> $@

install-gitinfo: $(MODULE_GITINFO)

ifneq ($($(PRJ)_VERSION),$(LIBVERSION))
#debugging: $(warning '$($(PRJ)_VERSION)' '$(LIBVERSION)')
FORCE_VERSION_FILE_REGEN=.FORCE
endif

ifndef $(PRJ)_VERSION_AS_LIST
$(PRJ)_VERSION_AS_LIST:=$(or $(call CONVERT_VERSION_TO_LIST,$(LIBVERSION),3),99 0 0)
endif


$(PRJ)_version.mk: $(FORCE_VERSION_FILE_REGEN)

_BLANK_SPACE=
_BLANK_SPACE+=

#
# Give a 'test' version the number 99.0.0
#
%_version.mk:
	$(RM) $@
	echo "# Automatically generated file; do not modify" >> $@ 
	echo "$(PRJ)_VERSION:=$(LIBVERSION)" >> $@
	echo "$(PRJ)_VERSION_MAJOR:=$(word 1, $($(PRJ)_VERSION_AS_LIST))" >> $@
	echo "$(PRJ)_VERSION_MINOR:=$(word 2, $($(PRJ)_VERSION_AS_LIST))" >> $@
	echo "$(PRJ)_VERSION_PATCH:=$(word 3, $($(PRJ)_VERSION_AS_LIST))" >> $@
	echo "$(PRJ)_VERSION_NUMERIC:=$(call CONVERT_VERSION_TO_NUMBER,$(subst $(_BLANK_SPACE),.,$(strip $($(PRJ)_VERSION_AS_LIST))), $(words $($(PRJ)_VERSION_AS_LIST)))" >> $@

.PHONY: .FORCE install-gitinfo

-include $(USER_EXTENSION_MK)
