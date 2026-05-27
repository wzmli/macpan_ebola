library(dplyr)
library(macpan2)
library(shellpipes)


loadEnvironments()

n <- 1000

spec <- rdsRead()

print(pipeStar())

ps <- unlist(strsplit(pipeStar(),split="[.]"))

if(ps[[1]] == "large"){
	I0 = 10
	E0 = 10
}

if(ps[[1]] == "medium"){
	I0 = 5
	E0 = 5
}


newspecs <- mp_tmb_update(spec,default=list(
	vaxprop=as.numeric(ps[[2]])/100
	, I0 = I0
	, E0 = E0
	)
)

print(newspecs)

time_steps = 100 ## Days

outputs <- c("I","infection")
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
			, vaxprop = ps[[2]]
			, I0 = ps[[1]]
		)
	)
}


incdf <- bind_rows(lapply(1:n,inc_sim))

print(incdf)


rdsSave(incdf)


