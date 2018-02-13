/*Question 1*/
data diy;
infile '/folders/myfolders/data source/hw2/diy.dat' expandtabs;
  input y1-y6 / n1-n6;
  array yall {6} y1-y6;
  array nall {6} n1-n6;
  do i=1 to 6;
    agegrp='younger';
	if i in(3,6) then agegrp='older';
    yes=yall{i};
	no=nall{i};
	output;
  end;
  drop i y1--n6;
/* after the following modification, the data set will contain:
  	agegrp (groups 1 and 2 from the text are the younger group, 
  		and group 3 is the older group)
  	response (yes or no answer to question about whether the individual 
  		hired someone to do home improvements they would have previously 
  		done themseleves
  	n (count variable)
*/
data diy;
	set diy;
	response = 'yes'; n = yes; output;
    response = 'no'; n = no; output;
	drop no yes;
run;

proc print data= diy;
run;

/* get counts and proportion*/
proc freq data= diy;
	tables agegrp*response/nopercent norow nocol;
	weight n;
run;

/*perform tests of association*/
proc freq data= diy;
	tables agegrp*response/nopercent norow nocol expected chisq;
	weight n;
run;

/*Question2 */
data crime100;
    infile '/folders/myfolders/data source/hw2/uscrime.dat' expandtabs;
    input R Age S Ed Ex0 Ex1 LF M N NW U1 U2 W X;
	if R>100 then Greater100 = 'yes';
	if R<=100 then Greater100 = 'no';
	If S = 1 then South = 'yes';
	if S = 0 then South = 'no';
	keep greater100 South;
run;

proc print data= crime100;
run;

/* get contingency table*/
proc freq data= crime100;
	tables Greater100*South/nopercent norow nocol expected;
run;

/*perform tests of association*/
proc freq data= crime100;
	tables Greater100*South/nopercent norow nocol expected chisq;
run;

/* test riskdifferences */
proc freq data= crime100;
	tables South*Greater100 /nopercent norow nocol riskdiff;
run;

/* Question3 */
data bupa;
	infile '/folders/myfolders/data source/hw2/bupa.data' dlm=',';
	input mcv alkphos sgpt sgot gammagt drinks selector;
	drinkgroup = 1;
	If 1<=drinks<3 then drinkgroup = 2;
	If 3<=drinks<6 then drinkgroup = 3;
	If 6<=drinks<9 then drinkgroup = 4;
	If 9<=drinks then drinkgroup =5;
	drop sgpt sgot gammagt drinks selector;
run;

proc print data=bupa;
run;

/* 3(a) */
proc univariate data= bupa;
	var mcv;
run; /* the sample median is 90 */

/* add grouping variables that indicate whether mcv are greater than sample median*/
data bupa;
	set  bupa;
	mcvgrp=mcv >= 90;
run;
proc print data=bupa;
run;

proc freq data= bupa;
	tables mcvgrp*drinkgroup/ nopercent norow nocol expected chisq;
run;

/* perform a one-way ANOVA for mcv as a function of drinking group and test the equal variance*/
proc anova data=bupa;
	class drinkgroup;
	model mcv = drinkgroup;
	means drinkgroup / hovtest tukey cldiff;
run;

/* perform a one-way ANOVA for alkphos as a function of drinking group and test the equal variance*/
proc anova data=bupa;
	class drinkgroup;
	model alkphos = drinkgroup;
	means drinkgroup / hovtest tukey cldiff;
run;





