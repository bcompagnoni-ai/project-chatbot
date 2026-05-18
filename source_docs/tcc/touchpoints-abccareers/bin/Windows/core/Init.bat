REM ---------------------------------------------------------------
REM            PARAMETERS 
REM ---------------------------------------------------------------
REM %1: Optional - Calling batch filename, used to set window title and log filename.

REM ---------------------------------------------------------------
REM            CONFIG BOARD
REM ---------------------------------------------------------------
REM Set the default config board.
SET DEFAULT_CONFIG_BOARD=%TCC_HOME%\system\default.configuration_brd.xml
If "%CONFIG_BOARD%"=="" (
	SET CONFIG_BOARD="%DEFAULT_CONFIG_BOARD%"
) 

REM If CONFIG_BOARD is only a filename, prefix it with CONFIG_BOARDS_FOLDER.
echo %CONFIG_BOARD%|findstr \\ >nul:
IF %errorlevel%==1 (
	SET CONFIG_BOARD=%CONFIG_BOARDS_FOLDER%\%CONFIG_BOARD%
)

REM ---------------------------------------------------------------
REM            VALIDATIONS
REM ---------------------------------------------------------------
If "%TCC_HOME%"=="" (
	echo ### ERROR - TCC_HOME variable is mandatory. ###
	pause
	exit 1
)
If Not Exist "%TCC_HOME%" (
	echo ### ERROR - The TCC_HOME path "%TCC_HOME%" does not exist. ###
	pause
	exit 1
)
If "%CONFIG_BOARD%"=="" (
	echo ### ERROR - CONFIG_BOARD variable is mandatory. ###
	pause
	exit 1
)
If Not Exist "%CONFIG_BOARD%" (
	echo ### ERROR - The configuration board file "%CONFIG_BOARD%" does not exist. ###
	pause
	exit 1
)

REM ---------------------------------------------------------------
REM            JAVA_HOME CONFIGURATION
REM ---------------------------------------------------------------
set JAVA_HOME=%TCC_HOME%\jre

REM ---------------------------------------------------------------
REM            READ TALEO_HOST FROM CONFIG BOARD
REM ---------------------------------------------------------------
call :GetDefaultHost TALEO_HOST

REM ---------------------------------------------------------------
REM            COUNT_ONLY CONFIGURATION
REM ---------------------------------------------------------------
IF "%COUNT_ONLY%"=="true" (
	SET LASTRUNDATE_FOLDER=%LASTRUNDATE_FOLDER%\Count
	SET OUTBOUND_FOLDER=%OUTBOUND_FOLDER%\Count
)

REM ---------------------------------------------------------------
REM            SET DATE AND TIME VARIABLES
REM ---------------------------------------------------------------
FOR /F "skip=1 tokens=1-6" %%A IN ('WMIC ^Path Win32_LocalTime Get Year^,Month^,Day^,Hour^,Minute^,Second /Format:table') DO (
  IF %%A GTR 0 (
		SET DD=%%A
		SET HH=%%B
		SET MI=%%C
		SET MM=%%D
		SET SS=%%E
		SET YYYY=%%F
  )
)
if %MM% LSS 10 set MM=0%MM%
if %DD% LSS 10 set DD=0%DD%
if %HH% LSS 10 set HH=0%HH%
if %MI% LSS 10 set MI=0%MI%
if %SS% LSS 10 set SS=0%SS%
SET YY=%YYYY:~2,2%

REM Build the NOW variable.
SET NOW=%YYYY%%MM%%DD%_%HH%%MI%%SS%

REM ---------------------------------------------------------------
REM            SET WINDOW TITLE
REM ---------------------------------------------------------------
TITLE %~nx1 - %TALEO_HOST% - %date% %time%

REM ---------------------------------------------------------------
REM            MULTI_ZONE CONFIGURATION
REM ---------------------------------------------------------------
SET TALEO_ZONE=%TALEO_HOST:~0,-10%

