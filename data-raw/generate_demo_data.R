##
## Generate simulated demo datasets for ExcessMortalityApp
##
## SampleInput4.csv: Monthly, 2015-2025, sex+age, partial year 2025 (through June)
##   Demonstrates: configurable cutoff, COVID exclusion, partial year fix
##
## SampleInput5.csv: Monthly, 2018-2025, no subgroups, short baseline
##   Demonstrates: minimum data warnings (only 2 years pre-2020)
##
## SampleInput6.csv: Monthly, 2010-2024, sex breakdown, full years
##   Demonstrates: K-monthly aggregation (bimonthly, quarterly)
##

set.seed(2024)

generate_monthly_deaths <- function(years, months, base_rate, population,
                                    seasonal_amplitude = 0.15,
                                    trend_per_year = 0.005,
                                    covid_multiplier = c(1.0, 1.0, 1.0)) {
  data <- expand.grid(month = months, year = years)
  data <- data[order(data$year, data$month), ]

  year_offset <- data$year - min(data$year)
  trend <- 1 + trend_per_year * year_offset

  seasonal <- 1 + seasonal_amplitude * cos(2 * pi * (data$month - 1) / 12)

  covid_factor <- rep(1.0, nrow(data))
  for (i in seq_along(covid_multiplier)) {
    yr <- 2019 + i
    covid_factor[data$year == yr] <- covid_multiplier[i]
    if (yr %in% data$year) {
      peak_months <- if(i == 1) c(3, 4, 5, 11, 12) else if(i == 2) c(1, 2, 8, 9) else c(1, 2)
      for (m in peak_months) {
        idx <- which(data$year == yr & data$month == m)
        if (length(idx) > 0) covid_factor[idx] <- covid_multiplier[i] * 1.15
      }
    }
  }

  expected <- population * base_rate * trend * seasonal * covid_factor
  data$deaths <- rpois(nrow(data), lambda = expected)
  data$population <- population
  return(data)
}


## -----------------------------------------------------------------------
## SampleInput4: Monthly, 2015-2025 (partial), sex + age
## -----------------------------------------------------------------------

sexes <- c("Male", "Female")
ages <- c("0-64", "65+")
pop_map <- list(
  "Male.0-64" = 500000, "Male.65+" = 150000,
  "Female.0-64" = 520000, "Female.65+" = 180000
)
rate_map <- list(
  "Male.0-64" = 0.0003, "Male.65+" = 0.003,
  "Female.0-64" = 0.00025, "Female.65+" = 0.0025
)

sample4 <- NULL
for (s in sexes) {
  for (a in ages) {
    key <- paste(s, a, sep = ".")
    full_years <- 2015:2024
    partial_year <- 2025
    d_full <- generate_monthly_deaths(
      years = full_years, months = 1:12,
      base_rate = rate_map[[key]], population = pop_map[[key]],
      seasonal_amplitude = ifelse(a == "65+", 0.20, 0.10),
      trend_per_year = 0.003,
      covid_multiplier = c(1.25, 1.18, 1.10)
    )
    d_partial <- generate_monthly_deaths(
      years = partial_year, months = 1:6,
      base_rate = rate_map[[key]], population = pop_map[[key]],
      seasonal_amplitude = ifelse(a == "65+", 0.20, 0.10),
      trend_per_year = 0.003,
      covid_multiplier = c(1.0, 1.0, 1.0)
    )
    d <- rbind(d_full, d_partial)
    d$sex <- s
    d$age <- a
    sample4 <- rbind(sample4, d)
  }
}
sample4 <- sample4[order(sample4$year, sample4$month, sample4$sex, sample4$age), ]
write.csv(sample4, "data-raw/SampleInput4.csv", row.names = FALSE)
cat("SampleInput4.csv:", nrow(sample4), "rows,", length(unique(sample4$year)), "years\n")


## -----------------------------------------------------------------------
## SampleInput5: Monthly, 2018-2025 (partial), no subgroups, short baseline
## -----------------------------------------------------------------------

sample5 <- generate_monthly_deaths(
  years = 2018:2024, months = 1:12,
  base_rate = 0.0008, population = 1000000,
  seasonal_amplitude = 0.15,
  trend_per_year = 0.004,
  covid_multiplier = c(1.30, 1.20, 1.12)
)
d_partial5 <- generate_monthly_deaths(
  years = 2025, months = 1:6,
  base_rate = 0.0008, population = 1000000,
  seasonal_amplitude = 0.15,
  trend_per_year = 0.004,
  covid_multiplier = c(1.0, 1.0, 1.0)
)
sample5 <- rbind(sample5, d_partial5)
sample5 <- sample5[order(sample5$year, sample5$month), ]
write.csv(sample5, "data-raw/SampleInput5.csv", row.names = FALSE)
cat("SampleInput5.csv:", nrow(sample5), "rows,", length(unique(sample5$year)), "years\n")


## -----------------------------------------------------------------------
## SampleInput6: Quarterly (4 periods/year), 2010-2024, with sex
##   Pre-aggregated into quarters using a 'period' column (1-4)
##   Demonstrates: Custom periods time scale
## -----------------------------------------------------------------------

sample6_monthly <- NULL
for (s in c("Male", "Female")) {
  pop <- ifelse(s == "Male", 600000, 650000)
  rate <- ifelse(s == "Male", 0.0007, 0.0006)
  d <- generate_monthly_deaths(
    years = 2010:2024, months = 1:12,
    base_rate = rate, population = pop,
    seasonal_amplitude = 0.18,
    trend_per_year = 0.003,
    covid_multiplier = c(1.22, 1.15, 1.08)
  )
  d$sex <- s
  sample6_monthly <- rbind(sample6_monthly, d)
}
sample6_monthly$period <- ceiling(sample6_monthly$month / 3)
sample6 <- aggregate(cbind(deaths, population) ~ year + period + sex,
                     data = sample6_monthly, FUN = sum)
sample6 <- sample6[order(sample6$year, sample6$period, sample6$sex), ]
write.csv(sample6, "data-raw/SampleInput6.csv", row.names = FALSE)
cat("SampleInput6.csv:", nrow(sample6), "rows,", length(unique(sample6$year)), "years,", max(sample6$period), "periods/year\n")

cat("\nAll demo datasets generated successfully.\n")
