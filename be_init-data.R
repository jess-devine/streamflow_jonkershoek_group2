### be_init-data

### streamflow = 2014, values 5000:6000, log-transformed


library(here)
library(tidyverse)
library(rjags)

hdat <- read.csv(here("data", "data_hourly_2025-07-09.csv"))
head(hdat)
names(hdat)
dim(hdat)

library(zoo)
hdat$year <- year(hdat$Date)
hdat2014 <- hdat[hdat$year == "2014", ]

streamflow <- hdat$Streamflow
datetime <- as.Date(hdat$Date)

plot(x = datetime, streamflow, type = "l", las = 1)

with(hdat2014, 
     plot(x = as.Date(Date), Streamflow, type = "l", las = 1))


head(hdat2014)
dim(hdat2014)
streamflow <- hdat2014$Streamflow[5000:6000]
plot.ts(streamflow)

hist(streamflow, main = "", las = 1)
hist(log(streamflow), main = "", las = 1)
streamflow = log(streamflow)
summary(streamflow)

##########################################################################

# Data for vapor deficit (Jess) 

names(hdat2014)
temperature <- hdat2014$Air.Temperature[5000:6000]
RH <- hdat2014$Relative.Humidity[5000:6000]

calculate_vpd <- function(temp_C, RH) {
  # Saturation vapor pressure (es) in kPa 
  es <- 0.6108 * exp((17.27 * temp_C) / (temp_C + 237.3))
  # Actual vapor pressure (ea) in kPa
  ea <- (RH / 100) * es
  # Vapor Pressure Deficit (VPD)
  vpd <- es - ea
  return(vpd)
}

# Calculate VPD for the entire dataset
hdat2014$VPD <- calculate_vpd(hdat2014$Air.Temperature, hdat2014$Relative.Humidity)

# VPD for subset
VPD <- hdat2014$VPD[5000:6000]

par(mfrow = c(3, 1)) 
plot(streamflow~temperature)
plot(streamflow~RH)
plot(streamflow ~ VPD)

