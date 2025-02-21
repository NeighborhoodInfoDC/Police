/**************************************************************************
 Program:  Read_crimes_2020.sas
 Library:  Police
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  06/27/06
 Version:  SAS 8.2
 Environment:  Windows
 
 Description:  Autocall macro to read crime report data from MPD.
 2020 vintage files and later.

 Modifications:
  11/19/06 PAT  Added remaining geographies, crime summary variables. 
  12/11/06 PAT  Added CITY geo. identifier.
                Only add geo. IDs for obs. w/valid, nonmissing blocks.
  09/17/08 PAT  Support different file format for 2007.
  06/09/10 PAT  New version for new files 2007-
  08/12/12 PAT  Added new 2010 geographies. Switched pre-2007 files from
                DDE to tab-delimited text.
**************************************************************************/

/** Macro Read_crimes - Start Definition **/

%macro Read_crimes_2020( year=, path=, revisions=New file. );

  %local MAX_ROWS ds_lbl freqvars ;

  %let MAX_ROWS = 500000;
  
  %let freqvars = SHIFT METHOD OFFENSE ward2022;

  filename xfile "&_dcdata_r_path\Police\Raw\Crime_Incidents_in_&year..csv";
  
  %let ds_lbl = Preliminary part 1 crime reports, &year, DC;

  data Crimes_input;

    infile xfile missover dsd dlm=',' firstobs=2 lrecl=1000;

    ** Input statement for 2020 or later **;
  
    input
      X
      Y
      CCN : $9. 
      REPORT_DAT : $40.
      xSHIFT : $40.
      METHOD : $40.
      OFFENSE : $40.
      Location : $80.
      XBLOCK 
      YBLOCK
      WARD : $2.
      ANC : $4.
      DISTRICT : $4.
      PSA : $4.
      NEIGHBORHOOD_CLUSTER : $12.
      BLOCK_GROUP : $12.
      CENSUS_TRACT : $8.
      VOTING_PRECINCT : $12.
      LATITUDE
      LONGITUDE
      BID : $8.
      START_DATE_orig : $40.
      END_DATE_orig : $40.
      OBJECTID
      OCTO_RECORD_ID : $20.
    ;
    
    format LATITUDE LONGITUDE 12.8;
    
    drop OCTO_RECORD_ID;
    
  run;
  
  proc sort data=Crimes_input;
    by ccn;
  run;

  ** Add block IDs using spatial merge **;

  proc mapimport out=Blocks_2020
    datafile="\\sas1\DCDATA\Libraries\OCTO\Maps\Census_Blocks_in_2020.shp";
  run;

  goptions reset=global border;

  proc ginside includeborder dropmapvars
    data=Crimes_input (keep=ccn Location block_group latitude longitude rename=(latitude=y longitude=x)) 
    map=Blocks_2020
    out=Crimes_input_ginside;
    id geocode;
  run;
  
  ** Geocode records that could not be spatially joined **;
  
  data Crimes_input_for_geocode;
  
    set Crimes_input_ginside;
    where missing( geocode );
    
    length address $40;
    
    address = 
      catx( ' ',
            scan( Location, 1 ), 
            substr( Location, index( upcase( Location ), "BLOCK OF" ) + 8 )
          );
  
  run;
  
  %DC_mar_geocode(
    geo_match=Y,
    block_match=Y,
    data=Crimes_input_for_geocode,
    out=Crimes_input_geocoded,
    staddr=address,
    zip=,
    keep_geo=GeoBlk2020,
    id=ccn,
    listunmatched=N
  )

  
    ** Combine data with blocks **;
    
    data Crimes_&year.;
    
      merge 
        Crimes_input
        Crimes_input_ginside (keep=ccn geocode rename=(geocode=GeoBlk2020) where=(not(missing(GeoBlk2020))))
        Crimes_input_geocoded (keep=ccn GeoBlk2020);
      by ccn;

      Reportdate = input( scan( REPORT_DAT, 1, ' ' ), yymmdd10. );
      Reporttime = input( scan( REPORT_DAT, 2, ' +' ), time10. );
      
      Start_date = input( scan( START_DATE_orig, 1, ' ' ), yymmdd10. );
      Start_time = input( scan( START_DATE_orig, 2, ' +' ), time10. );
      
      if not( missing( END_DATE_orig ) ) then do;
        End_date = input( scan( END_DATE_orig, 1, ' ' ), yymmdd10. );
        End_time = input( scan( END_DATE_orig, 2, ' +' ), time10. );
      end;
    
      format reportdate Start_Date End_Date MMDDYY10. reporttime Start_time End_time time8.;
    
      label 
        CCN='Criminal complaint number'
        Offense='Type of offense'
        Method='Method of crime (weapon)'
        Start_Date_orig='Original report start date + time field'
        End_Date_orig='Original report end date + time field'
        Start_Date='Report start date (USE REPORTDATE INSTEAD)'
        End_Date='Report end date (USE REPORTDATE INSTEAD)'
        Start_time='Report start time'
        End_time='Report end time'
        Shift='Shift'
        Location='Crime incident location (block/intersection)'
        district='Police district'
        PSA='MPD Police Service Area (from source data)'
        ward = 'Ward (from source data)'
        REPORT_DAT = 'Original reported date + time field'
        reportdate = 'Date of reported crime'
        reporttime = 'Time of reported crime'
        ANC = "Advisory Neighborhood Commmission (ANC, from source data)"
        BID = "Business Improvement District (from source data)"        
        BLOCK_GROUP = "Census block group (from source data)"
        CENSUS_TRACT = "Census tract (from source data)"
        LATITUDE = "Latitude of crime block"
        LONGITUDE = "Longitude of crime block"
        NEIGHBORHOOD_CLUSTER = "Neighborhood cluster (from source data)"
        OBJECTID = "ObjectID from source data"
        VOTING_PRECINCT = "Voting precinct (from source data)"
        X = "Longitude of crime block (MD State Plane, NAD 1983 meters)"
        XBLOCK = "Longitude of crime block (MD State Plane, NAD 1983 meters)"
        Y = "Latitude of crime block (MD State Plane, NAD 1983 meters)"
        YBLOCK = "Latitude of crime block (MD State Plane, NAD 1983 meters)"
    ;
             
    ** Record Number **;
     
    RecordNo = _N_;
     
    label recordno = "Record number (UI Created)";
    
    ** Year of crime report **;

    reportdate_yr = year( reportdate );
        
    ******  GEOGRAPHIES  ******;
    
    ** City **;
    
    length City $ 1;
    
    City = "1";
    
    label City = "City total";
    format City $city.;

    ** Check blocks **;
    
    if GeoBlk2020 ~= "" and put( GeoBlk2020, $blk20v. ) = "" then do;
      %err_put( msg="Invalid census block ID: " RecordNo= CCN= GeoBlk2020= )
    end;

    %Block20_to_anc02()
    %Block20_to_anc12()
    %Block20_to_bg20()
    %Block20_to_bpk()
    %Block20_to_city()
    %Block20_to_cluster_tr00()
    %Block20_to_cluster00()
    %Block20_to_cluster17()
    %Block20_to_eor()
    %Block20_to_npa19()
    %Block20_to_psa04()
    %Block20_to_psa12()
    %Block20_to_psa19()
    %Block20_to_stantoncommons()
    %Block20_to_tr00()
    %Block20_to_tr10()
    %Block20_to_tr20()
    %Block20_to_vp12()
    %Block20_to_ward02()
    %Block20_to_ward12()
    %Block20_to_ward22()
    
    ** Police district **;

    length Psa2019_district $ 2;

    if psa2019 ~= '' then psa2019_district = substr( psa2019, 1, 1 ) || 'D';
    
    ** Recoded vars **;
    
    length Shift $ 3;
    
    select ( upcase( xShift ) );
      when ( 'DAY' ) Shift = 'DAY';
      when ( 'EVENING' ) Shift = 'EVN'; 
      when ( 'MIDNIGHT' ) Shift = 'MID';
    end;

    ******  CRIME CODES  ******;

    ** Create EVENT and EVENT_N codes for types of crimes **;

    %Offense_to_event
    
    ** Create summary crime variables **;
    
    if 100 <= ui_event <= 199 then Crimes_pt1 = 1;
    else Crimes_pt1 = 0;
    
    select ( put( ui_event, uievsum. ) );
      when ( 'Homicide' ) Crimes_pt1_homicide = 1;
      when ( 'Sexual assault' ) Crimes_pt1_sexual = 1;
      when ( 'Robbery' ) Crimes_pt1_robbery = 1;
      when ( 'Aggravated assault' ) Crimes_pt1_assault = 1;
      when ( 'Burglary' ) Crimes_pt1_burglary = 1;
      when ( 'Larceny/theft' ) Crimes_pt1_theft = 1;
      when ( 'Stolen auto' ) Crimes_pt1_auto = 1;
      when ( 'Arson' ) Crimes_pt1_arson = 1;
      otherwise
        /** Not a Part 1 crime **/;
    end;
    
    array a_crimes{*} Crimes_:;
    
    do i = 1 to dim( a_crimes );
      if a_crimes{i} = . then a_crimes{i} = 0;
    end;
    
    Crimes_pt1_violent = 
      sum( Crimes_pt1_homicide, Crimes_pt1_assault, Crimes_pt1_robbery, Crimes_pt1_sexual );
    
    Crimes_pt1_property = 
      sum( Crimes_pt1_burglary, Crimes_pt1_theft, Crimes_pt1_auto, Crimes_pt1_arson );

    label
      PSA2019_district = 'MPD Police District (2019)'
      Start_Time='Report start time'
      reportdate_yr = 'Year of reported crime'
      Crimes_pt1 = "Total part 1 crimes"
      Crimes_pt1_homicide = "Homicide"
      Crimes_pt1_sexual = "Sexual assault"
      Crimes_pt1_robbery = "Robbery"
      Crimes_pt1_assault = "Aggravated assault"
      Crimes_pt1_burglary = "Burglary"
      Crimes_pt1_theft = "Larceny/theft"
      Crimes_pt1_auto = "Stolen auto"
      Crimes_pt1_arson = "Arson"
      Crimes_pt1_violent = "Violent crimes"
      Crimes_pt1_property = "Property crimes";

    drop i xShift;

  run;

  %Finalize_data_set(
    data=Crimes_&year.,
    out=Crimes_&year.,
    outlib=Police,
    label="&ds_lbl",
    sortby=ccn,
    /*******sortby=reportdate Start_Time,************/
    /** Metadata parameters **/
    revisions=%str(&revisions),
    /** File info parameters **/
    printobs=10,
    freqvars=&freqvars
  )
  
  proc freq data=Crimes_&year.;
    tables 
      event * offense * method 
      ui_event * offense * method 
      / missing list;
  run;

  proc tabulate data=Crimes_&year. format=comma12.0 missing noseps;
      where 100 <= ui_event <= 199;
      class offense ui_event;
      table all='Total' offense=' ', n='Number of Crimes' pctn='Percent of Crimes' /rts=45 box='MPD offense codes';
      table all='Total' ui_event=' ', n='Number of Crimes' pctn='Percent of Crimes' /rts=45 box='UI offense codes';
      format ui_event uievsum.;
      title2;
      title3 "Reported Part 1 Crimes, &year";
  run;

  %exit_macro:

  title2;
  
%mend Read_crimes_2020;

/** End Macro Definition **/

