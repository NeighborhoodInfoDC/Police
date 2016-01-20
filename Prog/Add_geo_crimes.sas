/**************************************************************************
 Program:  Add_geo_crimes.sas
 Library:  Police
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  06/09/10
 Version:  SAS 9.1
 Environment:  Windows
 
 Description:  Autocall macro to add geography vars. to crime
 incident data downloaded from the OCTO DCGIS catalog.

 Modifications: Updated to accept SAS dataset created by StatTransfer. -RP 6-8-12
**************************************************************************/

/** Macro Add_geo_crimes - Start Definition **/

%macro Add_geo_crimes( year= );

%if &year = 2007 %then %let drop_list = narrative city state fid_1 fid_2 fullarea shape_area shape_leng Cnt_cjrTra;
%else %let drop_list = city state fid_1 fid_2 fullarea shape_area shape_leng Cnt_cjrTra;

%let DISTANCE_CUTOFF = 50;
%let LOCATION_LEN = 80;

%File_info( 
  data=Police.crime_incidents_&year._w_block, 
  printobs=0, 
  freqvars=method offense shift city state ward district psa anc smd neighborho hotsp: businessim 
)

/*
proc print data=Police.crime_incidents_&year._w_block;
  where city = '';
  id ccn;
  var OFFENSE BLOCKSITEA WARD ANC SMD DISTRICT PSA cjrTractBl Distance;
  format OFFENSE $15. BLOCKSITEA $20. ANC SMD $4. DISTRICT $8. WARD PSA 3. cjrTractBl $9.;
run;
*/

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

data 
  block (drop=address)
  no_block_bo (drop=cjrTractBl latitude longitude x_coord y_coord)
  no_block_blank (drop=address cjrTractBl latitude longitude x_coord y_coord)
  no_block_oth (drop=address cjrTractBl latitude longitude x_coord y_coord);

  length Ccn $ 9 Location $ &LOCATION_LEN Method Offense $ 40 Shift $ 3 Anc $ 2 Smd $ 4
         Cjrtractbl $ 9 district cluster $ 2 psa $ 3 ward $ 1
         BID Hotspot2004 Hotspot2005 Hotspot2006 $ 40;

  %if &year <= 2010 %then %do;
  set Police.crime_incidents_&year._w_block 
       (drop=&drop_list
        rename=(hotspot200=hotspot2006 hotspot2_1=hotspot2005 hotspot2_2=hotspot2004
                businessim=BID 
                ccn=x_ccn district=x_district reportdate=x_reportdate 
                lastmodifi=x_lastmodifi neighborho=x_neighborho
                ward=x_ward anc=x_anc psa=x_psa blocksitea=x_blocksitea));
  %end;

  %else %if &year >= 2011 %then %do;
  set Police.crime_incidents_&year._w_block 
       (drop=&drop_list
        rename=(hotspot200=hotspot2006 hotspot201=hotspot2005 hotspot202=hotspot2004
                businessim=BID 
                ccn=x_ccn district=x_district reportdate=x_reportdate 
                lastmodifi=x_lastmodifi neighborho=ch_neighborho
                ward=x_ward anc=x_anc psa=x_psa blocksitea=x_blocksitea));

  x_neighborho = ch_neighborho + 0;
  drop ch_neighborho;
   %end;

  
  
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
  
  Reportdate = input( x_reportdate, mmddyy10. );
  LastModifiedDt = input( x_lastmodifi, mmddyy10. );
  
  format Reportdate LastModifiedDt mmddyy10.;
  
  ** Reformat variables **;
  
  %Octo_GeoBlk2000()
  
  ccn = left( put( x_ccn, 9. ) );
  Anc = left( upcase( x_anc ) );
  if not( missing( x_neighborho ) ) then cluster = put( x_neighborho, z2. );
  if not( missing( x_psa ) ) then psa = put( x_psa, 3. );
  if not( missing( x_ward ) ) then ward = put( x_ward, 1. );
     
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
    
  x_blocksitea = left( compbl( x_blocksitea ) );
    
  if length( x_blocksitea ) <= &LOCATION_LEN then location = x_blocksitea;
  else do;
    %err_put( msg="Location information over &LOCATION_LEN characters: " _n_= ccn= 'BLOCKSITEA=' x_blocksitea )
  end;
    
  drop distance x_: i;
  
  rename point_x=x_coord point_y=y_coord;
  
  format _all_ ;
  informat _all_ ;

  ** Output data **;

  if distance <= &DISTANCE_CUTOFF then output block;
  else if index( X_BLOCKSITEA, 'B/O' ) then do;
    length address $ &LOCATION_LEN;
    address = tranwrd( location, 'B/O', '' );
    output no_block_bo;
  end;
  else if X_BLOCKSITEA = '' then output no_block_blank;
  else output no_block_oth;
  
