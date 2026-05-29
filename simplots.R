library(macpan2)
library(ggplot2);theme_set(theme_bw())
library(dplyr)
library(tidyr)
library(zoo)
library(shellpipes)

startGraphics(width=8,height=5)

sims <- rdsRead("sims")
dat <- rdsRead("clean")

dat_offset=95
dat_offset=70

zeroDate <- min(dat$date)-dat_offset
cutdate <- as.Date("2026-06-15")

hackdat <- (dat
	|> mutate(time = date - min(date) + dat_offset
	)
	|> select(time, newIs, cumDs=suspect_death, cumIs=suspect_cases, newDs, cumIc = confirmed_cases, newIc)
	|> pivot_longer(!time, names_to = "type", values_to="value")
	|>	mutate(type = factor(type,levels=c("cumDs","cumIs","cumIc","cumIncidence"
			, "newDs", "newIs","newIc", "Incidence"
			)
		)
		, newDate = time + zeroDate
	)
	|> filter(value>0)
	|> filter(newDate <= cutdate)
)

case_offset <- 12

hacksims <- (bind_rows(sims)
	|> mutate(time = ifelse(matrix %in% c("cumIs","newIs","cumIc","newIc"),time + case_offset, time)
		, effS = factor(effS)
		, type = factor(matrix,levels=c("cumDs","cumIs","cumIc","cumIncidence"
			, "newDs", "newIs", "newIc","Incidence"
			)
		)
	)
	|> filter(beta == 0.55)
	|> mutate(newDate = time + zeroDate)
	|> filter(newDate <= cutdate)
)


gg <- (ggplot(hacksims,aes(x=newDate))
	+ geom_line(alpha=0.1, aes(y=value,group=interaction(iter,effS),color=effS))
	+ geom_line(data = filter(hacksims,iter==0),aes(x=newDate,y=value,color=effS))
	+ scale_color_manual(values=c("black","blue","orange","dark green"))
	+ facet_wrap(~type,scale="free",nrow=2)
	+ geom_point(data=hackdat,size=0.5,color="red",aes(x=newDate,y=value))
	+ theme(legend.position="bottom")
	+ xlab("Date")
)

print(gg)

