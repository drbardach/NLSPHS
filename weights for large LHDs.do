* Step1: To identify the percentiles of the LHDs population based on the population categories used in small-sized jurisidiction from NACCHO2013
 
use "U:\Data\NACCHO2013\2013 Profile_id.dta", clear
recode c0population (1/9999=1) (10000/49999=2) (50000/99999=3) (100000/max=.), gen(popcat) // generates popcat variable for small size LHDs
tab popcat

/*

. tab popcat

  RECODE of |
c0populatio |
          n |
(Population |
    number) |      Freq.     Percent        Cum.
------------+-----------------------------------
          1 |        293       19.81       19.81
          2 |        857       57.94       77.76
          3 |        329       22.24      100.00
------------+-----------------------------------
      Total |      1,479      100.00

. 
end of do-file


*/
*The cumulative percentages in the result table 19.81% and 77.76% will be used in categorizing the large LHDs by population categories

* Step2: Subsetting NACCHO2013 data for large size LHDs

drop popcat
keep if c0population>99999 // Keeping only the LHDs whose population is >=100,000 from NACCHO2013
count
sort c0population


keep nacchoid c0population c0govcat c0jurisdiction c0regcount c0module c0state c1q1 c1q8 
save "X:\xDATA\NLSPHS 2014\Analysis\NACCHO13_large.dta", replace

sort nacchoid
gen naccho13=1
save naccho_large, replace

* Step3: Match merge the large LHDs from NACCHO profile with that from the sampling frame used for NLSPHS2014

use "X:\xDATA\NLSPHS 2014\Contacts\Mail merger\nlsphswithsurveylinks_Master_Final1.dta", clear
keep if Arm==1
count

sort nacchoid
gen nlsphs=1
save nlsphs_large, replace
merge nacchoid using naccho_large
rename _merge merge2
sort nacchoid
gen test=1
save sframe_large, replace
count

/*Looking for any LHDs with missing population. This might usually happen if some LHDs in the sampling frame did not respond to NACCHO2013*/

br if c0population==.

/*
Step4: Populating the missing population field using population data obtained for counties, towns and cities from US Census.gov using factfinder and quickfacts. 
A column called nacchoid was also created.

For notes and suggested citation refer to the X:\xDATA\NLSPHS 2014\Analysis\data\SAMPFRAME_MISPOP.xlsx file's "notes and citations" tab. 
*/
 
use "X:\xDATA\NLSPHS 2014\Analysis\data\SAMPFRAME_MISPOP.dta", clear
keep if nacchoid != "" //Keeping only those LHDs that had missing population. 

keep PopEst2013 nacchoid

sort nacchoid
save mispop_sframe, replace

merge nacchoid using sframe_large
replace c0population=PopEst2013 if c0population==.
count

/*
br if nlsphs==. & naccho13==. //Looking for those not in NACCHO13 and NLSPHS sampling frame
drop if nlsphs==. & naccho13==.
count
*/
*Step5: Generating a population category based on the percentiles calculated above from small size jurisdiction

gen popcat=2
_pctile c0population, p(19.81, 77.76)
return list

/* Update the list if necessary from the output

scalars:
                 r(r1) =  133038
                 r(r2) =  518522


*/

replace popcat=1 if c0population<r(r1)
replace popcat=3 if r(r2)<=c0population
tab popcat

replace state2014="OH" if nacchoid=="OH080" // OH080 had missing field for state name. OH080 has unid 302827 and will make sframe size to 630
replace state2014=c0state if state2014==""
replace lhdname2014=c1q1 if lhdname2014==""
count

count if Arm==1
count if naccho13==1
count if nlsphs==1

gen frame_arm1=1
gen insamp_arm1=1 if nlsphs==1
replace insamp_arm1=0 if insamp_arm1==.

sort state2014

save nlsphsnaccho_large, replace
count // This count will give the number of LHDs in sampling frame for arm=1

*Step6: Pulling information about US Regions to create strata similar to the strata created for small size LHDs

use "X:\xDATA\NLSPHS 2014\Analysis\USSTATEREGIONS.dta", clear
rename statecode state2014
sort state2014
save usstreg, replace

use nlsphsnaccho_large, clear
rename _merge _merge1
merge state2014 using usstreg
drop if frame_arm1==.
count

gen strata=.


