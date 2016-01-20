/**************************************************************************
 Program:  Upload_crimes_2000_to_2005.sas
 Library:  Police
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  12/08/06
 Version:  SAS 8.2
 Environment:  Windows with SAS/Connect
 
 Description:  Upload crime files for 2000 to 2005 and register
 metadata.

 Modifications:
**************************************************************************/

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";
%include "K:\Metro\PTatian\DCData\SAS\Inc\AlphaSignon.sas" /nosource2;

** Define libraries **;
%DCData_lib( Police )

%Upload_crimes( year=2000, revisions=New file. )
%Upload_crimes( year=2001, revisions=New file. )
%Upload_crimes( year=2002, revisions=New file. )
%Upload_crimes( year=2003, revisions=New file. )
%Upload_crimes( year=2004, revisions=New file. )
%Upload_crimes( year=2005, revisions=New file. )

run;

signoff;
