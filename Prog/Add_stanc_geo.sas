/**************************************************************************
 Program:  Add_stanc_geo.sas
 Library:  Police
 Project:  NeighborhoodInfo DC
 Author:   Yipeng Su
 Created:  05/16/2018
 Version:  SAS 9.4
 Environment:  Windows 7
 
 Description:  Adds the stantoncommons geography to crimes_yyyy from 2000
			   to 2017. Future crime updates will have Stantoncommons added
			   automatically as a standard geography. 
 
 Modifications:
**************************************************************************/

%include "L:\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( Police )

%macro addstantoncommons (year);

%do year = 2000 %to 2016;

%if &year < 2007 %then %let ds_lbl = Preliminary part 1 & 2 crime reports, &year, DC;
%else %let ds_lbl = Preliminary part 1 crime reports, &year, DC;

%let revisions = Added StantonCommons Geography. ;

%let freqvars = offense method location ui_event
                district psa2004_district 
                city psa psa2004 psa2012 ward ward2002 ward2012 
                anc2002 anc2012 cluster2000 cluster_tr2000 
                zip geo2000 geo2010 VoterPre2012 bridgepk cluster2017 stantoncommons;

data crime_addstantoncommons_&year.;
	set police.crimes_&year.;
	%Block00_to_stantoncommons();
run;

%Finalize_data_set(
    data=crime_addstantoncommons_&year.,
    out=Crimes_&year.,
    outlib=Police,
    label="&ds_lbl",
    sortby=reportdate Start_Time,
    /** Metadata parameters **/
    revisions=%str(&revisions),
    /** File info parameters **/
    printobs=5,
    freqvars=&freqvars
  )

%end;
%mend addstantoncommons;
%addstantoncommons;


/* End of Program */
