library(shellpipes)

prior_range <- list(
	beta_I = c(0.2,0.5)
	, beta_D = c(0.2,0.5)
	, effS = c(0.0001,0.0002)
	, mort = c(0.1,0.3)
	, prop_Ic = c(0.1,0.7)
	, prop_Dc = c(0.3,0.7)
)

saveVars(prior_range)
