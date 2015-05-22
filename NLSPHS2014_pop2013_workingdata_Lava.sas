/*Runs sas code from another sas file and creates the formatted dataset for the NLSPHS2014 survey*/

%include 'X:\xDATA\NLSPHS 2014\Analysis\Github\NLSPHS\NLSPHS_lava_working.sas';
/* 
*All corrections for paper form are verified in REDCap so no need to run this following sas code file;
%include 'X:\xDATA\NLSPHS 2014\Analysis\Github\NLSPHS\corection_from_verification.sas';
*/

data NLSPHS10 ;
set NLSPHS9;
run;


proc print data=NLSPHS10;
var unid nacchoid lhdname2014 state2014;
where nacchoid="";
run;



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

proc sort data=nlsphs10;
by nacchoid;
proc sort data=naccho2013;
by nacchoid;
run;

data NLSPHSPOP13;
merge nlsphs10 naccho2013;
by nacchoid;
run;

data NLSPHSPOP13;
set NLSPHSPOP13;
where unid ne .;
run;

PROC IMPORT OUT= WORK.POPMISS13 
            DATAFILE= "X:\xDATA\NLSPHS 2014\Analysis\nlsphs2014population_full.csv" 
            DBMS=CSV REPLACE;
     GETNAMES=YES;
     DATAROW=2; 
RUN;

data popmiss13 (rename=(nacchoid=TBD_nacchoid pop13=TBD_pop13));
set popmiss13;
run;

proc sort data=popmiss13;
by unid;
proc sort data=nlsphspop13;
by unid;
run;

data a;
merge nlsphspop13 popmiss13;
by unid;
run;

data nlsphspop13 (drop=TBD_:);
set a;
if c0population=. then do;
c0population=TBD_pop13;
end;
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
            DATAFILE= "X:\xDATA\NLSPHS 2014\Analysis\NLSPHS2014popmiss.xlsx" 
            DBMS=EXCEL REPLACE;
     RANGE="NLSPHS2014POPMISS$"; 
     GETNAMES=YES;
     MIXED=NO;
     SCANTEXT=YES;
     USEDATE=YES;
     SCANTIME=YES;
RUN;

data NLSPHS2014popmiss (keep=nacchoid unid lhdname2014 city2014 state2014 zip2014 misspop_uscb jurisdiction_included);
set NLSPHSPOP13;
misspop_uscb=.;
jurisdiction_included="";
where c0population=.;
run;

PROC EXPORT DATA= WORK.NLSPHS2014popmiss
            OUTFILE= "X:\xDATA\NLSPHS 2014\Analysis\NLSPHS2014popmiss.xlsx" 
            DBMS=EXCEL REPLACE;
RUN;

/*Update the field for population from US Census data*/

PROC IMPORT OUT= WORK.NLSPSH2014mispop 
            DATAFILE= "X:\xDATA\NLSPHS 2014\Analysis\NLSPHS2014popmiss.xlsx" 
            DBMS=EXCEL REPLACE;
     RANGE="NLSPHS2014POPMISS$"; 
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
            OUTFILE= "X:\xDATA\NLSPHS 2014\Analysis\data\nlsphs2014population.csv" 
            DBMS=CSV REPLACE;
RUN;

/*Subsetting data by large and small jurisdiction*/

data lava.NLSPHS2014_LARGE;
set NLSPHS2014_FINAL1;
where arm=1;
run;

data lava.NLSPHS2014_SMALL;
set NLSPHS2014_FINAL1;
where arm ne 1;
run;















