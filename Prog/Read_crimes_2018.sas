/**************************************************************************
 Program:  Read_crimes_2018.as
 Library:  Police
 Project:  NeighborhoodInfo DC
 Author:   Eleanor Noble
 Created:  09/06/2019
 Version:  SAS 9.4
 Environment:  Windows 7
 
 Description:  Read in preliminary crime report data from MPD.
 
 Modifications:
**************************************************************************/

%include "L:\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( Police )

%Read_crimes(
  year = 2018
)

