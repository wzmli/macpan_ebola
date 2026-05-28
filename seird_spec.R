library(macpan2)
library(shellpipes)

loadEnvironments()

print(initialize_state)
print(flow)
print(default)

spec = mp_tmb_model_spec(
    before = initialize_state
  , during = flow
  , default = default
)

rdsSave(spec)

