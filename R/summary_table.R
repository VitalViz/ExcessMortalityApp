#' Function to create summary tables
#' 
#' @param time_case string indicating monthly or weekly input
#' @param T number of time periods
#' @param years a sequence of years to show
#' @param morData the long format data frame
#' 
#' @return a list of summary tables
#' 
#' @export
#' 
#' @examples
#' data(SampleInput1)
#' SampleInput1$sex <- SampleInput1$age <- "All"
#' SampleInput1$timeCol = SampleInput1$month
#' SampleInput1$popCol = SampleInput1$population
#' tab <- summary_table(SampleInput1, time_case = "Monthly", T = 12, years = 2015:2021)
#' data(SampleInput3)
#' SampleInput3$timeCol = SampleInput3$week
#' SampleInput3$popCol = SampleInput3$population
#' tab <- summary_table(SampleInput3, time_case = "Weekly", T = 53, years = 2015:2021)
#' 

summary_table <- function(time_case, T, years, morData){

	   safe_sum <- function(x) if(length(x) == 0) NA_real_ else sum(x, na.rm = TRUE)
	   safe_rate <- function(num, denom) {
	     if(is.na(num) || length(denom) == 0 || sum(denom, na.rm = TRUE) == 0) NA_real_
	     else num / sum(denom, na.rm = TRUE) * 1e5
	   }

	   cleanTab <- NULL
	   tab <- data.frame(matrix(NA, nrow = T, ncol = length(years)))
       colnames(tab) <- years  
       if(time_case == "Monthly" && T == 12){
         rownames(tab) <- month.name
       }else if(time_case == "Monthly" && T < 12){
         rownames(tab) <- paste0("Period ", 1:T)
       }else{
         rownames(tab) <- 1:T
       }
       tab.rate <- tab

       # Overall
       for(i in 1:T){
         for(j in 1:ncol(tab)){
            idx <- which(morData$timeCol == i & morData$year == years[j])
            tab[i, j] <- safe_sum(morData$deaths[idx])
            tab.rate[i, j] <- safe_rate(tab[i, j], morData$popCol[idx])
         }
       }
       tab1 <- cbind(rownames(tab), tab)
       colnames(tab1)[1] <- if(time_case == "Monthly" && T == 12) "Month" else if(time_case == "Monthly") "Period" else "Week"
       tab1.rate <- cbind(rownames(tab.rate), tab.rate)
       colnames(tab1.rate)[1] <- if(time_case == "Monthly" && T == 12) "Month" else if(time_case == "Monthly") "Period" else "Week"
       cleanTab[['Death Counts']][["All"]][["All"]] <- tab1
       cleanTab[['Death Rate (Number of Deaths Per 100,000 Population)']][["All"]][["All"]] <- tab1.rate


       # by Sex
       for(s in unique(morData$sexCol)){
        tab.sex <- tab.sex.rate <- tab * NA
         for(i in 1:T){
           for(j in 1:ncol(tab)){
              idx <- which(morData$timeCol == i & morData$year == years[j] & morData$sexCol == s)
              tab.sex[i, j] <- safe_sum(morData$deaths[idx])
              tab.sex.rate[i, j] <- safe_rate(tab.sex[i, j], morData$popCol[idx])
           }
         }
         tab.sex <- cbind(rownames(tab.sex), tab.sex)
         colnames(tab.sex)[1] <- if(time_case == "Monthly" && T == 12) "Month" else if(time_case == "Monthly") "Period" else "Week"
         tab.sex.rate <- cbind(rownames(tab.sex.rate), tab.sex.rate)
         colnames(tab.sex.rate)[1] <- if(time_case == "Monthly" && T == 12) "Month" else if(time_case == "Monthly") "Period" else "Week"
         cleanTab[['Death Counts']][[s]][["All"]] <- tab.sex
         cleanTab[['Death Rate (Number of Deaths Per 100,000 Population)']][[s]][["All"]] <- tab.sex.rate
       }

       # by Age
       for(a in unique(morData$ageCol)){
        tab.age <- tab.age.rate <- tab * NA
         for(i in 1:T){
           for(j in 1:ncol(tab)){
              idx <- which(morData$timeCol == i & morData$year == years[j] & morData$ageCol == a)
              tab.age[i, j] <- safe_sum(morData$deaths[idx])
              tab.age.rate[i, j] <- safe_rate(tab.age[i, j], morData$popCol[idx])
           }
         }
         tab.age <- cbind(rownames(tab.age), tab.age)
         colnames(tab.age)[1] <- if(time_case == "Monthly" && T == 12) "Month" else if(time_case == "Monthly") "Period" else "Week"
         tab.age.rate <- cbind(rownames(tab.age.rate), tab.age.rate)
         colnames(tab.age.rate)[1] <- if(time_case == "Monthly" && T == 12) "Month" else if(time_case == "Monthly") "Period" else "Week"
         cleanTab[['Death Counts']][["All"]][[a]] <- tab.age
         cleanTab[['Death Rate (Number of Deaths Per 100,000 Population)']][["All"]][[a]] <- tab.age.rate
       }

        # by Sex and Age
        for(s in unique(morData$sexCol)){
          for(a in unique(morData$ageCol)){
          tab.sexage <- tab.sexage.rate <- tab * NA
           for(i in 1:T){
             for(j in 1:ncol(tab)){
                idx <- which(morData$timeCol == i & morData$year == years[j] & morData$sexCol == s & morData$ageCol == a)
                tab.sexage[i, j] <- safe_sum(morData$deaths[idx])
                tab.sexage.rate[i, j] <- safe_rate(tab.sexage[i, j], morData$popCol[idx])
             }
           }
           tab.sexage <- cbind(rownames(tab.sexage), tab.sexage)
           colnames(tab.sexage)[1] <- if(time_case == "Monthly" && T == 12) "Month" else if(time_case == "Monthly") "Period" else "Week"
           tab.sexage.rate <- cbind(rownames(tab.sexage.rate), tab.sexage.rate)
           colnames(tab.sexage.rate)[1] <- if(time_case == "Monthly" && T == 12) "Month" else if(time_case == "Monthly") "Period" else "Week"
           cleanTab[['Death Counts']][[s]][[a]] <- tab.sexage
           cleanTab[['Death Rate (Number of Deaths Per 100,000 Population)']][[s]][[a]] <- tab.sexage.rate
          }
        }

        return(cleanTab)
}