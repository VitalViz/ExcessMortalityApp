# source("renv/activate.R")
local({
  r <- getOption("repos")
  r["INLA"] <- "https://inla.r-inla-download.org/R/stable"
  options(repos = r)
  options(renv.config.snapshot.type = "all")
  
  # Stamp INLA's DESCRIPTION with its repo so renv identifies the source
  # without needing to query the R 4.6 package index
  inla_pkg <- tryCatch(find.package("INLA"), error = function(e) NULL)
  if (!is.null(inla_pkg)) {
    desc_file <- file.path(inla_pkg, "DESCRIPTION")
    lines <- readLines(desc_file, warn = FALSE)
    if (!any(grepl("^Repository:", lines))) {
      writeLines(c(lines, "Repository: INLA"), desc_file)
    }
  }
})
