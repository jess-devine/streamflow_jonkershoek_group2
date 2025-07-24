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
