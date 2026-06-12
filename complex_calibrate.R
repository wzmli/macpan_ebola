library(macpan2)
library(tidyverse)
library(zoo)
library(shellpipes)

loadEnvironments()

time_steps <- 200
firstdate <- as.Date("2026-02-01")

## make a macpan2 dataset for calibration
dat <- (rdsRead("clean")
	|> select(date, newIc, newDc)
)

firstdat <- data.frame(
	date = firstdate
	, newIc = 1
	, newDc = NA
)

calibdat <- (bind_rows(firstdat,dat)
	|> mutate(time = as.numeric(date - min(date))+1)
	|> group_by(time)
	|> pivot_longer(-c(time,names_to = "matrix", values_to = "value")
	|> filter(!is.na(value))
)

print(calibdat,n=Inf)

calib <- mp_tmb_calibrator(spec = rdsRead("complex_prop_spec") |> mp_rk4()
	, data = calibdat
	, time = mp_sim_bounds(1, time_steps)
	, traj = list(newIc ~ mp_norm(0,sd = log(20))
		, newDc ~ mp_norm(0,sd=log(5))
	)
#	, traj = c("newIc","newDc")
	, par = c("log_prop_Ic", "log_prop_Dc")
	, outputs = c("newIc","newDc")
)

cal_opt = mp_optimize(calib)

## Check optimized fit

print(cal_opt)

## Plots

fitted_data = (mp_trajectory_sd(calib, conf.int = TRUE)
	|> mutate(date = time + firstdate)
)

print(fitted_data)

gg <- (ggplot(data = (fitted_data ))
  + geom_line(aes(time, value))
  + geom_ribbon(aes(time, ymin = conf.low, ymax = conf.high)
    , alpha = 0.2
    , colour = "red"
  )
  + facet_wrap(~matrix,scale="free")
  + geom_point(data=calibdat,aes(date, value))
)

print(gg)




