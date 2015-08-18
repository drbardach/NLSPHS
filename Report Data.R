start <- Sys.time()

## Read and modify the data
source("/users/David/Dropbox/Work/Health Management and Policy/NLSPHS Reports/Append Data.R")

##############################
## Run reports for big lhds ##
##############################
data <- subset(resp, Big == 1)

## Get the number of reports to generate
n <- length(unique(data$unid)) - 1

## Loop to generate the PDFs
for (i in 1:n) {
  dir.create(paste0("/users/David/OneDriveBusiness/Reports/Report", data$unid[i]))
  setwd(paste0("/users/David/OneDriveBusiness/Reports/Report", data$unid[i]))
  ctr <- "ph"     #for health departments
  rmarkdown::render("/users/David/Dropbox/Work/Health Management and Policy/NLSPHS Reports/Report Template.Rmd",
                    output_file = paste0('report_', data$unid[i], '.pdf')
                    )
  ctr <- "hsp"     #for hospitals
  rmarkdown::render("/users/David/Dropbox/Work/Health Management and Policy/NLSPHS Reports/Report Template.Rmd",
                    output_file = paste0('hspreport_', data$unid[i], '.pdf')
                    )
}


################################
## Run reports for small lhds ##
################################
data <- subset(resp, Big == 0)

## Get the number of reports to generate
n <- length(unique(data$unid))

## Loop to generate the PDFs
for (i in 1:184) {
  dir.create(paste0("/users/David/OneDriveBusiness/Reports/Report", data$unid[i]))
  setwd(paste0("/users/David/OneDriveBusiness/Reports/Report", data$unid[i]))
  ctr <- "ph"     #for health departments
  rmarkdown::render("/users/David/Dropbox/Work/Health Management and Policy/NLSPHS Reports/Report Template (snap).Rmd",
                    output_file = paste0('report_', data$unid[i], '.pdf')
                    )
  ctr <- "hsp"     #for hospitals
  rmarkdown::render("/users/David/Dropbox/Work/Health Management and Policy/NLSPHS Reports/Report Template (snap).Rmd",
                    output_file = paste0('hspreport_', data$unid[i], '.pdf')
                    )
}

# Number 185 (unid 71439) is a problem due to answering "No" to all stem questions

for (i in 186:n) {
  dir.create(paste0("/users/David/OneDriveBusiness/Reports/Report", data$unid[i]))
  setwd(paste0("/users/David/OneDriveBusiness/Reports/Report", data$unid[i]))
  ctr <- "ph"     #for health departments
  rmarkdown::render("/users/David/Dropbox/Work/Health Management and Policy/NLSPHS Reports/Report Template (snap).Rmd",
                    output_file = paste0('report_', data$unid[i], '.pdf')
  )
  ctr <- "hsp"     #for hospitals
  rmarkdown::render("/users/David/Dropbox/Work/Health Management and Policy/NLSPHS Reports/Report Template (snap).Rmd",
                    output_file = paste0('hspreport_', data$unid[i], '.pdf')
  )
}

end <- Sys.time()

####################
## Email the PDFs ##
####################
for (i in 1:n) {
  mailR::send.mail(from = "PublicHealthPBRN <PublicHealthPBRN@uky.edu>",
                   to = mm[i],
                   # bcc = "PublicHealthPBRN@uky.edu",
                   subject = "Your Customized NLSPHS Report",
                   body = paste0('<p>Thank you for participating in the most recent wave of the National Longitudinal Survey of Public Health Systems (NLSPHS).
                                   Attached is a copy of your customized report. 
                                   You may use it to assess how your district compares with qualitatively similar districts, or to all districts of a similar size.</p>
                                   
                                   <p>New to the report this year is a network analysis of organizational types in your community.
                                   For your convenience, this graphic has been oriented around the local health department.
                                   If you would like to share a copy of this report with your hospital partners, a reoriented report for your community can be downloaded by
                                   <a href=\"https://luky-my.sharepoint.com/personal/drba223_uky_edu/Documents/Reports/hspreport_', data$unid[i], '.pdf\">clicking here</a>.</p>
                                   
                                   <p>Thank you again for your assistance in completing this study.</p>
                                   
                                   Sincerely,<br>
                                   Glen P. Mays, M.P.H., Ph.D.<br>
                                   F. Douglas Scutchfield Endowed Professor in Health Services and Systems Research<br>
                                   University of Kentucky College of Public Health<br>
                                   121 Washington Ave, Rm 201<br>
                                   Lexington, KY 40536-0003<br>
                                   Phone: 859-218-2029<br>
                                   Email: glen.mays@uky.edu<br>
                                   http://www.publichealthsystems.org<br>
                                   Archive: http://works.bepress.com/glen_mays/'),
                   attach.files = paste0('report_', data$unid[i], '.pdf'),
                   smtp = list(host.name = "uksmtp.uky.edu", port = 25),
                   html = T,
                   authenticate = F,
                   debug = F)
}