## This is macpan_ebola (Mike Li)

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

######################################################################

alldirs += ebola_2026
ebola_2026/%: | ebola_2026 ;
Ignore  += $(alldirs)

ebola_2026: 
	git clone https://github.com/wzmli/ebola_2026

######################################################################

update:
	cd ebola_2026 && $(MAKE) pull

read.Rout: ebola_2026/read.R ebola_2026/who3.csv
	$(pipeR)

clean.Rout: clean.R read.rds
	$(pipeR)

flows.Rout: flows.R 
	$(pipeR)

spec.Rout: spec.R flows.rda
	$(pipeR)

prop_spec.Rout: prop_spec.R spec.rds flows.rda
	$(pipeR)

## convolution (Currently not using)
convo_spec.Rout: convo_spec.R spec.rds flows.rda
	$(pipeR)

prop_sims.Rout: sims.R prop_spec.rds flows.rda
	$(pipeR)

## prop_simplots.Rout: simplots.R sims.R
prop_simplots.Rout: simplots.R prop_sims.rds clean.rds 
	$(pipeR)

## ebola1.jpg

######################################################################

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
