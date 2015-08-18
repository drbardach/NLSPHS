## Read in data
raw <- haven::read_sas("/users/David/Desktop/nlsphs_allwaves.sas7bdat")

## Store logos
library(png)
library(grid)
ncc <- readPNG("/users/David/OneDriveBusiness/Reports/NCC_PHSSR_PBRN_OutlinesFINAL-01.png")
uk <- readPNG("/users/David/OneDriveBusiness/Reports/College of Public Health PMS 286.png")

## Filter the data to only include respondents
resp <- subset(raw, survresp == 1)

## Sort the data by UNID so we know which report lines up with which LHD
resp <- resp[order(resp$unid),]

## Measure missingness
library(dplyr)
countNA <- resp %>% 
  select(shatot, saotot, loctot, fedtot, fbotot, hsptot, instot, emptot, phytot, chctot, nonotot, schtot, unitot, Arm) %>% 
  group_by(Arm) %>% 
  mutate(sha = sum(is.na(shatot)),
         sao = sum(is.na(saotot)),
         loc = sum(is.na(loctot)),
         fed = sum(is.na(fedtot)),
         fbo = sum(is.na(fbotot)),
         hsp = sum(is.na(hsptot)),
         ins = sum(is.na(instot)),
         emp = sum(is.na(emptot)),
         phy = sum(is.na(phytot)),
         chc = sum(is.na(chctot)),
         nono = sum(is.na(nonotot)),
         sch = sum(is.na(schtot)),
         uni = sum(is.na(unitot))
         ) %>% 
  select(sha, sao, loc, fed, fbo, hsp, ins, emp, phy, chc, nono, sch, uni, Arm) %>% 
  unique()

participation <- resp %>% 
  select(av1:av20, unid) %>% 
  mutate(ans = 20 - rowSums(is.na(.[1:20])))

## Only keep respondents who answered at least 2 stem questions
resp$ans <- participation$ans
resp <- resp[ which(resp$ans >= 2),]

## Create measure of Public Health Agency involvement
resp$ph1 <- ifelse(resp$lhd1 > 0, 1, 0)
resp$ph2 <- ifelse(resp$lhd2 > 0, 1, 0)
resp$ph3 <- ifelse(resp$lhd3 > 0, 1, 0)
resp$ph4 <- ifelse(resp$lhd4 > 0, 1, 0)
resp$ph5 <- ifelse(resp$lhd5 > 0, 1, 0)
resp$ph6 <- ifelse(resp$lhd6 > 0, 1, 0)
resp$ph7 <- ifelse(resp$lhd7 > 0, 1, 0)
resp$ph8 <- ifelse(resp$lhd8 > 0, 1, 0)
resp$ph9 <- ifelse(resp$lhd9 > 0, 1, 0)
resp$ph10 <- ifelse(resp$lhd10 > 0, 1, 0)
resp$ph11 <- ifelse(resp$lhd11 > 0, 1, 0)
resp$ph12 <- ifelse(resp$lhd12 > 0, 1, 0)
resp$ph13 <- ifelse(resp$lhd13 > 0, 1, 0)
resp$ph14 <- ifelse(resp$lhd14 > 0, 1, 0)
resp$ph15 <- ifelse(resp$lhd15 > 0, 1, 0)
resp$ph16 <- ifelse(resp$lhd16 > 0, 1, 0)
resp$ph17 <- ifelse(resp$lhd17 > 0, 1, 0)
resp$ph18 <- ifelse(resp$lhd18 > 0, 1, 0)
resp$ph19 <- ifelse(resp$lhd19 > 0, 1, 0)

## Replace select missing values? Should this be handled before receiving the data?
resp$peer[is.na(resp$peer)] <- 0
resp$shatot[is.na(resp$shatot)] <- 0
resp$saotot[is.na(resp$saotot)] <- 0
resp$loctot[is.na(resp$loctot)] <- 0
resp$fedtot[is.na(resp$fedtot)] <- 0
resp$fbotot[is.na(resp$fbotot)] <- 0
resp$hsptot[is.na(resp$hsptot)] <- 0
resp$instot[is.na(resp$instot)] <- 0
resp$emptot[is.na(resp$emptot)] <- 0
resp$phytot[is.na(resp$phytot)] <- 0
resp$chctot[is.na(resp$chctot)] <- 0
resp$nonotot[is.na(resp$nonotot)] <- 0
resp$schtot[is.na(resp$schtot)] <- 0
resp$unitot[is.na(resp$unitot)] <- 0

## Combine Arms 2&3 for reporting
resp$Big <- 0
resp$Big[resp$Arm == 1 | resp$yearsurvey < 2014] <- 1

## Tabulate responses by year
xtabs(~yearsurvey+Big, data=resp)

