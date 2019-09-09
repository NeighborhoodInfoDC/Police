/**************************************************************************
 Program:  Add_geo_crimes_shp.sas
 Library:  Police
 Project:  NeighborhoodInfo DC
 Author:   Rob Pitingolo
 Created:  06/20/16
 Version:  SAS 9.4
 Environment:  Windows 7
 
 Description:  Macro to add geography vars to crime
 incident shapefile downloaded from opendata.dc.gov

 Modifications: 
**************************************************************************/

/** Macro Add_geo_crimes_shp - Start Definition **/

%macro Add_geo_crimes_shp( year=);

%let drop_list = fid_1 fid_2 fullarea shape_area shape_leng Cnt_cjrTra start_date end_date ;

%let DISTANCE_CUTOFF = 50;
%let LOCATION_LEN = 80;

%File_info( 
  data=Police.crime_incidents_&year._w_block, 
  printobs=0, 
  %if &year. >= 2017 %then %do;
  freqvars=method offense shift ward district psa anc neighborho bid 
  %end;
  %else %do;
  freqvars=method offense shift ward district psa anc neighborho businessim 
  %end;
)

proc format;
  value dist 
    0 = '0'
    0< - &DISTANCE_CUTOFF. = "1-&DISTANCE_CUTOFF. m."
    &DISTANCE_CUTOFF.< - high = "> &DISTANCE_CUTOFF. m.";

proc freq data=Police.crime_incidents_&year._w_block;
  tables distance;
  format distance dist.;
run;


** Separate data with and without matching blocks within distance cutoff **;

data block ;

  length Ccn $ 9 Location $ &LOCATION_LEN Method Offense $ 40 Shift $ 3 Anc $ 2 Smd $ 4
         Cjrtractbl $ 9 district cluster $ 2 psa $ 3 ward $ 1
         BID Hotspot2004 Hotspot2005 Hotspot2006 $ 40;

  set Police.crime_incidents_&year._w_block
    %if &year. >= 2017 %then %do;
       (drop=&drop_list latitude longitude
        rename=(ccn=x_ccn district=x_district report_dat=ch_reportdate 
                neighborho=ch_neighborho
                ward=ch_ward anc=x_anc psa=ch_psa block=x_blocksitea
				XBLOCK=latitude YBLOCK=longitude objectid=nid));
  %end;

  %else %do;
       (drop=&drop_list
        rename=(BUSINESSIM=BID 
                ccn=x_ccn district=x_district reportdate=ch_reportdate 
                lastmodifi=ch_lastmodifi neighborho=ch_neighborho
                ward=ch_ward anc=x_anc psa=ch_psa BLOCKSITEA=x_blocksitea
				BLOCKXCOOR=latitude BLOCKYCOOR=longitude objectid=nid));
  %end;

  /* Fix vars coded as character in shapefile */
  x_neighborho = ch_neighborho + 0;
  x_ward = ch_ward + 0;
  x_psa = ch_psa +0;
  x_reportdate=substr(ch_reportdate,1,10);
  x_lastmodifi=substr(ch_lastmodifi,1,10);
  drop ch_neighborho ch_ward ch_psa ch_reportdate ch_lastmodifi;

  /* Legacy variables no longer provided by OCTO */
  Hotspot2004 = " ";
  Hotspot2005 = " ";
  Hotspot2006 = " ";
  smd = " ";
  
  
  ** Recodes **;
  
  array a{*} x_ward x_psa x_neighborho;
  
  do i = 1 to dim( a );
    if a{i} in ( 0, . ) then a{i} = .u;
  end;  
  
  array b{*} $ x_anc BID x_district hotsp: smd;
  
  do i = 1 to dim( b );
    b{i} = upcase( left( b{i} ) );
    if b{i} = 'NONE' then b{i} = '';
  end;
  
  shift = upcase( left( shift ) );
  if shift = 'UNK' then shift = '';
  if shift = 'EVE' then shift = 'EVN';
  
  Reportdate = input( x_reportdate, yymmdd10. );
  LastModifiedDt = input( x_lastmodifi, yymmdd10. );
  
  format Reportdate LastModifiedDt yymmdd10.;

  if offense = "ASSAULT W/DANGEROUS WEAPON" then offense = "ADW";
  if offense = "MOTOR VEHICLE THEFT" then offense = "STOLEN AUTO";
  if offense = "THEFT/OTHER" then offense = "THEFT";

  if method = "OTHERS" then method = "OTHER";
  
  ** Reformat variables **;
  
  %Octo_GeoBlk2000()
  
  ccn = left( put( x_ccn, 9. ) );
  Anc = left( upcase( x_anc ) );
  if not( missing( x_neighborho ) ) then cluster = put( x_neighborho, z2. );
  if not( missing( x_psa ) ) then psa = put( x_psa, 3. );
  if not( missing( x_ward ) ) then ward = put( x_ward, 1. );
     
  %if &year. >= 2017 %then %do;
  select( upcase( x_district ) );
    when ( '1' ) district = '1D';
    when ( '2' ) district = '2D';
    when ( '3' ) district = '3D';
    when ( '4' ) district = '4D';
    when ( '5' ) district = '5D';
    when ( '6' ) district = '6D';
    when ( '7' ) district = '7D';
    when ( '' ) district = '';
    otherwise do;
      %err_put( msg='Invalid DISTRICT code: ' _n_= ccn= ' DISTRICT=' x_district )
    end;
  end;
  %end;

 %else %do;
  select( upcase( x_district ) );
    when ( 'FIRST' ) district = '1D';
    when ( 'SECOND' ) district = '2D';
    when ( 'THIRD' ) district = '3D';
    when ( 'FOURTH' ) district = '4D';
    when ( 'FIFTH' ) district = '5D';
    when ( 'SIXTH' ) district = '6D';
    when ( 'SEVENTH' ) district = '7D';
    when ( '' ) district = '';
    otherwise do;
      %err_put( msg='Invalid DISTRICT code: ' _n_= ccn= ' DISTRICT=' x_district )
    end;
  end;
  %end;
    
  x_blocksitea = left( compbl( x_blocksitea ) );
    
  if length( x_blocksitea ) <= &LOCATION_LEN then location = x_blocksitea;
  else do;
    %err_put( msg="Location information over &LOCATION_LEN characters: " _n_= ccn= 'BLOCKSITEA=' x_blocksitea )
  end;
    
  drop distance x_: i;
  
  rename point_x=x_coord point_y=y_coord;
  
  format _all_ ;
  informat _all_ ;
  
