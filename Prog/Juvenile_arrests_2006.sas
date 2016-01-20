/**************************************************************************
 Program:  Juvenile_arrests_2006.sas
 Library:  Police
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  07/26/08
 Version:  SAS 9.1
 Environment:  Windows
 
 Description:  Read CJIS juvenile arrest data from OCTO data feed.
 http://data.octo.dc.gov/Main_DataCatalog_Go.aspx?category=6&filter=CJIS&view=All

 Modifications:
**************************************************************************/

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";

** Define libraries **;
%DCData_lib( Police )

%let year = 2006;

libname xmlR xml "D:\DCData\Libraries\Police\Raw\cjis_juvenile_&year._plain.xml";

*options obs=20;

data Police.Juvenile_arrests_&year (label="Juvenile arrest locations from MPD CJIS, DC, &year");

  set xmlR.ArrestedJuvenile;
  
  ** Remove existing labels and formats **;
  
  format _all_ ;
  informat _all_ ;  
  attrib _all_ label="";
  
  ** Create standard geography vars **;
  
  length ward2002 $ 1 cluster2000 $ 2;
  
  if ward ~= 'NONE' then ward2002 = ward;
  
  if NEIGHBORHOODCLUSTER ~= 'NONE' then 
    cluster2000 = put( input( NEIGHBORHOODCLUSTER, 2. ), z2. );
  
  ** Recode birth date to SAS date value **;
  
  xDateOfBirth = input( left( put( dateofbirth, 8. ) ), yymmdd8. );
  
  label
    xDateOfBirth = "Date of birth of arrestee";

  format xDateOfBirth mmddyy10.;  
  
  rename xDateOfBirth=DateOfBirth;
  
  drop DateOfBirth;
  
  ** Recode arrest date/time to SAS date & time values **;
  
  ArrestDate = input( substr( ARRESTDATETIME, 1, 10 ), yymmdd10. );
  
  ArrestTime = input( substr( ARRESTDATETIME, 12, 8 ), time8. ); 
  
  label
    ArrestDate = 'Date of arrest'
    ArrestTime = 'Time of arrest';
  
  format ArrestDate mmddyy10. ArrestTime time5.;
  
  ** Calculate age at time of arrest **;
  
  AgeArrest = int( ( ArrestDate - xDateOfBirth ) / 365.25 );
  
  label AgeArrest = 'Age at time of arrest (years) [calculated]';

  ** Recode offense date/time to SAS date & time values **;
  
  OffenseDate = input( substr( OFFENSEDATETIME, 1, 10 ), yymmdd10. );
  
  OffenseTime = input( substr( OFFENSEDATETIME, 12, 8 ), time8. ); 
  
  label
    OffenseDate = 'Date of offense'
    OffenseTime = 'Time of offense';
  
  format OffenseDate mmddyy10. OffenseTime time5.;
  
  ** Recode booking date/time to SAS date & time values **;
  
  BookingDate = input( substr( BOOKINGDATETIME, 1, 10 ), yymmdd10. );
  
  BookingTime = input( substr( BOOKINGDATETIME, 12, 8 ), time8. ); 
  
  label
    BookingDate = 'Date of booking'
    BookingTime = 'Time of booking';
  
  format BookingDate mmddyy10. BookingTime time5.;
  
run;

%File_info( data=Police.Juvenile_arrests_&year, 
            freqvars=ward ward2002 neighborhoodcluster cluster2000 offensedescription 
                     drugdescription weapondescription weaponcode
                     gender race AgeArrest )

proc freq data=Police.Juvenile_arrests_&year;
  tables ArrestDate BookingDate OffenseDate;
  format ArrestDate BookingDate OffenseDate year4.;
  label 
    ArrestDate = 'Year of arrest' 
    BookingDate = 'Year of booking'
    OffenseDate = 'Year of offense';
run;

