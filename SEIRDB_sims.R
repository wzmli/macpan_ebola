library(dplyr)
library(macpan2)
library(ggplot2);theme_set(theme_bw())
library(shellpipes)


loadEnvironments()

nsims <- 100

spec <- rdsRead()

beta_D <- default[["beta_D"]]

time_steps = 150L ## Days
outputs <- c("cumIs","cumIc","cumDs","cumDc","cumIncidence","newIs","newIc","newDs","newDc","Incidence")

# updating spec

effSvec <- c(0.006,0.004,0.002)
betaDvec <- c(0.35,0.4, 0.55)

ddparams <- expand.grid(effS = effSvec, beta_D=betaDvec)

simtraj <- function(x){
	pars <- ddparams[x,]
	spec <- mp_tmb_update(spec
		, default = list(N = default[["N"]]*pars$effS
			, beta_D = pars$beta_D
		)
	)


	simulator <- mp_simulator(model = spec
  		, time_steps = time_steps
  		, outputs = outputs
	)

	det_sim <- (mp_trajectory(simulator))

	parameterized_sim <- (mp_tmb_calibrator(mp_euler_multinomial(spec)
   	, par = "beta_D"
   	, time = mp_sim_bounds(1,time_steps)
   	, outputs = outputs
   	)
	)

	beta_D_sample <- rnorm(n=nsims,mean=pars$beta_D,sd=0.01)

	sim_fn <- function(y){
   	stochsim <- mp_trajectory_par(parameterized_sim, list(beta_D=y))
	}

	stoch_sim <- (lapply(beta_D_sample,sim_fn)
   	|> bind_rows(.id="iter")
	)

	simdf <- (det_sim
   	|> mutate(iter = "0")
   	|> bind_rows(stoch_sim)
		|> mutate(NULL
			, effS = pars$effS
			, beta_D = pars$beta_D
		)
	)

	return(simdf)
}

simlist <- lapply(1:nrow(ddparams),simtraj)

print(simlist[[1]])

rdsSave(simlist)
