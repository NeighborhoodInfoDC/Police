/**************************************************************************
 Program:  Upload_crime_incidents_raw.sas.sas
 Library:  Police
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  08/12/12
 Version:  SAS 9.1
 Environment:  Windows with SAS/Connect
 
 Description:  Upload crime_incidents_raw_* data sets to Alpha (do
 not register).

 Modifications:
**************************************************************************/

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";
%include "K:\Metro\PTatian\DCData\SAS\Inc\AlphaSignon.sas" /nosource2;

** Define libraries **;
%DCData_lib( Police )

** Start submitting commands to remote server **;

rsubmit;

proc upload status=no
  inlib=Police 
  outlib=Police memtype=(data);
  select crime_incidents_raw_:;
run;

endrsubmit;

** End submitting commands to remote server **;

run;

signoff;
