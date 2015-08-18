PROC IMPORT OUT= WORK.NLSPHSSMALL 
            DATAFILE= "X:\xDATA\NLSPHS 2014\Analysis\data\NLSPHS_Small_Clustering.xls" 
            DBMS=EXCEL REPLACE;
     RANGE="Sheet1$"; 
     GETNAMES=YES;
     MIXED=NO;
     SCANTEXT=YES;
     USEDATE=YES;
     SCANTIME=YES;
RUN;

data NLSPHSSMALL;
set NLSPHSSMALL;
if nacchoid="MOXXX" then do;
f0453710=96.3;
f0978112=17416;
f1440808=27.6;
end;
if nacchoid="NJXXX" then do;
f0453710=69.6;
f0978112=30803;
f1440808=9.0;
end;
if nacchoid="IL046" then do;
pop13=85390;
end;
run;

data NLSPHSSMALL;
set NLSPHSSMALL;
pctnonwh=100-f0453710;
run;

proc means data=NLSPHSSMALL n nmiss mean min max;
var pop13 f0453710 pctnonwh f0978112 f1440808 epi_direct;
run;

proc stdize data=NLSPHSSMALL out=NLSPHSSMALLstd method=std;
var pop13 f0453710 pctnonwh f0978112 f1440808 epi_direct;
run;

%macro clus(N);
/*Cluster analysis*/
proc fastclus data=NLSPHSSMALLstd out=SMALLNACCHO1clus&N.  
maxclusters=&N. maxiter=100;
var pctnonwh f0978112 f1440808 epi_direct;
run;

/*
proc freq  data=SMALLNACCHO1clus&N. ;
tables Strata*Cluster;
run;
*/

proc freq  data=SMALLNACCHO1clus&N. ;
tables Cluster;
run;

/*Checking for missingness so that we have complete data to run "PROC CANDISC" for all observation such that we can create first and second 
canonical variables and plot them to observe how the different 'number of clustering' behaves. Based on Cubic Clustering Criterion and other 
criteria from the output, this will also help us decide on choosing the number of clusters. 
*/

proc means data=SMALLNACCHO1clus&N. n nmiss ;
var pctnonwh f0978112 f1440808 epi_direct;
run;


/*Using regression method for non-monotone misssing pattern to impute missing values of clustering variables to include all observation in the subsequent plot that will be created;
proc mi data=SMALLNACCHO1clus&N. round=.9 nimpute=1 
           seed=533265 out=SMALLNACCHO1clus_&N.;
      var pop13 f0453710 pctnonwh f0978112 f1440808 epi_direct;
	  fcs reg(pop13 f0453710 pctnonwh f0978112 f1440808 epi_direct);
run;
*/

/*With more than two variables we use canonical variables created by "PROC CANDISC" to check graphical distribution of the clusters*/
proc candisc data=SMALLNACCHO1clus&N. out=Can&N. ;
var pctnonwh f0978112 f1440808 epi_direct;
class cluster;
run;

proc means data=can&N. n nmiss ;
var can1 can2 pctnonwh f0978112 f1440808 epi_direct;
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

/*The number of cluster was 6 with the optimal CCC. Thus, we will go with 6 clusters and take the data obtained
above (can6) */

proc freq data=can6;
tables cluster;
run;

data peersmall (keep=nacchoid cluster clusanalysis);
set can6;
clusanalysis=1;
run;

data small_peer (rename=(cluster=peer));
set peersmall;
label cluster=peer;
run;

proc sort data=small_peer;
by nacchoid;
proc sort data=NLSPHSSMALL;
by nacchoid;
run;

data SMALL_PEER_NLSPHS;
merge NLSPHSSMALL small_peer;
by nacchoid;
run;

data SMALL_PEER_NLSPHS;
set SMALL_PEER_NLSPHS;
state1=state0;
state=state0;
run;

data SMALL_PEER_FINAL (keep=nacchoid peer);
set SMALL_PEER_NLSPHS;
run;

PROC EXPORT DATA= WORK.SMALL_PEER_FINAL 
            OUTFILE= "X:\xDATA\NLSPHS 2014\Analysis\data\SMALL_PEER_FINAL.dta" 
            DBMS=STATA REPLACE;
RUN;
