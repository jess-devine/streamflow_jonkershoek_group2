## implement Kalman Filter

source("kf_functions.R")


## data
Y = streamflow

## options for process model 
#alpha = 0        ## assume no spatial flux
#alpha = 0.05    ## assume a large spatial flux
M = theta   ## adj*alpha + diag(1-alpha*apply(adj,1,sum))  ## random walk with flux

## options for process error covariance
# Q = diag(2)
# (Q[1, 1] <- tau_proc)          ## full process error covariance matrix
(Q = matrix(1/tau_proc, nrow = 1, ncol = 1))


## observation error covariance (assumed independent)  
(R = matrix(1/tau_obs, nrow = 1, ncol = 1))

## prior on first step, initialize with long-term mean and covariance
mu0 = mean(streamflow) 
P0 = var(streamflow)


#w <- P0*0+0.25 + diag(0.75,dim(P0)) ## iptional: downweight covariances in IC
#P0 = P0*w 

## Run Kalman Filter

KF00 = KalmanFilter(M, mu0, P0, Q, R, Y)
str(KF00)

xest <- KF00$mu.a
xsd <- sqrt(KF00$P.a)

plot(KF00$mu.a, col = "red", pch = 20, ylab = "log(streamflow)", type = "l", lwd = 2)
ecoforecastR::ciEnvelope(tt, xest - 1.96 * xsd, xest + 1.96 * xsd, 
                         col = ecoforecastR::col.alpha("lightBlue",0.75))
lines(KF00$mu.a, col = "red", pch = 20, lwd = 2)
lines(streamflow, pch = 20, cex = 0.6)


plot(KF00$P.a)
