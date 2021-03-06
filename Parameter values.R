#'===========================================================================================================
#' This script is where many of the model parameters are either defined or read in.
#' 
#' It is sourced by the "Model run" script
#'
#' Inputs:
#' Many of the parameters are first defined by the "Parameter creation" scripts and 
#' the output of that script is then simply read in below.
#' 
#' Output:
#' A whole bunch of parameter value objects
#' 
#' This script also creates a lot of functions that are called on to define the parameters values during 
#' the model run when they are dependent on other parameters (e.g. age, years since arrival etc).
#' 
#' Coding style
#' https://google.github.io/styleguide/Rguide.xml

#'LOAD LIBRARIES ===========================================================================================
library(data.table)


#'DEFTINE SOME PARAMETERS HERE ==============================================================================

# Set the working directory
setwd("H:/Katie/PhD/CEA/MH---CB-LTBI")
# setwd("C:/Users/Robin/Documents/Katie/PhD/CEA/LTBI-Aust-CEA")

#' Choose whether it is the onshore or offshore strategy here, and whether to use a payer perspective (1)
#' or not (0)
params <- readRDS("params onshore.rds")
onshore <- 1
payerperspect <- 0

# params <- readRDS("params offshore.rds")
# onshore <- 0
# payerperspect <- 0

#' Choose whether to include emigration here (1) or not (0)
emigration <- 0

#' The tests and treatments we want to consider in the run:
testlist <- c("TST10") # baseline c("QFTGIT", "TST10", "TST15"), for sensitivity analysis c("TST15") 
treatmentlist <- c("4R") # baseline c("4R", "3HP", "6H", "9H"), for sensitivity analysis c("3HP")


#' Other parameters
disc <- 0.03 # discount rate baseline 0.03, low 0.00, high 0.05
startyear <- 2020 # Rstart.year
start.year <- startyear
totalcycles <- 91 #  cycles ... The mortality data continues until 2150 and migrant 
finalyear <- startyear + totalcycles
final.year <- finalyear
kill.off.above <- 119 # age above which all enter death state

#' Migrant inflow size
migrant.inflow.size <- 434340 # baseline 434340, permanent 103740
#' the migrant inflow will stop after the following number of Markov cycles. Inflows possible until 2050 (i.e. 30)
finalinflow <- 0

if (payerperspect == 1) {
  
  # params[p == "cscreentst", mid := 7.33]
  params[p == "cscreentst", mid := 20.10 ] # 162.68
  
}

#'Manual Sensitivity analyses ==============================================================================

#' This function can be used to choose which parameters to change
#' for sensitivity analysis.
#' It replaces the "mid" value in the dataframe with a 
#' low or high value depending on what is specified.
sensfunc <- function(paramname, loworhigh) {
  paramname <- deparse(substitute(paramname))
  colname <- deparse(substitute(loworhigh))
  newvalue <- params[p == paramname, ..colname]
  params[p == paramname, mid:= newvalue]
}

# sensfunc(attscreen, low)
# =========================================================================================================

