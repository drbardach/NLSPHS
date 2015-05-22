libname clus "X:\xDATA\NLSPHS 2014\Analysis";

data NLSPHS2014_SMALL;
set clus.NLSPHS2014_SMALL;
where nacchoid ne "";
run;

PROC IMPORT OUT= WORK.NACCHO2013 
            DATAFILE= "U:\Data\NACCHO2013\2013 Profile_id.xlsx" 
            DBMS=EXCEL REPLACE;
     RANGE="Data$"; 
     GETNAMES=YES;
     MIXED=NO;
     SCANTEXT=YES;
     USEDATE=YES;
     SCANTIME=YES;
RUN;

proc sort data=NACCHO2013;
by nacchoid;
proc sort data=NLSPHS2014_SMALL;
by nacchoid;
run;

data SMALLNACCHO;
merge NACCHO2013 NLSPHS2014_SMALL;
by nacchoid;
run;

proc freq data=NLSPHS2014_SMALL;
tables arm;
run;

data SMALLNACCHO;
set SMALLNACCHO;
where 2<=arm<=3;
run;

/*c3q15 is total expenditure; c3q16 is total revenue and c5q37 is total FTE workforce at LHD*/
data SMALLNACCHO1 (keep=nacchoid c0population c0govcat c0jurisdiction c0regcount c0state c1q8 c3q15 c3q16 c5q37 unid arm av1-av20 ef1-ef19 lhd1-lhd19 Region popcat pop13);
set SMALLNACCHO;
run;

data SMALLNACCHO1;
set SMALLNACCHO1;
percapexp=c3q15/pop13;
percaprev=c3q16/pop13;
percapfte=c5q37/pop13;
pop13_rec=pop13;
if popcat=1 and Region=1 then strata=1; 
else if popcat=1 and Region=2 then strata=2;
else if popcat=1 and Region=3 then strata=3;
else if popcat=1 and Region=4 then strata=4;
else if popcat=2 and Region=1 then strata=5;
else if popcat=2 and Region=2 then strata=6;
else if popcat=2 and Region=3 then strata=7;
else if popcat=2 and Region=4 then strata=8;
else if popcat=3 and Region=1 then strata=9;
else if popcat=3 and Region=2 then strata=10;
else if popcat=3 and Region=3 then strata=11;
else if popcat=3 and Region=4 then strata=12;
av_s=sum(of av1-av20);
ef_s=sum(of ef1-ef19);
lhd_s=sum(of lhd1-lhd19);
run;

proc stdize data=SMALLNACCHO1 out=SMALLNACCHO1std method=std;
var pop13_rec percapexp percaprev percapfte av_s ef_s lhd_s;
run;

%macro clus(N);
/*Cluster analysis*/
proc fastclus data=SMALLNACCHO1std out=SMALLNACCHO1clus&N.  
maxclusters=&N. maxiter=100;
var pop13_rec percapexp percaprev percapfte av_s ef_s lhd_s;
run;

proc freq  data=SMALLNACCHO1clus&N. ;
tables Strata*Cluster;
run;

proc freq  data=SMALLNACCHO1clus&N. ;
tables Cluster;
run;

/*Checking for missingness so that we have complete data to run "PROC CANDISC" for all observation such that we can create first and second 
canonical variables and plot them to observe how the different 'number of clustering' behaves. Based on Cubic Clustering Criterion and other 
criteria from the output, this will also help us decide on choosing the number of clusters. 

Note: AK004 looked like an outlier. Need to re-run cluster analysis without AK004 in the data.*/

proc means data=SMALLNACCHO1clus&N. n nmiss ;
var pop13_rec percapexp percaprev percapfte av_s ef_s lhd_s;
run;

/*Using regression method for non-monotone misssing pattern to impute missing values of clustering variables to include all observation in the subsequent plot that will be created*/
proc mi data=SMALLNACCHO1clus&N. round=.9 nimpute=1 
           seed=533265 out=SMALLNACCHO1clus_&N.;
      var pop13_rec percapexp percaprev percapfte av_s ef_s lhd_s;
	  fcs reg(pop13_rec percapexp percaprev percapfte av_s ef_s lhd_s);
run;

/*With more than two variables we use canonical variables created by "PROC CANDISC" to check graphical distribution of the clusters*/
proc candisc data=SMALLNACCHO1clus_&N. out=Can&N. ;
var pop13_rec percapexp percaprev percapfte av_s ef_s lhd_s;
class cluster;
run;

proc means data=can&N. n nmiss ;
var can1 can2 pop13_rec percapexp percaprev percapfte av_s ef_s lhd_s;
run;

proc freq data=can&N. ;
tables cluster;
run;


%mend;


%clus(3);
%clus(4);
%clus(5);
%clus(6);
%clus(7);
%clus(8);
%clus(9);
%clus(10);
%clus(11);
%clus(12);
%clus(13);

