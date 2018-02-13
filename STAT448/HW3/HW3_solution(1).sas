* ods html close; 
** ods preferences;
** ods html newfile=proc;
options nodate nonumber;
title1 ; footnote1;
ods noproctitle;


/*### Exercise 1 ###*/
data psych;
  input sex $ rank $ salary;
cards;
F Assist 33
F Assist 36
F Assist 35
F Assist 38
F Assist 42
F Assist 37
M Assist 39
M Assist 38
M Assist 40
M Assist 44
F Assoc 42
F Assoc 40
F Assoc 44
F Assoc 43
M Assoc 43
M Assoc 40
M Assoc 49
M Assoc 47
M Assoc 48
M Assoc 51
M Assoc 48
M Assoc 45
;
run;


/* a) tabulation of salary by rank and sex */
proc tabulate data=psych;
	class sex rank;
	var salary;
	table sex*rank, salary*(mean std n);
run;
/* b) two-way model with interaction */
proc glm data=psych;
  class sex rank;
  model salary = sex|rank / ss1 ss3;
  ods select OverallANOVA ModelANOVA FitStatistics; 
run;
/* reorder terms to see Type I analysis with rank termed entered first */
proc glm data=psych;
  class sex rank;
  model salary = rank|sex / ss1;
  ods select ModelANOVA; 
run;


/* c) & d) */
proc glm data=psych plots=diagnostics;
	class sex rank;
	model salary = sex rank;
	lsmeans sex rank / adjust=Tukey cl;
	ods select ModelANOVA OverallANOVA FitStatistics LSMeans LSMeanDiffCL;;
run;


/*### Exercise 2 ###*/
data heart; set sashelp.heart;
	where status='Alive';
	if (weight=. or cholesterol=. or diastolic=. or chol_status=' ' or systolic=.) then delete;
	keep weight diastolic systolic cholesterol bp_status weight_status;
run;

*part a and b;
proc reg data=heart;
 model cholesterol =  weight;
 ods exclude FitPlot ResidualPlot ;
 output out=diagnostics2 cookd= cd2;
run;

/*Identify which observation is highly influential*/
proc print data=diagnostics2;
 where cd2 > 1; *none are greater than 1
run;

/*### Exercise 3 ###*/

*checking for multicollinearity with scatter plot matrix and vif;
proc sgscatter data=heart;
 matrix weight--systolic;
run;

*no need to assess model. Check for VIF issues, then refit the model;
proc reg data=heart plots=none; 
 model cholesterol = diastolic systolic weight / vif;
 *ods select ANOVA FitStatistics ParameterEstimates DiagnosticsPanel;
 output out=diagnostics3 cookd=cd3 ;
run;

/*Identify which observation is highly influential*/
proc print data=diagnostics3;
 where cd3 > 1; *no points are highly influential;
run;                           

*With no multicollinearity issues, we refit the model;
 
 /* ods select ANOVA FitStatistics ParameterEstimates DiagnosticsPanel 
       this ods select statement is fine, but you may want
    to show the number of observations analyzed in the data set.
           Hence you can use the ods exclude FitPlot ResidualPlot */
proc reg data=heart plots=none; 
 model cholesterol = diastolic systolic weight / vif;
 * Checking the diagnostic panel plots shows Cook's Distances all < 1;
 *output out=diagnostics3 cookd=cd3 ; *so we don't output the diagnostics3 data set;
 ods exclude FitPlot ResidualPlot ;
run;


/*### Exercise 4 ###*/
* part a;
proc reg data=heart;
 model cholesterol = diastolic systolic weight/ selection=forward sle=0.05;
 ods select SelectionSummary;
run;

* part b;
proc reg data=heart;
 model cholesterol = systolic ;
 ods exclude FitPlot ResidualPlot ;
run;
