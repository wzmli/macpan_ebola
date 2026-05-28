library(macpan2)
library(ggplot2);theme_set(theme_bw())
library(dplyr)
library(tidyr)
library(shellpipes)

sims <- rdsRead("sims")
dat <- rdsRead("clean")
print(dat)

offset=95

hackdat <- (dat
	|> mutate(time = date - min(date) + offset
	)
	|> select(time, Inc_s, cumDs=suspect_death, cumIs=suspect_cases, newDs)
	|> pivot_longer(!time, names_to = "matrix", values_to="value")
)

gg <- (ggplot(sims,aes(time,value))
	+ geom_line(alpha=0.1, aes(group=iter))
	+ geom_line(data = filter(sims,iter==0))
	+ facet_wrap(~matrix,scale="free",nrow=2)
	+ geom_point(data=hackdat,size=0.5,color="red")
	+ xlim(c(NA,200))
)

print(gg)
