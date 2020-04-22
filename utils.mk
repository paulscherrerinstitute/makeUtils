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

# Assemble some info from git
GIT_COMMIT=$(shell git rev-parse HEAD)
GIT_BRANCH=$(shell git rev-parse --symbolic-full-name HEAD@{upstream})
GIT_REMOTE=$(shell git ls-remote --get-url)

# Adding 
#
# INSTALLS += $(MODULE_GITINFO)
#
# creates a README.gitinfo file in the installation area
#

ifndef EPICSVERSION
install:: install-gitinfo
endif

MODULE_GITINFO = $(MODULE_LOCATION)/README.gitinfo

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

