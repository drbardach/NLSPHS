/*Bringing in previous waves of NLSPHS data*/


use nlsphs_1998, clear
tab survresp
append using nlsphs_2006
count
tab survresp
append using nlsphs_2012
count
tab survresp

save nlsphs_980612, replace

keep if yearsurv12==1
count

rename (survresp peer survsamp yearnaccho yearsurvey id1998) (survresp12 peer12 survsamp12 yearnaccho12 yearsurvey12 id199812)
sort nacchoid
save a, replace

use nlsphs_980612, clear
keep if yearsurv06==1
count
rename (survresp peer survsamp yearnaccho yearsurvey id1998) (survresp06 peer06 survsamp06 yearnaccho06 yearsurvey06 id199806)
sort nacchoid
save b, replace

use nlsphs_980612, clear
keep if yearsurv98==1
count
rename (survresp peer survsamp yearnaccho yearsurvey id1998) (survresp98 peer98 survsamp98 yearnaccho98 yearsurvey98 id199898)

duplicates list nacchoid
sort nacchoid

quietly by nacchoid: gen dup=cond(_N==1,0,_n) 
list nacchoid id1998 id2006 id2012 if dup>1
save tbd, replace
drop if dup==2

sort nacchoid

save c, replace


merge nacchoid using b
drop _merge

sort nacchoid

merge nacchoid using a
count
drop _merge
sort nacchoid
save cba, replace

use tbd, clear
keep if dup==2
save tbd1, replace

/*
use cba, clear

sort nacchoid

save nlsphs_panel980612, replace
*/

use "X:\xDATA\NLSPHS 2014\Analysis\NLSPHS_full_wts_adj.dta", clear

duplicates list nacchoid unid
duplicates list nacchoid
br if nacchoid=="MN046" | nacchoid=="NJXXX"

drop if Arm==1 & (nacchoid=="MN046" | nacchoid=="NJXXX" )
drop if nacchoid==""

sort nacchoid

merge nacchoid using cba
append using tbd1
rename peer peer_large

