/**************************************************************************
 Program:  Add_geo_crimes_2009.sas
 Library:  Police
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  06/09/10
 Version:  SAS 9.1
 Environment:  Windows with SAS/Connect
 
 Description:  Add geography variables to raw crime report data.
 Need to add: tract, cluster (tract-based), ZIP code, casey target areas, EOR.
 
 Year = 2009.

 Modifications:
**************************************************************************/

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";
%include "K:\Metro\PTatian\DCData\SAS\Inc\AlphaSignon.sas" /nosource2;

** Define libraries **;
%DCData_lib( Police )
%DCData_lib( RealProp )


%Add_geo_crimes( year=2009 )


signoff;
