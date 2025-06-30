# install.packages("devtools")
# devtools::install_github("GMoncrieff/saeonobsr")

library(saeonobsr)
library(tidyverse)


### Try to call the token from the SAEON URL?
# rvest::read_html_live("https://observations.saeon.ac.za/account/token") %>%
#   rvest::html_nodes("h1") %>%
#   rvest::html_text()

Sys.setenv(OBSDB_KEY = "PvCODZmAWASPBMgyqdz_N-egX2IiHAXuI6RCv1qXSrI.iiyHJR-RPMzgcVSvhXz0LvJIT-6mVHZRco2uDvOpl0A")

### View available datasets
# Langrivier streamflow
stream_obs = viewDatasets() %>% 
  #as_tibble() %>% 
  filter(`siteName` == "Jonkershoek" &
           `stationName` == "Langrivier g2m07a Weir" &
         `description` == "Streamflow volume - Average - Cubic meters per second")

streamflow <- getDatasets(stream_obs) %>%
  filter(sensor == "Langrivier OTT Orpheus Mini Water Level Average Old DT")
#obs <- getDatasets(dataset, startDate = "2012-01-01")

# High altitude weather
weather_obs = viewDatasets() %>% 
  #as_tibble() %>% 
  filter(`siteName` == "Jonkershoek" &
           `stationName` == "Dwarsberg automated weather station")

weather <- getDatasets(weather_obs)
#obs <- getDatasets(dataset, startDate = "2012-01-01")

# Visualize the data
streamflow %>% ggplot() +
  geom_line(aes(y = value, x = as.Date(date))) +
  geom_hline(aes(yintercept = 4.076)) +
  ggtitle("Langrivier streamflow") +
  xlab("Date") +
  ylab("Streamflow (Cubic metres per second)")


# Assume you have a vector of streamflows called 'streamflow'
threshold <- 4.076  # Example threshold
exceedance_probability <- 1 - pnorm(threshold, mean(streamflow$value, na.rm = T), sd(streamflow$value, na.rm = T))
print(exceedance_probability)
