/**************************************************************************
 Program:  Read_crimes_2000.sas
 Library:  Police
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  12/08/06
 Version:  SAS 8.2
 Environment:  Windows
 
 Description:  Read in preliminary crime report data from MPD.
 
 Must open Excel workbook Clean_2000.xls before running program.

 Modifications:
**************************************************************************/

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";

** Define libraries **;
%DCData_lib( Police )

options nospool;

%Read_crimes(
  path = D:\DCData\Libraries\Police\Raw\05-26-2006,
  year = 2000
)


libname save "D:\DCData\Libraries\Police\Data\Save";

proc compare base=Save.Crimes_2000 compare=Police.Crimes_2000 maxprint=(40,32000);
  id reportdate start_time;
  run;

