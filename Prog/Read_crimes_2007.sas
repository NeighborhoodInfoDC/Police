/**************************************************************************
 Program:  Read_crimes_2007.sas
 Library:  Police
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  09/17/08
 Version:  SAS 9.1
 Environment:  Windows
 
 Description:  Read in preliminary crime report data from MPD.
 
 Must open Excel workbook Raw\03-25-2008\Clean_2007.xls 
 before running program.

 Modifications:
**************************************************************************/

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";

** Define libraries **;
%DCData_lib( Police )

%Read_crimes(
  year = 2007
)

** Compare with earlier data **;

data A;

  set 
    Police.crimes_2007 (in=in1)
    Police.crimes_2007_09_17_08;
    
  total = 1;

  if in1 then do;
    new = 1;
    change = 1;
  end;
  else do;
    old = 1;
    change = -1;
  end;
  
run;

proc format;
  value file
    1 = 'New File'
    2 = 'Old File';
  value $wd (notsorted)
    '1' = 'Ward 1'
    '2' = 'Ward 2'
    '3' = 'Ward 3'
    '4' = 'Ward 4'
    '5' = 'Ward 5'
    '6' = 'Ward 6'
    '7' = 'Ward 7'
    '8' = 'Ward 8'
    ' ' = 'Unknown';

options missing='-';

ods rtf file="&_dcdata_path\police\prog\Read_crimes_2007.rtf" style=Styles.Rtf_arial_9pt;

proc tabulate data=A format=comma12.0 noseps missing;
  where 100 <= ui_event <= 199;
  class ui_event;
  class ward2002 / preloadfmt order=data;
  var new old change;
  table 
    /** Rows **/
    all='\b TOTAL CRIMES' ui_event=' ',
    /** Columns **/
    sum='Pt 1 crimes, 2007' * ( new='New File' old='Old File' )
    change=' ' * ( sum='Difference' pctsum<old>='%' * f=comma10.1 );
  table 
    /** Rows **/
    all='\b TOTAL CRIMES' ward2002=' ',
    /** Columns **/
    sum='Pt 1 crimes, 2007' * ( new='New File' old='Old File' )
    change=' ' * ( sum='Difference' pctsum<old>='%' * f=comma10.1 );
   format ui_event uievsum. ward2002 $wd.;
  title2 'New / Old File Comparison, 2007';
run;

ods rtf close;

