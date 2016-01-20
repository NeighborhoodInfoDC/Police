/**************************************************************************
 Program:  Read_crimes_2011.sas
 Library:  Police
 Project:  NeighborhoodInfo DC
 Author:   Rob Pitingolo
 Created:  06/01/11
 Version:  SAS 9.2
 Environment:  Windows
 
 Description:  Read in preliminary crime report data from MPD.
 
 Modifications:
**************************************************************************/

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";

** Define libraries **;
%DCData_lib( Police )

%Read_crimes(
  year = 2011
)