#' Define the target population
if (onshore == 1) {
  Get.POP <- function(DT, strategy) {
    
    # 200+
    (ifelse(DT[, ISO3] == "200+", 1, 0)) & 
      # 150+
      # (ifelse(DT[, ISO3] == "200+", 1, 0) | ifelse(DT[, ISO3] == "150-199", 1, 0)) & 
      # 100+
      # (ifelse(DT[, ISO3] == "200+", 1, 0) | ifelse(DT[, ISO3] == "150-199", 1, 0) | ifelse(DT[, ISO3] == "100-149", 1, 0)) &
      # 40+
      # (ifelse(DT[, ISO3] == "200+", 1, 0) | ifelse(DT[, ISO3] == "150-199", 1, 0) | ifelse(DT[, ISO3] == "100-149", 1, 0) | ifelse(DT[, ISO3] == "40-99", 1, 0)) &
      # Adjust age at arrival
      (ifelse(DT[, AGERP] > 10, 1, 0) &
         ifelse(DT[, AGERP] < 66, 1, 0))
    
  }
  
  targetfunc <- function(DT) {
    
    # 200+
    DT <- subset(DT, ISO3 == "200+")
    # 150+
    # DT <- subset(DT, ISO3 == "200+" | ISO3 == "150-199" )
    # 100+
    # DT <- subset(DT, ISO3 == "200+" | ISO3 == "150-199" | ISO3 == "100-149")
    # 40+
    # DT <- subset(DT, ISO3 == "200+" | ISO3 == "150-199" | ISO3 == "100-149" | ISO3 == "40-99")
    # Adjust age at arrival
    DT <- subset(DT, AGERP > 10 &
                   AGERP < 66)
    DT
  }
  
} else if (onshore == 0) {
  
  Get.POP <- function(DT, strategy) {
    
    # 200+
    #(ifelse(DT[, ISO3] == "200+", 1, 0)) & 
      # 150+
      # (ifelse(DT[, ISO3] == "200+", 1, 0) | ifelse(DT[, ISO3] == "150-199", 1, 0)) & 
      # 100+
      (ifelse(DT[, ISO3] == "200+", 1, 0) | ifelse(DT[, ISO3] == "150-199", 1, 0) | ifelse(DT[, ISO3] == "100-149", 1, 0)) &
      # 40+
      # (ifelse(DT[, ISO3] == "200+", 1, 0) | ifelse(DT[, ISO3] == "150-199", 1, 0) | ifelse(DT[, ISO3] == "100-149", 1, 0) | ifelse(DT[, ISO3] == "40-99", 1, 0)) &
      # Adjust age at arrival
      (ifelse(DT[, AGERP] > 10, 1, 0) &
         ifelse(DT[, AGERP] < 66, 1, 0))
    
  }
  
  targetfunc <- function(DT) {
    
    # 200+
    # DT <- subset(DT, ISO3 == "200+")
    # 150+
    # DT <- subset(DT, ISO3 == "200+" | ISO3 == "150-199" )
    # 100+
    DT <- subset(DT, ISO3 == "200+" | ISO3 == "150-199" | ISO3 == "100-149")
    # 40+
    # DT <- subset(DT, ISO3 == "200+" | ISO3 == "150-199" | ISO3 == "100-149" | ISO3 == "40-99")
    # Adjust age at arrival
    DT <- subset(DT, AGERP > 10 &
                   AGERP < 66)
    DT
  }
}

options(scipen = 999)
params <- as.data.table(params)

#' Taking the values from the params table and
#' putting them into the environment
for(i in 1:nrow(params)) {
  assign(params[i, p], params[i, mid])
}

#' Adjusting the partial LTBI treatment utilities so 
#' they are dependent on the value of
#' the sampled utility for full treatment
part.utility.dec <- 0.5
ultbipart3HP <- uhealthy - ((uhealthy - ultbi3HP) * part.utility.dec)
ultbipart4R <- uhealthy - ((uhealthy - ultbi4R) * part.utility.dec)
ultbipart6H <- uhealthy - ((uhealthy - ultbi6H) * part.utility.dec)
ultbipart9H <- uhealthy - ((uhealthy - ultbi9H) * part.utility.dec)

# uactivetb <- uactivetb - (uhealthy - ultbi4R)

#' Sourcing the medical costs
source("Medical costs.R")

#' These specify how much of the appointment and medicine
#' costs are applied for the partial costs and treatment
part.appt <- 2
part.med <- 3

c.gp.first <- c.gp.c.vr * (1 - proportion.nonvr) + c.gp.c.nonvr * proportion.nonvr

c.gp.review <- c.gp.b.vr * (1 - proportion.nonvr) + c.gp.b.nonvr * proportion.nonvr

chance.of.needing.mcs <- 0.1

#' Cost of initial appointment after positive screen
#' These costs are different for on and off-shore screening
#' so this need to be taken into account, i.e. for onshore
#' screening this appointment will be a review with the GP
#' or it may be the first appointment with a specialist
#' and a liver function test will be ordered
#' Also, all ongoing appointments related to LTBI treatment will be
#' review appointments

