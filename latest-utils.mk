ifeq ($(findstring extglob,$(SHELL)),)
SHELL:=$(SHELL) -O extglob
endif

THIS_MAKEFILE:=$(lastword $(MAKEFILE_LIST))

include $(firstword $(shell ls -vdr $(dir $(THIS_MAKEFILE))../+(+([0-9]).)+([0-9])))/$(notdir $(THIS_MAKEFILE))
