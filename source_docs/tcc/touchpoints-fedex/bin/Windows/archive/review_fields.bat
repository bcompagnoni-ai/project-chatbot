CLS
::@ECHO OFF

REM Ensure the current directory is set.
cd /d "%~dp0"

REM Set the environment variables.
Call Environment.bat %0

REM Run TCC.

Call core\TCC.bat "%SCRIPTS_FOLDER%\ReviewFields\ReviewFields_loop_cfg.xml" "%SCRIPTS_FOLDER%\ReviewFields\ReviewFields_loop_sq.xml" "%OUTBOUND_FOLDER%\review_fields_%NOW%.csv"

REM Exit
Exit /B %ERRORLEVEL%
