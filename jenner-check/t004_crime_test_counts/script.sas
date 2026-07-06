/**************************************************************************
 Adapted from: Prog/Crime_test_counts.sas  (NeighborhoodInfoDC/Police)
 Original author: P. Tatian.  Quick record counts on the cleaned TCAP
 crime files. The %include of the local SAS environment header and
 %DCData_lib( Police ) are removed; the Police.tcap* library datasets
 are replaced with in-line samples of the same shape so PROC MEANS and
 PROC FREQ run self-contained. PROC MEANS is given an explicit VAR list
 of the numeric Part-1 crime counts.
**************************************************************************/

data tcap1998;
  length event $ 2;
  input recordno event $ crimes_pt1;
  datalines;
1 10 1
2 30 1
3 51 1
4 60 1
5 61 1
;
run;

data tcap2000;
  length event $ 2;
  input recordno event $ crimes_pt1;
  datalines;
1 10 1
2 20 1
3 30 1
4 31 1
5 60 1
6 70 1
;
run;

data tcap2000_raw;
  length event $ 2;
  input event $;
  datalines;
10
30
30
60
60
60
70
;
run;

proc means n sum data=tcap1998;
  var crimes_pt1;
  title2 '1998';
run;

proc means n sum data=tcap2000;
  var crimes_pt1;
  title2 '2000';
run;

proc freq data=tcap2000_raw;
  tables event;
  title2 '2000 raw event distribution';
run;
