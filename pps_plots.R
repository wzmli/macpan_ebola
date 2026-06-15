library(macpan2)
library(bbmle)
library(tidyverse)
library(ggplot2);theme_set(theme_bw())
library(shellpipes)


firstdate <- as.Date("2026-03-01")
nudge <- 5

simdf <- (rdsRead("sims")
	|> mutate(date = firstdate + time - 1 + nudge)
)
dat <- (rdsRead("clean")
	|> select(date, newIc, newDc, cumIc = confirmed_cases, cumDc = confirmed_death)
	|> pivot_longer(-date,names_to="matrix",values_to = "value")
)


print(head(simdf))

#gg <- (ggplot(simdf,aes(date,value))
gg <- (ggplot(filter(simdf,iter<20),aes(date,value))
	+ geom_line(alpha=0.1,aes(group=iter))
	+ facet_wrap(~matrix,scale="free")
	+ geom_point(data=dat,aes(date,value),color="red")
)

print(gg)

simdf2 <- (simdf
	|> group_by(date,matrix)
	|> summarise(NULL
		, med = quantile(value,prob=0.5)
		, lwr = quantile(value,prob=0.025)
		, upr = quantile(value,prob=0.975)
	)
)

gg2 <-(ggplot(simdf2, aes(date,med))
	+ geom_line()
	+ geom_ribbon(aes(ymin=lwr,ymax=upr),alpha=0.2)
	+ facet_wrap(~matrix,scale="free")
	+ geom_point(data=dat,aes(date,value),color="red")
)

print(gg2)
