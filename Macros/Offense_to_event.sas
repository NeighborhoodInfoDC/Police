/**************************************************************************
 Program:  Offense_to_event.sas
 Library:  Police
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  03/30/06
 Version:  SAS 8.2
 Environment:  Windows
 
 Description:  Autocall macro to convert Offense and Method
 descriptions in MPD crime data to MPD and UI Event codes.

 Modifications:
  06/27/06 PAT  Modified codes for new data.
  11/19/06 PAT  Revised codes.
  06/09/10 PAT  Converting offense and method strings to Propcase().
                Coding 'Theft F/Auto' as Stolen Auto when method is 
                Stolen Auto.
                Added Asphyxiation to Homicide, other. 
  06/08/12 RMP  Added Attempted assualt and animal cruetly.
  06/22/16 RMP  Added new ui_event codes based on new OCTO method values.
**************************************************************************/

/** Macro Offense_to_event - Start Definition **/

%macro Offense_to_event;

  offense = propcase( left( offense ) );
  method = propcase( left( method ) );

  length event $ 2 Ui_event 8;

  if offense='Homicide' and method='Arson' then do;
    event = '10';
    ui_event = 100;
  end;
  else if offense='Homicide' and method='Blunt Force Trauma' then do;
    event = '10';
    ui_event = 101;
  end;
  else if offense='Homicide' and method='Gun' then do;
    event = '10';
    ui_event = 102;
  end;
  else if offense='Homicide' and method=:'Knife' then do;
    event = '10';
    ui_event = 103;
  end;
  else if offense='Homicide' and method='Neglect' then do;
    event = '10';
    ui_event = 104;
  end;
  else if offense='Homicide' and method in ( 'Other','Others', 'Asphyxiation' ) then do;
    event = '10';
    ui_event = 108;
  end;
  else if offense='Homicide' and method='Unknown' then do;
    event = '10';
    ui_event = 109;
  end;

  else if offense ='Sex Abuse' and method in ( 'Adult 1st', 'Adult First' ) then do;
    event = '20';
    ui_event = 110;
  end;
  else if offense ='Sex Abuse' and method in ( 'Adult 2nd', 'Adult Twond' ) then do;
    event = '21';
    ui_event = 111;
  end;
  else if offense ='Sex Abuse' and method='Adult 3rd' then do;
    event = '23';
    ui_event = 112;
  end;
  else if offense ='Sex Abuse' and method in ( 'Adult 4th', 'Adault 4th' ) then do;
    event = '24';
    ui_event = 113;
  end;
  else if offense ='Sex Abuse' and method in ( 'Child 1st', 'Child First' ) then do;
    event = '22';
    ui_event = 115;
  end;
  else if offense ='Sex Abuse' and method in ( 'Child 2nd', 'Child Twond' ) then do;
    event = '25';
    ui_event = 116;
  end;
  else if offense ='Sex Abuse' and method in ( 'Awic 1st Degree' ) then do;
    event = '26';
    ui_event = 117;
  end;
  else if offense ='Sex Abuse' and method in ( 'Attempt 1st Degree' ) then do;
    event = '27';
    ui_event = 118;
  end;
    else if offense ='Sex Abuse' and method in ( 'Other','Others' ) then do;
    event = '28';
    ui_event = 119;
  end;
   else if offense ='Sex Abuse' and method in ( 'Gun' ) then do;
    event = '28';
    ui_event = 114;
  end;
  else if offense ='Sex Abuse' and method in ( 'Knife' ) then do;
    event = '28';
    ui_event = 114.1;
  end;
  
  else if offense ='Robbery' and method='Assault W/Intent' then do;
    event = '38';
    ui_event = 128;
  end;
  else if offense ='Robbery' and method='Attempt' then do;
    event = '39';
    ui_event = 129;
  end;
  else if offense ='Robbery' and method='F&v' then do;
    event = '34';
    ui_event = 124;
  end;
  else if offense ='Robbery' and method='Fear' then do;
    event = '33';
    ui_event = 123;
  end;
  else if offense ='Robbery' and method='Gun' then do;
    event = '30';
    ui_event = 120;
  end;
  else if offense ='Robbery' and method='Knife' then do;
    event = '31';
    ui_event = 121;
  end;
  else if offense ='Robbery' and method='Other Armed' then do;
    event = '32';
    ui_event = 122;
  end;
  else if offense ='Robbery' and method='P/P' then do;
    event = '37';
    ui_event = 127;
  end;
  else if offense ='Robbery' and method='Pbs' then do;
    event = '36';
    ui_event = 126;
  end;
  else if offense ='Robbery' and method='Snatch' then do;
    event = '35';
    ui_event = 125;
  end;
  else if offense ='Robbery' and method=:'Car Jacking' then do;
    event = '3x';
    ui_event = 130;
  end;
  else if offense ='Robbery' and method='Stealth' then do;
    event = '3x';
    ui_event = 131;
  end;
   else if offense ='Robbery' and method in ('Other','Others') then do;
    event = '29';
    ui_event = 132;
  end;

  else if offense='Assault' and method='Aggravated Assault' then do;
    event = '4x';
    ui_event = 140;
  end;
  else if offense='Adw' and method='Gun' then do;
    event = '41';
    ui_event = 141;
  end;
  else if offense='Adw' and method='Knife' then do;
    event = '42';
    ui_event = 142;
  end;
  else if offense='Adw' and method='Club' then do;
    event = '43';
    ui_event = 143;
  end;
  else if offense='Adw' and method in ('Other','Others') then do;
    event = '40';
    ui_event = 149;
  end;

  else if offense ='Burglary' and method in ( 'One', '1', '1 Armed', 'One Armed' ) then do;
    event = '51';
    ui_event = 150;
  end;
  else if offense ='Burglary' and method in ( 'Two', '2' ) then do;
    event = '52';
    ui_event = 151;
  end;
  else if offense ='Burglary' and method=:'Attemp' then do;
    event = '53';
    ui_event = 152;
  end;
    else if offense ='Burglary' and method in ('Other','Others') then do;
    event = '54';
    ui_event = 153;
  end;
  else if offense ='Burglary' and method in ('Gun') then do;
    event = '54';
    ui_event = 154;
  end;
  else if offense ='Burglary' and method in ('Knife') then do;
    event = '54';
    ui_event = 155;
  end;

  else if offense ='Theft' and method in ( 'One', '1', '1 Armed' ) then do;
    event = '60';
    ui_event = 160;
  end;
  else if offense ='Theft' and method in ( 'Two', '2' ) then do;
    event = '61';
    ui_event = 161;
  end;
  else if offense ='Theft' and method=:'Attemp' then do;
    event = '62';
    ui_event = 162;
  end;
  else if offense ='Theft' and method='Shoplifting' then do;
    event = '63';
    ui_event = 163;
  end;
  else if offense ='Theft' and method='B&e Vending' then do;
    event = '64';
    ui_event = 164;
  end;
  else if offense ='Theft' and method='Bicycle' then do;
    event = '6x';
    ui_event = 165;
  end;
  else if offense ='Theft' and method='F/Mail' then do;
    event = '6x';
    ui_event = 166;
  end;
  else if offense ='Theft' and method='Tags' then do;
    event = '6x';
    ui_event = 167;
  end;
  else if offense ='Theft' and method in ('Other','Others') then do;
    event = '59';
    ui_event = 168;
  end;
 else if offense ='Theft' and method in ('Gun') then do;
    event = '57';
    ui_event = 169;
  end;
 else if offense ='Theft' and method in ('Knife') then do;
    event = '58';
    ui_event = 169.1;
  end;

  else if offense ='Theft F/Auto' and method in ( 'One', '1' ) then do;
    event = '66';
    ui_event = 170;
  end;
  else if offense ='Theft F/Auto' and method in ( 'Two', '2' ) then do;
    event = '67';
    ui_event = 171;
  end;
  else if offense ='Theft F/Auto' and method='Attempt' then do;
    event = '68';
    ui_event = 172;
  end;
    else if offense ='Theft F/Auto' and  method in ('Other','Others') then do;
    event = '69';
    ui_event = 173;
  end;
   else if offense ='Theft F/Auto' and  method in ('Gun') then do;
    event = '69';
    ui_event = 174;
  end;
  else if offense ='Theft F/Auto' and  method in ('Knife') then do;
    event = '69';
    ui_event = 175;
  end;
  
  else if offense in ( 'Stolen Auto', 'Theft F/Auto' ) and method='Stolen Auto' then do;
    event = '70';
    ui_event = 180;
  end;
  else if offense ='Stolen Auto' and method='Attempt' then do;
    event = '71';
    ui_event = 181;
  end;
  else if offense ='Stolen Auto' and method in ('Other','Others') then do;
    event = '72';
    ui_event = 182;
  end;
  else if offense ='Stolen Auto' and method in ('Gun') then do;
    event = '72';
    ui_event = 183;
  end;
  else if offense ='Stolen Auto' and method in ('Knife') then do;
    event = '72';
    ui_event = 184;
  end;

  else if offense ='Arson' and method in ('Arson','Other','Others') then do;
    event = '80';
    ui_event = 190;
  end;

  else if offense ='Assault' and method='Simple' then do;
    event = '99';
    ui_event = 200;
  end;
  else if offense ='Assault' and method='Threats' then do;
    event = '99';
    ui_event = 201;
  end;
  
  else if offense ='Disorder' and method='Drinking' then do;
    event = '99';
    ui_event = 210;
  end;
  else if offense ='Disorder' and method='Indecent Exposure' then do;
    event = '99';
    ui_event = 211;
  end;
  else if offense ='Disorder' and method='Peeping Tom' then do;
    event = '99';
    ui_event = 212;
  end;
  else if offense ='Disorder' and method='Stalking' then do;
    event = '99';
    ui_event = 213;
  end;
  else if offense ='Disorder' and method='Unlawful Entry' then do;
    event = '99';
    ui_event = 214;
  end;
  
  else if offense ='Drug' and method='Cocaine Distribution' then do;
    event = '99';
    ui_event = 220;
  end;
  else if offense ='Drug' and method='Cocaine PWID' then do;
    event = '99';
    ui_event = 221;
  end;
  else if offense ='Drug' and method='Cocaine Possession' then do;
    event = '99';
    ui_event = 222;
  end;
  else if offense ='Drug' and method='Heroine Possession' then do;
    event = '99';
    ui_event = 223;
  end;
  else if offense ='Drug' and method='Marijuana' then do;
    event = '99';
    ui_event = 224;
  end;
  else if offense ='Drug' and method='Other' then do;
    event = '99';
    ui_event = 225;
  end;
  else if offense ='Drug' and method='Paraphanalia Poss' then do;
    event = '99';
    ui_event = 226;
  end;
  
  else if offense ='Fraud' and method='Fraud' then do;
    event = '99';
    ui_event = 230;
  end;
  else if offense ='Property Damage' and method='Property Damage' then do;
    event = '99';
    ui_event = 240;
  end;
  else if offense ='Property' and method='Destruction <=$200' then do;
    event = '99';
    ui_event = 241;
  end;
  else if offense ='Property' and method='Destruction > $200' then do;
    event = '99';
    ui_event = 242;
  end;
  else if offense ='Receiving Stln Prop' and method='Receiving Stln' then do;
    event = '99';
    ui_event = 250;
  end;
  else if offense ='Threats' and method='Threats' then do;
    event = '99';
    ui_event = 260;
  end;
  else if offense ='Assault' and method='Threats' then do;
    event = '99';
    ui_event = 260;
  end;
  else if offense ='Uttering' and method='Uttering' then do;
    event = '99';
    ui_event = 270;
  end;
  else if offense ='Warrant' and method='Bench' then do;
    event = '99';
    ui_event = 280;
  end;
  else if offense ='Warrant' and method='Fugitive F/J' then do;
    event = '99';
    ui_event = 281;
  end;
  else if offense ='Weapon' and method='Cdw' then do;
    event = '99';
    ui_event = 290;
  end;
  else if offense ='Weapon' and method='Cpwl' then do;
    event = '99';
    ui_event = 291;
  end;
  else if offense ='Weapon' and method='Ppwa' then do;
    event = '99';
    ui_event = 292;
  end;
  else if offense ='Weapon' and method='Ppwb' then do;
    event = '99';
    ui_event = 293;
  end;
  
  else if offense='Interstate R' and method='Interstate Recovery' then do;
    event = '99';
    ui_event = 300;
  end;
  
  else do;
    %warn_put( msg="Offense and weapon not found: " RecordNo= ccn= offense= method= )
  end;
  
  label
    event = 'MPD event code (type of crime, pt. 1 only)'
    ui_event = 'UI event code (type of crime, pts. 1 & 2)';
    
  format event $tcpevt. ui_event uievent.;

%mend Offense_to_event;

/** End Macro Definition **/

