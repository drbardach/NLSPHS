/*Runs sas code from another sas file and creates the formatted dataset for the NLSPHS2014 survey*/

%include 'X:\xDATA\NLSPHS 2014\Analysis\Github\NLSPHS\NLSPHS_lava_working.sas';

/*Pulling NACCHO2013 population data and creating a working data for NLSPHS2014 with population variable embedded in it*/

/*
output data: nlsphs2014population.csv
folder location: X:\xDATA\NLSPHS 2014\Analysis
*/

PROC IMPORT OUT= WORK.NACCHO2013 
            DATAFILE= "U:\Data\NACCHO2013\NACCHO2013population.xlsx" 
            DBMS=EXCEL REPLACE;
     RANGE="Data$"; 
     GETNAMES=YES;
     MIXED=NO;
     SCANTEXT=YES;
     USEDATE=YES;
     SCANTIME=YES;
RUN;

proc sort data=nlsphs9;
by nacchoid;
proc sort data=naccho2013;
by nacchoid;
run;

data NLSPHSPOP13;
merge nlsphs9 naccho2013;
by nacchoid;
run;

data NLSPHSPOP13;
set NLSPHSPOP13;
where unid ne .;
run;

/*
Checking for LHDs with missing population and create an excel file with population variable "misspop_uscb" and 
also include a column for "jurisdiction_included" so that we can aggregate populations of the component jurisdiction 
to report total population of the sampled jurisdiction. Name the file as NLSPSH2014popmiss.xlsx and save it in X:\xDATA\NLSPHS 2014\Analysis.
*/
proc print data=nlsphspop13;
var nacchoid unid lhdname2014 city2014 state2014 zip2014;
where c0population =.;
run;

PROC IMPORT OUT= WORK.NLSPSH2014mispop 
            DATAFILE= "X:\xDATA\NLSPHS 2014\Analysis\NLSPSH2014popmiss.xlsx" 
            DBMS=EXCEL REPLACE;
     RANGE="Sheet1$"; 
     GETNAMES=YES;
     MIXED=NO;
     SCANTEXT=YES;
     USEDATE=YES;
     SCANTIME=YES;
RUN;

data mispop (keep=unid misspop_uscb jurisdiction_included);
set Nlspsh2014mispop;
run;

proc sort data=Nlsphspop13;
by unid;
proc sort data=mispop;
by unid;
run;

data NLSPHS2014_;
merge NLSPHSPOP13 mispop;
by unid;
run;

data NLSPHS2014_FINAL;
set NLSPHS2014_;
if c0population =. then do;
c0population=misspop_uscb;
end;
run;

proc print data=NLSPHS2014_FINAL;
var nacchoid unid lhdname2014 city2014 state2014 zip2014;
where c0population =.;
run;

data NLSPHS2014_FINAL (rename=(c0population=pop13));
set NLSPHS2014_FINAL;
run;

data NLSPHS2014_FINAL (drop=c0: c1q: misspop_uscb jurisdiction_included);
set NLSPHS2014_FINAL;
run;

data NLSPHS2014_FINAL1 ;
set NLSPHS2014_FINAL;
format pop13 12.0;
run;

PROC EXPORT DATA= WORK.NLSPHS2014_FINAL1 
            OUTFILE= "X:\xDATA\NLSPHS 2014\Analysis\nlsphs2014population.csv" 
            DBMS=CSV REPLACE;
RUN;













