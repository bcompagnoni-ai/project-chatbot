REM ---------------------------------------------------------------
REM            TCC HOME
REM ---------------------------------------------------------------
SET TCC_HOME=C:\Taleo Connect Client

REM ---------------------------------------------------------------
REM            CONFIGURATION BOARD
REM ---------------------------------------------------------------
REM Note: File name of the configuration board in the \configboards folder. Leave blank to use TCC default.
SET CONFIG_BOARD=bombardier_brd.xml

REM ---------------------------------------------------------------
REM            JAVA SETTINGS
REM ---------------------------------------------------------------
SET JAVA_HOME=%TCC_HOME%\jre
REM Note: Java maximum available memory (typically 256m, 512m, 1024m or 2048m)
SET JAVA_XMX=512m

REM ---------------------------------------------------------------
REM            FOLDER SETTINGS
REM ---------------------------------------------------------------
REM Note: Folders can be set as relative or absolute, including mapped drives and UNC paths.
SET INBOUND_FOLDER=..\..\data\inbound
SET OUTBOUND_FOLDER=..\..\data\outbound
SET ARCHIVE_FOLDER=..\..\data\archive
SET ERROR_FOLDER=..\..\data\error
SET CONFIG_BOARDS_FOLDER=..\..\configboards
SET CUSTOM_DICTIONARIES_FOLDER=..\..\customdictionaries
SET FEATUREPACKS_FOLDER=..\..\featurepacks
SET LOG_FOLDER=..\..\log
SET LIB_FOLDER=..\..\lib
SET LASTRUNDATE_FOLDER=..\..\lrd
SET MONITOR_FOLDER=..\..\monitor
SET NETCHANGE_FOLDER=..\..\net-change
SET NETCHANGE_REPOSITORY=%NETCHANGE_FOLDER%\repository
SET SCRIPTS_FOLDER=..\..\scripts
SET TEMP_FOLDER=..\..\temp

REM ---------------------------------------------------------------
REM            PROXY SETTINGS
REM ---------------------------------------------------------------
REM SET PROXY_HOST=chproxy.tbe.taleocloud.net
REM SET PROXY_PORT=3128
REM SET PROXY_USER=
REM Note: Password may be encrypted using %TCC_HOME%\EncryptPassword.bat
SET PROXY_PASSWORD=
SET PROXY_NTDOMAIN=

REM ---------------------------------------------------------------
REM            RUN SETTINGS
REM ---------------------------------------------------------------
SET NB_RETRIES=0

REM ---------------------------------------------------------------
REM            CLEANUP SETTINGS
REM ---------------------------------------------------------------
REM Note: Number of days old files will be kept in the log, monitor, outbound, archive and error folders, when using the Cleanup.bat script.
SET RETENTION_DAYS=31

REM ---------------------------------------------------------------
REM            DEFAULT CURRENT_RUN_DATE
REM ---------------------------------------------------------------
REM IF "%CURRENT_RUN_DATE%"=="" (
REM SET CURRENT_RUN_DATE=%YYYY%-%MM%-%DD% %HH%:%MI%:%SS%
REM )

REM ---------------------------------------------------------------
REM            INITIALIZE
REM ---------------------------------------------------------------
Call core\Init.bat