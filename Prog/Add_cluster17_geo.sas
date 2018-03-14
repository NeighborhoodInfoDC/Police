/**************************************************************************
 Program:  Add_cluster17_geo.sas
 Library:  Police
 Project:  NeighborhoodInfo DC
 Author:   Rob Pitingolo
 Created:  02/06/2018
 Version:  SAS 9.4
 Environment:  Windows 7
 
 Description:  Adds the Cluster17 geography to crimes_yyyy from 2000
			   to 2016. Future crime updates will have Cluster17 added
			   automatically as a standard geography. 
 
 Modifications:
**************************************************************************/

%include "L:\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( Police )

%macro addcluster17 (year);

%do year = 2000 %to 2016;

%if &year < 2007 %then %let ds_lbl = Preliminary part 1 & 2 crime reports, &year, DC;
%else %let ds_lbl = Preliminary part 1 crime reports, &year, DC;

%let revisions = Added Cluster2017 Geography. ;

%let freqvars = offense method location ui_event
                district psa2004_district 
                city psa psa2004 psa2012 ward ward2002 ward2012 
                anc2002 anc2012 cluster2000 cluster_tr2000 
                zip geo2000 geo2010 VoterPre2012 bridgepk cluster2017;

data crime_addcluster17_&year.;
	set police.crimes_&year.;
	%Block00_to_cluster17();
run;

%Finalize_data_set(
    data=crime_addcluster17_&year.,
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
%mend addcluster17;
%addcluster17;


/* End of Program */
