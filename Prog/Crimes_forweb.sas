/**************************************************************************
 Program:  Crime_forweb
 Library:  Police
 Project:  NeighborhoodInfo DC
 Author:   Rob Pitingolo
 Created:  11/07/2017
 Version:  SAS 9.4
 Environment:  Windows
 Modifications: 

**************************************************************************/

%include "L:\SAS\Inc\StdLocal.sas"; 

** Define libraries **;
%DCData_lib( Police )
%DCData_lib( Web )


/***** Update the let statements for the data you want to create CSV files for *****/

%let library = police; /* Library of the summary data to be transposed */
%let outfolder = crime; /* Name of folder where output CSV will be saved */
%let sumdata = crimes_sum; /* Summary dataset name (without geo suffix) */
%let start = 2000; /* Start year */
%let end = 2016; /* End year */
%let keepvars = crimes_pt1 Crimes_pt1_property Crimes_pt1_violent Crime_rate_pop; /* Summary variables to keep and transpose */


/***** Update the web_varcreate marcro if you need to create final indicators for the website after transposing *****/

%macro web_varcreate;

Crimes_pt1_property_per1000 = Crimes_pt1_property / Crime_rate_pop*1000;
Crimes_pt1_violent_per1000 = Crimes_pt1_violent / Crime_rate_pop*1000;

drop crimes_pt1 Crimes_pt1_property Crimes_pt1_violent Crime_rate_pop;

label Crimes_pt1_violent_per1000 = "Violent Crimes (per 1,000 pop.)"
	  Crimes_pt1_property_per1000 = "Property Crimes (per 1,000 pop.)";

%mend web_varcreate;



/**************** DO NOT UPDATE BELOW THIS LINE ****************/

%macro csv_create(geo);
			 
%web_transpose(&library., &outfolder., &sumdata., &geo., &start., &end., &keepvars. );

/* Load transposed data, create indicators for profiles */
data &sumdata._&geo._long_allyr;
	set &sumdata._&geo._long;
	%web_varcreate;
	label start_date = "Start Date"
		  end_date = "End Date"
		  timeframe = "Year of Data";
run;


/*Subset datasets by year 
%do j = &start. %to &end.;
data &sumdata._&geo._long_&j. ;
	set &sumdata._&geo._long_allyr;
	where timeframe ="&j." ;
run;*/


/* Create metadata for the dataset */
proc contents data = &sumdata._&geo._long_allyr out = &sumdata._&geo._metadata noprint;
run;

/* Output the metadata */
ods csv file ="&_dcdata_default_path.\web\output\&outfolder.\&outfolder._&geo._metadata..csv";
	proc print data =&sumdata._&geo._metadata noobs;
	run;
ods csv close;


/* Output the CSV */
ods csv file ="&_dcdata_default_path.\web\output\&outfolder.\&outfolder._&geo..csv";
	proc print data =&sumdata._&geo._long_allyr noobs;
	run;
ods csv close





/* Output each year as a separate CSV 
ods csv file ="&_dcdata_default_path.\web\output\&outfolder.\&geo.\&outfolder._&geo._&j..csv";
	proc print data =&sumdata._&geo._long_&j. noobs;
	run;
ods csv close;
%end;*/


%mend csv_create;
%csv_create (tr10);
%csv_create (tr00);
%csv_create (anc12);
%csv_create (wd02);
%csv_create (wd12);
%csv_create (city);
%csv_create (psa12);
%csv_create (zip);
%csv_create (cltr00);
%csv_create (cluster17);
