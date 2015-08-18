/*Use StatTransfer to convert NLSPHS14_Arm23_FIPS_for_Clustering_final.dta into sas data file*/

libname ref "X:\xDATA\NLSPHS 2014\Analysis\data";

data SMALLJURIS;
set ref.Nlsphs14_clustering_final;
where nacchoid ne "";
run;

proc freq data=SMALLJURIS;
tables arm;
run;

proc print data=SMALLJURIS;
var nacchoid pop13 LHD_Name Area State2014;
where pop13=.;
run;

/*Fillin the population from Census.gov*/

data SMALLJURIS;
set SMALLJURIS;
if pop13=. then do;
if nacchoid="CT091" then pop13=11320;
if nacchoid="CT098" then pop13=11928;
if nacchoid="CT102" then pop13=2979;
if nacchoid="CT109" then pop13=55046;
if nacchoid="CT110" then pop13=6906;
if nacchoid="IL046" then pop13=38243;
end;
run;

libname clus "X:\xDATA\NLSPHS 2014\Analysis";

data A (keep=nacchoid region popcat pop13);
set clus.NLSPHS2014_SMALL;
where nacchoid ne "";
run;

proc sort data=A;
by nacchoid;
proc sort data=SMALLJURIS;
by nacchoid;
run;

data SMALL;
merge SMALLJURIS A ;
by nacchoid;
run;

proc freq data=SMALL;
tables Arm;
run;

data usstategeo (keep=STATENAME STATECODE DIVISION REGION);
set sashelp.US_DATA;
run;

data usstategeo (rename=(STATECODE=f12424));
set usstategeo;
if region="Northeast" then region1=1; else if region="Midwest" then region1=2; else if region="South" then region1=3; else if region="West" then region1=4;
run;

data usstategeo (drop=region);
set usstategeo;
run;

proc sort data=SMALL;
by f12424;
proc sort data=usstategeo;
by f12424;
run;

data SMALL1;
merge SMALL usstategeo;
by f12424;
run;

proc freq data=SMALL1;
tables Arm;
run;

data SMALL1;
set SMALL1;
where Arm ne .;
run;

data SMALL2;
set SMALL1;
if popcat=. then do;
if  1<=pop13<10000 then popcat=1; else if 10000<=pop13<=49999 then popcat=2; else if 50000<=pop13<=99999 then popcat=3;
end;
run;



data SMALLNACCHO1;
set NLSPHS2014_SMALL;
pop13_rec=pop13;
nonwhtpct=100-f0453710;
run;

proc stdize data=SMALLNACCHO1 out=SMALLNACCHO1std method=std;
var pop13_rec nonwhtpct f0978112 f1440808 c6q84a ;
run;

%macro clus(N);
/*Cluster analysis*/
proc fastclus data=SMALLNACCHO1std out=SMALLNACCHO1clus&N.  
maxclusters=&N. maxiter=100;
var pop13_rec nonwhtpct f0978112 f1440808 c6q84a ;
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

