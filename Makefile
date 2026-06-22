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

update: | ebola_2026
	cd ebola_2026 && $(MAKE) pull

read.Rout: ebola_2026/read.R ebola_2026/drc_sitrep.csv
	$(pipeR)

clean.Rout: clean.R read.rds
	$(pipeR)

SEIRD_flows.Rout: SEIRD_flows.R 
	$(pipeR)

impmakeR += spec
# SEIRD.spec.Rout: spec.R
%.spec.Rout: spec.R SEIRD_flows.rda
	$(pipeR)

SEIRD_prop_spec.Rout: SEIRD_prop_spec.R SEIRD.spec.rds SEIRD_flows.rda
	$(pipeR)

## convolution (Currently not using)
convo_spec.Rout: convo_spec.R spec.rds flows.rda
	$(pipeR)

SEIRD_sims.Rout: SEIRD_sims.R SEIRD_prop_spec.rds SEIRD_flows.rda
	$(pipeR)

## prop_simplots.Rout: sims.R flows.R
SEIRD_simplots.Rout: SEIRD_simplots.R SEIRD_sims.rds clean.rds 
	$(pipeR)

## ebola1.jpg ebola2.jpg


######################################################################

SEIRDB_flows.Rout: SEIRDB_flows.R 
	$(pipeR)

SEIRDB.spec.Rout: spec.R SEIRDB_flows.rda
	$(pipeR)

SEIRDB_prop_spec.Rout: SEIRDB_prop_spec.R SEIRDB.spec.rds SEIRDB_flows.rda
	$(pipeR)

SEIRDB_sims.Rout: SEIRDB_sims.R SEIRDB_prop_spec.rds SEIRDB_flows.rda
	$(pipeR)

SEIRDB_simplots.Rout: SEIRDB_simplots.R SEIRDB_sims.rds clean.rds
	$(pipeR)

complex_detsimplots.Rout: complex_detsimplots.R complex_detsims.rds clean.rds
	$(pipeR)

base_priors.Rout: SEIRDB_priors.R
	$(pipeR)

ll_priors.Rout: ll_priors.R
	$(pipeR)

lh_priors.Rout: lh_priors.R
	$(pipeR)

hl_priors.Rout: hl_priors.R
	$(pipeR)

hh_priors.Rout: hh_priors.R
	$(pipeR)

impmakeR += SEIRDB_calibrate
# base_SEIRDB_calibrate.Rout: SEIRDB_calibrate.R SEIRDB_priors.R
# ll_SEIRDB_calibrate.Rout: SEIRDB_calibrate.R
# lh_SEIRDB_calibrate.Rout:
# hl_SEIRDB_calibrate.Rout:
# hh_SEIRDB_calibrate.Rout:
%_SEIRDB_calibrate.Rout: SEIRDB_calibrate.R SEIRDB_prop_spec.rds SEIRDB_flows.rda clean.rds %_priors.rda
	$(pipeR)

impmakeR += pps
# base_SEIRDB_pps.Rout: SEIRDB_pps.R
# ll_SEIRDB_pps.Rout: 
# lh_SEIRDB_pps.Rout:
# hl_SEIRDB_pps.Rout:
# hh_SEIRDB_pps.Rout:
%_SEIRDB_pps.Rout: SEIRDB_pps.R %_SEIRDB_calibrate.rds
	$(pipeR)

impmakeR += pps_sims
# base_SEIRDB_pps_sims.Rout: SEIRDB_pps_sims.R
# ll_SEIRDB_pps_sims.Rout: SEIRDB_pps_sims.R
# lh_SEIRDB_pps_sims.Rout:
# hl_SEIRDB_pps_sims.Rout:
# hh_SEIRDB_pps_sims.Rout:
%_SEIRDB_pps_sims.Rout: SEIRDB_pps_sims.R %_SEIRDB_pps.rda
	$(pipeR)

impmakeR += pps_plots
# base_SEIRDB_pps_plots.Rout: SEIRDB_pps_plots.R SEIRDB_priors.R
# ll_SEIRDB_pps_plots.Rout: pps_plots.R
# lh_SEIRDB_pps_plots.Rout:
# hl_SEIRDB_pps_plots.Rout:
# hh_SEIRDB_pps_plots.Rout:
%_SEIRDB_pps_plots.Rout: SEIRDB_pps_plots.R %_SEIRDB_pps_sims.rds clean.rds
	$(pipeR)

combo_pps.Rout: combo_pps.R ll_SEIRDB_pps_sims.rds lh_SEIRDB_pps_sims.rds hl_SEIRDB_pps_sims.rds hh_SEIRDB_pps_sims.rds
	$(pipeR)

compare.Rout: compare.R combo_pps.rds compare.csv
	$(pipeR)

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
