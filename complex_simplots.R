library(macpan2)
library(ggplot2);theme_set(theme_bw())
library(dplyr)
library(tidyr)
library(zoo)
library(shellpipes)

startGraphics(width=8,height=4)

sims <- rdsRead("sims")
dat <- rdsRead("clean")

#dat_offset=110
dat_offset=100
#dat_offset=70

zeroDate <- min(dat$date)-dat_offset
cutdate <- as.Date("2026-06-20")
cutdate <- as.Date("2026-09-20")
hackdat <- (dat
	|> mutate(time = date - min(date) + dat_offset
	)
	|> select(time, newIs, cumDs=suspect_death, cumIs=suspect_cases, newDs, cumIc = confirmed_cases, newIc, cumDc = confirmed_death, newDc)
	|> pivot_longer(!time, names_to = "type", values_to="value")
	|>	mutate(type = factor(type,levels=c("cumDs","cumDc","cumIs","cumIc","cumIncidence"
			, "newDs", "newDc" ,"newIs","newIc", "Incidence"
			)
		)
		, newDate = time + zeroDate
	)
	|> filter(value>0)
	|> filter(newDate <= cutdate)
)

case_offset <- 35

hacksims <- (bind_rows(sims)
	|> mutate(time = ifelse(matrix %in% c("cumIs","newIs","cumIc","newIc","cumIncidence","Incidence"),time + case_offset, time+5)
		, effS = factor(effS)
		, type = factor(matrix,levels=c("cumDs","cumDc","cumIs","cumIc","cumIncidence"
			, "newDs", "newDc","newIs", "newIc","Incidence"
			)
		)
	)
	|> filter(beta_D == 0.55)
#	|> filter(beta_D == 0.4)
#	|> filter(beta == 0.35)
	|> mutate(newDate = time + zeroDate)
)


hacksims2 <- (hacksims
	|> group_by(newDate,type,effS)
	|> summarise(lwr=quantile(value,prob=0.025)
		, upr=quantile(value,prob=0.975)
	)
)

gg <- (ggplot(hacksims,aes(x=newDate))
	+ geom_line(alpha=0.05, aes(y=value,group=interaction(iter,effS),color=effS))
	+ scale_color_manual(values=c("black","orange","blue","dark green"))
	+ facet_wrap(~type,scale="free",nrow=2)
	+ theme(legend.position="bottom")
	+ xlab("Date")
	+ geom_vline(aes(xintercept = as.Date("2026-05-28")),linetype = "dotted")
)

exportdat <- (hacksims
	|> filter(type == "Incidence", iter==0, effS == 0.002)
	|> select(date=newDate, Incidence = value)
)

csvSave(exportdat)

print(gg 
	+ geom_point(data=hackdat,size=0.5,color="red",aes(x=newDate,y=value))
	+ geom_line(data = filter(hacksims,iter==0),aes(x=newDate,y=value,color=effS))
)

print(gg %+% filter(hacksims, type %in% c("cumDs","cumDc", "cumIs", "cumIc"))
	+ geom_line(data = filter(hacksims,iter==0, type %in% c("cumDs","cumDc","cumIs","cumIc")),aes(x=newDate,y=value,color=effS))
	+ geom_point(data=filter(hackdat, type %in% c("cumDs","cumDc", "cumIs", "cumIc")),size=0.5, color="red",aes(x=newDate,y=value))
	+ xlim(c(as.Date("2026-05-15"),as.Date("2026-06-15")))
)


gg2 <- (ggplot(hacksims2,aes(x=newDate))
#	+ geom_ribbon(alpha=0.2, aes(ymin=lwr,ymax=upr,fill=effS))
#	+ geom_point(data=hackdat,size=0.5,color="red",aes(x=newDate,y=value))
#	+ geom_line(data = filter(hacksims,iter==0),aes(x=newDate,y=value,color=effS))
	+ scale_color_manual(values=c("black","orange","blue","dark green"))
	+ scale_fill_manual(values=c("black","orange","blue","dark green"))
	+ facet_wrap(~type,scale="free",nrow=2)
	+ theme(legend.position="bottom")
	+ xlab("Date")
	+ geom_vline(aes(xintercept = as.Date("2026-05-28")),linetype = "dotted")
)

print(gg2
	+ geom_ribbon(alpha=0.2, aes(ymin=lwr,ymax=upr,fill=effS))
	+ geom_point(data=hackdat,size=0.5,color="red",aes(x=newDate,y=value))
	+ geom_line(data = filter(hacksims,iter==0),aes(x=newDate,y=value,color=effS))
	+ scale_color_manual(values=c("black","orange","blue","dark green"))
)

print(gg2 %+% filter(hacksims2, type %in% c("cumDs","cumDc", "cumIs", "cumIc"))
	+ geom_ribbon(alpha=0.2, aes(ymin=lwr,ymax=upr,fill=effS))
	+ geom_line(data = filter(hacksims,iter==0, type %in% c("cumDs","cumDc","cumIs","cumIc")),aes(x=newDate,y=value,color=effS))
	+ geom_point(data=filter(hackdat, type %in% c("cumDs","cumDc", "cumIs", "cumIc")),size=0.5, color="red",aes(x=newDate,y=value))
)
print(gg2 %+% filter(hacksims2, type %in% c("newDs","newDc", "newIs", "newIc"))
	+ geom_ribbon(alpha=0.2, aes(ymin=lwr,ymax=upr,fill=effS))
	+ geom_line(data = filter(hacksims,iter==0, type %in% c("newDs","newDc","newIs","newIc")),aes(x=newDate,y=value,color=effS))
	+ geom_point(data=filter(hackdat, type %in% c("newDs","newDc", "newIs", "newIc")),size=0.5, color="red",aes(x=newDate,y=value))
)
