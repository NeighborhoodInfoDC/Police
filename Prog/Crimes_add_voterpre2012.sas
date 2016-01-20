/**************************************************************************
 Program:  Crimes_add_voterpre2012.sas
 Library:  Police
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  03/30/14
 Version:  SAS 9.2
 Environment:  Remote Windows session (SAS1)
 
 Description:  Add voterpre2012 to Crimes_yyyy data sets.

 Modifications:
**************************************************************************/

%include "F:\DCData\SAS\Inc\StdRemote.sas";

** Define libraries **;
%DCData_lib( Police )

/** Macro Process_all - Start Definition **/

%macro Process_all( );

  %local year label;
  
  %do year = 2000 %to 2011;
  
    %if &year < 2007 %then %let label = Preliminary part 1 & 2 crime reports;
    %else %let label = Preliminary part 1 crime reports;

    data Crimes_&year (label="&label, &year, DC");

      set Police.Crimes_&year;
      
      %Block00_to_vp12()

    run;

    proc datasets library=Police memtype=(data);
      change Crimes_&year=xxx_Crimes_&year /memtype=data;
      copy in=work out=Police memtype=data;
        select Crimes_&year;
    quit;

    %File_info( data=Police.Crimes_&year, printobs=0, freqvars=voterpre2012 )
    
    %Dc_update_meta_file(
      ds_lib=Police,
      ds_name=Crimes_&year,
      creator_process=Crimes_add_voterpre2012.sas,
      restrictions=None,
      revisions=%str(Added var voterpre2012 to data set.)
    )

  %end;

%mend Process_all;

/** End Macro Definition **/


%Process_all()
