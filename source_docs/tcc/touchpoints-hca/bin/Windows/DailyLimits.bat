:: Run this batch file to get the export and import daily limits and actual count.
:: Results are found in the OUTBOUND_FOLDER\results_DailyLimit.txt

CLS
@ECHO OFF

REM Ensure the current directory is set.
cd /d "%~dp0"

REM Set the environment variables.
Call Environment.bat
TITLE %~nx0 - %TALEO_HOST% - %date% %time%

REM Run TCC.
Call core/TCC.bat "%SCRIPTS_FOLDER%\DailyLimits\DailyLimit_export_cfg.xml" "%SCRIPTS_FOLDER%\DailyLimits\DailyLimit_export_sq.xml" "%TEMP_FOLDER%\results_DailyLimit_export.xml"
Call core/TCC.bat "%SCRIPTS_FOLDER%\DailyLimits\DailyLimit_import_cfg.xml" "%SCRIPTS_FOLDER%\DailyLimits\DailyLimit.csv" "%TEMP_FOLDER%\results_DailyLimit_import.xml"

REM Format results with XSL.
"%TCC_HOME%\jre\bin\java.exe" -cp "%TCC_HOME%\lib\saxon8.jar" net.sf.saxon.Transform "%TEMP_FOLDER%\results_DailyLimit_export.xml" "%SCRIPTS_FOLDER%\DailyLimits\Format.xsl" >"%OUTBOUND_FOLDER%\results_DailyLimit.txt"
"%TCC_HOME%\jre\bin\java.exe" -cp "%TCC_HOME%\lib\saxon8.jar" net.sf.saxon.Transform "%TEMP_FOLDER%\results_DailyLimit_import.xml" "%SCRIPTS_FOLDER%\DailyLimits\Format.xsl" >>"%OUTBOUND_FOLDER%\results_DailyLimit.txt"

REM Remove temp files.
del "%TEMP_FOLDER%\results_DailyLimit_export.xml"
del "%TEMP_FOLDER%\results_DailyLimit_import.xml"
