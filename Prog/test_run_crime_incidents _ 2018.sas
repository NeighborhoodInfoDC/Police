NOTE: Copyright (c) 2002-2012 by SAS Institute Inc., Cary, NC, USA.
NOTE: SAS (r) Proprietary Software 9.4 (TS1M1)
      Licensed to THE URBAN INSTITUTE, Site 70097024.
NOTE: This session is executing on the X64_7PRO  platform.



NOTE: Updated analytical products:

      SAS/STAT 13.1
      SAS/ETS 13.1

NOTE: Additional host information:

 X64_7PRO WIN 6.1.7601 Service Pack 1 Workstation

NOTE: SAS initialization used:
      real time           1.46 seconds
      cpu time            0.63 seconds

1    data test;
2
3    set police.Crime_incidents_2017_w_block;
ERROR: Libref POLICE is not assigned.
4
5    businessim = bid;
6    drop bid;
7
8
9
10
11   run;

NOTE: The SAS System stopped processing this step because of errors.
WARNING: The data set WORK.TEST may be incomplete.  When this step was stopped there were 0
         observations and 1 variables.
NOTE: DATA statement used (Total process time):
      real time           0.00 seconds
      cpu time            0.01 seconds


