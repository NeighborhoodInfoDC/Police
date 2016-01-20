/**************************************************************************
 Program:  Format_ps1004c.sas
 Library:  Police
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  06/09/10
 Version:  SAS 9.1
 Environment:  Windows
 
 Description:  Create format to convert 2010 to 2004 PSA numbers.

 Modifications:
**************************************************************************/

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";

** Define libraries **;
%DCData_lib( Police )

proc format library=Police;
  value $ps1004c
    '208' = '306'
    '505' = '502';
run;

proc catalog catalog=Police.formats;
  modify ps1004c (desc="Convert 2010 to 2004 PSA numbers") / entrytype=formatc;
  contents;
quit;

