library(macpan2)
library(shellpipes)

loadEnvironments()

spec <- rdsRead()

prop_spec = mp_tmb_insert(spec
	, expression = list(newIs ~ prop_Is * Incidence
		, cumIs ~ cumIs + newIs
		, newIc ~ prop_Ic*Incidence
		, cumIc ~ cumIc + newIc
		, newDs ~ prop_Ds * Death
		, cumDs ~ cumDs + newDs
		)
	, at =Inf
	, phase = "during"
)

#prop_spec = mp_tmb_insert(prop_spec
#	, expression = list(prop_Is = 0.2
#		, prop_Ds = 0.05
#	)
#	, phase = "default"
#)

rdsSave(prop_spec)