IF NOT "%MULTI_ZONE%"=="true" GOTO END_MULTI_ZONE
	SET LOG_FOLDER=%LOG_FOLDER%\%TALEO_ZONE%
	SET LASTRUNDATE_FOLDER=%LASTRUNDATE_FOLDER%\%TALEO_ZONE%
	SET MONITOR_FOLDER=%MONITOR_FOLDER%\%TALEO_ZONE%
	SET TEMP_FOLDER=%TEMP_FOLDER%\%TALEO_ZONE%
	SET OUTBOUND_FOLDER=%OUTBOUND_FOLDER%\%TALEO_ZONE%
	SET DOCUMENT_OUTBOUND_FOLDER=%DOCUMENT_OUTBOUND_FOLDER%\%TALEO_ZONE%
	SET DEFERRED_MERGE_FOLDER=%DEFERRED_MERGE_FOLDER%\%TALEO_ZONE%
:END_MULTI_ZONE

REM ---------------------------------------------------------------
REM            LOG CONFIGURATION 
REM ---------------------------------------------------------------
IF "%~n1"=="" (
	SET LOG_ID=%TALEO_ZONE%
) ELSE (
	SET LOG_ID=%TALEO_ZONE%_%~n1
)

REM ---------------------------------------------------------------
REM            OUTPUT FILE CONFIGURATION
REM ---------------------------------------------------------------
REM Output filename prefix and suffix. Leave empty for none.
SET OUTPUT_FILE_PREFIX=
SET OUTPUT_FILE_SUFFIX=_%YYYY%%MM%%DD%
SET OUTPUT_FILE_EXTENSION=csv

REM ---------------------------------------------------------------
REM            ADVANCED RUN CONFIGURATION
REM ---------------------------------------------------------------
REM Set the CURRENT_RUN_DATE variable.
IF "%CURRENT_RUN_DATE%"=="" (
	SET CURRENT_RUN_DATE=%YYYY%-%MM%-%DD% %HH%:%MI%:%SS%
)

REM Mask to apply to the current run date (yyyy-MM-dd 00:00:00 sets it back to midnight on the current day).
SET DATE_TIME_MASK=yyyy-MM-dd 00:00:00

REM Indicate if duplicates are removed in the result files (true/false).
SET REMOVE_DUPLICATES=true

REM Indicate if files are merged when looping (true/false).
REM If false, the OUTPUT_FILE_SUFFIX must contain a timestamp. A loop index will also be added to filename.
SET MERGE_FILES=true

REM Allows to defer merging the files until the end of the process (true/false) (see Operation Manual).
SET DEFERRED_MERGE=true

REM Settings relative to reaching limits.

set TRANSACTION_LIMIT_PATTERN=The number of entities returned by this export request (.*) has exceeded the max.*
set FILE_SIZE_LIMIT_PATTERN=The processing of this export request has generated a result whose size has exceeded the maximum allowed size*
set LOOP_DECREASE_FACTOR=2
set LOOP_INCREASE_FACTOR=1.5

REM Use the temporary files compression in TCC 12C and above (true/false).
SET COMPRESS_TEMP_FILES=false

REM ---------------------------------------------------------------
REM            SET DEFAULT VALUES
REM ---------------------------------------------------------------
set TIME_INCREMENT=0
set LOOP_INDEX=0
set LOOPING_ACTIVE=false
set PAGING_ACTIVE=false
set COMPLETE_EXIT_CODE=0
set END_LOOPING_EXIT_CODE=99
set LIMIT_EXIT_CODE=7
set DAILY_LIMIT_EXIT_CODE=33
set BREAK_EXIT_CODE=9
set PAGING_SIZE=100000

REM ---------------------------------------------------------------
REM            RESET THE ERRORLEVEL
REM ---------------------------------------------------------------
REM This simple trick resets the ERRORLEVEL to 0.
REM Note that "Set ERRORLEVEL=0" does not do, because once you set this variable explicitly 
REM then any command you run after will not be able to change the value of the %ERRORLEVEL%.
verify >nul

GOTO :EOF
REM ---------------------------------------------------------------
REM            FUNCTIONS
REM ---------------------------------------------------------------
:GetDefaultHost var -- Get the value of the default host in the configuration board file.
::									-- var [in/out] - The variable to set the value.
SETLOCAL ENABLEDELAYEDEXPANSION
set var=!%~1!
path "%JAVA_HOME%\bin\"
for /F "delims=" %%a in ('java.exe -jar "%TCC_HOME%\lib\saxon8.jar" "%CONFIG_BOARD%" ..\xsl\GetDefaultHost.xsl') do set value=%%a
( ENDLOCAL & REM RETURN VALUES
	SET %~1=%value%
)
EXIT /b