replace strata=1 if region=="Midwest" & popcat==1
replace strata=2 if region=="Midwest" & popcat==2
replace strata=3 if region=="Midwest" & popcat==3
replace strata=4 if region=="Northeast" & popcat==1
replace strata=5 if region=="Northeast" & popcat==2
replace strata=6 if region=="Northeast" & popcat==3
replace strata=7 if region=="South" & popcat==1
replace strata=8 if region=="South" & popcat==2
replace strata=9 if region=="South" & popcat==3
replace strata=10 if region=="West" & popcat==1
replace strata=11 if region=="West" & popcat==2
replace strata=12 if region=="West" & popcat==3

drop if nacchoid==""

tab nlsphs strata, m


/*computing SelecProb=Probability of selection of an individual = (# of LHDs from NLSPHS13/Total LHDs in each strata)*/

/*




. tab nlsphs strata, m

           |                              strata
    nlsphs |         1          2          3          4          5          6 |     Total
-----------+------------------------------------------------------------------+----------
         1 |        25         84         23         18         34         15 |       497 
         . |        14         13          2         10         13          9 |       134 
-----------+------------------------------------------------------------------+----------
     Total |        39         97         25         28         47         24 |       631 


           |                              strata
    nlsphs |         7          8          9         10         11         12 |     Total
-----------+------------------------------------------------------------------+----------
         1 |        26        130         51          4         57         29 |       497 
         . |        21         27          8          6          7          4 |       134 
-----------+------------------------------------------------------------------+----------
     Total |        47        157         59         10         64         33 |       631 


           |   strata
    nlsphs |         . |     Total
-----------+-----------+----------
         1 |         1 |       497 
         . |         0 |       134 
-----------+-----------+----------
     Total |         1 |       631 



. 
end of do-file

Note: This table indicates that in a sampling frame of 630 large size LHDs 495 were sampled. The information is detailed for each of the strata created above.

*/

*Step7: Calculating sampling weights

/*computing SelecProb=Probability of selection of an individual from the sampling frame*/

gen SelecProb=25/39 if strata==1 & nlsphs==1
replace SelecProb=84/97 if strata==2 & nlsphs==1
replace SelecProb=23/25 if strata==3 & nlsphs==1
replace SelecProb=18/28 if strata==4 & nlsphs==1
replace SelecProb=34/47 if strata==5 & nlsphs==1
replace SelecProb=15/24 if strata==6 & nlsphs==1
replace SelecProb=26/47 if strata==7 & nlsphs==1
replace SelecProb=130/157 if strata==8 & nlsphs==1
replace SelecProb=51/59 if strata==9 & nlsphs==1
replace SelecProb=4/10 if strata==10 & nlsphs==1
replace SelecProb=57/64 if strata==11 & nlsphs==1
replace SelecProb=29/33 if strata==12 & nlsphs==1

/*computing pweights=sampling weights which is equal to the reciprocal of the probability for an individual to be sampled*/
gen pw=1/SelecProb

drop if nacchoid==""

*drop if unid == .

drop PopEst2013 Comments updated_unid region2014 Invite_1-Responded Updated-unidrec1 c0govcat-_merge1 _merge

by strata, sort: summarize SelecProb

