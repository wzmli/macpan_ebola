library(shellpipes)

flow_rates = list(
	## infection ~ reulermultinom(S,clamp(I * beta * (1-ve*vaxprop)/N))
	infection ~ reulermultinom(S,clamp(I * beta/N))
	, progression ~ reulermultinom(E,clamp(alpha))
	, recovery ~ reulermultinom(I, clamp((1-mort)*gamma))
	, death ~ reulermultinom(I, clamp((mort*delta))
)

update_state = list(
	S ~ S - infection 
	, E ~ E + infection - progression
	, I ~ I + progression - recovery - death
	, R ~ R + recovery 
	, D ~ D + death
)	

saveVars(flow_rates, update_state)
