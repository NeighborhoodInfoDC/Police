/**************************************************************************
 Program:  Read_crimes_2010.sas
 Library:  Police
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  05/01/11
 Version:  SAS 9.1
 Environment:  Windows
 
 Description:  Read in preliminary crime report data from MPD.
 
 Modifications:
**************************************************************************/

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";

** Define libraries **;
%DCData_lib( Police )

%Read_crimes(
  year = 2010
)


libname save "D:\DCData\Libraries\Police\Data\Save";

proc compare base=Save.Crimes_2010 compare=Police.Crimes_2010 maxprint=(40,32000);
  id reportdate start_time;
  run;

