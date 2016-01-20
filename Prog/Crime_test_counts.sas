%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";
%DCData_lib( Police )

proc means n sum data=police.tcap1998;
title2 '1998';
run;

proc means n sum data=police.tcap2000;
title2 '2000';
run;

proc freq data=police.tcap2000_raw;
  tables event;
run;
