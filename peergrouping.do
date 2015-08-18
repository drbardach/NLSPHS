use "X:\xDATA\NLSPHS 2014\Analysis\data\SMALL_PEER_FINAL.dta", clear
tab peer

sort nacchoid
gen clusanalysis=1
rename peer peerclus
sort nacchoid


merge 1:m nacchoid using "X:\xDATA\NLSPHS 2014\Analysis\data\NLSPHS_98061214.dta"

drop _merge

sort nacchoid
save NLSPHS_SMALLPEER, replace

use "X:\xDATA\NLSPHS 2014\Analysis\data\NLSPHS_98061214.dta", clear
count
keep nacchoid peer yearsurvey
*keep if Arm!=2 & Arm!=3
gen peer98=peer*1
keep if yearsurvey==1998
drop yearsurvey
count
sort nacchoid

save part98, replace

merge 1:m nacchoid using NLSPHS_SMALLPEER

/*
peerclus is peer grouping obtained from cluster analysis for small size jurisdiction and these peer grouping are different than the 
peer grouping in varibale peer for large size jurisdictions
*/

save "X:\xDATA\NLSPHS 2014\Analysis\data\NLSPHS_98061214_final.dta", replace

export excel using "X:\xDATA\NLSPHS 2014\Analysis\data\NLSPHS_98061214_final.xlsx", firstrow(variables) replace
