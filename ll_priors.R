library(shellpipes)

prior_range <- list(
	beta_I = c(0.3,0.5)
	, beta_D = c(0.3,0.5)
	, effS = c(0.001,0.002)
	, mort = c(0.1,0.3)
	, prop_Ic = c(0.1,0.3)
	, prop_Dc = c(0.1,0.3)
)

saveVars(prior_range)
