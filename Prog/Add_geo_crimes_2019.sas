/**************************************************************************
 Program:  Add_geo_crimes_2019.sas
 Library:  Police
 Project:  NeighborhoodInfo DC
 Author:   Ananya Hariharan
 Created:  December 21, 2020
 Version:  SAS 9.2
 Environment:  Windows 7
 
 Description:  Add geography variables to raw crime report data.
 Need to add: tract, cluster (tract-based), ZIP code, casey target areas, EOR.
 
 Year = 2019

 Modifications:
**************************************************************************/

%include "\\sas1\DCdata\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( Police )
%DCData_lib( RealProp )


%Add_geo_crimes_shp( year=2019 )
