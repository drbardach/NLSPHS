/*Assigning weights for small jurisdiction in large-sized sample (arm=1)*/
libname ref "X:\xDATA\NLSPHS 2014\Analysis";

data smalljuris;
set ref.Nlsphs2014_small;
run;

proc sort data=smalljuris;
by region popcat;
run;

/*Getting the weights by region and popcat from small size jurisdictions*/
proc means data=smalljuris mean;
var SelectionProb SamplingWeight;
by region popcat;
output out=weights mean(SelectionProb)=SP mean(SamplingWeight)=wts;
run;

data weights (drop=region);
set weights;
region1=region*1;
run;

data weights (rename=(region1=Region_TBD));
set weights;
run;

PROC EXPORT DATA= WORK.WEIGHTS 
            OUTFILE= "X:\xDATA\NLSPHS 2014\Analysis\WTSSMALL.dta" 
            DBMS=STATA REPLACE;
RUN;

/*****************************************/

PROC IMPORT OUT= WORK.Master_Final1 
            DATAFILE= "X:\xDATA\NLSPHS 2014\Contacts\Mail merger\nlsphswithsurveylinks_Master_Final1.xls" 
            DBMS=EXCEL REPLACE;
     RANGE="Master_Updated$"; 
     GETNAMES=YES;
RUN;

data Master_Final2 ;
set Master_Final1;
if arm=2 then insamp_arm2=1; else insamp_arm2=0; 
if arm=3 then insamp_arm3=1; else insamp_arm3=0;
where arm>1;
run;

proc freq data=Master_Final2;
tables arm;
run;

proc sort data=Master_Final2;
by nacchoid;
proc sort data=smalljuris;
by nacchoid;
run;

data smalljuris_1;
merge smalljuris Master_Final2;
by nacchoid;
run;

libname ref3 "U:\NLSPHS2014";

data Sampled511a (keep=Region popcat nacchoid pop13 c0population SelectionProb SamplingWeight fpc);
set ref3.Sampled511a;
run;

proc sort data=Sampled511a;
by nacchoid;
proc sort data=Smalljuris_1;
by nacchoid;
run;

data smalljuris_2;
merge smalljuris_1 Sampled511a;
by nacchoid;
run;

/*Use census.gov to fill out the missing population for the LHDs*/
data mispopsmalljuris (keep=nacchoid unid lhdname2014 city2014 state2014 zip2014 pop13 arm);
set smalljuris_2;
where c0population=. AND pop13=.;
run;

PROC EXPORT DATA= WORK.mispopsmalljuris 
            OUTFILE= "X:\xDATA\NLSPHS 2014\Analysis\mispopsmalljuris.xls" 
            DBMS=EXCEL REPLACE;
			SHEET="data";
RUN;

PROC IMPORT OUT= WORK.mispopsmalljuris1 
            DATAFILE= "X:\xDATA\NLSPHS 2014\Analysis\mispopsmalljuris1.xls" 
            DBMS=EXCEL REPLACE;
     RANGE="data$"; 
     GETNAMES=YES;
RUN;

proc sort data=mispopsmalljuris1;
by nacchoid;
proc sort data=smalljuris_2;
by nacchoid;
run;

data smalljuris_3;
merge smalljuris_2 mispopsmalljuris1;
by nacchoid;
run;

proc print data=smalljuris_3;
where c0population=.=. ;
run;

data smalljuris;
set smalljuris_3;
run;

/*****************************************/

/*Populating missing values of region and popcat*/

data usstategeo (keep=STATENAME STATECODE DIVISION REGION);
set sashelp.US_DATA;
run;

data usstategeo (rename=(STATECODE=state2014));
set usstategeo;
if region="Northeast" then region1=1; else if region="Midwest" then region1=2; else if region="South" then region1=3; else if region="West" then region1=4;
run;

data usstategeo (drop=region);
set usstategeo;
run;

proc sort data=smalljuris;
by state2014;
proc sort data=usstategeo;
by state2014;
run;

data smalljuris1;
merge smalljuris usstategeo;
by state2014;
run;

data smalljuris1;
set smalljuris1;
where unid ne .;
run;

proc sort data=smalljuris1;
by nacchoid;
run;

