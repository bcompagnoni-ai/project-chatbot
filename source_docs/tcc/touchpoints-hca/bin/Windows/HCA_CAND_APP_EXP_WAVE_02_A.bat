CLS
::@ECHO OFF
set IterationName=HCA_CAND_APP_EXP_WAVE_02_A
set PagingFile="%IterationName%.pgn"
set /a var=1
:LOOP
IF %var% gtr 2000 goto :END

REM Ensure the current directory is set.
cd /d "%~dp0"

REM Set the environment variables.
Call Environment.bat %0

REM Run TCC.

Call core\TCC.bat "C:\TCC\touchpoints-hca\scripts\%IterationName%_cfg.xml" "C:\TCC\touchpoints-hca\scripts\%IterationName%_sq.xml" "%OUTBOUND_FOLDER%\%IterationName%_%NOW%.csv"

ECHO "%OUTBOUND_FOLDER%\%PagingFile%"

IF EXIST "%OUTBOUND_FOLDER%\%PagingFile%" (
	set continue=true
) else (goto END
)

set /a var+=1
goto LOOP

REM Exit

:END
Exit /B %ERRORLEVEL%