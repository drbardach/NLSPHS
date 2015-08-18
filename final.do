/*


do "X:\xDATA\NLSPHS 2014\Analysis\Github\NLSPHS\manage previous waves of data.do"

/*Final data output from this is X:\xDATA\NLSPHS 2014\Analysis\data\NLSPHS_2012_noresp.dta*/



*/

/*
Appending with previous waves
*/

use "X:\xDATA\NLSPHS 2014\Analysis\data\NLSPHS_2014_wts_adj.dta", clear
gen year=2013
gen survresp=NLSPHS_responded
gen survsamp=insamp
gen yearnaccho=year
gen yearsurvey=2014

save nlsphs_2014, replace


use "X:\xDATA\NLSPHS 2014\Analysis\data\NLSPHS_2012_noresp.dta", clear
tab survresp
save NLSPHS_2012_noresp, replace

/*
. count
  116
*/
  
/***********************************/
/*Filling in the missing nacchoids*/
use "X:\xDATA\NLSPHS 2014\nlsphs_tot.dta", clear
keep nacchoid id1998 id2006 id2012 year survresp survsamp yearnaccho yearsurvey lhdn* county_06 ptcnty_06 counties1 counties2 av1-peer
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

br id1998 id2006 nacchoid id2012 nacchoid_rec test check

carryforward nacchoid_rec, gen(nacchoid_rec1)
gsort -id1998 -nacchoid_rec
replace nacchoid_rec1=nacchoid if id1998==.

replace nacchoid=nacchoid_rec1 

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
append using NLSPHS_2012_noresp
tab survresp yearsurvey

list id1998 id2006 id2012 if id1998==1038 | id1998==2657 /*Note that there were some LHDs that splited in 2012 */
list id1998 id2006 id2012 if id1998==. & (yearsurvey==2012 & survresp==1)


/*
 

      +----------------------------+
      | id1998     id2006   id2012 |
      |----------------------------|
2703. |   1038          .       39 |
2704. |   1038          .      212 |
2705. |   1038   11494110        . |
2706. |   1038   11494110        . |
3211. |   2657   11493791        . |
      |----------------------------|
3212. |   2657   11493791        . |
3213. |   2657          .       63 |
3214. |   2657          .      165 |
      +----------------------------+


      +--------------------------+
      | id1998   id2006   id2012 |
      |--------------------------|
   2. |      .        .      193 |
   4. |      .        .      234 |
      +--------------------------+

  
 
*/

tab survresp yearsurvey

/*
 Responded |
   to Mays |   Year of Mays survey (1998 or
    survey |              2006)
   (1=yes) |      1998       2006       2012 |     Total
-----------+---------------------------------+----------
         0 |       143        118        116 |       377 
         1 |       354        236        241 |       831 
-----------+---------------------------------+----------
     Total |       497        354        357 |     1,208 

*/

append using nlsphs_2014

tab survresp yearsurvey

/*


. tab survresp yearsurvey

 Responded |
   to Mays |
    survey |     Year of Mays survey (1998 or 2006)
   (1=yes) |      1998       2006       2012       2014 |     Total
-----------+--------------------------------------------+----------
         0 |       143        118        116        528 |       905 
         1 |       354        236        241        525 |     1,356 
-----------+--------------------------------------------+----------
     Total |       497        354        357      1,053 |     2,261 



*/
replace eff1=ef1 if eff1==.
replace eff2=ef2 if eff2==.
replace eff3=ef3 if eff3==.
replace eff4=ef4 if eff4==.
replace eff5=ef5 if eff5==.
replace eff6=ef6 if eff6==.
replace eff7=ef7 if eff7==.
replace eff8=ef8 if eff8==.
replace eff9=ef9 if eff9==.
replace eff10=ef10 if eff10==.
replace eff11=ef11 if eff11==.
replace eff12=ef12 if eff12==.
replace eff13=ef13 if eff13==.
replace eff14=ef14 if eff14==.
replace eff15=ef15 if eff15==.
replace eff16=ef16 if eff16==.
replace eff17=ef17 if eff17==.
replace eff18=ef18 if eff18==.
replace eff19=ef19 if eff19==.

replace countyfull=county_06 if countyfull==""
replace countypart=ptcnty_06 if countypart==""
replace countyfull=counties1 if countyfull==""
replace countypart=counties2 if countypart==""

drop ef1-ef19 county_06 ptcnty_06 counties1 counties2

tab survresp yearsurvey
tab survresp yearsurvey, miss


drop if survresp==.
tab survresp yearsurvey

drop arm TBD responded yearsurv12 NLSPHS_responded SelecProb_TBD pw_TBD

save "X:\xDATA\NLSPHS 2014\Analysis\data\NLSPHS_98061214.dta", replace

