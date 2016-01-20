/**************************************************************************
 Program:  Offense_method.sas
 Library:  Police
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  07/03/06
 Version:  SAS 8.2
 Environment:  Windows
 
 Description:  Summarize offense & method combinations in DC crime
 reports, 2000-2005.

 Modifications:
**************************************************************************/

***%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";
%include "C:\DCData\SAS\Inc\Stdhead.sas";

** Define libraries **;
%DCData_lib( Police )

data all;

  set 
    Police.Crimes_2000_dc
    Police.Crimes_2001_dc
    Police.Crimes_2002_dc
    Police.Crimes_2003_dc
    Police.Crimes_2004_dc
    Police.Crimes_2005_dc;

run;

proc freq data=all;
  tables offense * method / missing list;
  tables ui_event * event * offense * method / missing list;
  format event $2.;
  title2 'DC Crime reports, 2000-2005';
run;

