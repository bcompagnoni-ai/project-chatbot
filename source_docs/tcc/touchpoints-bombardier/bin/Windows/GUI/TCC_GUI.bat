CLS
@ECHO OFF
SETLOCAL 

REM Ensure the current directory is set.
cd /d "%~dp0\.."

REM Set the environment variables.
Call Environment.bat

REM Select the config board to use.
SET SELECTED_CONFIG_BOARD=
call :selectConfigBoard SELECTED_CONFIG_BOARD
IF "%SELECTED_CONFIG_BOARD%"=="{Quit}" (
 	Exit /b
)
SET CONFIG_BOARD=%SELECTED_CONFIG_BOARD%

REM Select the net-change repository to use.
SET SELECTED_NETCHANGE_REPOSITORY=
call :selectNetChangeRepository SELECTED_NETCHANGE_REPOSITORY
IF "%SELECTED_NETCHANGE_REPOSITORY%"=="{Quit}" (
 	Exit /b
)
SET NETCHANGE_REPOSITORY=%SELECTED_NETCHANGE_REPOSITORY%

REM Rerun Init to read the selected config board.
Call core\Init.bat

TITLE %~nx0 - %TALEO_HOST% - %date% %time%
CLS
echo Using configuration board: 
echo   %CONFIG_BOARD%
echo.
IF NOT "%NETCHANGE_REPOSITORY%"=="" (
	echo Using net-change repository: 
	echo   %NETCHANGE_REPOSITORY%
	echo.
)

REM Recover backup of TaleoConnectClient.ini if present or create backup if absent.
IF exist "%TCC_HOME%\TaleoConnectClient.ini.bak" (
	copy /Y "%TCC_HOME%\TaleoConnectClient.ini.bak" "%TCC_HOME%\TaleoConnectClient.ini"
) ELSE (
	copy /Y "%TCC_HOME%\TaleoConnectClient.ini" "%TCC_HOME%\TaleoConnectClient.ini.bak"
)

REM Copy the Java extensions from the /lib folder to TCC_HOME after backing up the actual jars.
IF exist ..\..\lib\*.jar (
	IF not exist "%TCC_HOME%\extensions\externaljars\bak\" mkdir "%TCC_HOME%\extensions\externaljars\bak\"
	move /Y "%TCC_HOME%\extensions\externaljars\*.jar" "%TCC_HOME%\extensions\externaljars\bak\"
	copy /Y ..\..\lib\*.jar "%TCC_HOME%\extensions\externaljars\"
)

REM Add the missing pieces to TaleoConnectClient.ini using absolute short path names.
>>"%TCC_HOME%\TaleoConnectClient.ini" echo.

IF NOT "%ALERTING_MAIL_FROM%"=="" (
	>>"%TCC_HOME%\TaleoConnectClient.ini" echo -Dalerting.email.sender=%ALERTING_MAIL_FROM%
)

call :makeAbsoluteShortName CONFIG_BOARD
>>"%TCC_HOME%\TaleoConnectClient.ini" echo -Dcom.taleo.integration.client.configuration.board.default.file=%CONFIG_BOARD%

IF "%LASTRUNDATE_FOLDER%"=="" GOTO END_LASTRUNDATE_FOLDER
	call :makeAbsoluteShortName LASTRUNDATE_FOLDER
	>>"%TCC_HOME%\TaleoConnectClient.ini" echo -Dcom.taleo.integration.client.lastrundates.dir=%LASTRUNDATE_FOLDER%
:END_LASTRUNDATE_FOLDER

IF "%CUSTOM_DICTIONARIES_FOLDER%"=="" GOTO END_CUSTOM_DICTIONARIES_FOLDER
	call :makeAbsoluteShortName CUSTOM_DICTIONARIES_FOLDER
	>>"%TCC_HOME%\TaleoConnectClient.ini" echo -Dcom.taleo.integration.client.customdictionaries.dir=%CUSTOM_DICTIONARIES_FOLDER%
:END_CUSTOM_DICTIONARIES_FOLDER

IF "%NETCHANGE_REPOSITORY%"=="" GOTO END_NETCHANGE_REPOSITORY
	call core\Init_net-change.bat
	call :makeAbsoluteShortName NETCHANGE_CONFIG_FOLDER
	>>"%TCC_HOME%\TaleoConnectClient.ini" echo -Dcom.taleo.integration.client.extensions.plugins.configuration.dir.plugins.tcc-netchange=%NETCHANGE_CONFIG_FOLDER%
