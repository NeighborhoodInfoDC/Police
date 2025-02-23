/**************************************************************************
 Program:  Read_crimes_yyyy.sas
 Library:  Police
 Project:  Urban-Greater DC
 Author:   
 Created:  
 Version:  SAS 9.4
 Environment: Local Windows session (desktop)
 
 Description:  Read in crime incident data from MPD, downloaed from
 opendata.dc.gov.
 
 Downloaded input file must be saved as
 \\sas1\DCDATA\Libraries\Police\Raw\Crime_Incidents_in_yyyy.csv
 
 Modifications:
   02/23/25 Updated for new file format for 2020 and later.
**************************************************************************/

%include "\\sas1\DCdata\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( Police )


%Read_crimes(
  year = yyyy,
  revisions = %str(Add ZIP geo var.)
)
