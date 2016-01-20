/**************************************************************************
 Program:  Make_formats.sas
 Library:  Police
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  06/09/10
 Version:  SAS 9.1
 Environment:  Windows
 
 Description:  Make formats for Police data library.

 Modifications:
**************************************************************************/

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";

** Define libraries **;
%DCData_lib( Police )

proc format library=Police;

  ** Geocoding status **;
  
  value $av_stat
    'M' = 'Geocoded'
    'U' = 'Unmatched';
    
  ** TCAP event codes **;
  
  value $tcpevt
    10      =      'HOMICIDE--'
    20      =      'SEX ABUSE A1-ADULT 1ST'
    21      =      'SEX ABUSE A2-ADULT 2ND'
    22      =      'SEX ABUSE C1-CHILD 1ST'
    23      =      'SEX ABUSE A3-ADULT 3RD'
    24      =      'SEX ABUSE A4-ADULT 4TH'
    25      =      'SEX ABUSE C2-CHILD 2ND'
	26      =      'SEX ABUSE AWIC 1ST'
	27      =      'SEX ABUSE ATTEMPT 1ST'
    30      =      'ROBBERY-GUN'
    31      =      'ROBBERY-KNIFE'
    32      =      'ROBBERY-OTHER ARMED'
    33      =      'ROBBERY-FEAR'
    34      =      'ROBBERY-F&V'
    35      =      'ROBBERY-SNATCH'
    36      =      'ROBBERY-PBS'
    37      =      'ROBBERY-P/P'
    38      =      'ROBBERY-ASSLT W/I'
    39      =      'ROBBERY-ATTEMPT'
    40      =      'ASSAULT-OTHER'
    41      =      'ASSAULT-GUN'
    42      =      'ASSAULT-KNIFE'
    43      =      'ASSAULT-CLUB'
    50      =      'BURGLARY-1 ARMED'
    51      =      'BURGLARY-1'
    52      =      'BURGLARY-2'
    53      =      'BURGLARY-ATTEMPT'
    60      =      'THEFT-1'
    61      =      'THEFT-2'
    62      =      'THEFT-ATTEMPT'
    63      =      'THEFT-SHOPLIFTING'
    64      =      'B&E VENDING--'
    66      =      'THFT F/AUTO-1'
    67      =      'THFT F/AUTO-2'
    68      =      'THFT F/AUTO-ATTEMPT'
    70      =      'STOLEN AUTO--'
    71      =      'STOLEN AUTO-ATTEMPT'
    80      =      'ARSON--'
    ;

  ** UI crime event codes **;

  value uievent

    100 = 'Homicide/arson'
    101 = 'Homicide/blunt force trauma'
    102 = 'Homicide/gun'
    103 = 'Homicide/knife'
    104 = 'Homicide/neglect'
    108 = 'Homicide/other'
    109 = 'Homicide/unknown'

    110 = 'Sexual assault/adult 1'
    111 = 'Sexual assault/adult 2'
    112 = 'Sexual assault/adult 3'
    113 = 'Sexual assault/adult 4'
    115 = 'Sexual assault/child 1'
    116 = 'Sexual assault/child 2'
	117 = 'Sexual assault/awic 1'
	118 = 'Sexual assault/attempt 1'
    
    120 = 'Robbery/gun'
    121 = 'Robbery/knife'
    122 = 'Robbery/other armed'
    123 = 'Robbery/fear'
    124 = 'Robbery/F&V'
    125 = 'Robbery/purse snatching'
    126 = 'Robbery/PBS'
    127 = 'Robbery/pocket picking'
    128 = 'Robbery/assault w/intent'
    129 = 'Robbery/attempt'
    130 = 'Robbery/car jacking'
    131 = 'Robbery/stealth'

    140 = 'Aggravated assault'
    141 = 'Aggravated assault/gun'
    142 = 'Aggravated assault/knife'
    143 = 'Aggravated assault/club'
    149 = 'Aggravated assault/other deadly weapon'

    150 = 'Burglary/1'
    151 = 'Burglary/2'
    152 = 'Burglary/attempt'

    160 = 'Theft/1'
    161 = 'Theft/2'
    162 = 'Theft/attempt'
    163 = 'Theft/shoplifting'
    164 = 'Theft/B&E vending'
    165 = 'Theft/bicycle'
    166 = 'Theft/mail'
    167 = 'Theft/tags'
    170 = 'Theft from auto/1'
    171 = 'Theft from auto/2'
    172 = 'Theft from auto/attempt'
    180 = 'Stolen auto'
    181 = 'Stolen auto/attempt'
    190 = 'Arson'

    200 = 'Assault/simple'
    201 = 'Assault/threats'
    241 = 'Property destruction/$200 or less'
    242 = 'Property destruction/over $200'
    300 = 'Interstate Recovery';
    
	
  ** UI event code summary format **;
	
  value uievsum
    100-109 = 'Homicide'
    110-116 = 'Sexual assault'
    120-131 = 'Robbery'
    140-149 = 'Aggravated assault'
    150-152 = 'Burglary'
    160-172 = 'Larceny/theft'
    180-181 = 'Stolen auto'
    190     = 'Arson'
    200-201 = 'Simple assault'
    241-242 = 'Property destruction'
    300     = 'Interstate Recovery';

  ** MPD shift **;	
	
  value $shift
    'DAY' = 'Day (7a-3p)'
    'EVN' = 'Evening (3p-11p)'
    'MID' = 'Midnight (11p-7a)';

  ** Source flag for geography vars (2007 and later) **;
	
  value $geosrc
    '1' = 'X/Y spatial join to Census block'
    '2' = 'Geocoded block address (LOCATION)'
    '3' = 'Used MPD/DCSTAT-provided geography';

	run;

proc catalog catalog=Police.formats;
  modify av_stat (desc="Geocoding status") / entrytype=formatc;
  modify tcpevt (desc="TCAP crime event codes") / entrytype=formatc;
  modify uievent (desc="UI crime event codes") / entrytype=format;
  modify uievsum (desc="UI crime event summary codes") / entrytype=format;
  modify shift (desc="MPD tour of duty shift") / entrytype=formatc;
  modify geosrc (desc="Source of geographic information") / entrytype=formatc;
  contents;
quit;

run;
