library(macpan2)
library(bbmle)
library(tidyverse)
library(ggplot2);theme_set(theme_bw())
library(shellpipes)
startGraphics(width=6,height=4)


firstdate <- as.Date("2026-03-01")
nudge <- 5
nudge <- 7

simdf <- (rdsRead("sims")
	|> mutate(date = firstdate + time - 1 + nudge)
)


dat <- (rdsRead("clean")
	|> select(date, newIc, newDc, cumIc = confirmed_cases, cumDc = confirmed_death)
	|> pivot_longer(-date,names_to="matrix",values_to = "value")
	|> mutate(report_type = matrix
		, report_type = ifelse(report_type == "newIc", "Daily new cases", report_type)
		, report_type = ifelse(report_type == "newDc", "Daily new death", report_type)
		, report_type = ifelse(report_type == "cumIc", "Cumulative cases", report_type)
		, report_type = ifelse(report_type == "cumDc", "Cumulative death", report_type)
	)
)

simdf$value <- pmax(rnorm(mean=simdf$value,sd=8,n=length(simdf$value)),0)

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
print(gg2
	+ xlim(as.Date(c("2026-05-01","2026-06-30")))
)

simdf3 <- (simdf2
	|> mutate(report_type = matrix
		, report_type = ifelse(report_type == "newIc", "Daily new cases", report_type)
		, report_type = ifelse(report_type == "newDc", "Daily new death", report_type)
		, report_type = ifelse(report_type == "cumIc", "Cumulative cases", report_type)
		, report_type = ifelse(report_type == "cumDc", "Cumulative death", report_type)
	)
	|> filter(date <= as.Date("2026-07-01"))
	|> filter(report_type %in% c("Cumulative cases","Cumulative death","Daily new cases", "Daily new death"))
)


gg3 <- (ggplot(simdf3, aes(date,med))
	+ geom_line()
	+ geom_ribbon(aes(ymin=lwr,ymax=upr),alpha=0.2)
	+ facet_wrap(~report_type,scale="free")
	+ geom_point(data=dat,aes(date,value),color="red",size=0.8)
	+ xlim(as.Date(c("2026-05-01","2026-06-30")))
	+ theme(legend.position="bottom")
)

print(gg3)

outdat <- (simdf2
	|> filter(matrix %in% c("newIc","Incidence","cumIc"))
	|> filter(date < as.Date("2026-07-31"))
	|> select(date,matrix,med)
	|> pivot_wider(names_from=matrix,values_from=med)
)

print(outdat,n=Inf)
csvSave(outdat)


