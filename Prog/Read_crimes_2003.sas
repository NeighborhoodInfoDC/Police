/**************************************************************************
 Program:  Read_crimes_2003.sas
 Library:  Police
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  11/19/06
 Version:  SAS 8.2
 Environment:  Windows
 
 Description:  Read in preliminary crime report data from MPD.
 
 Must open Excel workbook Clean_2003.xls before running program.

 Modifications:
**************************************************************************/

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";
***%include "C:\DCData\SAS\Inc\Stdhead.sas";

** Define libraries **;
%DCData_lib( Police )

%Read_crimes(
  path = D:\DCData\Libraries\Police\Raw\05-26-2006,
  year = 2003
)

