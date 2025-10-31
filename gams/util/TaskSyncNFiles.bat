@REM *******************************************************************
@REM
@REM  TASKSYNC.BAT                               Status: 20.08.09  1
@REM
@REM  Synchronize support for separate started tasks
@REM
@REM  August 09, by H. J. Greuel
@REM
@REM  Institute for Food and Resource Economics, University of Bonn
@REM
@REM *******************************************************************

@ECHO OFF

setlocal enableextensions
setlocal ENABLEDELAYEDEXPANSION

SET _seconds=%1
SET _maxtrys=%2
SET _FlagFiles=%3
SET _nFiles=%4


set /a _maxTrys/=5
set /a _seconds*=5

set /a _trys=0
:again

set _count=1

for %%x in (%_FlagFiles%) do set /a _count+=1

REM @echo %_count% %_nFiles% >> d:\temp\test.txt

if %_count% gtr %_nFiles% (

  set /a _trys+=1

  if %_trys%.==%_MaxTrys%. goto errorexit

REM @echo %_trys% %_maxTrys% %_seconds% >> d:\temp\test.txt


  sleep.exe %_seconds%

  goto again

)

REM @echo After loop >> d:\temp\test.txt

REM --------------- success -----------------------------------------
EXIT /B 0

REM --------------- error --------------------------------------------
:errorexit
exit /B 50
