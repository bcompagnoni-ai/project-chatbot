REM Write the Net-Change configuration (storage.properties) dynamically, using NETCHANGE_REPOSITORY value if defined.

REM Skip if NETCHANGE_REPOSITORY is empty.
IF "%NETCHANGE_REPOSITORY%"=="" GOTO END

REM Set the Net-Change config folder to the TEMP_FOLDER.
SET NETCHANGE_CONFIG_FOLDER=%TEMP_FOLDER%

REM If empty, use system defined TEMP folder.
IF "%NETCHANGE_CONFIG_FOLDER%"=="" SET NETCHANGE_CONFIG_FOLDER=%TEMP%

REM Add a random subfolder to avoid conflicts between running instances.
SET NETCHANGE_CONFIG_FOLDER=%NETCHANGE_CONFIG_FOLDER%\%RANDOM%

REM Make both paths absolute short name (necessary when used in the GUI).
call :makeAbsoluteShortName NETCHANGE_CONFIG_FOLDER
call :makeAbsoluteShortName NETCHANGE_REPOSITORY

REM Replace / with \ as per specification for repository location.
SET NETCHANGE_REPOSITORY=%NETCHANGE_REPOSITORY:\=/%

REM Prepare an empty storage.properties file.
SET STORAGE_PROPERTIES=%NETCHANGE_CONFIG_FOLDER%\storage.properties
IF exist "%STORAGE_PROPERTIES%" del "%STORAGE_PROPERTIES%"

REM Write storage.properties content.
>>"%STORAGE_PROPERTIES%" echo UseCompression=true
>>"%STORAGE_PROPERTIES%" echo EncryptionMode=2
>>"%STORAGE_PROPERTIES%" echo RepositoryLocation=%NETCHANGE_REPOSITORY%
>>"%STORAGE_PROPERTIES%" echo StorageUnitImplementation=com.taleo.integration.storage.FileStorageUnit
>>"%STORAGE_PROPERTIES%" echo FileStorageUnit.DefaultBlockSize=1

GOTO END

::--------------------------------------------------------
::-- Function section
::--------------------------------------------------------

:makeAbsoluteShortName path -- Convert a path to and absolute short name path relative to the current directory.
::													-- If path does not exist, create it (otherwise it cannot be translated to short name).
::													-- If already an absolute path, just make it short named.
::           		  				  -- path [in/out] - The path to convert.
:$source - Adapted from http://www.dostips.com
SETLOCAL ENABLEDELAYEDEXPANSION
set path=!%~1!
if not exist "%path%" mkdir %path%
if "%path:~0,1%"=="." (
	for /f "tokens=*" %%a in ("%cd%\%path%") do set "abs=%%~fsa"
) else (
	for /f "tokens=*" %%a in ("%path%") do set "abs=%%~fsa"
)
( ENDLOCAL & REM RETURN VALUES
  set %~1=%abs%
)
EXIT /b


:END
