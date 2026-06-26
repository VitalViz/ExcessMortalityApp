library(dplyr)
library(scales)
library(ggplot2)
library(plotly)
library(DT)
library(lubridate)
library(stats)

if (!requireNamespace("INLA", quietly = TRUE)) {
  install.packages("INLA",
    repos = c(INLA = "https://inla.r-inla-download.org/R/stable",
              getOption("repos")))
}
library(INLA)

