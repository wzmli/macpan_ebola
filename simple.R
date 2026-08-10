
library(macpan2)
library(ggplot2)

sird_ebola = mp_tmb_model_spec(
  before = S ~ N - I - R - D,
  during = list(
    mp_per_capita_flow(
      from = "S", to = "I",
      rate = "beta * I / N",
      flow_name = "infection"
    ),
    mp_per_capita_flow(
      from = "I", to = "R",
      rate = "gamma",
      flow_name = "recovery"
    ),
    mp_per_capita_flow(
      from = "I", to = "D",
      rate = "mu",
      flow_name = "death"
    )
  ),
  default = list(
    N     = 2e6,   # population at risk in affected health zones -- PLACEHOLDER, replace with your real catchment population
    I     = 717,   # currently hospitalised/isolated, ECDC report as of 4 Aug 2026
    R     = 1406,  # cumulative confirmed cases (3874) - deaths (1751) - currently isolated (717)
    D     = 1751,  # cumulative deaths, ECDC report as of 4 Aug 2026
    beta  = 0.342, # transmission rate per day = R0 * (gamma + mu) = 1.71 * 0.2
    gamma = 0.112, # recovery rate per day = (1 - CFR) / infectious_period = 0.56 / 5
    mu    = 0.088  # disease death rate per day = CFR / infectious_period = 0.44 / 5
  )
)

print(sird_ebola)

## Simulate 180 days forward
simulator = mp_simulator(
  sird_ebola,
  time_steps = 180,
  outputs = c("S", "I", "R", "D")
)

traj = mp_trajectory(simulator)

ggplot(traj, aes(time, value, colour = matrix)) +
  geom_line(linewidth = 1) +
  labs(
    x = "Day", y = "People", colour = "Compartment",
    title = "SIRD projection: 2026 Bundibugyo Ebola outbreak (DRC)",
    subtitle = "beta=0.342, gamma=0.112, mu=0.088 (R0 ~ 1.71) -- illustrative, no E compartment"
  ) +
  theme_minimal()
