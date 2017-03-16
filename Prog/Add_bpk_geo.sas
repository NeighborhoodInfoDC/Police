/**************************************************************************
 Program:  Add_bpk_geo.sas
 Library:  Police
 Project:  NeighborhoodInfo DC
 Author:   Rob Pitingolo
 Created:  03/16/17
 Version:  SAS 9.4
 Environment:  Windows 7
 
 Description:  Adds the Bridge Park geography to crimes_yyyy from 2000
			   to 2016. Future crime updates will have Bridge Park added
			   automatically as a standard geography. 
 
 Modifications:
**************************************************************************/

%include "L:\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( Police )

%macro addbpk (year);

%do year = 2000 %to 2016;

%if &year < 2007 %then %let ds_lbl = Preliminary part 1 & 2 crime reports, &year, DC;
%else %let ds_lbl = Preliminary part 1 crime reports, &year, DC;

%let revisions = Added Bridge Park Geography. ;

%let freqvars = offense method shift location status code
                district psa2004_district 
                city psa psa2004 psa2012 ward ward2002 ward2012 
                anc2002 anc2012 cluster2000 cluster_tr2000 
                zip geo2000 geo2010 VoterPre2012 bridgepk;

data crime_addbpk_&year.;
	set police.crimes_&year.;
	%Block00_to_bpk( )
run;

%Finalize_data_set(
    data=crime_addbpk_&year.,
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
%mend addbpk;
%addbpk;

/* End of Program */
