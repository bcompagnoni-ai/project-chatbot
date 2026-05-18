CLS
@ECHO OFF

REM Ensure the current directory is set.
cd /d "%~dp0\.."

REM Set the environment variables.
Call Environment.bat

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
REM Encrypt password
Call "%TCC_HOME%\EncryptPassword.bat"

REM Delete the log file that is created.
If Exist log RD /S /Q log

pause