data smalljuris2;
set smalljuris1;
if region=. then do;
region=region1;
end;
if popcat=. then do;
if  1<=pop13<10000 then popcat=1; else if 10000<=pop13<=49999 then popcat=2; else if 50000<=pop13<=99999 then popcat=3;
end;
if popcat=. then do;
if  1<=c0population<10000 then popcat=1; else if 10000<=c0population<=49999 then popcat=2; else if 50000<=c0population<=99999 then popcat=3;
end;
run;

data weights1 (rename=(Region_TBD=region1));
set weights;
run;

proc sort data=weights1;
by region1 popcat;
proc sort data=smalljuris2;
by region1 popcat;
run;

data smalljuris3;
merge smalljuris2 weights1;
by region1 popcat;
run;

data smalljuris4;
set smalljuris3;
if SelectionProb=. then do;
SelectionProb=SP;
SamplingWeight=wts;
end;
if popcat=.  then do;
if 100000<pop13<133038 then popcat=1; 
else if 133038<=pop13<518522 then popcat=2; 
else if pop13=>518522 then popcat=3;
end;
run;

/*
 Output from stata to assign Selection Probabilities for larger jurisdiction in this sampling frame for arm=3
. by strata, sort:	summarize SelecProb

	
				Variable	Obs        	Mean		Std.Dev.		Min			Max
					
-> strata = 1	SelecProb	25    		.6410257	0				.6410257	.6410257

-> strata = 2 	SelecProb	84        	.8659794	0				.8659794	.8659794

-> strata = 3 	SelecProb	23         	.92			0				.92			.92

-> strata = 4 	SelecProb	18    		.6428571	0				.6428571	.6428571
					
-> strata = 5 	SelecProb	34    		.7234042	0				.7234042	.7234042

-> strata = 6 	SelecProb	15        	.625		0				.625		.625
						
-> strata = 7 	SelecProb	26    		.5531915	0				.5531915	.5531915

-> strata = 8 	SelecProb	130    		.8280255	0				.8280255	.8280255

-> strata = 9 	SelecProb	51    		.8644068	0				.8644068	.8644068

-> strata = 10 	SelecProb	4        	.4			0				.4			.4
						
-> strata = 11 	SelecProb	57        	.890625		0				.890625		.890625

-> strata = 12 	SelecProb	29    		.8787879	0				.8787879	.8787879


*/


data smalljuris5;
set smalljuris4;
if SelectionProb=. then do;
if Region=2 and popcat=1 /*strata=1*/ then SelectionProb=.6410257;
else if Region=2 and popcat=2 /*strata=2*/ then SelectionProb=.8659794 ;
else if Region=2 and popcat=3 /*strata=3*/ then SelectionProb=.92 ;
else if Region=1 and popcat=1 /*strata=4*/ then SelectionProb=.6428571 ;
else if Region=1 and popcat=2 /*strata=5*/ then SelectionProb=.7234042 ;
else if Region=1 and popcat=3 /*strata=6*/ then SelectionProb=.625 ;
else if Region=3 and popcat=1 /*strata=7*/ then SelectionProb=.5531915 ;
else if Region=3 and popcat=2 /*strata=8*/ then SelectionProb=.8280255 ;
else if Region=3 and popcat=3 /*strata=9*/ then SelectionProb=.8644068 ;
else if Region=4 and popcat=1 /*strata=10*/ then SelectionProb=.4 ;
else if Region=4 and popcat=2 /*strata=11*/ then SelectionProb=.890625 ;
else if Region=4 and popcat=3 /*strata=12*/ then SelectionProb=.8787879 ;
end;
if SamplingWeight=. then do;
SamplingWeight=1/SelectionProb;
end;
run;

data smalljuris (drop=DIVISION STATENAME region1 _TYPE_ _FREQ_ SP wts Comments updated_unid region2014 Sn Survey_Link Invite_1 Invite_3 Recd1-Recd3 Paper_Scanned Remind_1-Remind_4 
wave Success_invitation Responded Return_Code Updated Updated_Exe Updated_Email student u v Point_of_Contact Last rec9 unidrec unidrec1); 
set smalljuris5;
if unid=. then delete;
if nacchoid="" then delete;
if state2 ne "" then NLSPHS_Responded=1;
run;

proc freq data=smalljuris;
tables NLSPHS_Responded;
run;

PROC EXPORT DATA= WORK.smalljuris 
            OUTFILE= "X:\xDATA\NLSPHS 2014\Analysis\NLSPHS_small_wts_adj_frm_large.dta" 
            DBMS=STATA REPLACE;
RUN;


