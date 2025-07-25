RMSE <- function(obs, pred) {
  val <- sqrt(mean((obs - pred)^2))
  return(val)
}

MAE <- function(obs, pred) {
  val <- mean(abs(obs - pred))
  return(val)
}



RMSE.kf <- RMSE(streamflow, pred.kf)
RMSE.rw.rain <- RMSE(streamflow, pred.rain)
RMSE.rw <- RMSE(streamflow, pred.rw)

MAE.kf <- MAE(streamflow, pred.kf)
MAE.rw.rain <- RMSE(streamflow, pred.rain)
MAE.rw <- RMSE(streamflow, pred.rw)

