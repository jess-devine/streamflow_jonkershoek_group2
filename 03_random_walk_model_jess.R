# Jess Devine
# random walk model 
# 23/7/2025

library(rjags)
library(tidyverse)

######################

random_walk_model_corrected <- "model {
  # Priors
  tau ~ dgamma(0.001, 0.001)  # Precision of random walk increments
  sigma <- 1/sqrt(tau)         # Standard deviation
  
  # Likelihood for observed data
  y[1] ~ dunif(0, 1)  # Prior for first observation
  for(t in 2:N) {
    y[t] ~ dnorm(y[t-1], tau)
  }
  
  # Forecast for future 168 hours (1 week)
  y_future[1] ~ dnorm(y[N], tau)  # Start forecast from last observed point
  for(t in 2:168) {
    y_future[t] ~ dnorm(y_future[t-1], tau)
  }
}"

#########################
# Prepare your data
streamflow <- data_2023_week1$Streamflow
N <- length(streamflow)

# JAGS data list - now only contains observed data
jags_data <- list(
  y = streamflow,
  N = N
)

# Parameters to monitor
params <- c("y_future", "sigma")

# Initialize model
model <- jags.model(textConnection(random_walk_model_corrected),
                    data = jags_data,
                    n.chains = 3)

# Burn-in
update(model, 1000)

# Sample from posterior
samples <- coda.samples(model,
                        variable.names = params,
                        n.iter = 5000)

# Extract and analyze forecasts
forecast_samples <- as.matrix(samples)[, grep("y_future", colnames(as.matrix(samples)))]

# Open a new plotting device with larger margins
dev.new(width=10, height=8, unit="in")  # Adjust dimensions as needed
plot(samples)

######################


# 1. Extract forecast samples (convert to data frame)
forecast_samples <- as.data.frame(as.matrix(samples)[, grep("y_future", colnames(as.matrix(samples)))])

# 2. Calculate quantiles (e.g., 5%, 50%, 95%)
forecast_quantiles <- apply(forecast_samples, 2, quantile, probs = c(0.05, 0.5, 0.95)) %>% 
  t() %>% 
  as.data.frame() %>% 
  setNames(c("lower", "median", "upper"))

# 3. Create time indices
observed_time <- 1:N
forecast_time <- (N + 1):(N + 168)

# 4. Combine observed + forecast data for plotting
plot_data <- data.frame(
  time = c(observed_time, forecast_time),
  observed = c(streamflow, rep(NA, 168)),
  lower = c(rep(NA, N), forecast_quantiles$lower),
  upper = c(rep(NA, N), forecast_quantiles$upper)
)

# 5. Plot
ggplot(plot_data, aes(x = time)) +
  
  # Observed data (black line)
  geom_line(aes(y = observed, color = "Observed"), size = 0.8) +
  
  # Forecast confidence interval (blue ribbon)
  geom_ribbon(aes(ymin = lower, ymax = upper), 
              fill = "skyblue", alpha = 0.4) +
  
  # Optional: Add a few random walk realizations (e.g., 20)
  geom_line(data = forecast_samples %>% 
              slice_sample(n = 20) %>% 
              pivot_longer(everything(), names_to = "step", values_to = "value") %>% 
              mutate(time = rep(forecast_time, 20)),
            aes(y = value, group = step), 
            color = "blue", alpha = 0.2, size = 0.3) +
  
  # Vertical line separating observed & forecast
  geom_vline(xintercept = N + 0.5, linetype = "dashed", color = "red", alpha = 0.5) +
  
  # Customize plot
  labs(
    title = "Streamflow: Observed vs. Random Walk Forecast",
    subtitle = "Shaded area = 90% credible interval | Thin lines = random walk samples",
    x = "Time (hours)",
    y = "Streamflow"
  ) +
  scale_color_manual(values = c("Observed" = "black")) +
  theme_minimal() +
  theme(legend.position = "bottom")
