data leaves;
	infile '/folders/myfolders/data source/hw5/leaf.csv' dlm=',';
	input Species SpecimenNumber Eccentricity AspectRatio Elongation Solidity StochasticConvexity IsoperimetricFactor MaximalIndentationDepth Lobedness AverageIntensity AverageContrast Smoothness ThirdMoment Uniformity Entropy;
run;

proc print data=leaves;
run;

*Exercise 1;
*(a)(b);
proc princomp data= leaves;
	var Eccentricity--Entropy;
	id Species;
run;

*(c);
proc princomp data= leaves plots= score(ellipse ncomp=3);
   var Eccentricity--Entropy;
   id Species;
   ods select ScorePlot;
run;

*Exercise 2;
proc princomp cov data= leaves;
	var Eccentricity--Entropy;
	id Species;
run;

proc princomp cov data= leaves plots= score(ellipse ncomp=2);
   var Eccentricity--Entropy;
   id Species;
   ods select ScorePlot;
run;

*Exercise 3 ;
proc cluster data= leaves method= average ccc pseudo std outtree=ex3;
   var Eccentricity--Entropy ; 
   where Species <=8;
   copy species;
run;

proc print data=ex3;
run;

*choose 8 clusters;

proc tree data=ex3 n=8 out=clusters;
	copy Species ;
run;

proc print data=clusters;
run;

proc freq data=clusters;
  tables cluster*species/ nopercent norow nocol;
run;

