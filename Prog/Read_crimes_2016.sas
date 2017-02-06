/**************************************************************************
 Program:  Read_crimes_2016.sas
 Library:  Police
 Project:  NeighborhoodInfo DC
 Author:   Rob Pitingolo
 Created:  02/03/2016
 Version:  SAS 9.4
 Environment:  Windows 7
 
 Description:  Read in preliminary crime report data from MPD.
 
 Modifications:
**************************************************************************/

%include "L:\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( Police )

%Read_crimes(
  year = 2016
)