run;

%file_info( data=block, freqvars=method offense shift ward district psa Anc smd cluster hotsp: BID )
%file_info( data=no_block_bo )
%file_info( data=no_block_blank, freqvars=method offense shift ward district psa Anc smd cluster hotsp: BID )
%file_info( data=no_block_oth )

** Geocode B/O addresses to add geography vars **;

rsubmit;

proc upload status=no
  data=no_block_bo 
  out=no_block_bo;

%DC_geocode(
  geo_match=Y,
  data=no_block_bo,
  out=no_block_bo_geo,
  staddr=address,
  zip=,
  id=ccn,
  ds_label=,
  listunmatched=Y
)

proc download status=no
  data=no_block_bo_geo 
  out=no_block_bo_geo;

run;

endrsubmit;


%File_info( data=no_block_bo_geo, freqvars=ward2002 psa2004 anc2002 )

proc freq data=no_block_bo_geo;
  tables 
    ward * ward2002 
    psa * psa2004
    anc * anc2002
    / list;
run;

data no_block_bo_geo_b;

  set no_block_bo_geo;
  
  if not( missing( ward2002 ) ) then ward = ward2002;
  if not( missing( psa2004 ) ) then psa = psa2004;
  if not( missing( anc2002 ) ) then anc = anc2002;
  if not( missing( cluster2000 ) ) then cluster = cluster2000;

  drop ward2002 psa2004 anc2002 cluster2000 unitnumber address address_match 
       address_std cluster_tr2000 dcg_: geo2000 ssl str_addr_unit 
       ui_proptype zip_match;

run;

data Police.crime_incidents_raw_&year.;

  set block (in=in1) no_block_bo_geo_b (in=in2) no_block_blank no_block_oth;
  
  length Geo_source $ 1;
  
  if in1 then geo_source = '1';
  else if in2 then geo_source = '2';
  else geo_source = '3';
  
  label
    anc = 'Advisory Neighborhood Commmission (ANC, DCSTAT supplied)'
    bid = 'Business Improvement District name (DCSTAT supplied)'
    ccn = 'Crime control number'
    Cjrtractbl = 'Census block from spatial join (OCTO format)'
    Geo_source = 'Source of record geographic information'
    Hotspot2004 = 'Hotspot name (2004, MPD supplied)'
    Hotspot2005 = 'Hotspot name (2005, MPD supplied)'
    Hotspot2006 = 'Hotspot name (2006, MPD supplied)'
    LastModifiedDt = 'DCSTAT Date of last data load'
    latitude = 'Latitude of crime block (GCS North American Datum 1983, MPD supplied)'
    longitude = 'Longitude of crime block (GCS North American Datum 1983, MPD supplied)'
    location = 'Crime incident location (block/intersection)'
    method = 'Weapon or means used in the reported crime incident'
    nid = 'Unique identifier assigned by Metropolitan Police Department'
    offense = 'Reported crime incident'
    reportdate = 'Date of reported crime incident'
    shift = 'MPD member''s tour of duty associated with the time the report was taken'
    smd = 'ANC Single Member District (DCSTAT supplied)'
    cluster = 'Neighborhood cluster (DCSTAT supplied)'
    district = 'Police Service Area District (DCSTAT supplied)'
    psa = 'Police Service Area (DCSTAT supplied)'
    ward = 'Council ward (DCSTAT supplied)'
    x_coord = 'Longitude of crime block (MD State Plane Coord., NAD 1983 meters)'
    y_coord = 'Latitude of crime block (MD State Plane Coord., NAD 1983 meters)'
  ;
  
  format Reportdate LastModifiedDt mmddyy10. shift $shift. geo_source $geosrc.;

run;
    
%file_info( data=Police.crime_incidents_raw_&year., freqvars=geo_source method offense shift ward district psa Anc smd cluster hotsp: BID )

%mend Add_geo_crimes;

/** End Macro Definition **/

