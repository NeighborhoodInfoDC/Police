/**************************************************************************
 Program:  Read_crimes_2019.sas
 Library:  Police
 Project:  NeighborhoodInfo DC
 Author:   Ananya Hariharan
 Created:  December 21, 2020
 Version:  SAS 9.4
 Environment:  Windows 7
 
 Description:  Read in preliminary crime report data from MPD.
 
 Modifications:
**************************************************************************/

%include "\\sas1\DCdata\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( Police )

%Read_crimes(
  year = 2019
)

