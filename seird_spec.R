library(macpan2)
library(shellpipes)

loadEnvironments()

spec = mp_tmb_model_spec(
    before = list(N ~ pop
		, E ~ E0
		, I ~ I0
		, R ~ D0
		, D ~ D0
		, S ~ pop - I - R
		)
  , during = c(flow_rates, update_state)
  , default = c(params)
)

rdsSave(spec)

