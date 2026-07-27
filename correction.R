library(tidyverse);theme_set(theme_bw())
library(shellpipes)

startGraphics(width=8,height=5)

correction_date <- as.Date("2026-07-22")

dat <- (rdsRead()
	|> transmute(NULL
		, date
		, cumulative_cases = confirmed_cases
		, cumulative_death = confirmed_death
		, new_cases = newIc
		, new_death = newDc
	)
)

distribute_cases <- (dat 
	|> filter(date == correction_date)
	|> pull(new_cases)
)

print(distribute_cases)

distribute_death <- (dat 
	|> filter(date == correction_date)
	|> pull(new_death)
)

dat2 <- (dat
	|> mutate(new_cases = ifelse(date == correction_date, NA, new_cases)
		, new_death = ifelse(date == correction_date, NA, new_death)
	)
)

olddat <- (dat
	|> filter(date < correction_date)
	|> mutate(NULL
		, fillnewIc = ifelse(is.na(new_cases),0,new_cases)
		, propI = new_cases/sum(fillnewIc)
		, propI = ifelse(is.na(propI),0,propI)
		, cnew_cases = round(fillnewIc + propI*distribute_cases)
		, fillnewDc = ifelse(is.na(new_death),0,new_death)
		, propD = new_death/sum(fillnewDc)
		, propD = ifelse(is.na(propD),0,propD)
		, cnew_death = round(fillnewDc + propD*distribute_death)
	)
	|> transmute(NULL
		, date
		, cumulative_cases = cumsum(cnew_cases)
		, cumulative_death = cumsum(cnew_death)
		, new_cases = cnew_cases
		, new_death = cnew_death
	)
)


print(olddat,n=Inf)

gg <- (ggplot(data=pivot_longer(dat2, -date, names_to = "type",values_to = "value"), aes(date,value))
	+ geom_point()
	+ geom_point(data=pivot_longer(olddat, -date, names_to = "type",values_to = "value"), aes(date,value),color="red")
	+ facet_wrap(~type, scale="free")
)

print(gg)

mergedat <- (dat
	|> filter(date >= correction_date)
	|> bind_rows(olddat)
	|> arrange(date)
)

print(mergedat, n=Inf)

rdsSave(mergedat)
