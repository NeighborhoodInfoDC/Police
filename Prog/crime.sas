/**************************************************************************
 Program:  crime.sas
 Library:  Police
 Project:  NeighborhoodInfo DC
 Author:   K. Gentsch
 Created:  3/16/06
 Version:  SAS 8.2
 Environment:  Windows
 
 Description:  

 Modifications:
**************************************************************************/

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";

%DCData_lib(General);
%DCData_lib (Police);

options mrecall;

data police.crimes_2000_dc (label='Preliminary Part I crime reports, 2000, DC');

	length Geoblk2000 $15;

	set police.all_incidents_2000 (rename=(stfid=geoblk2000) drop=fipsstco);

	format _all_;
	informat _all_;

	** Create EVENT and EVENT_N codes for types of crimes **;

	%Offense_to_event

	** Add full tract ID **;

	length Geo2000 $ 11;
  
	Geo2000 = GeoBlk2000;
  
	label 
		GEO2000 = "Full census tract ID (2000): ssccctttttt";

	**** Add DC geographies ****;

	** Use MPD supplied ward unless missing **;

	%block00_to_ward02( outvar=_ward2002 )

	length ward2002 $ 1;

	if ward in ( 1, 2, 3, 4, 5, 6, 7, 8 ) then ward2002 = put( ward, 1. );
	else ward2002 = _ward2002;

	** Use MPD supplied PSA unless missing **;

	%Block00_to_psa04( outvar=_psa2004 )

	length Psa2004 $ 3 Psa2004_district $ 2;

	if put( put( psa, 3. ), $psa04v. ) ~= '' then psa2004 = put( psa, 3. );
	else psa2004 = _psa2004;

	if psa2004 ~= '' then psa2004_district = substr( psa2004, 1, 1 ) || 'D';

	** ANC **;

	%Block00_to_anc02( )

	** Cluster **;

	%Block00_to_cluster00( )
	%Block00_to_cluster_tr00( )

	** ZIP code **;

	%Block00_to_zip( )

	sevtdate=start_date;
	sevttime=start_time;
	event_year=year(start_date);

	format 
		End_Date Start_Date sevtdate MMDDYY10. 
		End_Time Start_Time sevttime TIME12.
		ward2002 $ward02a.
		psa2004 $psa04a.
		event $TCPEVT.;

	label 
	Area_T='Area'       
	BLOCK='Street address of crime'         
	BLOCK2000='Census block ID (2000): bbbb'
	CCN='CCN'           
	Code=' '          
	ward = 'Ward (MPD supplied)'
	ward2002 = 'Ward (2002)'
	DISTRICT='Police district'      
	End_Date='Event end date'      
	End_Time='Event end time'      
	FID_2=' '         
	ID=' '            
	Location='Location'      
	Method='Method'        
	Offense='Offense'       
	PSA='MPD Police Service Area (MPD supplied, 2004)'          
	psa2004 = 'MPD Police Service Area (2004)'
    PSA2004_district = 'MPD Police District (2004)'
	Property='Property'     
	Shift='Shift'         
	Start_Date='Event start date'    
	Start_Hour='Event start hour'    
	Start_Time='Event start time'    
	Status=' '        
	TRACT2000='Census tract ID (2000): tttttt'
	geoblk2000='Full census block ID (2000): sscccttttttbbbb'
	sevtdate='Event date'
	sevttime='Event time'
	event_year='Event year';

	drop _ward2002 _psa2004;

run;

proc sort data=police.crimes_2000_dc;
	by  sevtdate sevttime;
run;

%file_info(data=police.crimes_2000_dc, 
	freqvars=
		offense method shift area_t property
		location status code event ui_event 
		ward ward2002 district PSA2004_district psa psa2004 anc2002 cluster2000 cluster_tr2000 zip );

proc freq data=police.crimes_2000_dc;	/*some have neither start nor end in 2000*/
	tables start_date end_date sevtdate event_year start_time end_time sevttime / missing;
	format start_date end_date sevtdate year. start_time end_time sevttime hour. ;
run;

/*does a crime show up in more than 1 yr's file?*/

proc tabulate data=police.crimes_2000_dc format=comma12.0 missing noseps;
	where 100 <= ui_event <= 199;
	class offense;
	table all='Total' offense, n='Number of Crimes' pctn='Percent of Crimes';
	title2 'Reported Part 1 Crimes, 2000 (?)';
run;
