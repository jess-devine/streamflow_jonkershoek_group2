# Jess Devine
# linear model 
# 23/7/2025

# load packages 
library(rjags)
library(daymetr)
library(ecoforecastR)

# model structure 
LineStateSpace <- "
  model{
    X0 ~ dnorm(mu0,pa0)
    q ~ dgamma(aq,bq)
    r ~ dgamma(ar,br)
    m ~ dnorm(m0,s)
    
    for (i in 1:nt){
      Y[i] ~ dnorm(X[i],r)
      X[i] ~ dnorm(mu[i],q)
    }
    
    mu[1]<-X0 
    for (i in 2:nt){
      mu[i]<-m*X[i-1]
    }
  }"
  
# data and priors 
data <- list(y=log(y),n=length(y),      ## data
             x_ic=log(1000),tau_ic=100, ## initial condition prior
             a_obs=1,r_obs=1,           ## obs error prior
             a_add=1,r_add=1            ## process error prior
)

# initial state of the model's parameters for each chain in the MCMC
nchain = 3
init <- list()
for(i in 1:nchain){
  y.samp = sample(y,length(y),replace=TRUE)
  init[[i]] <- list(tau_add=1/var(diff(log(y.samp))),  ## initial guess on process precision
                    tau_obs=5/var(log(y.samp)))        ## initial guess on obs precision
}

# model 
j.model   <- jags.model (file = textConnection(RandomWalk),
                         data = data,
                         inits = init,
                         n.chains = 3)
jags.out   <- coda.samples (model = j.model,
                            variable.names = c("tau_add","tau_obs"),
                            n.iter = 1000)
plot(jags.out)
dic.samples(j.model, 2000)

# posterior conditions 
mu <- 
  pa0 <- 
  aq <- 
  bq <- 
  ar <- 
  br <- 
  m0 <- 
  s <- 