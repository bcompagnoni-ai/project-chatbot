REM Arguments:
REM %1: Mandatory - TCC configuration file
REM %2: Mandatory - TCC query file
REM %3: Optional  - Initial time increment in number of days (integer or decimal).
REM									If absent the INITIAL_TIME_INCREMENT set in the Environment file will be used. If 0, the increment is infinite.
REM %4: Optional  - Name of the result file (default: the query file name excluding the _sq.xml)

REM If COUNT_ONLY is true, simply call TCC and quit.
IF NOT "%COUNT_ONLY%"=="true" GOTO END_COUNT_ONLY
	call core\TCC.bat "%~1" "%~2"
	exit /B %ERRORLEVEL%
:END_COUNT_ONLY

SET LOOPING_ACTIVE=true

REM Set default CURRENT_RUN_DATE to the beginning of execution, otherwise time increment will loop forever if there is no LRD masking.
set CURRENT_RUN_DATE_TEMP=%CURRENT_RUN_DATE%
IF "%CURRENT_RUN_DATE%"=="" (
	SET CURRENT_RUN_DATE=%YYYY%-%MM%-%DD% %HH%:%MI%:%SS%
)

REM Get the EXTRACT_ID.
SET EXTRACT_ID=%~n2
SET EXTRACT_ID=%EXTRACT_ID:~0,-3%

REM Store a temporary copy of original variables.
set ABORT_ON_RERUN_ORIG=%ABORT_ON_RERUN%
set MERGE_FILES_ORIG=%MERGE_FILES%
set FTP_ACTIVE_ORIG=%FTP_ACTIVE%
set OUTBOUND_FOLDER_ORIG=%OUTBOUND_FOLDER%
set OUTPUT_FILE_SUFFIX_ORIG=%OUTPUT_FILE_SUFFIX%
set INITIAL_TIME_INCREMENT_ORIG=%INITIAL_TIME_INCREMENT%
set COMPLETE_EXIT_CODE_ORIG=%COMPLETE_EXIT_CODE%

REM Set INITIAL_TIME_INCREMENT and initialize TIME_INCREMENT.
IF NOT "%~3"=="" (
	SET INITIAL_TIME_INCREMENT=%~3
)
SET TIME_INCREMENT=%INITIAL_TIME_INCREMENT%

REM Set COMPLETE_EXIT_CODE to END_LOOPING_EXIT_CODE while looping.
set COMPLETE_EXIT_CODE=%END_LOOPING_EXIT_CODE%

REM Set the loop index.
set /a LOOP_INDEX=0

REM Count files waiting to be merged.
SET /a DEFERRED_MERGE_COUNT=0 
FOR %%a in ("%DEFERRED_MERGE_FOLDER%\%EXTRACT_ID%\*") do set /a DEFERRED_MERGE_COUNT+=1

REM Validate switch to DEFERRED_MERGE=false.
IF %DEFERRED_MERGE_COUNT% neq 0 (
	IF "%DEFERRED_MERGE%"=="false" (
		echo ### ERROR - You cannot switch to 'DEFERRED_MERGE=false' because there are files in %DEFERRED_MERGE_FOLDER%\%EXTRACT_ID%\ waiting to be merged. ###
		exit /B 1
	)
)

REM Initialize the loop without merging files when deferred merge is active.
IF "%DEFERRED_MERGE%"=="true" (
	SET MERGE_FILES=false

	REM Also do not abort on rerun if there are files waiting to be merged.
	IF %DEFERRED_MERGE_COUNT% neq 0 (
		SET ABORT_ON_RERUN=false
	)
)

