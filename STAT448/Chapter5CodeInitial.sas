* ods html close; 
* ods preferences;
* ods html newfile=proc;
/* create the data set */
data ozkids;
	* modify path to point to your files;
	infile '/folders/myfolders/data source/ozkids.dat' dlm=' ,' expandtabs missover;
    input cell origin $ sex $ grade $ type $ days @;
	do until (days=.);
	  output;
	  input days @;
	end;
	input;
run;
/* see data */
proc print data=ozkids;
run;
/* get cell means and counts for days absent */
proc tabulate data=ozkids;
	class cell;
	var days;
	table cell,
		  days*(mean n);
run;
/* four-way cross-tabulation */
proc tabulate data=ozkids;
	class origin sex grade type;
	var days;
	table origin*sex*grade*type,
          days*(mean n);
run;
/* fit the two-way main effects model with origin and grade */
proc glm data=ozkids;
	class origin grade;
	model days = origin grade;
run;
/* switch the order of terms */
proc glm data=ozkids;
	class grade origin;
	model days = grade origin;
run;
/* add the interaction term */
proc glm data= ozkids;
	class origin grade;
	model days = origin|grade;
run;
/* switch ordering of main effects */
proc glm data= ozkids;
	class grade origin;
	model days = grade|origin;
run;

proc glm data=ozkids;
	class grade origin;
	model days = grade*origin grade origin; /* degree of freedom becomes 7 for the interaction term(total 3) */
run;
/* four-way main effects getting only Type III SS and the resulting ANOVA tables and fit statistics */
proc glm data=ozkids;
	class origin sex grade type;
	model days= origin sex grade type/ss3;
	ods select OverallANOVA FitStatistics ModelANOVA; /* origin and grade is significant*/
run;
/* get all the one-way results */ /* get some sense about which one is least significant and can be removed*/
proc anova data= ozkids;
	class origin;
	model days= origin;
run;

proc anova data= ozkids;
	class sex;
	model days= sex;
run;

proc anova data= ozkids;
	class grade;
	model days= grade;
run;

proc anova data= ozkids;
	class type;
	model days= type;
run;

/* best main effects and all interactions between them;
   get Tukey tests for least squares means and main effect means */
proc glm data=ozkids plots=diagnostics;
	class origin grade;
	model days= origin|grade;
	lsmeans origin|grade /pdiff=all cl;
	ods select OverallANOVA ModelANOVA LSMeans LSMeanDiffCL Diagnostics DiagnosticsPanel;
run;
/* consider model with all categorical variables and interactions and get the type I and type III sums of squares */
proc glm data=ozkids;
	class origin grade sex type;
	model days=origin|grade|sex|type/ss1 ss3;
	ods select ModelANOVA;
run;/* not appropriate to include all variables in one model*/



