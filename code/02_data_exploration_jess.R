# null model : day of year 
# Jess Devine 
# 23/7/25

library(ecoforecastR)
library(tidyverse)
library(readr)

data_hourly <- read_csv("data/data_hourly_2025-07-22.csv")
head(data_hourly)
tail(data_hourly)
dim(data_hourly)

# Find the first non-NA date for each variable

# Get all January 1st at midnight for all years
jan_first_midnight <- data_hourly[format(data_hourly$Date, "%m-%d %H:%M:%S") == "01-01 00:00:00", ]
print(jan_first_midnight)

# Get column names (excluding Date and Streamflow which seem to have data throughout)
vars_to_check <- names(data_hourly)[!names(data_hourly) %in% c("Date", "Streamflow")]

# Find first non-NA date for each variable
first_data_dates <- sapply(vars_to_check, function(var) {
  first_non_na <- which(!is.na(data_hourly[[var]]))[1]
  if(is.na(first_non_na)) {
    return("No data")
  } else {
    return(as.character(data_hourly$Date[first_non_na]))
  }
})

print(first_data_dates)

max(data_daily$Date) #  "2025-04-29"
min(data_daily$Date) # "2011-08-24"

# Crop data to last year for validation 
start_date <- as.POSIXct("2024-04-29 00:00:00", tz = "UTC")
data_2024 <- data_hourly[data_hourly$Date >= start_date, ]
head(data_2024)
nrow(data_2024) # cropped rows

# Crop data to previous year for training 
start_date <- as.POSIXct("2023-04-29 00:00:00", tz = "UTC")
end_date <- as.POSIXct("2024-04-29 00:00:00", tz = "UTC")
data_2023 <- data_hourly %>% 
  filter(Date >= start_date & Date <= end_date)
head(data_2023)
nrow(data_2023) # cropped rows

#
start_date <- as.POSIXct("2023-04-29 00:00:00", tz = "UTC")
end_date <- as.POSIXct("2023-05-06 00:00:00", tz = "UTC")
# Filter the data between the two dates
data_2023_week1 <- data_hourly %>% 
  filter(Date >= start_date & Date <= end_date)
# Check the results
head(data_2023_week1)  # View first few rows
nrow(data_2023_week1)  # Number of rows (should be 168 if 7 full days exist)

