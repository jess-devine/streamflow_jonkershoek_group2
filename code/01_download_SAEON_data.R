### Download streamflow and weather data from SAEON servers -----------------

# This script downloads streamflow and weather data from the SAEON Observations Database using the `saeonobsr` R package (https://github.com/GMoncrieff/saeonobsr).
# If you don't have the package installed, you can install it from GitHub using devtools:
# install.packages("devtools")
# devtools::install_github("GMoncrieff/saeonobsr")

### Load required packages --------------------------------------------------

library(saeonobsr)
library(tidyverse)


### Set up the API token ----------------------------------------------------

# You need to set up an API token to access the SAEON Observations Database. 
# This requires you to register for an account on the SAEON Observations Database website (https://observations.saeon.ac.za/).  
# You can then retrieve your token from https://observations.saeon.ac.za/account/token
# Note that the token expires in about an hour or so, so you will need to set it up each time you start a new R session.
# The weather download can take a few minutes.

Sys.setenv(OBSDB_KEY = "NujAJoFle0XvKocr6pYdrX6lN-W95vBAkxJj1mcLCJ0.5zGOkPufoTzD9iGbq4QO6IImgNCT9Ug-sSddno3HpWA")


### View and download available datasets ------------------------------------

# Langrivier streamflow
stream_obs <- viewDatasets() |>
  # as_tibble() %>%
  filter(`siteName` == "Jonkershoek" &
    `stationName` == "Langrivier g2m07a Weir" &
    `description` == "Streamflow volume - Average - Cubic meters per second")

streamflow <- getDatasets(stream_obs) |>
  filter(sensor == "Langrivier OTT Orpheus Mini Water Level Average Old DT")


# Dwarsberg high altitude weather
# Daily
weather_obs_daily <- viewDatasets() |>
  filter(`siteName` == "Jonkershoek" &
    `stationName` == "Dwarsberg automated weather station" &
    str_detect(description, 'Daily') &
    `phenomenonName` %in% c("Air Temperature", "Relative Humidity", "Wind Speed", "Rainfall", "Soil Moisture"))

weather_daily <- getDatasets(weather_obs_daily)

# Hourly
weather_obs_hourly <- viewDatasets() |>
  filter(`siteName` == "Jonkershoek" &
           `stationName` == "Dwarsberg automated weather station" &
           !str_detect(description, 'Daily') &
           `phenomenonName` %in% c("Air Temperature", "Relative Humidity", "Wind Speed", "Rainfall", "Soil Moisture"))

weather_hourly <- getDatasets(weather_obs_hourly)

### Clean and format the data ------------------------------------------------

# Reduce streamflow data to necessary columns, rename and remove half-hourly values (hourly)
streamflow_hourly <- streamflow |>
  select(date, value) |>
  rename(`Streamflow, Average, Cumecs` = value) |>
  filter(!str_detect(substr(date, 15, 16), "30"))

# Calculate streamflow daily means
streamflow_daily <- streamflow_hourly |>
  mutate(date = as.Date(date, format("%Y-%m-%d"))) |>
  group_by(date) |>
  summarise(`Streamflow, Average, Cumecs` = mean(`Streamflow, Average, Cumecs`, na.rm = TRUE))

# Rename sensors and reduce hourly weather data to necessary columns, convert in wide format
weather_hourly <- weather_hourly |>
  mutate(sensor = case_when(
    sensor == "Dwarsberg CS215 Air temperature sensor" ~ "Air Temperature",
    sensor == "Dwarsberg CS215 Relative humidity sensor" ~ "Relative Humidity",
    sensor == "Dwarsberg R.M. Young Wind Sentry Set - Anemometer" ~ "Wind Speed",
    sensor == "Dwarsberg Texas TE525 rain gauge" ~ "Rainfall",
    sensor == "Dwarsberg Campbell Scientific CS616 Water Content Reflectometer1" ~ "Soil Moisture 10cm",
    sensor == "Dwarsberg Campbell Scientific CS616 Water Content Reflectometer2" ~ "Soil Moisture 30cm",
    sensor == "Dwarsberg Campbell Scientific CS616 Water Content Reflectometer3" ~ "Soil Moisture 30cm",
    sensor == "Dwarsberg Campbell Scientific CS616 Water Content Reflectometer4" ~ "Soil Moisture 20cm",
    sensor == "Dwarsberg Campbell Scientific CS616 Water Content Reflectometer5" ~ "Soil Moisture 20cm",
    sensor == "Dwarsberg Campbell Scientific CS616 Water Content Reflectometer6" ~ "Soil Moisture 10cm"
  )) |>
  mutate(variable = paste(sensor, offering, unit, sep = ", ")) |>
  select(date, value, variable) |>
  pivot_wider(names_from = variable, values_from = value, values_fn = ~ mean(.x, na.rm = TRUE)) 

