*Overall response rate
use "X:\xDATA\NLSPHS 2014\Analysis\NLSPHS_full_wts_adj.dta", clear

tab responded

/*

. tab responded

  responded |      Freq.     Percent        Cum.
------------+-----------------------------------
          0 |        528       50.14       50.14
          1 |        525       49.86      100.00
------------+-----------------------------------
      Total |      1,053      100.00


*/
*For Arm==1 with cohort size==497 from those who were surveyed in 1998 
tab responded if  Arm==1

/*

. tab responded if  Arm==1

  responded |      Freq.     Percent        Cum.
------------+-----------------------------------
          0 |        212       42.66       42.66
          1 |        285       57.34      100.00
------------+-----------------------------------
      Total |        497      100.00


*/
*For Arm==1 with cohort size==354 from those who responded to 2006
disp 285/354*100

/*
. disp 285/354*100
80.508475


*/

tab responded if  Arm==2

/*
. tab responded if  Arm==2

  responded |      Freq.     Percent        Cum.
------------+-----------------------------------
          0 |        296       57.93       57.93
          1 |        215       42.07      100.00
------------+-----------------------------------
      Total |        511      100.00


*/
tab responded if Arm==3

/*
. tab responded if Arm==3

  responded |      Freq.     Percent        Cum.
------------+-----------------------------------
          0 |         20       44.44       44.44
          1 |         25       55.56      100.00
------------+-----------------------------------
      Total |         45      100.00


*/
