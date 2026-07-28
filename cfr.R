library(tidyverse);theme_set(theme_bw())
library(shellpipes)

dat <- (rdsRead()
	|> transmute(date
		, daily_cfr = newDc/newIc
		, total_cfr = confirmed_death/confirmed_cases
	)
	|> pivot_longer(-date, names_to = "type", values_to = "value")
)

print(dat, n=Inf)

gg <- (ggplot(dat, aes(date,value))
	+ geom_point()
	+ facet_wrap(~type, nrow=2, scale="free")
	+ geom_smooth()
)

print(gg)

