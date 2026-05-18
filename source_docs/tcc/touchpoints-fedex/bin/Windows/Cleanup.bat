REM Delete files that are older than a given number of days.

CLS
@ECHO OFF
TITLE %~nx0 - %date% %time%

REM Ensure the current directory is set.
cd /d "%~dp0"

REM Set the environment variables.
Call Environment.bat

REM Do the cleanup.
cscript core\Cleanup.vbs "%LOG_FOLDER%" %RETENTION_DAYS%
cscript core\Cleanup.vbs "%MONITOR_FOLDER%" %RETENTION_DAYS%
cscript core\Cleanup.vbs "%OUTBOUND_FOLDER%" %RETENTION_DAYS%
cscript core\Cleanup.vbs "%ARCHIVE_FOLDER%" %RETENTION_DAYS%
cscript core\Cleanup.vbs "%ERROR_FOLDER%" %RETENTION_DAYS%

REM TEMP_FOLDER is set to keep files only 1 day and delete subfolders.
cscript core\Cleanup.vbs "%TEMP_FOLDER%" 1 true