if (onshore == 0) {
  cattend <- c.gp.first + (c.mcs * chance.of.needing.mcs) + c.cxr
} else if (onshore == 1) {
  cattend <- ((c.gp.review + (c.mcs * chance.of.needing.mcs) +
                c.cxr) * (1 - prop.spec)) + 
    ((c.spec.first + (c.mcs * chance.of.needing.mcs) +
       c.cxr) * prop.spec)
}

if (onshore == 1) {
  c.spec.first <- c.spec.review
} 

#' 3HP sort
appt <- num.appt3HP * c.gp.review + c.liver
spec.appt <- c.spec.first + (num.appt3HP - 1) * c.spec.review + c.liver
ctreat3HP <- appt + cmed3HP
cparttreat3HP <-  appt / part.appt + cmed3HP / part.med      
ctreatspec3HP <-  spec.appt + cmed3HP 
cparttreatspec3HP <-  spec.appt / part.appt + cmed3HP / part.med
#' 4r sort
appt <- num.appt4R * c.gp.review
spec.appt <- c.spec.first + (num.appt4R - 1) * c.spec.review
ctreat4R <- appt + cmed4R 
cparttreat4R <-  appt / part.appt + cmed4R / part.med      
ctreatspec4R <-  spec.appt + cmed4R 
cparttreatspec4R <-  spec.appt / part.appt + cmed4R / part.med
#' 6H sort
appt <- num.appt6H * c.gp.review + c.liver
spec.appt <- c.spec.first + (num.appt6H - 1) * c.spec.review + c.liver
ctreat6H <- appt + cmed6H
cparttreat6H <-  appt / part.appt + cmed6H / part.med      
ctreatspec6H <-  spec.appt + cmed6H 
cparttreatspec6H <-  spec.appt / part.appt + cmed6H / part.med
#' 9H sort
appt <- num.appt9H * c.gp.review + c.liver
spec.appt <- c.spec.first + (num.appt9H - 1) * c.spec.review + c.liver
ctreat9H <- appt + cmed9H
cparttreat9H <-  appt / part.appt + cmed9H / part.med      
ctreatspec9H <-  spec.appt + cmed9H 
cparttreatspec9H <-  spec.appt / part.appt + cmed9H / part.med 

#' Initial migrant cohort and LTBI prevalence and reactivation rates
aust <- readRDS("Data/Aust16.rds") # baseline
aust <- as.data.table(aust)
# aust <- subset(aust, ISO3 == "150-199")
#' Australian 2016 census data extracted from Table Builder by country of birth
#' (place of usual residence), single year age and single year of arrival. 

# #' Assuming a lower prevalence of LTBI and a higher reactivation rate (use UUI reactivation rate)
# aust[, LTBP := NULL]
# setnames(aust, "tfnum", "LTBP")

# #' Assuming a higher prevalence of LTBI and a lower reactivation rate (use LUI reactivation rate)
# aust[, LTBP := NULL]
# setnames(aust, "sfnum", "LTBP")

#' Reactivation rates
RRates <- readRDS("Data/RRatescobincidnosex.rds")
#' TB reactivation rate data from: Dale K, Trauer J, et al. Estimating long-term tuberculosis
#' reactivation rates in Australian migrants. Clinical Infectious Diseases 2019 (in press)
Get.RR <- function(xDT, year) {

  DT <- copy(xDT[, .(AGERP, SEXP, YARP, ISO3, AGEP)])

  DT[ISO3 == "0-39" | ISO3 == "40-99", COBI := "<100"]

  DT[ISO3 == "100-149" | ISO3 == "150-199" | ISO3 == "200+", COBI := "100+"]

  # Knocking everyone off after a certain age (mortality risk 100%, everything else 0)

  ifelse(DT[, AGEP] > kill.off.above, 0,

         # Baseline reactivation rates
         RRates[DT[, .(AGERP, SEXP, COBI, ST = year - YARP)], Rate, on = .(aaa = AGERP, Sex = SEXP,
                                                                           ysa = ST, cobi = COBI)]


         # # assuming a lower LTBI prevalence and a higher rate of reactivation
         # RRates[DT[, .(AGERP, SEXP, COBI, ST = year - YARP)], UUI, on = .(aaa = AGERP, Sex = SEXP,
         #                                                                   ysa = ST, cobi = COBI)]

         # # assuming a higher prevalence of LTBI and a lower rate of reactivation
         # RRates[DT[, .(AGERP, SEXP, COBI, ST = year - YARP)], LUI, on = .(aaa = AGERP, Sex = SEXP,
         #                                                                  ysa = ST, cobi = COBI)]
  )

}
 