/*

. by strata, sort: summarize SelecProb 

---------------------------------------------------------------------------------------------
-> strata = 1

    Variable |       Obs        Mean    Std. Dev.       Min        Max
-------------+--------------------------------------------------------
   SelecProb |        25    .6410257           0   .6410257   .6410257

---------------------------------------------------------------------------------------------
-> strata = 2

    Variable |       Obs        Mean    Std. Dev.       Min        Max
-------------+--------------------------------------------------------
   SelecProb |        84     .8659794           0   .8659794       .8659794

---------------------------------------------------------------------------------------------
-> strata = 3

    Variable |       Obs        Mean    Std. Dev.       Min        Max
-------------+--------------------------------------------------------
   SelecProb |        23         .92           0        .92        .92

---------------------------------------------------------------------------------------------
-> strata = 4

    Variable |       Obs        Mean    Std. Dev.       Min        Max
-------------+--------------------------------------------------------
   SelecProb |        18    .6428571           0   .6428571   .6428571

---------------------------------------------------------------------------------------------
-> strata = 5

    Variable |       Obs        Mean    Std. Dev.       Min        Max
-------------+--------------------------------------------------------
   SelecProb |        34    .7234042           0   .7234042   .7234042

---------------------------------------------------------------------------------------------
-> strata = 6

    Variable |       Obs        Mean    Std. Dev.       Min        Max
-------------+--------------------------------------------------------
   SelecProb |        15        .625           0       .625       .625

---------------------------------------------------------------------------------------------
-> strata = 7

    Variable |       Obs        Mean    Std. Dev.       Min        Max
-------------+--------------------------------------------------------
   SelecProb |        26    .5531915           0   .5531915   .5531915

---------------------------------------------------------------------------------------------
-> strata = 8

    Variable |       Obs        Mean    Std. Dev.       Min        Max
-------------+--------------------------------------------------------
   SelecProb |       130    .8280255           0   .8280255   .8280255

---------------------------------------------------------------------------------------------
-> strata = 9

    Variable |       Obs        Mean    Std. Dev.       Min        Max
-------------+--------------------------------------------------------
   SelecProb |        51    .8644068           0   .8644068   .8644068

---------------------------------------------------------------------------------------------
-> strata = 10

    Variable |       Obs        Mean    Std. Dev.       Min        Max
-------------+--------------------------------------------------------
   SelecProb |         4          .4           0         .4         .4

---------------------------------------------------------------------------------------------
-> strata = 11

    Variable |       Obs        Mean    Std. Dev.       Min        Max
-------------+--------------------------------------------------------
   SelecProb |        57     .890625            0   .890625     .890625 

---------------------------------------------------------------------------------------------
-> strata = 12

    Variable |       Obs        Mean    Std. Dev.       Min        Max
-------------+--------------------------------------------------------
   SelecProb |        29    .8787879           0   .8787879   .8787879



*/

save "X:\xDATA\NLSPHS 2014\Analysis\NLSPHS_large_wts.dta", replace


/*Adjusting the weights of large size jurisdictions whose population was <100000 in 2013*/
clear
use "X:\xDATA\NLSPHS 2014\Analysis\NLSPHS_large_wts.dta", clear
list nacchoid c0population region if c0population<100000
gen Region_TBD=1 if region=="Northeast"
replace Region_TBD=2 if region=="Midwest"
replace Region_TBD=3 if region=="South"
replace Region_TBD=4 if region=="West"
recode c0population (1/10000=1) (10000/49999=2) (50000/99999=3) (100000/max=.), gen(Popcat_TBD)
br region Region_TBD c0population Popcat_TBD if Popcat_TBD !=.
sort Region_TBD Popcat_TBD
save small, replace

/*
Reading data of weights assigned to small jurisdictions that will be used for those 27 LHDs
whose population was <100000
*/
use "X:\xDATA\NLSPHS 2014\Analysis\WTSSMALL.dta", clear
rename (region_tbd popcat) (Region_TBD Popcat_TBD)
drop if Region_TBD==.
sort Region_TBD Popcat_TBD
save wts, replace

use small,clear
merge Region_TBD Popcat_TBD using wts
replace SelecProb=sp if sp!=.
replace pw=wts if sp!=.

/*Cosntructing a second set of weights*/

gen SelectProb2=(497-27)/(631-27) if sp==.
replace SelectProb2=sp if SelectProb2==.
replace SelectProb2=. if frame_arm1==1 & insamp_arm1==0 // Weights are not assigned for LHDs not sampled 
gen pw2=1/SelectProb2 

gen small_frmarm1=Popcat_TBD>0 if !missing(Popcat_TBD)
replace small_frmarm1=0 if small_frmarm1==.

drop if nacchoid==""

keep nacchoid unid Arm frame_arm1 insamp_arm1 nlsphs SelecProb pw SelectProb2 pw2 small_frmarm1 region c0population popcat 
count

sort nacchoid

save large, replace

use "X:\xDATA\NLSPHS 2014\Analysis\NLSPHS2014_large.dta", clear
count
gen NLSPHS_responded=1
drop Region popcat SelectionProb SamplingWeight
sort nacchoid
merge nacchoid using large
duplicates list nacchoid unid
drop if unid==23309 & name_first=="Carlos" // We obtained paper response from the unid=23309 for TX007 and will use the response from it

replace pop13=c0population if pop13==.
replace NLSPHS_responded=0 if NLSPHS_responded==. & nlsphs !=.
tab NLSPHS_responded

gen region1=.
replace region1=1 if region=="Northeast"
replace region1=2 if region=="Midwest"
replace region1=3 if region=="South"
replace region1=4 if region=="West"

rename (region region1) (region_txt region)

drop if insamp_arm1==0

tab NLSPHS_responded

save "X:\xDATA\NLSPHS 2014\Analysis\NLSPHS_large_wts_adj_frm_small.dta", replace






