setwd("/Volumes/CCPHSSR/xDATA/NLSPHS 2014")

data <- haven::read_dta("Analysis/NLSPHS_full_wts_adj.dta")

library(plyr)
library(knitr)

