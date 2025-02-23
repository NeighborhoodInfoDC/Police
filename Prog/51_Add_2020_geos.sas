/**************************************************************************
 Program:  51_Add_2020_geos.sas
 Library:  Police
 Project:  Urban-Greater DC
 Author:   P. Tatian
 Created:  02/22/25
 Version:  SAS 9.4
 Environment:  Local Windows session (desktop)
 GitHub issue:  51
 
 Description:  Add 2020 vintage geos to DC crime data.
   GeoBlk2020 GeoBG2020 Geo2020 Ward2022 Npa2019 Psa2019

 Modifications:
**************************************************************************/

%include "\\sas1\DCdata\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( Police )

** Import 2000 to 2020 block crosswalk **;

filename csvFile  "&_dcdata_r_path\OCTO\Maps\block_clipped_xy_Project_2000_to_2020.csv" lrecl=2000;

data Blk_xwalk_2000_2020;

  infile csvFile dsd missover firstobs=2;

  input 
    cjrTractBl : $12.
    Cnt_cjrTra : $12. 
    FullArea
    Shape_Leng
    Shape_Area
    x
    y
    OBJECTID_1
    Join_Count
    TARGET_FID
    OBJECTID
    BLKGRP : $12.
    BLOCK : $12.
    GEOID : $40.
    ;    
    
  if not( missing( cjrTractBl ) or missing( GEOID ) ); 
    
  %Octo_GeoBlk2000()
  
  length GeoBlk2020 $ 15;
  
  GeoBlk2020 = substr( GEOID, 10 );
  
  keep GeoBlk: ;

run;

proc sort data=Blk_xwalk_2000_2020 nodupkey;
  by GeoBlk2000 GeoBlk2020;
run;

%Dup_check(
  data=Blk_xwalk_2000_2020,
  by=GeoBlk2000,
  id=GeoBlk2020
)

proc sort data=Blk_xwalk_2000_2020 nodupkey;
  by GeoBlk2000;
run;

%Data_to_format(
  FmtLib=work,
  FmtName=$Blk_xwalk_00_20_f,
  Desc=,
  Data=Blk_xwalk_2000_2020,
  Value=GeoBlk2000,
  Label=GeoBlk2020,
  OtherLabel=' ',
  DefaultLen=.,
  MaxLen=.,
  MinLen=.,
  Print=N,
  Contents=N
  )


** Update crime data sets **;

/** Macro Update_crime_data - Start Definition **/

%macro Update_crime_data( ds_name=, ds_label=, ds_sort=ccn );

  data &ds_name;

    set Police.&ds_name;
    
    length GeoBlk2020 $ 15;
    
    GeoBlk2020 = put( GeoBlk2000, $Blk_xwalk_00_20_f. );
    
    label GeoBlk2020 = "Full census block ID (2000): sscccttttttbbbb";
    
    %Block20_to_bg20()
    %Block20_to_npa19()
    %Block20_to_psa19()
    %Block20_to_tr20()
    %Block20_to_ward22()
    
  run;

  %Finalize_data_set( 
    /** Finalize data set parameters **/
    data=&ds_name,
    out=&ds_name,
    outlib=Police,
    label=&ds_label,
    sortby=&ds_sort,
    /** Metadata parameters **/
    restrictions=None,
    revisions=%str(Add GeoBlk2020 GeoBG2020 Geo2020 Ward2022 Npa2019 Psa2019 geographies.),
    /** File info parameters **/
    contents=N,
    printobs=0,
    freqvars=ward2022,
    stats=
  )

  title2 "**** &ds_name - Missing Blocks/Wards";
  proc print data=&ds_name;
    where missing( ward2022 ) and not( missing( GeoBlk2000 ) );
    var GeoBlk2000 GeoBlk2020 Ward2022;
  run;
  title2;

%mend Update_crime_data;

/** End Macro Definition **/


%Update_crime_data( ds_name=Crimes_2000, ds_label="Preliminary part 1 & 2 crime reports, 2000, DC" )
%Update_crime_data( ds_name=Crimes_2001, ds_label="Preliminary part 1 & 2 crime reports, 2001, DC" )
%Update_crime_data( ds_name=Crimes_2002, ds_label="Preliminary part 1 & 2 crime reports, 2002, DC" )
%Update_crime_data( ds_name=Crimes_2003, ds_label="Preliminary part 1 & 2 crime reports, 2003, DC" )
%Update_crime_data( ds_name=Crimes_2004, ds_label="Preliminary part 1 & 2 crime reports, 2004, DC" )
%Update_crime_data( ds_name=Crimes_2005, ds_label="Preliminary part 1 & 2 crime reports, 2005, DC" )
%Update_crime_data( ds_name=Crimes_2006, ds_label="Preliminary part 1 & 2 crime reports, 2006, DC" )

%Update_crime_data( ds_name=Crimes_2007, ds_label="Preliminary part 1 crime reports, 2007, DC" )
%Update_crime_data( ds_name=Crimes_2008, ds_label="Preliminary part 1 crime reports, 2008, DC" )
%Update_crime_data( ds_name=Crimes_2009, ds_label="Preliminary part 1 crime reports, 2009, DC" )
%Update_crime_data( ds_name=Crimes_2010, ds_label="Preliminary part 1 crime reports, 2010, DC" )
%Update_crime_data( ds_name=Crimes_2011, ds_label="Preliminary part 1 crime reports, 2011, DC" )
%Update_crime_data( ds_name=Crimes_2012, ds_label="Preliminary part 1 crime reports, 2012, DC" )
%Update_crime_data( ds_name=Crimes_2013, ds_label="Preliminary part 1 crime reports, 2013, DC" )
%Update_crime_data( ds_name=Crimes_2014, ds_label="Preliminary part 1 crime reports, 2014, DC" )
%Update_crime_data( ds_name=Crimes_2015, ds_label="Preliminary part 1 crime reports, 2015, DC" )
%Update_crime_data( ds_name=Crimes_2016, ds_label="Preliminary part 1 crime reports, 2016, DC" )
%Update_crime_data( ds_name=Crimes_2017, ds_label="Preliminary part 1 crime reports, 2017, DC" )
%Update_crime_data( ds_name=Crimes_2018, ds_label="Preliminary part 1 crime reports, 2018, DC" )
%Update_crime_data( ds_name=Crimes_2019, ds_label="Preliminary part 1 crime reports, 2019, DC" )


** Compare file structures for any important inconsistencies **;

data Crimes_2020;
  set Police.Crimes_2020;
run;

%Compare_file_struct( 
  prefix = Crimes_,
  file_list =
    2000 2001 2002 2003 2004 2005 2006 2007 2008 2009
    2010 2011 2012 2013 2014 2015 2016 2017 2018 2019
    2020
)

