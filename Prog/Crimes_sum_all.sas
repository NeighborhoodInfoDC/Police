/**************************************************************************
 Program:  Crimes_sum_all.sas
 Library:  Police
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  12/08/06
 Version:  SAS 9.2
 Environment:  Remote Windows session (SAS1)
 
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
  09/09/12 PAT Updated for new 2010/2012 geos.
  10/30/13 PAT Added check for invalid geography values. 
  03/30/14 PAT Updated for new SAS1 server.
               Added summary for voterpre2012.
**************************************************************************/

%include "L:\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( Police )
%DCData_lib( NCDB )

/** Update with information on latest file revision **/
%let revisions = %str(Updated with data for 2012 - 2015.);

/** Update with latest crime data year **/
%let end_yr = 2015;


/** Macro Crimes_sum_geo - Start Definition **/

%macro Crimes_sum_geo( geo=, start_yr=2000, end_yr=, revisions= );

  %local sum_vars sum_vars_wc geosuf geodlbl geofmt geovfmt i var;

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
    %let geovfmt = %sysfunc( putc( &geo, $geovfmt. ) );
  %end;
  %else %do;
    %err_mput( macro=Crimes_sum_geo, msg=Invalid or missing value of GEO= parameter (GEO=&geo). )
    %goto exit_macro;
  %end;
  
  ** Combine input data **;

  %Push_option( compress )

  options compress=no;

  data All_crimes;

    set 
      %do i = &start_yr %to &end_yr;
        Police.Crimes_&i (keep=reportdate_yr &geo &sum_vars)
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

  %** Do not add population var for block-level summaries **;

  %if &geo ~= GEOBLK2000 and &geo ~= GEOBLK2010 %then %do;
  
    ** Add Census population **;
    
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
  
  %if &geo ~= GEOBLK2000 and &geo ~= GEOBLK2010 %then %let var = &sum_vars Crime_rate_pop;
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

  data Crimes_sum&geosuf;

    set All_crimes_geo_tr;
    
    array a{*} &sum_vars_wc;
    
    do i = 1 to dim( a );
      if missing( a{i} ) then a{i} = 0;
    end;
    
    ** Check for invalid geography values **;

	/* Fix city format and check for other bad formats*/
	%if &geo = CITY %then %do;
	format city $CITY16. ;
	%end;

	%else %do;
    if missing( put( &geo, &geovfmt ) ) then do;
      %err_put( macro=Crimes_sum_geo, msg="Invalid geography value: " _n_= &geo= )
    end;
	%end;
    
    drop i;
    
  run;

  %Finalize_data_set(
    data=Crimes_sum&geosuf,
    out=Crimes_sum&geosuf,
    outlib=Police,
    label="Preliminary part 1 crime summary, DC, &geodlbl",
    sortby=&geo,
    /** Metadata parameters **/
    revisions=%str(&revisions),
    /** File info parameters **/
    printobs=0
  )

  %exit_macro:

%mend Crimes_sum_geo;

/** End Macro Definition **/


*options mlogic;

%Crimes_sum_geo( geo=ANC2002, end_yr=&end_yr, revisions=&revisions )
%Crimes_sum_geo( geo=ANC2012, end_yr=&end_yr, revisions=&revisions )
%Crimes_sum_geo( geo=CLUSTER_TR2000, end_yr=&end_yr, revisions=&revisions )
%Crimes_sum_geo( geo=EOR, end_yr=&end_yr, revisions=&revisions )
%Crimes_sum_geo( geo=geo2000, end_yr=&end_yr, revisions=&revisions )
%Crimes_sum_geo( geo=geo2010, end_yr=&end_yr, revisions=&revisions )
%Crimes_sum_geo( geo=GEOBLK2000, end_yr=&end_yr, revisions=&revisions )
/***NOT YET IN ALL FILES***%Crimes_sum_geo( geo=GEOBLK2010, end_yr=&end_yr, revisions=&revisions )***/
%Crimes_sum_geo( geo=PSA2004, end_yr=&end_yr, revisions=&revisions )
%Crimes_sum_geo( geo=PSA2012, end_yr=&end_yr, revisions=&revisions )
%Crimes_sum_geo( geo=ward2002, end_yr=&end_yr, revisions=&revisions )
%Crimes_sum_geo( geo=ward2012, end_yr=&end_yr, revisions=&revisions )
%Crimes_sum_geo( geo=ZIP, end_yr=&end_yr, revisions=&revisions )
%Crimes_sum_geo( geo=voterpre2012, end_yr=&end_yr, revisions=&revisions )
%Crimes_sum_geo( geo=city, end_yr=&end_yr, revisions=&revisions )

run;

