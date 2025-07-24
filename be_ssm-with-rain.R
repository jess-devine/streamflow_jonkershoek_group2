### state: random walk + rain
### n = 1000
### last 200 NA
### streamflow = log(streamflow)


n <- length(streamflow)
streamflow_new <- streamflow
streamflow_new[800:n] <- NA


### --- prepare rain variable

sel <- 5000:6000
rain <- hdat2014$Rainfall[sel]

hist(rain, las = 1, main = "")

par(mfrow = c(2, 1))
plot.ts(rain)
plot.ts(streamflow)


### --- Fit JAGS model: ssm plus rain

data <- list(y = streamflow_new,
             n = length(streamflow),      ## data
             rain = log(rain +1),
             x_ic = mean(streamflow, na.rm = TRUE),
             tau_ic = 100, ## initial condition prior
             a_obs = 1,
             r_obs = 1,           ## obs error prior
             a_add = 1,
             r_add = 1            ## process error prior
)


nchain = 3
init <- list()
for(i in 1:nchain){
  ##  y.samp = sample(y,length(y),replace=TRUE)
  init[[i]] <- list(tau_add = 1 / var(diff(streamflow), na.rm= TRUE),  ## initial guess on process precision
                    tau_obs = 5 / var(streamflow, na.rm= TRUE),      ## initial guess on obs precision
                    beta_rain = rnorm(1, 0, 1))
}

j.model   <- jags.model (file = "be_ssm-rain.jags",
                         data = data,
                         inits = init,
                         n.chains = 3)


## burn-in
jags.out   <- coda.samples (model = j.model,
                            variable.names = c("tau_add","tau_obs", "beta_rain"),
                            n.iter = 3000)

jags.out   <- coda.samples (model = j.model,
                            variable.names = c("tau_add","tau_obs", "beta_rain"),
                            n.iter = 3000)
jags.out   <- coda.samples (model = j.model,
                            variable.names = c("tau_add","tau_obs", "beta_rain"),
                            n.iter = 3000)

plot(jags.out)
#dic.samples(j.model, 2000)


jags.out   <- coda.samples (model = j.model,
                            variable.names = c("x","tau_add","tau_obs"),
                            n.iter = 10000)


### ---- plot observed and forecast

tt = seq(1, length(streamflow))       ## adjust to zoom in and out
out <- as.matrix(jags.out)         ## convert from coda to matrix  
x.cols <- grep("^x",colnames(out)) ## grab all columns that start with the letter x
ci <- apply(out[,x.cols],2,quantile,c(0.025,0.5,0.975)) ## model was fit on log scale

plot(tt, ci[2,], type = 'n', ylab = "log(streamflow)", ylim = c(-5, 3), 
     las = 1, xlab = "time (hourly)")
## adjust x-axis label to be monthly if zoomed
# if(diff(time.rng) < 100){ 
#   axis.Date(1, at=seq(time[time.rng[1]],time[time.rng[2]],by='month'), format = "%Y-%m")
# }
ecoforecastR::ciEnvelope(tt, ci[1,], ci[3,], 
                         col = ecoforecastR::col.alpha("lightBlue",0.75))
points(tt, streamflow, pch="+", cex=0.5)

pred <- apply(out[,x.cols], 2, mean)
points(tt, pred, col = "red", pch = 20, cex = 0.3)

legend("topleft", bty = "n", col = c("black", "red"), 
       legend = c("observed", "predicted"), lwd = 2)
