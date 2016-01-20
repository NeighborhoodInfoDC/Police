/**************************************************************************
 Program:  Upload_crimes_2010.sas
 Library:  Police
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  05/01/11
 Version:  SAS 9.1
 Environment:  Windows with SAS/Connect
 
 Description:  Upload crime file and register metadata.

 Modifications:
**************************************************************************/

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";
%include "K:\Metro\PTatian\DCData\SAS\Inc\AlphaSignon.sas" /nosource2;

** Define libraries **;
%DCData_lib( Police )

%Upload_crimes( year=2010, revisions=New file. )

run;

signoff;
