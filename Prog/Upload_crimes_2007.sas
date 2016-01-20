/**************************************************************************
 Program:  Upload_crimes_2007.sas
 Library:  Police
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  06/09/10
 Version:  SAS 9.1
 Environment:  Windows with SAS/Connect
 
 Description:  Upload crime files for 2007 and register metadata.

 Modifications:
**************************************************************************/

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";
%include "K:\Metro\PTatian\DCData\SAS\Inc\AlphaSignon.sas" /nosource2;

** Define libraries **;
%DCData_lib( Police )

%Upload_crimes( year=2007, revisions=Replace with new data downloaded from OCTO DCGIS catalog. )

run;

signoff;
