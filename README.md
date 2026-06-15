##### 2026 June 14 (Sun)

We are going to create scenarios using priors. 
We will have 4 scenarios:
LL,LH,HL and HH for eff and beta and see how it changes reporting proportions

ML: Based on trying various priors for beta, reporting and effS, beta almost always converge to the same ball park posterior regardless what priors. This is probably the data is strong enough to fit the underlying transmission rate. Therefore, the only they that affects duration of peak, final size is effS and what we think of under reporting. 


##### 2026 June 13 (Sat)

Finish the pipeline for pop_pred_samp. There are priors for most of the parameter of interest. We are still doing simple proportion and not convolution for now. 

TODO: The scenarios will be based on changing priors


##### 2026 June 12 (Fri)

We want to explore different reporting prop.
We know that the transmission rate (beta), effective population (effS) and reporting are all correlated and will affect the dynamics. We are going to experiment with different betas and calibrate to reported cases and estimate the reporting proportion.



##### 2026 June 9 (Tues)

JD mentioned to follow up with cumulative cases as it can have different interpretations:
1. new discovery of infections/cases
2. newly confirmed cases from the big pool of samples


##### 2026 May 27 (Wed)
 
So we're skipping the convolution for now. We're worried about identifiability of reporting ratios and effective populations susceptible. 

Mike wants to do the effective population as a fixed population of the country multiplied by some proportion that he can play with.

We're going to struggle to get anything reasonable unless we do something Bayesian with reporting probabilities, I think.  Can we put reasonable priors on the reporting probabilities? And do we think they're staying roughly constant over some period of time? 

We can easily imagine different effective susceptible proportions or detection probabilities in the past. Going forward, we can imagine some sort of effective intervention and that might or might not be mediated by detection probability. This is potentially important and potentially fun because increased detection probability could lead to a short term increase in reported cases, followed by a decrease because people are first detected, and then their transmission is reduced. One way to think about this is via contact tracing, but it could also happen through more active surveillance of any kind. 

Hi! (CL here) I think the lack of strain-sensitive tests will be an issue and (once found/manufractured) the slow rollout across the country might slow down that sudden jump in true detections. But it's definitely worth keeping an eye out for, e.g. get a date when it gets rolled out. 
