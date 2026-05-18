REM %1: Mode
REM				copy: Take a copy of the file and append a timestamp to its name.
REM				move: Simply move the file.
REM				copy_no_timestamp: Take a copy of the file without appending a timestamp to its name.
REM %2: File to archive
REM %3: The error code - Optional, if absent the current error level %ERROR_LEVEL% is used.

REM Set the ERR_CODE.
SET ERR_CODE=%3
IF "%ERR_CODE%"=="" (
	SET ERR_CODE=%ERRORLEVEL%
)

REM Check if file to archive exist.
if not exist %2 (
	ECHO.
	ECHO ###### ERROR while archiving %2. The file does not exist. ######
	Pause
	GOTO END
)

REM Create archive and error folders.
if not exist "%ARCHIVE_FOLDER%" mkdir "%ARCHIVE_FOLDER%"
if not exist "%ERROR_FOLDER%" mkdir "%ERROR_FOLDER%"

REM Copy or move sucessfully processed file to archive folder and failures to error folder.
IF "%ERR_CODE%"=="0" (
	SET DEST_FOLDER=%ARCHIVE_FOLDER%
) ELSE (
	SET DEST_FOLDER=%ERROR_FOLDER%
)	
IF "%1" == "copy" (
	copy /Y "%~f2" "%DEST_FOLDER%\%~n2_%NOW%%~x2"
) 
IF "%1" == "move" (
	move /Y "%~f2" "%DEST_FOLDER%\%~n2%~x2"
)
IF "%1" == "copy_no_timestamp" (
	copy /Y "%~f2" "%DEST_FOLDER%\%~n2%~x2"
)

:END

REM Exit with the same error code.
Exit /B %ERR_CODE%