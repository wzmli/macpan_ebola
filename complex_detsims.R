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
	
	beta_D_sample <- rnorm(n=nsims,mean=pars$beta_D,sd=0.5)
	beta_D_sample <- quantile(beta_D_sample,prob=c(0.025,0.975))

	detspec <- mp_tmb_update(spec
		, default = list(N = default[["N"]]*pars$effS
			, beta_D = pars$beta_D
		)
	)
	
	lwrspec <- mp_tmb_update(spec
		, default = list(N = default[["N"]]*pars$effS
			, beta_D = beta_D_sample[[1]]
		)
	)

	uprspec <- mp_tmb_update(spec
		, default = list(N = default[["N"]]*pars$effS
			, beta_D = beta_D_sample[[2]]
		)
	)

	detsimulator <- mp_simulator(model = detspec
  		, time_steps = time_steps
  		, outputs = outputs
	)

	det_sim <- (mp_trajectory(detsimulator)) |> mutate(iter="det")

	lwrsimulator <- mp_simulator(model = lwrspec
  		, time_steps = time_steps
  		, outputs = outputs
	)

	lwr_sim <- (mp_trajectory(lwrsimulator)) |> mutate(iter="lwr")

	uprsimulator <- mp_simulator(model = uprspec
  		, time_steps = time_steps
  		, outputs = outputs
	)

	upr_sim <- (mp_trajectory(uprsimulator)) |> mutate(iter="upr")


	simdf <- (det_sim 
   	|> bind_rows(lwr_sim)
   	|> bind_rows(upr_sim)
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
