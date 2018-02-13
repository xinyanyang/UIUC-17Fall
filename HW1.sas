* There is no data to read in or import. The iris data is already a part of SAS. ;
* So just as an example, you can print the data using the following ;
proc print data=sashelp.iris;
run;
*1.(a) get boxplot of sepallength;
proc sgplot data=sashelp.iris;
	vbox sepallength;
run;

*1.(b)get box plots for sepallength by species;
ods select ssplots;
proc univariate data=sashelp.iris plot;
	var sepallength;
	by species;
run;

* 1.(c)get basic univariate results for sepallength for all species together;
proc univariate data=sashelp.iris;
	var sepallength;
run;

* add univariate visualizations;
proc univariate data=sashelp.iris normaltest;
    var sepallength;
    histogram sepallength/normal;
    ods select Histogram GoodnessOfFit TestsForNormality;
run;

* 1.(d)get basic univariate results for sepallength by species;
proc univariate data=sashelp.iris;
	var sepallength;
	by species;
run;

* add univariate visualizations;
proc univariate data=sashelp.iris normaltest;
    var sepallength;
    by species;
    histogram sepallength/normal;
    ods select Histogram GoodnessOfFit TestsForNormality;
run;

*2.(a)location test for testing u=60;
proc univariate data=sashelp.iris mu0=60;
	var sepallength;
	ods select TestsForLocation;	
run;

*(b) location test for the third group mean whether greater than the sample mean;
proc ttest data=sashelp.iris  h0=58 sides=u;
	var sepallength;
	by species;
	ods select  ConfLimits TTests;
run;

**generate a new data set;
data new;
    set  sashelp.iris;
    if species="Virginica";
run;

proc  ttest data=sashelp.iris  h0=58 sides=u;
where species="Setosa" or species="Versicolor"; 
     var sepallength;
  ods select  ConfLimits TTests;
run;
  
  
*(c) ttest for testing if the mean of two species are the same;
proc ttest data=sashelp.iris;
	where species="Versicolor" or species="Setosa";
	var sepallength;
	class species;
run;

*3.(a)Obtain the Pearson correlation matrix for the entire data set;
proc corr data=sashelp.iris pearson spearman;
  var sepallength sepalwidth petallength petalwidth;
  ods select PearsonCorr SpearmanCorr;
run;

*(b) the corrlation matrix for each species;
proc corr data=sashelp.iris pearson spearman;
  var sepallength sepalwidth petallength petalwidth;
  ods select PearsonCorr;
  by species;
run;




