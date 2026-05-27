library(shellpipes)

pop <- 18000000
I0 <- 1
E0 <- 1
D0 <- 0

R0 <- 3
alpha <- 1/8
gamma <- 1/15
delta <- 1/15

mort <- 1/4

params <- list(beta = R0*(gamma)
	, alpha = alpha
	, gamma = gamma
	, delta = death
	, pop = pop
	, I0 = I0
	, E0 = E0
	, D0 = D0
)

print(params)

saveEnvironment()

