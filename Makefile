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

complex_detsims.Rout: complex_detsims.R complex_prop_spec.rds complex_flows.rda
	$(pipeR)

complex_simplots.Rout: complex_simplots.R complex_sims.rds clean.rds
	$(pipeR)

complex_detsimplots.Rout: complex_detsimplots.R complex_detsims.rds clean.rds
	$(pipeR)

complex_priors.Rout: complex_priors.R
	$(pipeR)

ll_priors.Rout: ll_priors.R
	$(pipeR)

lh_priors.Rout: lh_priors.R
	$(pipeR)

hl_priors.Rout: hl_priors.R
	$(pipeR)

hh_priors.Rout: hh_priors.R
	$(pipeR)

impmakeR += complex_calibrate
# ll_complex_calibrate.Rout: complex_calibrate.R
# lh_complex_calibrate.Rout:
# hl_complex_calibrate.Rout:
# hh_complex_calibrate.Rout:
%_complex_calibrate.Rout: complex_calibrate.R complex_prop_spec.rds complex_flows.rda clean.rds %_priors.rda
	$(pipeR)

impmakeR += pps
# ll_complex_pps.Rout: 
# lh_complex_pps.Rout:
# hl_complex_pps.Rout:
# hh_complex_pps.Rout:
%_complex_pps.Rout: pps.R %_complex_calibrate.rds
	$(pipeR)

impmakeR += pps_sims
# ll_complex_pps_sims.Rout: pps_sims.R
# lh_complex_pps_sims.Rout:
# hl_complex_pps_sims.Rout:
# hh_complex_pps_sims.Rout:
%_complex_pps_sims.Rout: pps_sims.R %_complex_pps.rda
	$(pipeR)

impmakeR += pps_plots
# ll_complex_pps_plots.Rout: pps_plots.R
# lh_complex_pps_plots.Rout:
# hl_complex_pps_plots.Rout:
# hh_complex_pps_plots.Rout:
%_complex_pps_plots.Rout: pps_plots.R %_complex_pps_sims.rds clean.rds
	$(pipeR)

combo_pps.Rout: combo_pps.R ll_complex_pps_sims.rds lh_complex_pps_sims.rds hl_complex_pps_sims.rds hh_complex_pps_sims.rds
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
