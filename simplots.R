library(macpan2)
library(ggplot2);theme_set(theme_bw())
library(dplyr)
library(tidyr)
library(shellpipes)

sims <- rdsRead("sims")
dat <- rdsRead("clean")
print(dat)

dat_offset=105

hackdat <- (dat
	|> mutate(time = date - min(date) + dat_offset
	)
	|> select(time, newIs, cumDs=suspect_death, cumIs=suspect_cases, newDs)
	|> pivot_longer(!time, names_to = "matrix", values_to="value")
)

case_offset <- 30

hacksims <- (sims
	|> mutate(time = ifelse(matrix %in% c("cumIs","newIs"),time + case_offset, time)
	)
)

gg <- (ggplot(hacksims,aes(time,value))
	+ geom_line(alpha=0.1, aes(group=iter))
	+ geom_line(data = filter(hacksims,iter==0))
	+ facet_wrap(~matrix,scale="free",nrow=2)
	+ geom_point(data=hackdat,size=0.5,color="red")
	+ xlim(c(NA,200))
)

print(gg)
