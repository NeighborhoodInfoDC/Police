/**************************************************************************
 Program:  62_Add_ANC2023.sas
 Library:  Police
 Project:  Urban-Greater DC
 Author:   P. Tatian
 Created:  07/04/25
 Version:  SAS 9.4
 Environment:  Local Windows session (desktop)
 GitHub issue:  62
 
 Description:  Add ANC2023 to Crimes_???? data sets.

 Modifications:
**************************************************************************/

%include "\\sas1\DCdata\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( Police )

** Update crime data sets **;

/** Macro Update_crime_data - Start Definition **/

%macro Update_crime_data( );

  %local y ds_label;

  %do y = 2000 %to 2024; 
  
    %if &y <= 2006 %then %let ds_label = "Preliminary part 1 & 2 crime reports, &y., DC";
    %else %let ds_label = "Preliminary part 1 crime reports, &y., DC";

  data Crimes_&y;

    set Police.Crimes_&y;
    
    %Block20_to_anc23()
    
  run;

  %Finalize_data_set( 
    /** Finalize data set parameters **/
    data=Crimes_&y,
    out=Crimes_&y,
    outlib=Police,
    label=&ds_label,
    sortby=ccn,
    /** Metadata parameters **/
    restrictions=None,
    revisions=%str(Add ANC2023.),
    /** File info parameters **/
    contents=Y,
    printobs=0,
    freqvars=Anc2023,
    stats=
  )

  title2 "**** Crimes_&y - Missing Blocks/Wards";
  proc print data=Crimes_&y;
    where missing( anc2023 ) and not missing( GeoBlk2020 );
    var GeoBlk2020 Anc2023;
  run;
  title2;
  
  %end;

%mend Update_crime_data;

/** End Macro Definition **/


%Update_crime_data( )
