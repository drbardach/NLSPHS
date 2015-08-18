/*Bringing in previous waves of NLSPHS data*/
use "X:\xDATA\NLSPHS 2014\nlsphs_tot.dta", clear
keep nacchoid survresp survsamp yearnaccho yearsurvey id1998 id2006 id2012 unid peer lhdn*
tab1 survresp yearsurvey
tab survresp yearsurvey

sort id1998 id2012
by id1998 id2012: gen nacchoid_rec = nacchoid[_n+1] 
replace nacchoid_rec=nacchoid if nacchoid_rec==""

*CHECK FRM HERE
gsort -id1998 -nacchoid_rec

*Checking if we have same ids for missing nacchoid_rec so that we can use "ill down" approach for missingness
gen test=id1998[_n-1] if nacchoid_rec==""
gen check=1 if id1998==test & nacchoid_rec==""
replace check=0 if id1998!=test & nacchoid_rec==""
tab check

carryforward nacchoid_rec, gen(nacchoid_rec1)
gsort -id1998 -nacchoid_rec
replace nacchoid_rec1=nacchoid if _n>=948

replace nacchoid=nacchoid_rec1 

drop nacchoid_rec nacchoid_rec1

sort nacchoid

gen yearsurv98=1 if yearsurvey==1998 & survresp!=.
replace yearsurv98=0 if yearsurv98==.
gen yearsurv06=1 if yearsurvey==2006 & survresp!=.
replace yearsurv06=0 if yearsurv06==.
/*
gen yearsurv12=1 if yearsurv06==1 
replace yearsurv12=0 if yearsurv12==. 

replace survresp=1 if yearsurvey==2012
*/

save nlsphs_tot, replace

keep if yearsurv98==1
tab survresp

/*

. tab survresp

  Responded |
    to Mays |
     survey |
    (1=yes) |      Freq.     Percent        Cum.
------------+-----------------------------------
          0 |        143       28.77       28.77
          1 |        354       71.23      100.00
------------+-----------------------------------
      Total |        497      100.00



*/
drop id2012 yearsurv06 id2006
save nlsphs_1998, replace

use nlsphs_tot, clear
keep if yearsurv06==1
tab survresp
/*

. tab survresp

  Responded |
    to Mays |
     survey |
    (1=yes) |      Freq.     Percent        Cum.
------------+-----------------------------------
          0 |        118       33.33       33.33
          1 |        236       66.67      100.00
------------+-----------------------------------
      Total |        354      100.00


*/
drop yearsurv98 id2012 id1998 

save nlsphs_2006, replace

use nlsphs_tot, clear

keep if yearsurvey==2012 | yearsurv06==1
keep nacchoid yearsurv06

duplicates list nacchoid
quietly by nacchoid: gen dup=cond(_N==1,0,_n)

drop if dup>=2

sort nacchoid
save year06_trunc, replace

use nlsphs_tot, clear
keep if yearsurvey==2012
sort nacchoid
duplicates list nacchoid
quietly by nacchoid: gen dup=cond(_N==1,0,_n)
drop if dup==2
sort nacchoid
merge nacchoid using year06_trunc
drop lhdnm06 lhdname lhdnm12 dup _merge test check

gen yearsurv12=1 

replace survresp=0 if survresp==.

tab survresp
replace yearsurvey=2012 if yearsurvey==.
replace yearnaccho=2010
drop yearsurv98 yearsurv06 id2006 id1998
save nlsphs_2012, replace
gen TBD=1

tab survresp

keep if survresp==0

save "X:\xDATA\NLSPHS 2014\Analysis\data\NLSPHS_2012_noresp.dta", replace


/*

*/










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

