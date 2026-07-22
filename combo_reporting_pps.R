library(tidyverse);theme_set(theme_bw())
library(shellpipes)
# startGraphics(width=8,height=6)

dd <- (bind_rows(rdsReadList(pat = "pps")))
dat <- rdsRead("clean")

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

fitdate <- as.Date("2026-07-21")

gg3 <- (ggplot(dd, aes(date,med))
	+ geom_line(aes(color=reporting))
	+ geom_ribbon(aes(ymin=lwr,ymax=upr,fill=reporting),alpha=0.2)
	+ facet_wrap(~report_type,scale="free")
	+ geom_point(data=filter(dat,date<=fitdate),aes(date,value),color="black",size=0.8)
	+ geom_point(data=filter(dat,date>fitdate),aes(date,value),color="red",size=0.8)
#	+ xlim(as.Date(c("2026-06-01","2026-07-31")))
	+ xlim(as.Date(c("2026-05-15","2026-08-02")))
	+ theme(legend.position="bottom")
)

print(gg3)

