/**************************************************************************
 Program:  Read_crimes.sas
 Library:  Police
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  06/27/06
 Version:  SAS 8.2
 Environment:  Windows
 
 Description:  Autocall macro to read crime report data from MPD.

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

%macro Read_crimes( year=, path=, revisions=New file. );

  %local MAX_ROWS ds_lbl freqvars ;

  %let MAX_ROWS = 50000;

  %if &year < 2007 %then %do;
    ***filename xlsfile dde "excel|&path\[Clean_&year..xls]Sheet1!r2c1:r&MAX_ROWS.c20" lrecl=2000 notab;
    filename xlsfile "&path\Clean_&year..txt" lrecl=2000;
  %end;
  
  %if &year < 2007 %then %let ds_lbl = Preliminary part 1 & 2 crime reports, &year, DC;
  %else %let ds_lbl = Preliminary part 1 crime reports, &year, DC;

  data Crimes_&year.;

    %if &year < 2007 %then %do;
    
      ***infile xlsfile stopover dsd dlm='09'x;
      infile xlsfile stopover dsd dlm='09'x firstobs=2;
    
      ** Input statement for before 2007 **;
    
      input 
        ccn  : $9.
        offense : $40.
        method : $40.
        start_date : mmddyy.
        start_hour
        end_date : mmddyy.
        shift : $3.
        block : $80.
        location : $40.
        district : $1.
        psa : $3.
        ward : $1.
        status : $40.
        code : $2.
        reportdate : mmddyy.
        id 
        fipsstco : $5.
        tract2000 : $6.
        block2000 : $4.
        GeoBlk2000 : $15.   /** Column STFID in spreadsheet **/
      ;
      
      %let freqvars = offense method shift location status code
                      district psa2004_district 
                      city psa psa2004 psa2012 ward ward2002 ward2012 
                      anc2002 anc2012 cluster2000 cluster_tr2000 
                      zip geo2000 geo2010;
    
      format End_Date Start_Date reportdate MMDDYY10.;
    
      label 
        CCN='Criminal complaint number'
        Offense='Type of offense'
        Method='Method of crime (weapon)'
        Start_Date='Report start date (DO NOT USE - USE REPORTDATE INSTEAD)'
        Start_Hour='Report start hour'
        End_Date='Report end date (DO NOT USE - USE REPORTDATE INSTEAD)'
        Shift='Shift'
        BLOCK='Street address of crime'
        Location='Location of crime'
        district='Police district'
        PSA='MPD Police Service Area (MPD supplied, 2004)'
        ward = 'Ward (MPD supplied)'
        Status= 'Crime investigation status'
        Code='Unknown variable'
        reportdate = 'Date of reported crime'
        ID='Unknown'
        tract2000 = 'Census tract ID (MPD supplied, 2000): tttttt'
        BLOCK2000='Census block ID (MPD supplied, 2000): bbbb'
        geoblk2000='Full census block ID (2000): sscccttttttbbbb';
        
      drop fipsstco;

    %end;
    %else %if &year >= 2007 %then %do;
    
      set Police.crime_incidents_raw_&year.;

    /****
      ** Input statement for 2007 **;
    
      input 
        ccn  : $9.
        district : $1.
        psa : $3.
        offense : $40.
        method : $40.
        block : $80.
        property : $10.
        location : $40.
        reportdate : mmddyy.
        fipsstco : $5.
        tract2000 : $6.
        block2000 : $4.
        GeoBlk2000 : $15.   /** Column STFID in spreadsheet **/
      ;
      ****/
      
      %let freqvars = offense method shift geo_source city psa2004_district 
                      psa2004 psa2012 ward2002 ward2012 anc2002 anc2012 cluster2000 cluster_tr2000 
                      zip geo2000 geo2010;
      
      format reportdate MMDDYY10.;
      
      %MACRO SKIP;
      label 
        CCN='Criminal complaint number'
        Offense='Type of offense'
        Method='Method of crime (weapon)'
        /*BLOCK='Street address of crime'*/
        Location='Location of crime'
        district='Police district'
        PSA='MPD Police Service Area (MPD supplied, 2004)'
        reportdate = 'Date of reported crime'
        /*tract2000 = 'Census tract ID (MPD supplied, 2000): tttttt'*/
        /*BLOCK2000='Census block ID (MPD supplied, 2000): bbbb'*/
        geoblk2000='Full census block ID (2000): sscccttttttbbbb';
      %MEND SKIP;
        
    %end;
    %else %do;
      
      %err_mput( macro=Read_crimes, msg=Unsupported year: YEAR=&year.. )
      %goto exit_macro;
      
    %end;
      
    ** Record Number **;
     
    RecordNo = _N_;
     
    label recordno = "Record number (UI Created)";
    
    ** Year of crime report **;

    reportdate_yr = year( reportdate );
    
    ** Convert time crime occured to SAS time format **;
    
    %if &year < 2007 %then %do;    
      start_time = input( put( start_hour, z2. ) || ":00", time5. );
      format start_time TIME12.;
    %end;
    %else %do;
      start_time = .u;
    %end;
    
    
    ******  GEOGRAPHIES  ******;
    
    ** City **;
    
    length City $ 1;
    
    City = "1";
    
    label City = "City total";
    format City $city.;

    ** Check blocks **;
    
    if GeoBlk2000 ~= "" and put( GeoBlk2000, $blk00v. ) = "" then do;
      %err_put( msg="Invalid census block ID: " RecordNo= GeoBlk2000= )
    end;

    ** Add standard geographies for obs. w/valid, nonmissing blocks **;
    ** 8/12/12: Added new 2010 geographies **;
    
    if GeoBlk2000 ~= "" and put( GeoBlk2000, $blk00v. ) ~= "" then do;
    
      %Block00_to_tr00( )

      %Block00_to_tr10( )

      %Block00_to_ward02( )
      
      %Block00_to_ward12( )

      %Block00_to_psa04(  )
      
      %Block00_to_psa12(  )

      %Block00_to_anc02( )
      
      %Block00_to_anc12( )

      %Block00_to_cluster00( )
      
      %Block00_to_cluster_tr00( )
      
      %Block00_to_zip( )
      
      %Block00_to_eor( )
      
      %Block00_to_vp12( )

	  %Block00_to_bpk( )

	  %Block00_to_cluster17( )

	  %Block00_to_stantoncommons( )
      
    end;
    
    ** Use MPD/DCSTAT-supplied geographies for any missing values **;
    
    if ward2002 = '' then ward2002 = put( ward, $ward02v. );
        
    **** NOTE: INCLUDES TEMPORARY RECODE OF 2010 TO 2004 PSA CODES ($ps1004c.)
    ****       NEED TO CHANGE LATER WHEN WE UPDATE ALL THE CODES;

    if psa2004 = '' then psa2004 = put( put( put( psa, 3. ), $ps1004c. ), $psa04v. );

    %if &year >= 2007 %then %do;
      if anc2002 = '' then anc2002 = put( anc, $anc02v. );
      if cluster2000 = '' then cluster2000 = put( cluster, $clus00v. );
      if cluster_tr2000 = '' then cluster_tr2000 = put( cluster, $clus00v. );
    %end;

    ** Police district **;

    length Psa2004_district $ 2;

    if psa2004 ~= '' then psa2004_district = substr( psa2004, 1, 1 ) || 'D';

   
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
      PSA2004_district = 'MPD Police District (2004)'
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

      format
        ward2002 $ward02a.
        psa2004 $psa04a.
        reportdate mmddyy10.;

    drop i;

  run;

  %if &year < 2007 %then %do;
    filename xlsfile clear;
  %end;

  proc freq data=Crimes_&year.;
    tables 
      reportdate start_time 
      event * offense * method 
      ui_event * offense * method 
      / missing list;
    format start_time hhmm. reportdate mmyys7.;
    label reportdate = 'Date of reported crime incident - formatted as month/year';
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

  %Finalize_data_set(
    data=Crimes_&year.,
    out=Crimes_&year.,
    outlib=Police,
    label="&ds_lbl",
    sortby=reportdate Start_Time,
    /** Metadata parameters **/
    revisions=%str(&revisions),
    /** File info parameters **/
    printobs=5,
    freqvars=&freqvars
  )
  
  %exit_macro:

  title2;
  
%mend Read_crimes;

/** End Macro Definition **/

