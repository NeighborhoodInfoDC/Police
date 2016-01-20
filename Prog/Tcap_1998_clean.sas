/**************************************************************************
 Program:  Tcap_1998_clean.sas
 Library:  Police
 Project:  DC Data Warehouse
 Author:   P. Tatian
 Created:  03/10/05
 Version:  SAS 8.2
 Environment:  Windows with SAS/Connect
 
 Description:  Clean TCAP raw data file for 1998.
 
 NB:  Currently excludes Assaults With a Deadly weapon and Homicides

 Modifications:
   03/25/05 Drop X_COORD & Y_COORD since values are truncated to 
            5 decimal places and therefore not valid.
**************************************************************************/

%let local = *;

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";
&local %include "K:\Metro\PTatian\DCData\SAS\Inc\AlphaSignon.sas" /nosource2;

** Define libraries **;
%DCData_lib( Police )

*options obs=100;

%let year = 1998;

proc sort data=Police.Tcap&year._raw out=Tcap_&year._sorted;
  by rptno event evtloca;

data Police.Tcap_&year._clean (label="Preliminary Part I crime reports (TCAP), &year, DC");

  set Tcap_&year._sorted (rename=(sevttime=sevttime_char geo00=geo2000));
  
  ** Record number **;
  
  RecordNo = _n_;
  
  label RecordNo = 'Record number (UI created)';
  
  ** Convert character time value to SAS time value **;
  
  if length( sevttime_char ) = 2 then
    fmt_time = substr( sevttime_char, 1, 2 ) || ":00";
  else if length( sevttime_char ) = 4 then 
    fmt_time = substr( sevttime_char, 1, 2 ) || ":" || substr( sevttime_char, 3, 2 );
  else 
    fmt_time = "";
  
  sevttime = input( fmt_time, time. );
  
  if sevttime = . then sevttime = .u;
  if sevtdate = . then sevtdate = .u;
  
  if year( sevtdate ) ~= &year then do;
    %warn_put( msg="Invalid event date year " sevtdate= " Value set to missing (.U)" )
    sevtdate = .u;
  end;
  
  label 
    geo2000 = "Full census tract ID (2000): ssccctttttt"
    rptno = "MPD report ID number"
    AV_STATU = "Geocoding status"
    district = "Police district"
    evtloca = "Street address of crime"
    Event = "MPD event code (type of crime)"
    SEVTDATE = "Event date"
    sevttime = "Event time"
    sevttime_char = "Event time (character)";
    
  format _all_ ;
  informat _all_ ;
  
  format 
    av_statu $av_stat. event $tcpevt.
    sevtdate mmddyy10. sevttime hhmm.;

  drop fmt_time X_COORD Y_COORD;
  
run;

%File_info( data=Police.Tcap_&year._clean, freqvars=av_statu district event )

proc freq data=Police.Tcap_&year._clean;
  table SEVTDATE;
  format SEVTDATE mmyys7.;
  label SEVTDATE = 'Event date (reformatted to month/year)';
run;

&local endrsubmit;

&local signoff;
