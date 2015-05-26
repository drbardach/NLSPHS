/*
Creating a full sample of LHDs that responded to the NLSPHS

*/


* Match merge the large LHDs from NACCHO profile with that from the sampling frame used for NLSPHS2014

use "X:\xDATA\NLSPHS 2014\Contacts\Mail merger\nlsphswithsurveylinks_Master_Final1.dta", clear
keep if Arm!=1
count
tab Arm

/*


        Arm |      Freq.     Percent        Cum.
------------+-----------------------------------
          2 |        511       91.91       91.91
          3 |         45        8.09      100.00
------------+-----------------------------------
      Total |        556      100.00

	  
*/

gen insamp_arm23=1 
keep nacchoid city2014 unid region2014 state2014 zip2014 phone2014 execname2014 lname2014 title2014 title2014_rec email2014 Arm treatment insamp_arm23
duplicates list nacchoid
sort nacchoid
save nlsphs_small, replace
count

/* Now use the data of small size LHDs with adjusted wts from large LHDs obtained in SAS*/
use "X:\xDATA\NLSPHS 2014\Analysis\NLSPHS_small_wts_adj_frm_large.dta", clear
count
gen NLSPHS_responded=1 
gen region1=real(region)
drop region
rename region1 region

replace NLSPHS_responded=0 if state2==""

rename (selectionprob samplingweight arm instrument) (SelecProb_TBD pw_TBD Arm Instrument)

sort nacchoid
merge nacchoid using nlsphs_small
drop if nacchoid==""
count

tab Arm

append using "X:\xDATA\NLSPHS 2014\Analysis\NLSPHS_large_wts_adj_frm_small.dta"
drop if nacchoid==""
drop c0population _merge nlsphs_responded
replace SelecProb=SelecProb_TBD if SelecProb==.
replace pw=pw_TBD if pw==.
egen insamp=rowtotal(insamp_arm1 insamp_arm23)

replace region_txt="Northeast" if region==1
replace region_txt="Midwest" if region==2
replace region_txt="South" if region==3
replace region_txt="West" if region==4

drop region2014 nlsphs frame_arm1 insamp_arm1 insamp_arm23

tab NLSPHS_responded if Arm==1
tab NLSPHS_responded if Arm>1
tab NLSPHS_responded if Arm==2
tab NLSPHS_responded if Arm==3

replace state2014=substr(nacchoid,1,2)

levelsof state2014, local(N)
display `: word count `N''

save "X:\xDATA\NLSPHS 2014\Analysis\NLSPHS_full_wts_adj.dta", replace

/*Normalizing the weights for national estimates*/

sum pw
return list

gen wt_adj=pw/r(mean)

save "X:\xDATA\NLSPHS 2014\Analysis\NLSPHS_full_wts_adj.dta", replace
