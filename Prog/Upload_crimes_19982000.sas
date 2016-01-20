/**********************************************************************
 Program:  Upload_crimes_19982000.sas
 Library:  Police
 Project:  NeighborhoodInfo DC
 Author:   B. Williams
 Created:  June 9, 2005
 Version:  SAS 8.2
 Environment:  Windows with SAS/Connect
 
 Description:  Upload DC 1998-2000 Crime Reports to the Alpha

 Modifications:
***********************************************************************/

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";
%include "K:\Metro\PTatian\DCData\SAS\Inc\AlphaSignon.sas" /nosource2;

** Define libraries **;
%DCData_lib(Police);



** Upload data set to Alpha **;

rsubmit;

proc upload status=no
	inlib=Police 
	outlib=Police memtype=(data);
		select Crimes_1998_dc Crimes_1999_dc Crimes_2000_dc;
run;


** Purge older versions of data sets **;

options noxwait;

x "purge [dcdata.police.data]*.*";

run;

endrsubmit;



** Upload formats to Alpha **;

rsubmit;

proc upload status=no
  inlib=Police 
  outlib=Police memtype=(catalog);
	  select formats;
run;

endrsubmit;



** Register data set with metadata system **;

rsubmit;

%Dc_update_meta_file
  (ds_lib=Police,
  ds_name=Crimes_1998_DC,
  creator_process=Crimes_1998_dC.sas,
  restrictions=Confidential,
  revisions=New file.);

%Dc_update_meta_file
  (ds_lib=Police,
  ds_name=Crimes_1999_DC,
  creator_process=Crimes_1999_DC.sas,
  restrictions=Confidential,
  revisions=New file.);

%Dc_update_meta_file
  (ds_lib=Police,
  ds_name=Crimes_2000_DC,
  creator_process=Crimes_2000_DC.sas,
  restrictions=Confidential,
  revisions=New file.);

run;

endrsubmit;
 

run;

signoff;
