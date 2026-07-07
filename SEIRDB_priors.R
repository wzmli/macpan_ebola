library(shellpipes)

prior_range <- list(
	beta_I = c(0.3,0.4)
	, beta_D = c(0.3,0.4)
	, effS = c(0.0015,0.002)
	, mort = c(0.2,0.4)
	, prop_Ic = c(0.2,0.4)
	, prop_Dc = c(0.3,0.4)
)

saveVars(prior_range)
