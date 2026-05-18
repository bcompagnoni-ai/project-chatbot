REM %1: Configuration file (e.g. %SCRIPTS_FOLDER%\Candidate_merge\Candidate_merge_cfg.xml)
REM %2: Input file pattern (e.g. Candidate_*.csv). Will be prepended with %FTP_INBOUND_FOLDER%\.
REM %3: Output file prefix (e.g. result_). Will be prepended to input file name and placed in the %FTP_OUTBOUND_FOLDER% by TCC.

REM Create temp folder.
if not exist "%TEMP_FOLDER%" mkdir "%TEMP_FOLDER%"

REM Get List of files from FTP in a temporary list.
Set FTP_LIST=%TEMP_FOLDER%\FTP_List_%RANDOM%.tmp
REM Create a temporary script file.
set TEMP_FTP=%TEMP_FOLDER%\temp_%RANDOM%.ftp
>%TEMP_FTP% ECHO open %FTP_HOST% %FTP_PORT%
>>%TEMP_FTP% ECHO %FTP_USER%
>>%TEMP_FTP% ECHO %FTP_PASSWORD%
>>%TEMP_FTP% ECHO cd %FTP_INBOUND_FOLDER%
>>%TEMP_FTP% ECHO prompt n
>>%TEMP_FTP% ECHO mls "%~2" "%FTP_LIST%"
>>%TEMP_FTP% ECHO bye
REM Use the temporary script for unattended FTP.
FTP -s:%TEMP_FTP%
REM Delete the temporary script file.
DEL %TEMP_FTP%

REM Loop on each file in the temporary list.
setlocal enabledelayedexpansion
set LOOP_INDEX=0
set ERR=0
For /f %%i in (%FTP_LIST%) do (
 	If !ERR!==0 (
		set /a LOOP_INDEX=!LOOP_INDEX! + 1
    Call :runTCC "%~1" "%%i" "%~3" ERR
	) Else (
		Exit /B !ERR!
	)
)
endlocal

REM Delete the temporary list.
DEL "%FTP_LIST%"
GOTO END

:runTCC
	REM Run TCC.
	Call core\TCC.bat "%~f1" "%~2" "%~3%~2"
	
	REM Set the ERR variable (fourth argument) to force exiting the loop on error.
	set %~4=%ERRORLEVEL%
GOTO END

:END