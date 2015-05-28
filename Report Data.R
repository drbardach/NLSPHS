## This is where generated reports will be saved
setwd("~/Desktop/Reports")

## Read in the data
data <- haven::read_dta("/Volumes/CCPHSSR/xDATA/NLSPHS 2014/Analysis/NLSPHS_full_wts_adj.dta")

## Sort the data by UNID so we know which report lines up with which LHD
data <- data[order(data$unid),]

## FOR loop to generate the actual PDFs
library(rmarkdown)
for (i in 1:dim(data)[2]){
  render("/Volumes/CCPHSSR/xDATA/NLSPHS 2014/Analysis/Github/NLSPHS/Report Template.Rmd",
         output_file = paste0('report_', i, '.pdf')
  )
}
