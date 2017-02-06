/**************************************************************************
 Program:  Add_geo_crimes_2016.sas
 Library:  Police
 Project:  NeighborhoodInfo DC
 Author:   Rob Pitingolo
 Created:  02/03/2017
 Version:  SAS 9.4
 Environment:  Windows 7
 
 Description:  Add geography variables to raw crime report data.
 Need to add: tract, cluster (tract-based), ZIP code, casey target areas, EOR.
 
 Year = 2016.

 Modifications:
**************************************************************************/

%include "L:\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( Police )
%DCData_lib( RealProp )


%Add_geo_crimes_shp( year=2016 )
