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

SET _seconds=%1
SET _maxtrys=%2
SET _FlagFiles=%3
SET _Mode=%4


set /a _trys=0
:again
IF %_Mode% EXIST %_FlagFiles% (
  set /a _trys+=1
  if %_trys%.==%_MaxTrys%. goto errorexit
  sleep.exe %_seconds%
  goto again
)



IF NOT %_Mode%.==NOT. EXIT /B 0


:testExist

   sleep.exe %_seconds%

set _test=
move %_FlagFiles% %_FlagFiles%>nul 2>nul
IF ERRORLEVEL 1 set _test=locked

IF %_test%.==locked. (
   sleep.exe %_seconds%
   goto testExist
)


REM --------------- success -----------------------------------------
EXIT /B 0

REM --------------- error --------------------------------------------
:errorexit
exit /B 50
