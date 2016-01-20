/**************************************************************************
 Program:  Upload_Tcap_1998_clean.sas
 Library:  Police
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  03/25/05
 Version:  SAS 8.2
 Environment:  Windows with SAS/Connect
 
 Description:  Upload and register TCAP 1998 (crime reports) data
 set.

 Modifications:
**************************************************************************/

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";
%include "K:\Metro\PTatian\DCData\SAS\Inc\AlphaSignon.sas" /nosource2;

** Define libraries **;
%DCData_lib( Police )

rsubmit;

%let filename = Tcap_1998_clean;

** Upload file **;

proc upload status=no
	inlib=Police
	outlib=Police memtype=(data);
	select &filename;
run;

** Register file metadata **;

%Dc_update_meta_file(
  ds_lib=Police,
  ds_name=&filename,
  creator_process=&filename..sas,
  restrictions=Confidential,
  revisions=Test file creation (does not include assaults with a deadly weapon and homicides).
);

endrsubmit;

signoff;