#' Reactivation rate adjustment for existing TB control
Get.RRADJ <- function(xDT, year) {
  
  DT <- copy(xDT[, .(year, AGERP, YARP, AGEP)])
  
  rradjrates[DT[, .(AGERP, ST = year - YARP)], rate, on = .(aaa = AGERP, ysa = ST)]
  
  # rradjrates[DT[, .(AGERP, ST = year - YARP)], lower, on = .(aaa = AGERP, ysa = ST)]
  
  # rradjrates[DT[, .(AGERP, ST = year - YARP)], upper, on = .(aaa = AGERP, ysa = ST)]
  
  # 1
  
}


#' Look up the mortality rate from vic.mortality
Get.MR <- function(xDT, year, rate.assumption = "Med") {
  
  DT <- copy(xDT[, .(AGEP, SEXP)])
  
  # To lookup all ages beyond the killing off age
  DT[AGEP > kill.off.above, AGEP := kill.off.above + 1]
  
  # Knocking everyone off after a certain age (mortality risk 100%, everything else 0)
  vic.mortality[Age > kill.off.above, Prob := 1]
  
  vic.mortality[Year == year & mrate == rate.assumption][DT, Prob, on = .(Age = AGEP, Sex = SEXP)]

}

#' Look up TB mortality rate
Get.TBMR <- function(xDT, year) {
  
  DT <- copy(xDT[, .(AGEP, SEXP)])
  
  # To lookup all ages beyond the killing off age
  DT[AGEP > kill.off.above, AGEP := kill.off.above + 1]
  
  # Knocking everyone off after a certain age (mortality risk 100%, everything else 0)
  vic.tb.mortality[age > kill.off.above, Prob := 0]
  vic.tb.mortality[age > kill.off.above, lower := 0]
  vic.tb.mortality[age > kill.off.above, upper := 0]
  
  vic.tb.mortality[DT[, .(AGEP, SEXP)], Prob, on = .(age = AGEP, sex = SEXP)]
  # vic.tb.mortality[DT[, .(AGEP, SEXP)], lower, on = .(age = AGEP, sex = SEXP)]
  # vic.tb.mortality[DT[, .(AGEP, SEXP)], upper, on = .(age = AGEP, sex = SEXP)]
  
}


#' Look up SAE rate from sae.rate (age and treatment dependent)
Get.SAE <- function(xDT, treat) {
  
  DT <- copy(xDT[, .(AGEP)])
  
  # To lookup all ages beyond the killing off age
  DT[AGEP > kill.off.above, AGEP := kill.off.above + 1]
  
  # Knocking everyone off after a certain age (mortality risk 100%, everything else 0)
  sae.rate[Age > kill.off.above, Rate := 0]
  sae.rate[Age > kill.off.above, low := 0]
  sae.rate[Age > kill.off.above, high := 0]
  
  DT$treatment <- as.character(treat)
  
  sae.rate[DT[, .(AGEP, treatment)], Rate, on = .(Age = AGEP, treatment = treatment)]
  # sae.rate[DT[, .(AGEP, treatment)], low, on = .(Age = AGEP, treatment = treatment)]
  # sae.rate[DT[, .(AGEP, treatment)], high, on = .(Age = AGEP, treatment = treatment)]

}

#' Look up SAE rate from sae.rate (age and treatment dependent)
Get.SAEMR <- function(xDT, treat) {
  
  DT <- copy(xDT[, .(AGEP)])
  
  # To lookup all ages beyond the killing off age
  DT[AGEP > kill.off.above, AGEP := kill.off.above + 1]
  
  # Knocking everyone off after a certain age (mortality risk 100%, everything else 0)
  sae.mortality[Age > kill.off.above, Rate := 0]
  sae.mortality[Age > kill.off.above, low := 0]
  sae.mortality[Age > kill.off.above, high := 0]
  
  DT$treatment <- as.character(treat)
  
  sae.mortality[DT[, .(AGEP, treatment)], Rate, on = .(Age = AGEP, treatment = treatment)]
  # sae.mortality[DT[, .(AGEP, treatment)], low, on = .(Age = AGEP, treatment = treatment)]
  # sae.mortality[DT[, .(AGEP, treatment)], high, on = .(Age = AGEP, treatment = treatment)]
  
}

