REM Arguments:
REM %1: Mandatory - TCC configuration file
REM %2: Optional  - Maximum duration used as time increment. Defined as a number of days or using the duration XML schema (http://www.w3.org/TR/xmlschema-2/#duration)
REM									If absent or 0, the increment is an infinite duration.


REM If COUNT_ONLY is true, simply call TCC and quit.
IF "%COUNT_ONLY%"=="true" (
  ECHO Count only: "%~1"
	CALL TCC.bat "%~1"
	GOTO END
)


REM Set MAX_DURATION.
SET MAX_DURATION=0
IF NOT "%~2"=="" (
  ECHO First param "%~1"
  ECHO Second param "%~2"
	SET MAX_DURATION=%~2
)
	
REM Store ABORT_ON_RERUN in a temporary variable.
SET ABORT_ON_RERUN_TEMP=%ABORT_ON_RERUN%

REM Set the exit code when execution ends because the last run date has reached the current date.
SET END_LOOPING_EXIT_CODE=99

REM Set the loop index.
SET LOOP_INDEX=0

REM Main loop calling TCC while ERRORLEVEL==0. 
:LOOP
	
	REM Increment the LOOP_INDEX.
	SET /a LOOP_INDEX=%LOOP_INDEX% + 1
	
	REM Call TCC.
	CALL core\TCC.bat "%~1"
	
	REM Set ABORT_ON_RERUN to true on subsequent loops.
	SET ABORT_ON_RERUN=true
	
	REM Loop if no error.
	echo Error Type: %ERRORLEVEL
	IF %ERRORLEVEL%==0 GOTO LOOP

:END_LOOP
	
REM Reset the ERRORLEVEL if it is the expected end of looping code.
IF %ERRORLEVEL%==%END_LOOPING_EXIT_CODE% (
	VERIFY >nul
)

REM Reset variables.
SET END_LOOPING_EXIT_CODE=0
SET LOOP_INDEX=0
SET ABORT_ON_RERUN=%ABORT_ON_RERUN_TEMP%
SET MAX_DURATION=0

:END
REM Exit with the ERRORLEVEL.
EXIT /B %ERRORLEVEL%