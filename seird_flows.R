library(macpan2)
library(shellpipes)

loadEnvironments()

flow = list(
	mp_per_capita_flow("S","E","beta * I / N","incidence")
	, mp_per_capita_flow("E","I","alpha","progression")
	, mp_per_capita_flow("I","R","(1-mort)*gamma","recovery")
	, mp_per_capita_flow("I","D","(mort)*delta","death")
)

default = list(beta = 0.4
	, alpha = 0.1
	, gamma = 0.1
	, delta = 0.1
	, mort = 0.05
	, N = 10000
	, I = 1
	, E = 1
	, R = 0
	, D = 0
)	

initialize_state = list(S ~ N - E - I - R - D)

saveVars(flow, default, initialize_state)
