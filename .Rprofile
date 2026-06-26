# source("renv/activate.R")
local({
  r <- getOption("repos")
  if (length(r) == 0 || identical(unname(r["CRAN"]), "@CRAN@")) {
    r["CRAN"] <- "https://cloud.r-project.org"
  }
  options(repos = r)
  options(renv.config.snapshot.type = "all")
})
