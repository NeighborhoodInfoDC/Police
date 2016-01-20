/**************************************************************************
 Program:  Upload_crimes_2010.sas
 Library:  Police
 Project:  NeighborhoodInfo DC
 Author:   Rob Pitingolo
 Created:  06/01/12
 Version:  SAS 9.2
 Environment:  Windows with SAS/Connect
 
 Description:  Upload crime file and register metadata.

 Modifications:
**************************************************************************/

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";
%include "K:\Metro\PTatian\DCData\SAS\Inc\AlphaSignon.sas" /nosource2;

** Define libraries **;
%DCData_lib( Police )

%Upload_crimes( year=2011, revisions=New file. )

run;

signoff;
