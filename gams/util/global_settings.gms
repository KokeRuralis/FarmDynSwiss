*
*  inherit $ options to included files
*
$ONGLOBAL
$OFFDIGIT

*
*  allow overwriting of definitions, here used for dummy declarations
$ONMULTI

$setglobal JAVA ON

*
* allow empty parameter statements etc.
$ONEMPTY
*
* allow empty parameter statements etc.
  option LIMROW = 0;
  option LIMCOL = 0;
*
*   --- GAMS version, if GAMS213,
*       model.solvelink will be used to speed up processing
*
$SETGLOBAL VERSION GAMS222
$SETGLOBAL NoProc 2
$setglobal addfile
*
*  shows the time differneces between title batch is called
$setglobal ShowTimeinTitleBatch OFF
*
scalar slast_time/0/;
scalar snew_time/0/;
scalar sdiff_time/0/;
scalar sstart_time/0/;
sstart_time = TimeElapsed;
scalar sexec_time/0/;
*