## Add peer and year summary values
nlssum <- function(data){
  library(dplyr)
  data %>% 
    summarise(av1.m = mean(av1, na.rm=T),
              av2.m = mean(av2, na.rm=T),
              av3.m = mean(av3, na.rm=T),
              av4.m = mean(av4, na.rm=T),
              av5.m = mean(av5, na.rm=T),
              av6.m = mean(av6, na.rm=T),
              av7.m = mean(av7, na.rm=T),
              av8.m = mean(av8, na.rm=T),
              av9.m = mean(av9, na.rm=T),
              av10.m = mean(av10, na.rm=T),
              av11.m = mean(av11, na.rm=T),
              av12.m = mean(av12, na.rm=T),
              av13.m = mean(av13, na.rm=T),
              av14.m = mean(av14, na.rm=T),
              av15.m = mean(av15, na.rm=T),
              av16.m = mean(av16, na.rm=T),
              av17.m = mean(av17, na.rm=T),
              av18.m = mean(av18, na.rm=T),
              av19.m = mean(av19, na.rm=T),
              av20.m = mean(av20, na.rm=T),
              avass.m = mean(avass, na.rm=T),
              avpol.m = mean(avpol, na.rm=T),
              avasr.m = mean(avasr, na.rm=T),
              avtot.m = mean(avtot, na.rm=T),
              eff1.m = mean(eff1, na.rm=T),
              eff2.m = mean(eff2, na.rm=T),
              eff3.m = mean(eff3, na.rm=T),
              eff4.m = mean(eff4, na.rm=T),
              eff5.m = mean(eff5, na.rm=T),
              eff6.m = mean(eff6, na.rm=T),
              eff7.m = mean(eff7, na.rm=T),
              eff8.m = mean(eff8, na.rm=T),
              eff9.m = mean(eff9, na.rm=T),
              eff10.m = mean(eff10, na.rm=T),
              eff11.m = mean(eff11, na.rm=T),
              eff12.m = mean(eff12, na.rm=T),
              eff13.m = mean(eff13, na.rm=T),
              eff14.m = mean(eff14, na.rm=T),
              eff15.m = mean(eff15, na.rm=T),
              eff16.m = mean(eff16, na.rm=T),
              eff17.m = mean(eff17, na.rm=T),
              eff18.m = mean(eff18, na.rm=T),
              eff19.m = mean(eff19, na.rm=T),
              eff20.m = mean(eff20, na.rm=T),
              effass.m = mean(effass, na.rm=T),
              effpol.m = mean(effpol, na.rm=T),
              effasr.m = mean(effasr, na.rm=T),
              efftot.m = mean(efftot, na.rm=T),
              lhd1.m = mean(lhd1, na.rm=T),
              lhd2.m = mean(lhd2, na.rm=T),
              lhd3.m = mean(lhd3, na.rm=T),
              lhd4.m = mean(lhd4, na.rm=T),
              lhd5.m = mean(lhd5, na.rm=T),
              lhd6.m = mean(lhd6, na.rm=T),
              lhd7.m = mean(lhd7, na.rm=T),
              lhd8.m = mean(lhd8, na.rm=T),
              lhd9.m = mean(lhd9, na.rm=T),
              lhd10.m = mean(lhd10, na.rm=T),
              lhd11.m = mean(lhd11, na.rm=T),
              lhd12.m = mean(lhd12, na.rm=T),
              lhd13.m = mean(lhd13, na.rm=T),
              lhd14.m = mean(lhd14, na.rm=T),
              lhd15.m = mean(lhd15, na.rm=T),
              lhd16.m = mean(lhd16, na.rm=T),
              lhd17.m = mean(lhd17, na.rm=T),
              lhd18.m = mean(lhd18, na.rm=T),
              lhd19.m = mean(lhd19, na.rm=T),
              lhd20.m = mean(lhd20, na.rm=T),
              lhdass.m = mean(lhdass, na.rm=T),
              lhdpol.m = mean(lhdpol, na.rm=T),
              lhdasr.m = mean(lhdasr, na.rm=T),
              lhdtot.m = mean(lhdtot, na.rm=T)
    )
}

d98 <- subset(resp, yearsurvey == 1998)
d06 <- subset(resp, yearsurvey == 2006)
d12 <- subset(resp, yearsurvey == 2012)
d14 <- subset(resp, yearsurvey == 2014)

sum98.peer <- nlssum(group_by(d98, peer))
sum06.peer <- nlssum(group_by(d06, peer))
sum12.peer <- nlssum(group_by(d12, peer))
sum14.peer <- nlssum(group_by(d14, peer))

sum98.all <- nlssum(d98)
sum06.all <- nlssum(d06)
sum12.all <- nlssum(d12)
sum14.all <- nlssum(group_by(d14, Big))

## Calculate missing SNA variables
vars <- paste0(rep(c("ph", "sha", "sao", "loc", "fed", "fbo", "hsp", "ins", "emp", "phy", "chc", "nono", "sch", "uni"), each = 19), 1:19)

getUNIDEdgelist <- function(r) {
  el <- data.frame(unid = character(), source = character(), target = character(), value = numeric())
  for(v in vars) {
    el0 <- data.frame(unid = resp[r, 'unid'],
                      source = regmatches(v, regexpr('[a-z]+', v)),
                      target = regmatches(v, regexpr('[0-9]+', v)),
                      value = as.numeric(resp[r, v]))
    el <- rbind(el, el0)
  }
el
}

library(parallel)
library(data.table)
xx <- do.call('rbind', mclapply(1:nrow(resp), getUNIDEdgelist, mc.cores=3))
xx <- data.table(xx)
xx <- xx[!is.na(xx$unid)]
xx$value[is.na(xx$value)] <- 0
# adj <- get.adjacency(g, attr = 'weight', type = 'upper')