ods pdf file="X:\xDATA\NLSPHS 2014\Analysis\AllClusters.pdf";
%MACRO plotcan (N=);
filename gsasfile "U:\Cluster Analysis\Plots\clus&N.pdf";
goptions reset=all gaccess=gsasfile dev=pdf target=ps300 gsfmode=append;
proc sgplot data=can&N;
scatter x=can1 y=can2 / group=cluster datalabel=nacchoid;
run;

quit;
%MEND plotcan;

%macro plotit;
%do i=3 %to 13;
%plotcan (N=&i);
%end;
%mend plotit;
%plotit;
ods pdf close;



/*Dropping AK004*/

data SMALLNACCHO1_noout;
set SMALLNACCHO1;
percapexp=c3q15/pop13;
percaprev=c3q16/pop13;
percapfte=c5q37/pop13;
pop13_rec=pop13;
if popcat=1 and Region=1 then strata=1; 
else if popcat=1 and Region=2 then strata=2;
else if popcat=1 and Region=3 then strata=3;
else if popcat=1 and Region=4 then strata=4;
else if popcat=2 and Region=1 then strata=5;
else if popcat=2 and Region=2 then strata=6;
else if popcat=2 and Region=3 then strata=7;
else if popcat=2 and Region=4 then strata=8;
else if popcat=3 and Region=1 then strata=9;
else if popcat=3 and Region=2 then strata=10;
else if popcat=3 and Region=3 then strata=11;
else if popcat=3 and Region=4 then strata=12;
av_s=sum(of av1-av20);
ef_s=sum(of ef1-ef19);
lhd_s=sum(of lhd1-lhd19);
if nacchoid="AK004" then delete;
run;

proc stdize data=SMALLNACCHO1_noout out=SMALLNACCHO1std_noout method=std;
var pop13_rec percapexp percaprev percapfte av_s ef_s lhd_s;
run;

%macro clus(N);
/*Cluster analysis*/
proc fastclus data=SMALLNACCHO1std_noout out=SMALLNACCHO1_nooutclus&N.  
maxclusters=&N. maxiter=100;
var pop13_rec percapexp percaprev percapfte av_s ef_s lhd_s;
run;

proc freq  data=SMALLNACCHO1_nooutclus&N. ;
tables Strata*Cluster;
run;

proc freq  data=SMALLNACCHO1_nooutclus&N. ;
tables Cluster;
run;

/*Checking for missingness so that we have complete data to run "PROC CANDISC" for all observation such that we can create first and second 
canonical variables and plot them to observe how the different 'number of clustering' behaves. Based on Cubic Clustering Criterion and other 
criteria from the output, this will also help us decide on choosing the number of clusters. 


proc means data=SMALLNACCHO1_nooutclus&N. n nmiss ;
var pop13_rec percapexp percaprev percapfte av_s ef_s lhd_s;
run;

/*Using regression method for non-monotone misssing pattern to impute missing values of clustering variables to include all observation in the subsequent plot that will be created*/
proc mi data=SMALLNACCHO1_nooutclus&N. round=.9 nimpute=1 
           seed=533265 out=SMALLNACCHO1_nooutclus_&N.;
      var pop13_rec percapexp percaprev percapfte av_s ef_s lhd_s;
	  fcs reg(pop13_rec percapexp percaprev percapfte av_s ef_s lhd_s);
run;

/*With more than two variables we use canonical variables created by "PROC CANDISC" to check graphical distribution of the clusters*/
proc candisc data=SMALLNACCHO1_nooutclus_&N. out=Can_noout&N. ;
var pop13_rec percapexp percaprev percapfte av_s ef_s lhd_s;
class cluster;
run;

proc means data=can_noout&N. n nmiss ;
var can1 can2 pop13_rec percapexp percaprev percapfte av_s ef_s lhd_s;
run;

proc freq data=can_noout&N. ;
tables cluster;
run;


%mend;


%clus(3);
%clus(4);
%clus(5);
%clus(6);
%clus(7);
%clus(8);
%clus(9);
%clus(10);
%clus(11);
%clus(12);
%clus(13);

/*Excluding the outlier AK004, the number of cluster was still 7 or 9 with 7 having the optimal CCC. Thus, we will go with 7 clusters and take the data obtained
above (can7) */

data peersmall (keep=nacchoid unid cluster pop13_rec percapexp percaprev percapfte av_s ef_s lhd_s);
set can7;
clusanalysis=1;
run;

data small;
set clus.Nlsphs2014_small;
run;

proc sort data=peersmall;
by unid;
proc sort data=small;
by unid;
run;

data small_peer;
merge small peersmall;
by unid;
run;

proc print data=small_peer;
var unid;
where cluster=.;
run;

data clus.small_peer (rename=(cluster=peer));
set small_peer;
label cluster=peer;
run;

data small_peer;
set clus.small_peer;
run;

proc sort data=small_peer;
by peer;
run;

ods csv file="X:\xDATA\NLSPHS 2014\Analysis\data\small_peer.csv";
proc print data=small_peer;
var nacchoid lhdname2014 state2014 peer pop13_rec percapexp percaprev percapfte av_s ef_s lhd_s ;
where peer ne .;
run;
ods csv close;

