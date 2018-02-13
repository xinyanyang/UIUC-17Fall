/* Quitting Smoking Experiment */
data quitsmoke;
	infile "/folders/myfolders/data source/hw6/smoke.dat";
	length proc$18;
	input id$ proc$ befh befw afth aftw;
	if proc='1' then proc='tapering';
	if proc='2' then proc='immediate stopping';
	if proc='3' then proc='aversion therapy';
	drop id;
run;

proc print data=quitsmoke;
run;

*Problem 1a;
proc discrim data=quitsmoke pool=test crossvalidate manova;
	class proc;
	var befh--aftw;
	priors proportional;
run;

*Problem 1b;
proc cluster data=quitsmoke method= complete print=15 ccc pseudo std plots= all outtree=complete;
   var  befh--aftw ; 
   copy proc;
   ods select ClusterHistory Dendrogram CccPsfAndPsTSqPlot;
run;

*Problem 1c;
proc tree data=complete n=3 out=clusters;
	copy proc befh--aftw;
run;

proc print data=clusters;
run;

* cross-tabulation to see how well clusters match up with species;
proc freq data=clusters;
  tables cluster*proc/ nopercent norow nocol;
run;

/* Egyptian Skulls */
data EgyptianSkulls;
	infile '/folders/myfolders/data source/hw6/skulls.dat' expandtabs;
  	input epoch mb bh bl nh;
run;

proc print data=EgyptianSkulls;
run;

*Problem 2a;
proc discrim data=EgyptianSkulls pool=test crossvalidate manova;
	class epoch;
	var mb--nh;
	priors proportional;
run;

*Problem 2b;
proc cluster data=EgyptianSkulls method= complete print=15 ccc pseudo std plots= all outtree=complete;
   var  mb--nh ; 
   copy epoch;
   ods select ClusterHistory Dendrogram CccPsfAndPsTSqPlot;
run;

*Problem 2c;
proc tree data=complete n=5 out=clusters;
	copy epoch mb--nh;
run;

proc print data=clusters;
run;

* cross-tabulation to see how well clusters match up with species;
proc freq data=clusters;
  tables cluster*epoch/ nopercent norow nocol;
run;

*Problem 3;
/* use stepwise selection to extract most significant explanatory variables */
proc stepdisc data=EgyptianSkulls sle=0.05 sls=0.05;
	class epoch;
	var mb--nh;
	ods select Summary;
run;

/* discriminant analysis with the terms chosen by stepdisc*/
proc discrim data=EgyptianSkulls pool=test crossvalidate manova;
	class epoch;
	var bl mb;
	priors proportional;  *use sample proportion for prior probability;
run;


proc cluster data=EgyptianSkulls method= complete print=15 ccc pseudo std plots= all outtree=complete;
   var  bl mb ; 
   copy epoch;
   ods select ClusterHistory Dendrogram CccPsfAndPsTSqPlot;
run;

proc tree data=complete n=5 out=clusters;
	copy epoch bl mb;
run;

* cross-tabulation to see how well clusters match up with species;
proc freq data=clusters;
  tables cluster*epoch/ nopercent norow nocol;
run;






