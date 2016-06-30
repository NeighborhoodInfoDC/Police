/**************************************************************************
 Program:  Add_geo_crimes_yyyy.sas
 Library:  Police
 Project:  NeighborhoodInfo DC
 Author:   Mychal Cohen
 Created:  06/30/2016
 Version:  SAS 9.2
 Environment:  Windows 7
 
 Description:  Add geography variables to raw crime report data.
 Need to add: tract, cluster (tract-based), ZIP code, casey target areas, EOR.
 
 Year = yyyy.

 Modifications:
**************************************************************************/

%include "L:\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( Police )
%DCData_lib( RealProp )


%Add_geo_crimes_shp( year=yyyy )
