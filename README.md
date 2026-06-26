# Excess Mortality Calculator

This is the Shiny Application for excess mortality calculation, developed by the [openVA team](https://openva.net), supported by Vital Strategies. 

An online version of this calculator is at [https://zehangli.shinyapps.io/ExcessMortalityApp/](https://zehangli.shinyapps.io/ExcessMortalityApp/).

# Local installation

To run the App on a local computer, the statistical programming software **R** needs to be installed. To install _R_, visit [https://cran.r-project.org/](https://cran.r-project.org/).

To install and run the App in _R_, the following packages are needed and can be installed by running the following command in _R_:

```
install.packages("devtools", repos = "https://cran.r-project.org")
```

The App can be installed in _R_ by running the following command
```
library(devtools)
install_github("richardli/ExcessMortalityApp")
```

The previous steps only need to be run when installing the first time or when updating the software. Once installed, the App can be launched by running the following command in `R`. 
```
library(ExcessMortalityApp)
launchApp()
```

The App will then open in the default browser. 

# Input data format

The input data file should be a CSV file containing death counts over time, and possibly by subpopulation. The required data input is in the "long format", where each row correspond to the death count of a given population at a given time. The dataset should include at least the following required columns (with the exact column names):

+ `year`: numerical value, e.g., 2015, 2016, ...
+ `month`, `week`, or `period`: numerical value. For monthly data, the `month` field is required to be from 1 to 12. For weekly data, the `week` field is required to be from 1 to 53. For custom periods, the `period` field should be from 1 to N (the number of periods per year).
+ `deaths`: numerical value. This is the death count for the corresponding year and month/week. 


There are additional columns that can be included in the data. The column names of these fields can be user-defined.

+ **Sex**: if death count of a given row is for a specific sex.
+ **Age**: if death count of a given row is for a specific age group. Please note the age needs to be grouped into bins.
+ **Population**: the total population corresponding to the row. For example, for a row corresponding to male and age group of 65 or above in a certain month. The `death` field specifies the number of male deaths above age 65 in that month, and the `population` field specifies the total population of male above age 65 in that month.

The App adds up all deaths within each month/week to produce the total deaths and total population at each time point. When both sex and age are specified, the App adds up all deaths within each age/sex to produce the marginal total deaths and total population by age and sex. 

The variables corresponding to age, sex, and population need to be specified manually in the App. If the variables are named "sex", "age", and "population" already, the variables will be automatically picked up by the App. When left unspecified, the App will ignore the age/sex breakdown.

# Features

## Configurable Baseline and Analysis Periods
The boundary between baseline (reference) and analysis periods is configurable. By default, it is set to 2020 if available in the data. Users can also exclude specific anomalous years (e.g., 2020-2022 for COVID-19) entirely — excluded years are removed from both baseline estimation and excess computation. For the Poisson Regression model, excluded years remain in the time series (with missing deaths) so the trend component maintains temporal continuity, but no excess estimates are produced for them.

## Time Scale Options
- **Monthly**: Standard monthly analysis (12 periods per year). Input data must have a `month` column (1-12).
- **Weekly**: Weekly analysis (up to 53 periods per year). Input data must have a `week` column (1-53).
- **Custom periods**: User-defined number of periods per year (e.g., 4 for quarterly, 6 for bimonthly). Input data must have a `period` column with values from 1 to N, where N is the number of periods per year. Data should already be aggregated to the desired period level.

## Minimum Data Validation
The app validates that sufficient baseline data is available and displays warnings when estimates may be unreliable. At least 3 baseline years are recommended; 5 or more are ideal.

# Troubleshooting

When errors occur, the most likely reason is because the input data are ill-formatted. The easiest approach to reset the app is by refreshing the page in the browser. Example input format are included in the links on the left navigation bar. 

# Version history

## version 0.3.0
This version adds configurable baseline/analysis year splits, COVID year exclusion, K-monthly time scale aggregation, minimum data validation with warnings, and fixes the partial-year line bug in the Historical Data Explorer. Simulated demo datasets are included in `data-raw/`.

## version 0.2.1
Minor bug fix and usability improvements.

## version 0.2.0
This version added a new smoothing model and several visualizations. 

## version 0.1.0
This version replicates the calculator by [Vital Strategies](https://preventepidemics.org/covid19/resources/excess-mortality/).


# Acknowledgement

The work is supported by Vital Strategies.

The deployment of this App to shinyapps.io uses the INLA repository at [https://github.com/inbo/INLA](https://github.com/inbo/INLA) to get around the issue of INLA not being on github or CRAN. Thanks INBO!


# Deployment notes

```
# Deployment to shinyapps.io using R 4.1 
install_github("inbo/INLA")
install_github("richardli/ExcessMortalityApp")
setwd("inst/shiny/")
deployApp()
```


