/**************************************************************************
 Adapted from: Prog/Juvenile_arrests_2006.sas  (NeighborhoodInfoDC/Police)
 Original author: P. Tatian.  Read CJIS juvenile arrest data from the
 OCTO data feed and recode geography, birth date, and arrest / offense /
 booking date-times to SAS date and time values. The XML LIBNAME source
 is replaced with a small in-line sample of the same column shape; the
 date/informat recoding logic, age calculation, labels and formats are
 reproduced as written. The UI %File_info call is replaced with PROC
 PRINT / PROC FREQ so the script is self-contained.
**************************************************************************/

data arrestedjuvenile;
  length ward $ 4 neighborhoodcluster $ 4
         arrestdatetime $ 19 offensedatetime $ 19 bookingdatetime $ 19;
  input ward $ neighborhoodcluster $ dateofbirth
        arrestdatetime $ offensedatetime $ bookingdatetime $;
  datalines;
2 18 19900115 2006-03-04T14:30:00 2006-03-04T13:05:00 2006-03-04T16:20:00
NONE NONE 19911207 2006-05-21T22:10:00 2006-05-21T21:45:00 2006-05-22T01:30:00
6 39 19890630 2006-08-09T09:00:00 2006-08-08T23:50:00 2006-08-09T11:15:00
4 2 19920922 2006-11-30T18:45:00 2006-11-30T18:30:00 2006-11-30T20:00:00
;
run;

data juvenile_arrests_2006 (label="Juvenile arrest locations from MPD CJIS, DC, 2006");

  set arrestedjuvenile;

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

proc print data=juvenile_arrests_2006 label noobs;
  var ward2002 cluster2000 DateOfBirth ArrestDate ArrestTime AgeArrest
      OffenseDate BookingDate;
  title 'Recoded juvenile arrest records (sample), DC 2006';
run;
