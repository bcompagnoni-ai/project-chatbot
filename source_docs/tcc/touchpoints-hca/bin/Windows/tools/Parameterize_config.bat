CLS
@ECHO OFF
TITLE %~nx0 - %date% %time%
SETLOCAL 

REM Ensure the current directory is set.
cd /d %~dp0\..

REM Set the environment variables.
Call Environment.bat

ECHO -------------------------------------------------------------------------------
ECHO This tool will parameterize a configuration file for use within TCC_Touchpoints. The original file will be renamed with .bak extension and the transformed file will replace the original.
ECHO -------------------------------------------------------------------------------
:Loop
SET /P CONFIG_FILE=Provide the path to the configuration file: 

REM Apply the transformation.
Call :Transform %CONFIG_FILE%
IF ERRORLEVEL 1 GOTO ERROR
GOTO SUCCESS

:Transform
	REM Extract CFGFOLDER from CONFIG_FILE.
	Set CFGFOLDER=%~dp1
	
	REM Apply the transformation.
	"%TCC_HOME%\jre\bin\java.exe" -cp "%TCC_HOME%\lib\saxon8.jar" net.sf.saxon.Transform "%~1" "..\xsl\Parameterize_config.xsl" CFGFOLDER="%CFGFOLDER%\" >"%~1.temp"
GOTO END

:ERROR
ECHO.
ECHO ###### ERROR ######
Pause
GOTO END

:SUCCESS
Move %CONFIG_FILE% %CONFIG_FILE%.bak
Move %CONFIG_FILE%.temp %CONFIG_FILE%
ECHO.
ECHO ###### SUCCESS ######
Pause
ECHO.
GOTO Loop

:END