run;


data crime_incidents_raw_&year.;

  set block (in=in1);
  
  length Geo_source $ 1;
  
  if in1 then geo_source = '1';
  /*else if in2 then geo_source = '2';
  else geo_source = '3';*/
  
  label
    anc = 'Advisory Neighborhood Commmission (ANC, OCTO supplied)'
    bid = 'Business Improvement District name (OCTO supplied)'
    ccn = 'Crime control number'
    Cjrtractbl = 'Census block from spatial join (OCTO format)'
    Geo_source = 'Source of record geographic information'
    Hotspot2004 = 'Hotspot name (2004, No longer supplied)'
    Hotspot2005 = 'Hotspot name (2005, No longer supplied)'
    Hotspot2006 = 'Hotspot name (2006, No longer supplied)'
    LastModifiedDt = 'OCTO Date of last data load'
    latitude = 'Latitude of crime block (OCTO supplied)'
    longitude = 'Longitude of crime block (OCTO supplied)'
	block_grou = 'Block group (OCTO supplied)'
	census_tra = 'Census tract (OCTO supplied)'
	voting_pre = 'Voting precint (OCTO supplied)'
    location = 'Crime incident location (block/intersection)'
    method = 'Weapon or means used in the reported crime incident'
    nid = 'Unique identifier assigned by OCTO'
    offense = 'Reported crime incident'
    reportdate = 'Date of reported crime incident'
    shift = 'MPD member''s tour of duty associated with the time the report was taken'
    smd = 'ANC Single Member District (No longer supplied)'
    cluster = 'Neighborhood cluster (OCTO supplied)'
    district = 'Police Service Area District (OCTO supplied)'
    psa = 'Police Service Area (OCTO supplied)'
    ward = 'Council ward (OCTO supplied)'
    x_coord = 'Longitude of crime block (Geocoded by UI, NAD 1983 meters)'
    y_coord = 'Latitude of crime block (Geocoded by UI, NAD 1983 meters)'
  ;
  
  format Reportdate LastModifiedDt mmddyy10. shift $shift. geo_source $geosrc.;

run;

%Finalize_data_set( 
/** Finalize data set parameters **/
data=crime_incidents_raw_&year.,
out=crime_incidents_raw_&year.,
outlib=police,
label="Crime data with block &year.",
sortby=ccn,
/** Metadata parameters **/
restrictions=None,
revisions=%str(New file),
/** File info parameters **/
printobs=5,
freqvars=district ward anc
);  


%mend Add_geo_crimes_shp;

/** End Macro Definition **/

