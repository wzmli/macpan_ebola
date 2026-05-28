library(macpan2)
library(shellpipes)

loadEnvironments()

flow = list(
	mp_per_capita_flow("S","E","beta * I / N","Incidence")
	, mp_per_capita_flow("E","I","alpha","Progression")
	, mp_per_capita_flow("I","R","(1-mort)*gamma","Recovery")
	, mp_per_capita_flow("I","D","(mort)*delta","Death")
)

default = list(beta = 0.4
	, alpha = 0.1
	, gamma = 0.1
	, delta = 1 ## death delay
	, mort = 0.01
	, effS = 0.1
	, N = 1.8e7
	, I = 1
	, E = 1
	, R = 0
	, D = 0
	, cumIs = 0
	, prop_Is = 0.2
	, prop_Ds = 0.1
	, cumDs = 0
)	

initialize_state = list(S ~ N - E - I - R - D)

saveVars(flow, default, initialize_state)
