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

lldirs += ebola_2026
ebola_2026/%: | ebola_2026 ;
Ignore  += $(alldirs)

ebola_2026: 
	git clone https://github.com/wzmli/ebola_2026

######################################################################

read.Rout: ebola_2026/read.R ebola_2026/who3.csv
	$(pipeR)

clean.Rout: ebola_2026/clean.R read.rds
	$(pipeR)

seird_flows.Rout: seird_flows.R 
	$(pipeR)

seird_spec.Rout: seird_spec.R seird_flows.rda
	$(pipeR)

seird_sims.Rout: sims.R seird_spec.rds seird_flows.rda
	$(pipeR)

seird_simplots.Rout: simplots.R seird_sims.rds clean.rds 
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
