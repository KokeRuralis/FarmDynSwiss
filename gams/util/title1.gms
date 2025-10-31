************************************************************************
*
*   CAPRI-project
*
*   Filetype:    GAMS program file
*   Responsible: W.Britz
*   Purpose:     Defines a file to which messages are written. Under
*                java, that is the GAMS logfile piped into stdout.
*
*   Remarks:     Regularly used in all CAPRI projects
************************************************************************
$IF %JAVA%==ON file logfile "writing directly into the log" / ''/;

$IF     %VERSION%==GAMS222    file batch /"%gams.SCRDIR%/%PGMNAME%titlebatch.bat"/;
$IF NOT %VERSION%==GAMS222    file batch /"%gams.SCRDIR%/%PGMNAME%titlebatch.bat"/;

$IF NOT %VERSION%==GAMS222    batch.ap = 0;
                              batch.pw = 9999;
$IF NOT %VERSION%==GAMS222    batch.nw = 0;
$IF NOT %VERSION%==GAMS222    batch.lw = 0;

$IF %JAVA%==ON $exit
