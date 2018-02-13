 * read in the data and create a water data set;
data water;
    infile '/folders/myfolders/data source/water.dat';
    input flag $ 1 Town $ 2-18 Mortal 19-22 Hardness 25-27;
    if flag='*' then location='north';
        else location='south';
run;
proc print data=water;
run;
* get a scatter plot of hardness vs. mortality;
proc sgplot data=water;
  scatter y=mortal x=hardness;
run;

/* get box plots of hardness and mortality using entire data.
we must first create a new variable which is constant, because proc boxplots forces us to use a grouping variable */

* use proc boxplot;
data water;
 set water;
 const=1;
run;

proc boxplot data=water;
 plot hardness*const;
 plot mortal*const;
run;

* use proc sgplot;
proc sgplot data=water;
 vbox hardness;
 run;

 proc sgplot data=water;
 vbox mortal;
 run;


/* get basic univariate results for mortality and hardness individually */
proc univariate data=water;
  var mortal hardness;
run;
* add univariate visualizations;
proc univariate data=water;
  var mortal hardness;
  histogram mortal hardness;
  probplot mortal hardness;
  * add ods statement to just grab the plots;
  ods select Histogram ProbPlot;
run;
/* one sample t tests assume an underlying normal population, 
   so should check if that assumption seems reasonable 
   if we want to use a t test for location;
   option to histogram  for general EDF tests */
proc univariate data=water;
  var mortal hardness;
  histogram mortal hardness /normal;
  probplot mortal hardness;
  ods select Histogram ProbPlot GoodnessOfFit; 
run;
* option to proc;
proc univariate data=water normal;
  var mortal hardness;
  ods select TestsForNormality;
run;
/* use both options to get a histogram and pdf, and to see difference in tests */
proc univariate data=water normal;
  var mortal hardness;
  histogram mortal hardness /normal;
  ods select Histogram GoodnessOfFit TestsForNormality;
run;
* check correlations;
proc corr data=water;
  var mortal hardness;
run;
proc corr data=water pearson spearman;
  var mortal hardness;
  ods select PearsonCorr SpearmanCorr;
run;
* scatter plots by location;
proc sgplot data=water;
  scatter y=mortal x=hardness /group=location;
run;

* univariate results by location (will need to sort by location first....);
proc sort data=water;
  by location;
run;

/* get box plots of hardness and mortality by location */

* use proc boxplot;
proc boxplot data=water;
	plot hardness*location;
	plot mortal*location;
run;
* use proc sgplot;
proc sgplot data=water;
  vbox hardenss/group=location;
run;

proc sgplot data=water;
  vbox mortal/group=location;
run;

proc univariate data=water normal;
  var mortal hardness;
  histogram mortal hardness /normal;
  probplot mortal hardness;
  by location; 
  ods select Moments BasicMeasures Histogram ProbPlot TestsForNormality;
run;
* correlations by location;
proc corr data=water pearson spearman;
  var mortal hardness;
  by location;
  ods select PearsonCorr SpearmanCorr;
run;
/* location test for mortal and hardness by geographic location with mu0=1500 45 */
proc univariate data=water mu0=1500 45 normal;
  var mortal hardness;
  by location; 
  ods select TestsForNormality TestsForLocation;
run;
/* location test for mortality ignoring geographic location */
proc univariate data=water mu0=1500;
  var mortal;
  ods select TestsForLocation;
run;
/* just the t-test using proc ttest */
proc ttest data=water h0=1500;
  var mortal;
  ods select ConfLimits TTests;
run;
/* again, this could be done by location to test the north and south samples separately */
proc ttest data=water h0=1500;
  var mortal;
  by location;
  ods select ConfLimits TTests;
run;
/* one-sided test to see if mortality is significantly greater than the null value */
proc ttest data=water h0=1500 sides=u;
  var mortal;
  by location;
  ods select ConfLimits TTests;
run;
/* t-test for equal mean mortality in each geographic location */
proc ttest data=water;
  class location;
  var mortal;
run;
/* demonstrate upper and lower tailed tests */
proc ttest data=water sides=u;
  class location;
  var mortal;
  ods select ConfLimits TTests Equality;
run;
proc ttest data=water sides=l;
  class location;
  var mortal;
  ods select ConfLimits TTests Equality;
run;
* rank sum test for calcium concentration;
proc npar1way data=water wilcoxon;
  class location;
  var hardness;
  ods exclude KruskalWallisTest;
run;
* add variable for log of hardness to data set;
data water;
  set water;
  lhardness=log(hardness);
run;

proc print data = water;
run;
* check normality assumption for entire sample 
    if we wanted to perform a test on the entire population;
proc univariate data=water normal;
	var lhardness;
	histogram lhardness;
	ods select TestsForNormality Histogram;
run;
* test by group (geographic location in this case) if 
  we want to test for group differences;
proc sort data=water;
	by location;
run;

proc univariate data=water normal;
	var lhardness;
	histogram lhardness;
	by location;
	ods select TestsForNormality Histogram;
run;
/* given the normality tests, we shouldn't trust a t-test;
   if we could trust a t-test, we could use the following
   and pick out any results of interest */ 

/* a rank based test could be used on lhardnes, but the results will be the
   same as for hardness because log will not change the order of the data values, 
   so the ranks will not change */

proc npar1way data=water wilcoxon;
   var lhardness;
   class location;
run;



