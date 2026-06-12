library(macpan2)
library(tidyverse)
library(zoo)
library(shellpipes)

loadEnvironments()

## make a macpan2 dataset for calibration
dat <- (rdsRead("clean")
	|> select(date, newIc, newDc)
)

firstdat <- data.frame(date = as.Date("2026-02-01")
	, newIc = 1
	, newDc = NA
)

calibdat <- (bind_rows(firstdat,dat)
	|> mutate(time = as.numeric(date - min(date))+1)
	|> select(-date)
	|> group_by(time)
	|> pivot_longer(-time,names_to = "matrix", values_to = "value")
)

print(calibdat,n=Inf)