#' Emigrate rate from emigrate.rate (zero)
#' Source emigrate data
emigrate.rate <- readRDS("Data/emigrate.rate.rds") # BASELINE assumed rate incorporating both temp and permanent residents 
#' emigrate.rate <- readRDS("Data/emigrate.rate.perm.rds") # LOWER assumed rate among permanent residents

emigrate.rate <- as.data.table(emigrate.rate)

#' Emigrate rate from emigrate.rate (age dependent)
Get.EMIGRATE <- function(xDT, year) {

  DT <- copy(xDT[, .(year, AGEP, YARP)])

  # To lookup all ages beyond the killing off age
  DT[AGEP > kill.off.above, AGEP := kill.off.above + 1]
  
  # Knocking everyone off after a certain age (mortality risk 100%, everything else 0)
  emigrate.rate[Age > kill.off.above, Rate := 0]
  emigrate.rate[Age > kill.off.above, lower := 0]
  emigrate.rate[Age > kill.off.above, upper := 0]

  if (emigration == 1) {
    
    emigrate.rate[DT[, .(AGEP)], Rate, on = .(Age = AGEP)] 
    # emigrate.rate[DT[, .(AGEP)], lower, on = .(Age = AGEP)]
    # emigrate.rate[DT[, .(AGEP)], upper, on = .(Age = AGEP)]
    
  } else if (emigration == 0) {
    
    0
    
  }
  
}


#' Look up treatment costs (it's treatment dependent)
Get.TREATC <- function(S, treat) {
  
  as.numeric(treatmentcost.dt[treatment == treat & practitioner == "spec", ..S]) * prop.spec +
    as.numeric(treatmentcost.dt[treatment == treat & practitioner == "gp", ..S]) * (1 - prop.spec)
  
}

#' Calculating the partial treatment efficacy
Get.PART.EFFIC <- function(xDT, C, E, treat) {
  
  DT <- copy(xDT[, .(year, AGEP)])
  
  treatment <- as.character(treat)
  
  treat.complete <- as.numeric(treatment.dt[treatment == treat, ..C])
  
  treat.effic <- as.numeric(treatment.dt[treatment == treat, ..E])
  
  ifelse(DT[, AGEP] > kill.off.above, 0,
         
         if (treat == '3HP') {
           
           treat.effic.1 <- 0
           treat.effic.2 <- 0.368 # Gao et al 2018
           treat.effic.2 <- ifelse(treat.effic.2 >= treat.effic, treat.effic, treat.effic.2)
           
           ratio.1 <- 0.6993362 # Page and Menzies
           ratio.2 <- 0.3006638 # Page and Menzies
           
           PART.EFFIC <- treat.effic.2 * ratio.2
           
         } else if (treat == '4R') {
           
           treat.effic.1 <- 0
           treat.effic.2 <- 0.368 # Gao et al 2018
           treat.effic.2 <- ifelse(treat.effic.2 >= treat.effic, treat.effic, treat.effic.2)
           
           ratio.1 <- 0.6993362 # Page and Menzies
           ratio.2 <- 0.3006638 # Page and Menzies
           
           PART.EFFIC <- treat.effic.2 * ratio.2
           
         } else if (treat == '6H') {
           
           treat.effic.1 <- 0
           treat.effic.2 <- 0.310 # IUAT
           treat.effic.2 <- ifelse(treat.effic.2 >= treat.effic, treat.effic, treat.effic.2)
           
           ratio.1 <- 0.7273 # IUAT
           ratio.2 <- 0.2727 # IUAT
           
           PART.EFFIC <- treat.effic.2 * ratio.2 
           
         } else if (treat == '9H') {
           
           treat.effic.1 <- 0
           treat.effic.2 <- 0.310 # IUAT
           treat.effic.3 <- 0.69 # IUAT
           treat.effic.3 <- ifelse(treat.effic.3 >= treat.effic, treat.effic, treat.effic.3)
           
           ratio.1 <- 0.59259 # IUAT
           ratio.2 <- 0.18519 # IUAT
           ratio.3 <- 0.22222 # IUAT
           
           PART.EFFIC <- treat.effic.1 * ratio.1 +
             treat.effic.2 * ratio.2 +
             treat.effic.3 * ratio.3
           
         } else {
           
           PART.EFFIC <- 0
         }
  )
  
}