# Rename sensors and reduce daily weather data to necessary columns, convert in wide format
weather_daily <- weather_daily |>
  mutate(sensor = case_when(
    sensor == "Dwarsberg CS215 Air temperature sensor_Daily" ~ "Air Temperature",
    sensor == "Dwarsberg CS215 Relative humidity sensor_Daily" ~ "Relative Humidity",
    sensor == "Dwarsberg R.M. Young Wind Sentry Set - Anemometer_Daily" ~ "Wind Speed",
    sensor == "Dwarsberg Texas TE525 rain gauge_Daily" ~ "Rainfall",
    sensor == "Dwarsberg Campbell Scientific CS616 Water Content Reflectometer1_Daily" ~ "Soil Moisture 10cm",
    sensor == "Dwarsberg Campbell Scientific CS616 Water Content Reflectometer2_Daily" ~ "Soil Moisture 30cm",
    sensor == "Dwarsberg Campbell Scientific CS616 Water Content Reflectometer3_Daily" ~ "Soil Moisture 30cm",
    sensor == "Dwarsberg Campbell Scientific CS616 Water Content Reflectometer4_Daily" ~ "Soil Moisture 20cm",
    sensor == "Dwarsberg Campbell Scientific CS616 Water Content Reflectometer5_Daily" ~ "Soil Moisture 20cm",
    sensor == "Dwarsberg Campbell Scientific CS616 Water Content Reflectometer6_Daily" ~ "Soil Moisture 10cm"
  )) |>
  mutate(variable = paste(sensor, offering, unit, sep = ", ")) |>
  select(date, value, variable) |>
  pivot_wider(names_from = variable, values_from = value, values_fn = ~ mean(.x, na.rm = TRUE)) |>
  mutate(date = as.Date(date, format("%Y-%m-%d")))
  

# Merge the data and save -------------------------------------------------

# Merge hourly streamflow and weather data and save
data_hourly <- streamflow_hourly |>
  left_join(weather_hourly, by = "date") 

# Extract metadata from column names and save
metadata_hourly <- data_hourly |>
  select(-date) |>
  colnames() |>
  as_tibble() |>
  separate_wider_delim(col = everything(), 
                       delim = ", ", 
                       names = c("phenomenon", "offering", "unit"), 
                       too_many = "merge") 

write_csv(metadata_hourly, paste0("data/metadata_hourly_", Sys.Date(), ".csv"))

# Rename data columns and save
names(data_hourly) <- c("Date", metadata_hourly$phenomenon)

write_csv(data_hourly, paste0("data/data_hourly_", Sys.Date(), ".csv"))

# Merge daily streamflow and weather data and save
data_daily <- streamflow_daily |>
  left_join(weather_daily, by = "date") 

# Extract metadata from column names and save
metadata_daily <- data_daily |>
  select(-date) |>
  colnames() |>
  as_tibble() |>
  separate_wider_delim(col = everything(), 
                       delim = ", ", 
                       names = c("phenomenon", "offering", "unit"), 
                       too_many = "merge") 

metadata_daily <- metadata_daily |>
  mutate(offeringshort = c("Ave", "Max", "Min", "Total", "Max", "Min", "Max", "Max", "Max", "Min", "Min", "Min", "Ave", "Max"))

write_csv(metadata_daily, paste0("data/metadata_daily_", Sys.Date(), ".csv"))

# Rename data columns and save
names(data_daily) <- c("Date", paste(metadata_daily$phenomenon, metadata_daily$offeringshort, sep = " "))
write_csv(data_daily, paste0("data/data_daily_", Sys.Date(), ".csv"))
