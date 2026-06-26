library(dplyr)
library(scales)
library(ggplot2)
library(plotly)
library(DT)
library(lubridate)
library(stats)

# INLA is loaded on-demand in server.R when Poisson Regression is selected.
# Loading it here at startup crashes the app if the package is unavailable.

