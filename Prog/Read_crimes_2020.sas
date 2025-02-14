/**************************************************************************
 Program:  Read_crimes_2020.sas
 Library:  Police
 Project:  Urban-Greater DC
 Author:   P. Tatian
 Created:  02/12/25
 Version:  SAS 9.4
 Environment:  Local Windows session (desktop)
 GitHub issue:  48
 
 Description:  Read crime incident data from MPD.

 Modifications:
**************************************************************************/

%include "\\sas1\DCdata\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( Police )
%DCData_lib( MAR )

%Read_crimes_2020(
  year = 2020
)

run;
