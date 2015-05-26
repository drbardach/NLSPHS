
use "X:\xDATA\NLSPHS 2014\nlsphs_tot.dta", clear
keep nacchoid survresp survsamp yearnaccho yearsurvey id1998 id2006 id2012 peer
tab survresp yearsurvey

save nlsphs_tot, replace

keep if yearsurvey==1998 & survresp!=.

duplicates list nacchoid

sort nacchoid

save nlsphs_19998, replace


use "X:\xDATA\NLSPHS 2014\Analysis\NLSPHS_full_wts_adj.dta", clear

duplicates list nacchoid unid
br if nacchoid=="MN046" | nacchoid=="NJXXX"

drop if Arm==1 & (nacchoid=="MN046" | nacchoid=="NJXXX" )

sort nacchoid

merge nacchoid using nlsphs_19998

rename peer peer_large

