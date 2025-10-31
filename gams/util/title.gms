************************************************************************
*
*   CAPRI-project
*
*   Filetype:    GAMS program file
*   Responsible: W.Britz
*   Purpose:     Write a block of strings to the console
*
*   See also:    util/title1.gms
*
************************************************************************
$iftheni %ShowTimeinTitleBatch%==ON;

$IF %JAVA%==ON snew_time = TimeElapsed;
$IF %JAVA%==ON sdiff_time = snew_time  - slast_time;
$IF %JAVA%==ON sexec_time = ( snew_time -sstart_time )/60;
$IF %JAVA%==ON putclose logfile 'title %PGMNAME%: ' '%LastTitlebatchTxt%'  ' - (' sdiff_time:6:0 ' sec. '  sexec_time:6:2 ' min. )';

$endif

$IF %JAVA%==ON putclose logfile 'title %PGMNAME%: ' %1 %2 %3 %4 %5 %6 %7 %8 %9 %10 %11 %12 %13 %14;

$iftheni %ShowTimeinTitleBatch%==ON

$IF %JAVA%==ON $setglobal LastTitlebatchTxt %1;
$IF %JAVA%==ON slast_time = TimeElapsed ;

$endif

$IF %JAVA%==ON $exit

$IF NOT %VERSION%==GAMS222 putclose batch "@title" ' %PGMNAME%: ' %1 %2 %3 %4 %5 %6 %7 %8 %9 %10 %11 %12 %13 %14;
$IF NOT %VERSION%==GAMS222 execute "%scrdir%\\%pgmname%titlebatch";

$IF %VERSION%==GAMS222 put_utility batch 'title' / ' %PGMNAME%: ' %1 %2 %3 %4 %5 %6 %7 %8 %9 %10 %11 %12 %13 %14;
