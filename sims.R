library(dplyr)
library(macpan2)
library(shellpipes)


loadEnvironments()

n <- 1000

spec <- rdsRead()

newspecs <- mp_tmb_update(spec,default=list(I0 = I0
	, E0 = E0
	)
)

print(newspecs)

time_steps = 100 ## Days

outputs <- c("I","infection","D")
# simulator object
sir = mp_simulator(
    model = newspecs
  , time_steps = time_steps
  , outputs = outputs
)


## ---------------------

inc_sim <- function(x){
	dd <- (mp_trajectory(sir)
		%>% mutate(NULL
			, seed = x
		)
	)
}


incdf <- bind_rows(lapply(1:n,inc_sim))

print(incdf)


rdsSave(incdf)


