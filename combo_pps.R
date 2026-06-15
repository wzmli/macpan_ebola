library(tidyverse);theme_set(theme_bw())
library(shellpipes)

dd <- (bind_rows(rdsReadList()))
firstdate <- as.Date("2026-03-01")
nudge <- 2

simdf <- (dd
	|> mutate(date = firstdate + time - 1 + nudge)
#	|> rowwise()
#	|> mutate(value = rpois(lambda=value,n=1))
)

simdf$value2 <- rpois(lambda=simdf$value,n=length(simdf$value))
simdf$value2 <- pmax(rnorm(mean=simdf$value,sd=5,n=length(simdf$value)),0)

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

simdf3 <- (simdf2
	|> filter(matrix %in% c("newIc","newDc","cumIncidence","cumIc","cumDc"))
	|> mutate(NULL
		, reporting = ifelse(type %in% c("hh","hl"),"high","low")
		, effective_pop = ifelse(type %in% c("ll","hl"), "low","high")
	)
)

gg3 <- (ggplot(simdf3, aes(date,med))
	+ geom_line(aes(color=effective_pop))
	+ geom_ribbon(aes(ymin=lwr,ymax=upr,fill=effective_pop),alpha=0.2)
	+ scale_color_manual(values=c("black","blue"))
	+ scale_fill_manual(values=c("black","blue"))
	+ facet_grid(matrix ~ reporting,scale="free")
	+ geom_point(data=dat,aes(date,value),color="red",size=0.5)
	+ xlim(as.Date(c("2026-05-01","2026-10-01")))
)

print(gg3 + xlim(as.Date(c("2026-05-01","2026-10-01"))))
print(gg3 + xlim(as.Date(c("2026-05-01","2026-08-01"))))

print(simdf3
	|> filter(matrix == "cumIncidence")
	|> filter(date == as.Date("2026-06-15"))
)
print(simdf3
	|> filter(matrix == "cumIncidence")
	|> filter(date == as.Date("2026-10-01"))
)

newIc <- (simdf3
	|> filter(matrix == "newIc")
	|> filter(date >= as.Date("2026-05-01"))
	|> filter(date < as.Date("2026-08-01"))
	|> filter(type == "lh")
	|> transmute(NULL
		, date
		, newIc = med
	)
	|> ungroup()
	|> mutate(cumIc = cumsum(newIc))
)

print(newIc,n=Inf)

csvSave(newIc)
