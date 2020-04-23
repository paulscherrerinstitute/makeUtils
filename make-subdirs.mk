default:

TGTS=default $(filter-out default,$(MAKECMDGOALS))

$(TGTS): .FORCE
	for d in $(SUBDIRS) do; $(MAKE) -C $d $@; done

.PHONY: .FORCE $(TGTS)
