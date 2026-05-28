library(dplyr)
library(macpan2)
library(ggplot2);theme_set(theme_bw())
library(shellpipes)


loadEnvironments()

nsims <- 10

spec <- rdsRead()

beta <- default[["beta"]]

time_steps = 500L ## Days

outputs <- c("cumIs","Inc_s","cumDs","newDs")
# simulator object

simulator <- mp_simulator(
    model = spec
  , time_steps = time_steps
  , outputs = outputs
)

det_sim <- (mp_trajectory(simulator))

parameterized_sim <- (mp_tmb_calibrator(mp_euler_multinomial(spec)
   , par = "beta"
   , time = mp_sim_bounds(1,time_steps)
   , outputs = outputs
   )
)

beta_sample <- rnorm(n=nsims,mean=beta,sd=0.001)

sim_fn <- function(x){
   stochsim <- mp_trajectory_par(parameterized_sim, list(beta=x))
}

stoch_sim <- (lapply(beta_sample,sim_fn)
   |> bind_rows(.id="iter")
)

simdf <- (det_sim
   |> mutate(iter = "0")
   |> bind_rows(stoch_sim)
)

rdsSave(simdf)
