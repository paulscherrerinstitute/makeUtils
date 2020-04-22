#
# Include this file after including 'driver.makefile'
#
# include $(EPICS_MODULES)/makeUtils/latest/utils.mk
#
# instead of 'latest' you may substitute a specific
# version.
#

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

ifndef EPICSVERSION
INSTALL_MODULE_TOP_RULE=install::
endif

ifndef T_A
INSTALL_EPICS_TOP_RULE=install::
endif


# Assemble some info from git
GIT_COMMIT=$(shell git rev-parse HEAD)
GIT_BRANCH=$(shell git rev-parse --symbolic-full-name HEAD@{upstream})
GIT_REMOTE=$(shell git ls-remote --get-url)

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
	$(RM) $@
	echo "Git Commit:"     >> $@
	echo "  $(GIT_COMMIT)" >> $@
	echo "Branch:"         >> $@
	echo "  $(GIT_BRANCH)" >> $@
	echo "From Remote:"    >> $@
	echo "  $(GIT_REMOTE)" >> $@

install-gitinfo: $(MODULE_GITINFO)

.PHONY: .FORCE install-gitinfo

-include $(USER_EXTENSION_MK)
