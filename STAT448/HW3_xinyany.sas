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



/*### Exercise 2 ###*/
data heart; set sashelp.heart;
	where status='Alive';
	if (weight=. or cholesterol=. or diastolic=. or chol_status=' ' or systolic=.) then delete;
	keep weight diastolic systolic cholesterol bp_status weight_status;
run;

