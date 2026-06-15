library(tidyverse)
library(shellpipes)

dd <- (bind_rows(rdsReadList()))
firstdate <- as.Date("2026-03-01")
nudge <- 5

simdf <- (dd
	|> mutate(date = firstdate + time - 1 + nudge)
#	|> rowwise()
#	|> mutate(value = rpois(lambda=value,n=1))
)

simdf$value2 <- rpois(lambda=simdf$value,n=length(simdf$value))

dat <- (readRDS("clean.rds")
	|> select(date, newIc, newDc, cumIc = confirmed_cases, cumDc = confirmed_death)
	|> pivot_longer(-date,names_to="matrix",values_to = "value")
)


print(head(simdf))

simdf2 <- (simdf
	|> group_by(date,matrix,type)
	|> summarise(NULL
		, med = quantile(value2,prob=0.5)
		, lwr = quantile(value2,prob=0.025)
		, upr = quantile(value2,prob=0.975)
	)
)

gg2 <-(ggplot(simdf2, aes(date,med))
	+ geom_line()
	+ geom_ribbon(aes(ymin=lwr,ymax=upr),alpha=0.2)
	+ facet_grid(matrix~type,scale="free")
	+ geom_point(data=dat,aes(date,value),color="red")
)

print(gg2)

