options obs=100;

/* Minimal stand-in for the Urban Institute %warn_put autocall macro,
   which writes a warning line to the log. Supplied here so the
   verbatim %Offense_to_event macro resolves outside the UI library. */
%macro warn_put( msg= );
  put "WARNING: " &msg;
%mend warn_put;