Get.FULL.EFFIC <- function(xDT, E, treat) {
  
  DT <- copy(xDT[, .(year, AGEP)])
  
  treatment <- as.character(treat)
  
  treat.effic <- as.numeric(treatment.dt[treatment == treat, ..E])
  
  ifelse(DT[, AGEP] > kill.off.above, 0, treat.effic)

}


Get.TREATR <- function(C, E, treat) {

  treat.complete <- as.numeric(treatment.dt[treatment == treat, ..C])

  treat.effic <- as.numeric(treatment.dt[treatment == treat, ..E])

  treatment <- as.character(treat)
  
  if (treat == '3HP') {

    treat.effic.1 <- 0
    treat.effic.2 <- 0.368 # Gao et al 2018
    treat.effic.2 <- ifelse(treat.effic.2 >= treat.effic, treat.effic, treat.effic.2)

    ratio.1 <- 0.6993362 # Page and Menzies
    ratio.2 <- 0.3006638 # Page and Menzies

    treat.complete.1 <- (1 - treat.complete) * ratio.1
    treat.complete.2 <- (1 - treat.complete) * ratio.2

    TREATR <- treat.effic.1 * treat.complete.1 +
      treat.effic.2 * treat.complete.2 +
      treat.effic * treat.complete

  } else if (treat == '4R') {

    treat.effic.1 <- 0
    treat.effic.2 <- 0.368 # Gao et al 2018
    treat.effic.2 <- ifelse(treat.effic.2 >= treat.effic, treat.effic, treat.effic.2)

    ratio.1 <- 0.6993362 # Page and Menzies
    ratio.2 <- 0.3006638 # Page and Menzies

    treat.complete.1 <- (1 - treat.complete) * ratio.1
    treat.complete.2 <- (1 - treat.complete) * ratio.2

    TREATR <- treat.effic.1 * treat.complete.1 +
      treat.effic.2 * treat.complete.2 +
      treat.effic * treat.complete

  } else if (treat == '6H') {

    treat.effic.1 <- 0
    treat.effic.2 <- 0.310 # IUAT
    treat.effic.2 <- ifelse(treat.effic.2 >= treat.effic, treat.effic, treat.effic.2)

    ratio.1 <- 0.7273 # IUAT
    ratio.2 <- 0.2727 # IUAT

    treat.complete.1 <- (1 - treat.complete) * ratio.1
    treat.complete.2 <- (1 - treat.complete) * ratio.2

    TREATR <- treat.effic.1 * treat.complete.1 +
      treat.effic.2 * treat.complete.2 +
      treat.effic * treat.complete

  } else if (treat == '9H') {

    treat.effic.1 <- 0
    treat.effic.2 <- 0.310 # IUAT
    treat.effic.3 <- 0.69 # IUAT
    treat.effic.3 <- ifelse(treat.effic.3 >= treat.effic, treat.effic, treat.effic.3)

    ratio.1 <- 0.59259 # IUAT
    ratio.2 <- 0.18519 # IUAT
    ratio.3 <- 0.22222 # IUAT

    treat.complete.1 <- (1 - treat.complete) * ratio.1
    treat.complete.2 <- (1 - treat.complete) * ratio.2
    treat.complete.3 <- (1 - treat.complete) * ratio.3

    TREATR <- treat.effic.1 * treat.complete.1 +
      treat.effic.2 * treat.complete.2 +
      treat.effic.3 * treat.complete.3 +
      treat.effic * treat.complete

  } else {
    
    TREATR <- 0
  }

}

