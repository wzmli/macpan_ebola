library(macpan2)
library(shellpipes)

loadEnvironments()

spec <- rdsRead()

suspect_spec = mp_tmb_insert_reports(spec
  , incidence_name = "Incidence"
  , report_prob = 0.2#0.1
  , mean_delay = 150 ## same as death delay delta?
  , cv_delay = 0.5#0.25
  , reports_name = "Inc_s"
  , report_prob_name = "suspect_prob"
)

suspect_spec = mp_tmb_insert(suspect_spec
	, expression = list(cumIs ~ cumIs + Inc_s)
	, at =Inf
	, phase = "during"
)

suspect_spec = mp_tmb_insert_reports(suspect_spec
  , incidence_name = "D" ## why incidence? maybe convolution?
  , report_prob = 0.1#0.1
  , mean_delay = 1
  , cv_delay = 0.95#0.25
  , reports_name = "D_s"
  , report_prob_name = "D_suspect_prob"
)



rdsSave(suspect_spec)

