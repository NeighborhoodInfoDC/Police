/**************************************************************************
 Adapted from: Prog/Offense_method.sas  (NeighborhoodInfoDC/Police)
 Original author: P. Tatian.  Summarize offense & method combinations
 in DC crime reports. The %include of the local SAS environment header
 and %DCData_lib( Police ) are removed; the per-year Police.Crimes_*
 library datasets are replaced with small in-line samples of the same
 column shape (offense, method, event, ui_event) so the SET
 concatenation and PROC FREQ cross-tabulations run self-contained.
**************************************************************************/

data crimes_2000_dc;
  length offense $ 12 method $ 8 event $ 2;
  input offense $ method $ event $ ui_event;
  datalines;
Robbery Gun 30 120
Theft 1 60 160
Burglary 1 51 150
Homicide Gun 10 102
;
run;

data crimes_2001_dc;
  length offense $ 12 method $ 8 event $ 2;
  input offense $ method $ event $ ui_event;
  datalines;
Robbery Knife 31 121
Theft 2 61 161
Robbery Fear 33 123
Burglary 2 52 151
;
run;

data crimes_2002_dc;
  length offense $ 12 method $ 8 event $ 2;
  input offense $ method $ event $ ui_event;
  datalines;
Theft 1 60 160
Robbery Gun 30 120
Homicide Knife 10 103
Theft 2 61 161
;
run;

data all;
  set
    crimes_2000_dc
    crimes_2001_dc
    crimes_2002_dc;
run;

proc freq data=all;
  tables offense * method / missing list;
  tables ui_event * event * offense * method / missing list;
  format event $2.;
  title2 'DC Crime reports, sample of 2000-2002';
run;
