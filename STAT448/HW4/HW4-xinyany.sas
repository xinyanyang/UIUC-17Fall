options nodate nonumber;
title ;
ods rtf file='e:\CourseMaterials\Stat448\Homework4xinyany2.rtf' nogtitle startpage=no;
ods noproctitle;
*exercise 1;
proc import datafile="/folders/myfolders/hw4/Indian Liver Patient Dataset (ILPD).csv"
	out= liver
	dbms = csv
	replace;
	getnames=no;
run;
/* after importing, rename the variables to match the data description */
data liver;
	set liver;
	Age=VAR1; Gender=VAR2; TB=VAR3;	DB=VAR4; Alkphos=VAR5;
	Alamine=VAR6; Aspartate=VAR7; TP=VAR8; ALB=VAR9; AGRatio=VAR10;
	if VAR11=1 then LiverPatient='Yes';
		Else LiverPatient='No';
	drop VAR1--VAR11;
run;
* now only keep the adult observations;
data liver;
	set liver;
	where age>17;
run;
* Exercise 1: females;
proc logistic data = liver desc plots=influence;
	where Gender = "Female";
	class LiverPatient;
	model LiverPatient = Age TB--AGRatio / selection = stepwise;
	output out=diagnosticsF cbar=cbar;
	ods select ModelBuildingSummary InfluencePlots;
run;
proc logistic data = liver desc;
	where Gender = "Female";
	model LiverPatient = Aspartate/ lackfit;
	ods select FitStatistics GlobalTests LackFitChiSq ParameterEstimates OddsRatios;
run;
* Exercise 2: males;
proc logistic data = liver desc plots=influence;
	where Gender = "Male";
	model LiverPatient = Age TB--AGRatio / selection = stepwise;
	output out=diagnosticsM cbar=cbar;
	ods select ModelBuildingSummary InfluencePlots;
run;

proc logistic data = diagnosticsM desc plots=influence;
	where Gender = "Male" and cbar<.5;
	model LiverPatient = Age TB--AGRatio / selection = stepwise;
	ods select ModelBuildingSummary InfluencePlots;
run;

/*
proc logistic data = diagnosticsM desc plots=influence;
	where Gender = "Male" and cbar<.5;
	model LiverPatient = Age DB Alamine AGRatio;
	ods select InfluencePlots;
run;
*/

proc logistic data = diagnosticsM desc plots=influence;
	where Gender = "Male" and cbar<.5;
	model LiverPatient = Age DB Alamine AGRatio/ lackfit;
	ods select FitStatistics GlobalTests LackFitChiSq ParameterEstimates OddsRatios InfluencePlots;
run;

* Exercise 3;
data hyper;
  * modify path to point to your files;
  infile '/folders/myfolders/hw4/hypertension.dat';
  input n1-n12;
  if _n_<4 then biofeed='P';
           else biofeed='A';
  if _n_ in(1,4) then drug='X';
  if _n_ in(2,5) then drug='Y';
  if _n_ in(3,6) then drug='Z';
  array nall {12} n1-n12;
  do i=1 to 12;
      if i>6 then diet='Y';
                 else diet='N';
	  bp=nall{i};
      output;
  end;
  drop i n1-n12;
run;
* part a -- gamma model with log link;
proc genmod data=hyper plots=(stdreschi stdresdev);
	class drug diet biofeed;
	model bp = drug diet biofeed/ dist=gamma link=log type1 type3;
	output out = gammares pred = predbp stdreschi = schires;
	ods select ModelInfo ParameterEstimates Type1 Type3 DiagnosticPlot;
run;
proc sgplot data=gammares;
	scatter y=schires x=predbp;
run;
* proc sgplot ;
* part b -- overdispersed Poisson model with deviance scale;
proc genmod data=hyper plots=(stdreschi stdresdev);
	class drug diet biofeed;
	model bp = drug diet biofeed/ dist=poisson link=log 
				scale=d type1 type3;
	output out = poisres pred = predbp stdreschi = schires;
	ods select ModelInfo ParameterEstimates Type1 Type3 DiagnosticPlot;
run;
proc sgplot data=poisres;
	scatter y=schires x=predbp;
run;
* part c -- ;
* refers to previous to models and model from Chapter 4, 
  so code is not necessary;

proc freq data=hyper;
	tables drug*diet*biofeed/ norow nocol nopercent;
run;
  
proc glm data=hyper;
  class drug diet biofeed;
  model bp = drug diet biofeed;
  output out=diagnostics2 cookd= cd2;
  ods select OverallANOVA ModelANOVA FitStatistics; 
run; 

proc print data=diagnostics2;
 where cd2 > 1; *none are greater than 1

ods rtf close;
