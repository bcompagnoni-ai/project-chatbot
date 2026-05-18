CLS
::@ECHO OFF

REM Ensure the current directory is set.
cd /d "%~dp0"

REM Set the environment variables.
Call Environment.bat %0

REM Run TCC.

Call core\TCC.bat "%SCRIPTS_FOLDER%\CandidateAttachment\CandidateApplicationAttachedFiles_Visible_cfg.xml" "%SCRIPTS_FOLDER%\CandidateAttachment\CandidateApplicationAttachedFiles_Visible_sq.xml" "%OUTBOUND_FOLDER%\candidate_attach_%NOW%.csv"

REM Exit
Exit /B %ERRORLEVEL%