:END_NETCHANGE_REPOSITORY

IF "%FEATUREPACKS_FOLDER%"=="" GOTO END_FEATUREPACKS_FOLDER
	call :makeAbsoluteShortName FEATUREPACKS_FOLDER
	>>"%TCC_HOME%\TaleoConnectClient.ini" echo -Dcom.taleo.integration.client.featurepacks.dir=%FEATUREPACKS_FOLDER%
	>>"%TCC_HOME%\TaleoConnectClient.ini" echo -Dcom.taleo.integration.client.productpacks.dir=%FEATUREPACKS_FOLDER%
:END_FEATUREPACKS_FOLDER

>>"%TCC_HOME%\TaleoConnectClient.ini" echo -Dhttp.proxyHost=%PROXY_HOST%
>>"%TCC_HOME%\TaleoConnectClient.ini" echo -Dhttp.proxyPort=%PROXY_PORT%
>>"%TCC_HOME%\TaleoConnectClient.ini" echo -Dhttp.proxyUser=%PROXY_USER%
>>"%TCC_HOME%\TaleoConnectClient.ini" echo -Dhttp.proxyPassword=%PROXY_PASSWORD%
>>"%TCC_HOME%\TaleoConnectClient.ini" echo -Dhttp.proxyNTDomain=%PROXY_NTDOMAIN%

REM Use the base monitor folder (in TCC_HOME) in order to display HTML with its CSS.
>>"%TCC_HOME%\TaleoConnectClient.ini" echo -Dcom.taleo.client.symbol.MONITOR_FOLDER=monitor

call :makeAbsoluteShortName LOG_FOLDER
>>"%TCC_HOME%\TaleoConnectClient.ini" echo -Dcom.taleo.client.symbol.LOG_FOLDER=%LOG_FOLDER%

call :makeAbsoluteShortName INBOUND_FOLDER
>>"%TCC_HOME%\TaleoConnectClient.ini" echo -Dcom.taleo.client.symbol.INBOUND_FOLDER=%INBOUND_FOLDER%

call :makeAbsoluteShortName OUTBOUND_FOLDER
>>"%TCC_HOME%\TaleoConnectClient.ini" echo -Dcom.taleo.client.symbol.OUTBOUND_FOLDER=%OUTBOUND_FOLDER%

call :makeAbsoluteShortName TEMP_FOLDER
>>"%TCC_HOME%\TaleoConnectClient.ini" echo -Dcom.taleo.client.symbol.TEMP_FOLDER=%TEMP_FOLDER%

>>"%TCC_HOME%\TaleoConnectClient.ini" echo -Dcom.taleo.client.symbol.TODAY=%TODAY%

>>"%TCC_HOME%\TaleoConnectClient.ini" echo -Dcom.taleo.client.symbol.LOOP_INDEX=0

>>"%TCC_HOME%\TaleoConnectClient.ini" echo -Dcom.taleo.client.symbol.TALEO_HOST=%TALEO_HOST%

>>"%TCC_HOME%\TaleoConnectClient.ini" echo -Dcom.taleo.client.symbol.TALEO_ZONE=%TALEO_HOST:~0,-10%

REM Run TCC GUI.
cd /d "%TCC_HOME%"
Start "" "%TCC_HOME%\TaleoConnectClient.exe"
echo Starting TCC. Please wait, this window will close automatically...

REM Sleep 30 seconds and set back TaleoConnectClient.ini.
call :sleep 30
Copy "%TCC_HOME%\TaleoConnectClient.ini.bak" "%TCC_HOME%\TaleoConnectClient.ini"
Del "%TCC_HOME%\TaleoConnectClient.ini.bak"

REM Delete the NETCHANGE_CONFIG_FOLDER.
IF exist "%NETCHANGE_CONFIG_FOLDER%" rd /S /Q "%NETCHANGE_CONFIG_FOLDER%"


GOTO :EOF
::--------------------------------------------------------
::-- Function section
::--------------------------------------------------------

:sleep seconds -- waits some seconds before returning
::             -- seconds [in]  - number of seconds to wait
:$source http://www.dostips.com
FOR /l %%a in (%~1,-1,1) do (ping -n 2 -w 1 127.0.0.1>NUL)
EXIT /b

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

