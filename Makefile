## This is macpan_ebola …

## This section is for Dushoff-style vim-setup and vim targeting
## You can delete it if you don't want it
current: target
-include target.mk
Ignore = target.mk

vim_session:
	bash -cl "vmt"

######################################################################

### Makestuff

Sources += Makefile README.md $(wildcard *.R)

Ignore += makestuff
msrepo = https://github.com/dushoff

seird_params.Rout: seird_params.R
	$(pipeR)

seird_flows.Rout: seird_flows.R seird_params.rda
	$(pipeR)

seird_spec.Rout: seird_spec.R seird_params.rda seird_flows.rda
	$(pipeR)

seird_sims.Rout: sims.R seird_spec.rds seird_params.rda
	$(pipeR)

## ln -s ../makestuff . ## Do this first if you want a linked makestuff
Makefile: makestuff/00.stamp
makestuff/%.stamp: | makestuff
	- $(RM) makestuff/*.stamp
	cd makestuff && $(MAKE) pull
	touch $@
makestuff:
	git clone --depth 1 $(msrepo)/makestuff

-include makestuff/os.mk
-include makestuff/pipeR.mk
-include makestuff/git.mk
-include makestuff/visual.mk
