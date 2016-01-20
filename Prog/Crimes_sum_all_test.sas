/**************************************************************************
 Program:  Crimes_sum_all.sas
 Library:  Police
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  12/08/06
 Version:  SAS 8.2
 Environment:  Windows with SAS/Connect
 
 Description:  Summarize crime data by all geographies.

 Modifications:
  01/04/06  Added Census 2000 population (Crime_rate_pop) for calculating 
            crime rates.
  06/09/10  Updated 2007 with new data from OCTO DCGIS.
  06/09/10  Added data for 2008 and 2009.
  05/01/11  Added data for 2010.
  05/04/11  Use interpolated population counts between 2000 and 2010 for
            Crime_rate_pop_*, rather than 2000 counts only.
            Dropped Casey neighborhood summary levels.
**************************************************************************/

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";
/***%include "K:\Metro\PTatian\DCData\SAS\Inc\AlphaSignon.sas" /nosource2;***/

** Define libraries **;
%DCData_lib( Police )
%DCData_lib( NCDB )

/***************** MACRO TESTING ******************/
filename MacTest 'D:\DCData\SAS\Macros\Test';
%MacroSearch( cat=MacTest, action=B )
/**************************************************/

/***rsubmit;***/

%let revisions = Added estimated population totals for 2000-2010.;
%let register = N;
%let end_yr = 2010;
/*%LET END_YR = 2000;  /*** TESTING ***/

/** Macro Crimes_sum_geo - Start Definition **/

%macro Crimes_sum_geo( geo=, start_yr=2010, end_yr=, revisions=, register=N );

  %local sum_vars sum_vars_wc geosuf geodlbl geofmt i var;

  %let register = %upcase( &register );

  %let sum_vars = 
    Crimes_pt1 Crimes_pt1_homicide Crimes_pt1_sexual
    Crimes_pt1_robbery Crimes_pt1_assault Crimes_pt1_burglary
    Crimes_pt1_theft Crimes_pt1_auto Crimes_pt1_arson
    Crimes_pt1_violent Crimes_pt1_property
  ;

  %let sum_vars_wc = Crimes_: ;

  %let geo = %upcase( &geo );

  %if %sysfunc( putc( &geo, $geoval. ) ) ~= %then %do;
    %let geosuf = %sysfunc( putc( &geo, $geosuf. ) );
    %let geodlbl = %sysfunc( putc( &geo, $geodlbl. ) );
    %let geofmt = %sysfunc( putc( &geo, $geoafmt. ) );
  %end;
  %else %do;
    %err_mput( macro=Create_sum_geo, msg=Invalid or missing value of GEO= parameter (GEO=&geo). )
    %goto exit_macro;
  %end;
  
  ** Combine input data **;

  %Push_option( compress )

  options compress=no;

  data All_crimes;

    set 
      %do i = &start_yr %to &end_yr;
        Police.Crimes_&i
      %end;
    ;
    by reportdate_yr;
    
  run;

  ** Convert data to single obs. per geographic unit & year **;

  proc summary data=All_crimes nway completetypes;
    class &geo / preloadfmt;
    class reportdate_yr;
    var &sum_vars;
    output out=All_crimes_geo sum=;
    format &geo &geofmt;

  %** Do not add population var for block-level summary **;

  %if &geo ~= GEOBLK2000 %then %do;
  
    ** Add Census 2000 population **;
    
    data All_crimes_geo;
    
      merge 
        All_crimes_geo 
        Ncdb.Ncdb_sum&geosuf (keep=&geo TotPop_2000)
        Ncdb.Ncdb_sum_2010&geosuf (keep=&geo TotPop_2010);
      by &geo;
      
      if reportdate_yr <= 2000 then 
        Crime_rate_pop = TotPop_2000;
      else if 2000 < reportdate_yr < 2010 then 
        Crime_rate_pop = round( TotPop_2000 + ( ( TotPop_2010 - TotPop_2000 ) * 
                         ( ( reportdate_yr - 2000 ) / ( 2010 - 2000 ) ) ) );
      else Crime_rate_pop = TotPop_2010;
      
      label
        Crime_rate_pop = "Population for calculating crime rates (est.)";
      
    run;    
    
  %end;
  
  ** Transpose data by year **;
  
  %if &geo ~= GEOBLK2000 %then %let var = &sum_vars Crime_rate_pop;
  %else %let var = &sum_vars;

  %Super_transpose(  
    data=All_crimes_geo,
    out=All_crimes_geo_tr,
    var=&var,
    id=reportdate_yr,
    by=&geo,
    mprint=N
  )

  ** Recode missing values to zero (0) **;

  %Pop_option( compress )

  data Police.Crimes_sum&geosuf (label="Preliminary part 1 crime summary, DC, &geodlbl" sortedby=&geo);

    set All_crimes_geo_tr;
    
    array a{*} &sum_vars_wc;
    
    do i = 1 to dim( a );
      if missing( a{i} ) then a{i} = 0;
    end;
    
    drop i;
    
  run;

  /***TESTING*** x "purge [dcdata.police.data]Crimes_sum&geosuf..*";***/

  %File_info( data=Police.Crimes_sum&geosuf, printobs=0 )
  
  %if &register = Y %then %do;

    ** Register in metadata **;
    
    %Dc_update_meta_file(
      ds_lib=Police,
      ds_name=Crimes_sum&geosuf,
      creator_process=Crimes_sum_all.sas,
      restrictions=None,
      revisions=%str(&revisions)
    )
    
  %end;
  
  %exit_macro:

%mend Crimes_sum_geo;

/** End Macro Definition **/


*options mlogic;

%Crimes_sum_geo( geo=ward2012, end_yr=&end_yr, revisions=&revisions, register=&register )
%Crimes_sum_geo( geo=ward2002, end_yr=&end_yr, revisions=&revisions, register=&register )

%Crimes_sum_geo( geo=ANC2012, end_yr=&end_yr, revisions=&revisions, register=&register )
%Crimes_sum_geo( geo=PSA2012, end_yr=&end_yr, revisions=&revisions, register=&register )
%Crimes_sum_geo( geo=geo2010, end_yr=&end_yr, revisions=&revisions, register=&register )

/**** TESTING ***
%Crimes_sum_geo( geo=GEOBLK2000, end_yr=&end_yr, revisions=&revisions, register=&register )
%Crimes_sum_geo( geo=city, end_yr=&end_yr, revisions=&revisions, register=&register )
%Crimes_sum_geo( geo=ward2002, end_yr=&end_yr, revisions=&revisions, register=&register )
%Crimes_sum_geo( geo=geo2000, end_yr=&end_yr, revisions=&revisions, register=&register )
%Crimes_sum_geo( geo=ANC2002, end_yr=&end_yr, revisions=&revisions, register=&register )
%Crimes_sum_geo( geo=CLUSTER_TR2000, end_yr=&end_yr, revisions=&revisions, register=&register )
%Crimes_sum_geo( geo=EOR, end_yr=&end_yr, revisions=&revisions, register=&register )
%Crimes_sum_geo( geo=PSA2004, end_yr=&end_yr, revisions=&revisions, register=&register )
%Crimes_sum_geo( geo=ZIP, end_yr=&end_yr, revisions=&revisions, register=&register )
***/

run;

/***endrsubmit;***/

/***signoff;***/

libname save "D:\DCData\Libraries\Police\Data\Save";

proc compare base=Save.Crimes_sum_wd02 compare=Police.Crimes_sum_wd02 maxprint=(40,32000);
  id ward2002;
  run;