REM Main loop calling TCC. 
:LOOP	
	REM Increment the LOOP_INDEX.
	set /a LOOP_INDEX+=1
	
	REM Build the PADDED_LOOP_INDEX, up to 9999.
	set PADDED_LOOP_INDEX=%LOOP_INDEX%
	IF 1%PADDED_LOOP_INDEX% LSS 100 SET PADDED_LOOP_INDEX=0%PADDED_LOOP_INDEX%
	IF 1%PADDED_LOOP_INDEX% LSS 1000 SET PADDED_LOOP_INDEX=0%PADDED_LOOP_INDEX%
	IF 1%PADDED_LOOP_INDEX% LSS 10000 SET PADDED_LOOP_INDEX=0%PADDED_LOOP_INDEX%
	
	REM Build OUTPUT_FILE_SUFFIX.
	IF "%DEFERRED_MERGE%"=="true" (
		SET OUTPUT_FILE_SUFFIX=_%YYYY%%MM%%DD%_%HH%%MI%%SS%_%PADDED_LOOP_INDEX%
	)
	IF "%MERGE_FILES%"=="true" (
		SET OUTPUT_FILE_SUFFIX=%OUTPUT_FILE_SUFFIX_ORIG%
	)
	IF "%MERGE_FILES_ORIG%"=="false" (
		SET OUTPUT_FILE_SUFFIX=%OUTPUT_FILE_SUFFIX_ORIG%_%PADDED_LOOP_INDEX%
	)

	REM Make adjustments for deferred merge.
	IF "%MERGE_FILES_ORIG%"=="true" (
		IF "%DEFERRED_MERGE%"=="true" (
			IF "%MERGE_FILES%"=="false" (
				SET OUTBOUND_FOLDER=%DEFERRED_MERGE_FOLDER%\%EXTRACT_ID%
				SET MERGE_PATTERN=
				SET FTP_ACTIVE=false
			) ELSE (
				SET OUTBOUND_FOLDER=%OUTBOUND_FOLDER_ORIG%
				SET MERGE_PATTERN=.^|%DEFERRED_MERGE_FOLDER%\%EXTRACT_ID%\*
				SET FTP_ACTIVE=%FTP_ACTIVE_ORIG%
			)
		)
	)	
		
	REM Call TCC.
	call core\TCC.bat "%~1" "%~2" "%~4"
	set ERR=%ERRORLEVEL%
	
	REM Set ABORT_ON_RERUN to true on subsequent loops.
	set ABORT_ON_RERUN=true
	
	REM Detect the end of loop and return for a final run when deferred merge is active.
	IF %ERR%==%END_LOOPING_EXIT_CODE% (
		IF %LOOP_INDEX% neq 1 (
			IF "%DEFERRED_MERGE%"=="true" (
				IF "%MERGE_FILES_ORIG%"=="true" (
					IF "%MERGE_FILES%"=="false" (
						SET ABORT_ON_RERUN=false
						SET MERGE_FILES=true
						GOTO LOOP
					)
				)
			)
		)
	)
			
	REM If a transaction limit was reached and paging is active, then exit.
	IF %ERR%==%LIMIT_EXIT_CODE% (
		IF "%PAGING_ACTIVE%" == "true" (
			GOTO END_LOOP
		)
	)
			
	REM If a transaction limit was reached, decrease TIME_INCREMENT and loop.
	IF %ERR%==%LIMIT_EXIT_CODE% (
		For /F "tokens=1" %%a in ('cscript /nologo core\Divide.vbs %TIME_INCREMENT% %LOOP_DECREASE_FACTOR%') do set TIME_INCREMENT=%%a
		GOTO LOOP
	)

	REM End looping if an error was raised.
	IF %ERR% neq 0 (
		GOTO END_LOOP
	)
		
	REM If no error, increase TIME_INCREMENT and loop.
	For /F "tokens=1" %%a in ('cscript /nologo core\Multiply.vbs %TIME_INCREMENT% %LOOP_INCREASE_FACTOR%') do set TIME_INCREMENT=%%a
	GOTO LOOP

:END_LOOP
	
REM Reset the ERR if it is the expected end of looping code.
IF "%ERR%"=="%END_LOOPING_EXIT_CODE%" (
	SET ERR=0
)

REM Reset variables.
set LOOP_INDEX=0
set COMPLETE_EXIT_CODE=%COMPLETE_EXIT_CODE_ORIG%
set ABORT_ON_RERUN=%ABORT_ON_RERUN_ORIG%
set MERGE_FILES=%MERGE_FILES_ORIG%
set FTP_ACTIVE=%FTP_ACTIVE_ORIG%
set OUTBOUND_FOLDER=%OUTBOUND_FOLDER_ORIG%
set INITIAL_TIME_INCREMENT=%INITIAL_TIME_INCREMENT_ORIG%
set TIME_INCREMENT=0
set MERGE_PATTERN=
set OUTPUT_FILE_SUFFIX=%OUTPUT_FILE_SUFFIX_ORIG%
set LOOPING_ACTIVE=false
set CURRENT_RUN_DATE=%CURRENT_RUN_DATE_TEMP%

:END
REM Exit with the ERR.
exit /B %ERR%