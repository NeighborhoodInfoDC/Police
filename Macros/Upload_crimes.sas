/**************************************************************************
 Program:  Upload_crimes.sas
 Library:  Police
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  12/08/06
 Version:  SAS 8.2
 Environment:  Windows
 
 Description:  Autocall macro to upload crime records and register
 metadata.

 Modifications:
**************************************************************************/

/** Macro Upload_crimes - Start Definition **/

%macro Upload_crimes( year= , revisions=New file. );

  %syslput year=&year;
  %syslput revisions=&revisions;

  rsubmit;
  
  ** Upload file **;
  
  proc upload status=no
    inlib=Police 
    outlib=Police memtype=(data);
    select Crimes_&year;

  run;
  
  x "purge [dcdata.Police.data]Crimes_&year..*";
  
  ** Register in metadata **;
  
  %Dc_update_meta_file(
    ds_lib=Police,
    ds_name=Crimes_&year,
    creator_process=Read_crimes_&year..sas,
    restrictions=None,
    revisions=%str(&revisions)
  )
  
  run;
  
  endrsubmit;

%mend Upload_crimes;

/** End Macro Definition **/