:selectConfigBoard path -- Select the config board to use.
::           		  			-- selection [out] - The path of the selected config board.
	setlocal enabledelayedexpansion

	REM Exit if CONFIG_BOARDS_FOLDER does not exist.
	IF not exist "%CONFIG_BOARDS_FOLDER%" (
		goto end_selectConfigBoard
	)

	REM Exit if only one config board.
	Set /a COUNT=0
	For %%i in ("%CONFIG_BOARDS_FOLDER%\*") do set /a COUNT+=1
	IF %COUNT% gtr 1 goto begin_selectConfigBoard
	For %%i in ("%CONFIG_BOARDS_FOLDER%\*") do set SELECTION=%%i
	GOTO end_selectConfigBoard
	
	:begin_selectConfigBoard
	REM Build the options.
	ECHO.
	ECHO List of available config boards:
	ECHO.
	ECHO   0. Environment (%CONFIG_BOARD%)
	set LOOP_INDEX=0
	For %%i in ("%CONFIG_BOARDS_FOLDER%\*.xml") do (
		set /a LOOP_INDEX=!LOOP_INDEX! + 1
	  Call :echo_option !LOOP_INDEX! "%%i"
	) 
	ECHO   Q. Quit
	
	REM Get user selection.
	SET Option=0
	ECHO.
	SET /P Option=Type the code and press Enter (default: 0): 
	IF '!Option!'=='0' SET SELECTION=%CONFIG_BOARD%
	set LOOP_INDEX=0
	For %%i in ("%CONFIG_BOARDS_FOLDER%\*.xml") do (
		set /a LOOP_INDEX=!LOOP_INDEX! + 1
		IF '!Option!'=='!LOOP_INDEX!' SET SELECTION=%%i
	) 
	IF /I '!Option!'=='Q' (
		SET SELECTION={Quit}
		goto end_selectConfigBoard
	)
	
	IF '!SELECTION!'=='' (
		CLS
		ECHO "%Option%" is not valid. Please try again.
		ECHO.
		GOTO begin_selectConfigBoard
	)
	
	:end_selectConfigBoard
	( ENDLOCAL & REM RETURN VALUES
		SET %~1=%SELECTION%
	)
EXIT /b

:selectNetChangeRepository path -- Select the Net-Change repository to use.
::           		  							-- selection [out] - The path of the selected repository.
	setlocal enabledelayedexpansion

	REM Exit if NETCHANGE_FOLDER does not exist.
	IF not exist "%NETCHANGE_FOLDER%" (
		goto end_selectNetChangeRepository
	)

	REM Exit if only one repository folder.
	Set /a COUNT=0
	For /d %%i in ("%NETCHANGE_FOLDER%\*") do set /a COUNT+=1
	IF %COUNT% gtr 1 goto begin_selectNetChangeRepository
	For /d %%i in ("%NETCHANGE_FOLDER%\*") do set SELECTION=%%i
	GOTO end_selectNetChangeRepository

	:begin_selectNetChangeRepository
	REM Build the options.
	ECHO.
	ECHO List of available net-change repositories:
	ECHO.
	ECHO   0. Environment (%NETCHANGE_REPOSITORY%)
	set LOOP_INDEX=0
	For /d %%i in ("%NETCHANGE_FOLDER%\*") do (
		set /a LOOP_INDEX=!LOOP_INDEX! + 1
	  Call :echo_option !LOOP_INDEX! "%%i"
	) 
	ECHO   Q. Quit
	
	REM Get user selection.
	SET Option=0
	ECHO.
	SET /P Option=Type the code and press Enter (default: 0): 
	IF '!Option!'=='0' SET SELECTION=%NETCHANGE_REPOSITORY%
	set LOOP_INDEX=0
	For /d %%i in ("%NETCHANGE_FOLDER%\*") do (
		set /a LOOP_INDEX=!LOOP_INDEX! + 1
		IF '!Option!'=='!LOOP_INDEX!' SET SELECTION=%%i
	) 
	IF /I '!Option!'=='Q' (
		SET SELECTION={Quit}
		goto end_selectNetChangeRepository
	)
	
	IF '!SELECTION!'=='' (
		CLS
		ECHO "%Option%" is not valid. Please try again.
		ECHO.
		GOTO begin_selectNetChangeRepository
	)
	
	:end_selectNetChangeRepository
	( ENDLOCAL & REM RETURN VALUES
		SET %~1=%SELECTION%
	)
EXIT /b

:echo_option
	ECHO   %1. %~n2
EXIT /b
