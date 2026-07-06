/**************************************************************************
 Adapted from: Prog/Make_formats.sas  (NeighborhoodInfoDC/Police)
 Original author: P. Tatian.  Crime-event code formats for the DC
 Police data library. The %include of the local SAS environment header
 and the %DCData_lib( Police ) library setup are removed; the format
 catalog is written to WORK so the script is self-contained.
**************************************************************************/

proc format;

  ** Geocoding status **;

  value $av_stat
    'M' = 'Geocoded'
    'U' = 'Unmatched';

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
    120 = 'Robbery/gun'
    121 = 'Robbery/knife'
    140 = 'Aggravated assault'
    150 = 'Burglary/1'
    160 = 'Theft/1'
    180 = 'Stolen auto'
    190 = 'Arson'
    200 = 'Assault/simple';

  ** UI event code summary format **;

  value uievsum
    100-109 = 'Homicide'
    110-119 = 'Sexual assault'
    120-132 = 'Robbery'
    140-149 = 'Aggravated assault'
    150-155 = 'Burglary'
    160-175 = 'Larceny/theft'
    180-184 = 'Stolen auto'
    190     = 'Arson'
    200-201 = 'Simple assault';

  ** MPD shift **;

  value $shift
    'DAY' = 'Day (7a-3p)'
    'EVN' = 'Evening (3p-11p)'
    'MID' = 'Midnight (11p-7a)';

run;

** Demonstrate the formats against a few sample crime-event codes **;

data sample_events;
  input ui_event av_statu $ shift $;
  datalines;
102 M DAY
121 M EVN
150 U MID
160 M DAY
190 M EVN
200 U MID
;
run;

proc print data=sample_events label noobs;
  format ui_event uievent. av_statu $av_stat. shift $shift.;
  label ui_event = 'UI crime event'
        av_statu = 'Geocoding status'
        shift    = 'MPD tour of duty';
  title 'Sample crime events with NeighborhoodInfoDC Police formats applied';
run;
