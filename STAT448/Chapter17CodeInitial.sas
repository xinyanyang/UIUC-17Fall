* ods html close; 
* ods preferences;
* ods html newfile=proc;
proc print data=sashelp.iris; 
run;
* use complete linkage and show last 15 merges;
proc cluster data=sashelp.iris method= complete print=15 ;
   var sepal: petal:  ; *: means choose all predictors start with sepal;
   copy species  ;
run;
* try 3 clusters because we know there are 3 species;
proc tree noprint ncl=3 out=out ;
   copy petal: sepal: species:  ;
run;

proc print data=out;
run;
* cross-tabulation to see how well clusters match up with species;
proc freq data=out;
  tables cluster*species/ nopercent norow nocol;
run;

* use single linkage and show last 15 merges;
proc cluster data=sashelp.iris method= single print=15 ;
   var sepal: petal:  ; *: means choose all predictors start with sepal;
   copy species  ;
run;

proc tree noprint ncl=3 out=out ;
   copy petal: sepal: species:  ;
run;

proc print data=out;
run;
* cross-tabulation to see how well clusters match up with species;
proc freq data=out;
  tables cluster*species/ nopercent norow nocol;
run;

* use average linkage and show last 15 merges;
proc cluster data=sashelp.iris method= average print=15 ;
   var sepal: petal:  ; *: means choose all predictors start with sepal;
   copy species  ;
run;

proc tree noprint ncl=3 out=out ;
   copy petal: sepal: species:  ;
run;

proc print data=out;
run;
* cross-tabulation to see how well clusters match up with species;
proc freq data=out;
  tables cluster*species/ nopercent norow nocol;
run;

* (Q) See which cluster analysis result matches better or worse with Species?;



* get ccc and pseudo t^2 and F stats and diagnostic plots for average linkage case;
proc cluster data= sashelp.iris method= average ccc pseudo plots= all print= 15;
	var petal:sepal:;
	copy species;
	ods select ClusterHistory Dendrogram CccPsfAndPsTSqPlot;
run;

*ccc: peak at 2, 4, 6
pseudo F: peak at 2, 4
T: lowest at 2, 4
choose 2 or 4 clusters;

data usair;
  infile '/folders/myfolders/data source/usair2.dat' expandtabs;
  input city $16. so2 temperature factories population windspeed rain rainydays;
run;
proc print data=usair;
run;
* use univariate analysis to identify extreme observations;
proc univariate data=usair;
  var temperature--rainydays;
  id city;
  ods select ExtremeObs;
run;
*remove Chicago and Phoenix which are deemed extreme on several variables;
data usair2;
  set usair;
  if city not in('Chicago','Phoenix');
run;
* variables are on very different scales, so standardize measurements, 
If certain variable has large scale, would cause a large influence on the result like PCA using covariance;
* use complete linkage and obtain ccc values for number of clusters;
proc cluster data=usair2 method=complete ccc pseudo std outtree=complete; *std indicates standardized;
  var temperature--rainydays;
  id city;
  copy so2;
run;

proc print data= complete;
run;

*ccc: all are negative 
F: 5-7
T: 6 ;

* choose 4 clusters(textbook) for analysis and retain original variables for later analyses;
proc tree data=complete n=4 out=clusters;
	copy city so2 temperature--rainydays;
run;

proc print data=clusters;
run;

* sort by cluster so we can do analysis by cluster;
proc sort data=clusters;
	by cluster;
run;

* do means analysis on variables by cluster;
proc means data=clusters;
	var temperature--rainydays;
	by cluster;
run;

*cluster1: 
cluster2: high temperature, high precipitation
cluster3: low precipitation, low rainy days
cluster4: many factories, many popualtion;

* perform principal components analysis on cluster data to extract 2 most prominent features;
proc princomp data= clusters n=2 out=pcout; *display the first and second component;
	var temperature--rainydays;
run;
*PC1: large positive factories and population, large negative temperature and rain, cluster4;
*PC2: cluster2;

* visualize the data points in the first two principal 
  coordinates and see where the clustered values are in this space;
proc sgplot data= pcout;
scatter y=prin1 x=prin2/markerchar=cluster;
run;

* visualize the distribution of SO2 values by cluster;
proc sgplot data=clusters;
vbox so2/ category= cluster;
run;


* perform an analysis of variance on the SO2 levels as a function of cluster;
proc anova data= clusters;  *h0: all groups have same mean of SO2 ha: at least 1 group have differnent mean of So2;
class cluster;
model so2= cluster;
means cluster/hovtest cldiff tukey;
ods selct OverallANOVA CLDiffs HOVFTest;
run;

proc print data= clusters;
where cluster=4;
run;

* nonparametric tests to avoid normality assumption;
*npar1way is only for comparing two groups so we add DSDF;
proc npar1way data= clusters wilcoxon DSDF;
class cluster;
var so2;
run;
*cluster1 has large mean compared with cluster2;
*cluster1 has large mean compared with cluster3;
*we cannot generalize the result with cluster4 because there are only two sample;

*in sas, hierarchy clustering is more used but k-means is more popular;
*in k-means clustering, we set k first, (proc fastclus);

