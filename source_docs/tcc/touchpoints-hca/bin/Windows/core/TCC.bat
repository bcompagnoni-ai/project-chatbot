@ECHO OFF
REM Arguments:
REM %1: TCC configuration file
REM %2: TCC query file
REM %3: Optional - Name of the result file (default: Name of the query file excluding the _sq.xml)

REM Note: To force an error and interrupting execution, simply create a file named "Break" in this folder.

REM ---------------------------------------------------------------
REM            VALIDATIONS
REM ---------------------------------------------------------------
If "%TALEO_HOST%"=="" (
	echo ### ERROR - The default endpoint must be defined with a vaild host. ###
	pause
	exit 1
)

REM Read arguments.
SET CONFIG_FILE=%~1
SET QUERY_FILE=%~2
SET EXTRACT_ID=%~n2
SET EXTRACT_ID=%EXTRACT_ID:~0,-3%

SET TABLE_NAME=%EXTRACT_ID%
IF NOT "%~n3"=="" (
	SET TABLE_NAME=%~n3
)
SET TABLE_NAME=%OUTPUT_FILE_PREFIX%%TABLE_NAME%

IF "%COUNT_ONLY%"=="true" (
	ECHO Executing a count of %EXTRACT_ID% extract at the following endpoint: %TALEO_HOST%
	
	REM Switch to the CONFIG_FILE for count.
	SET CONFIG_FILE=%~p1\Count_%~nx1
	
	REM Build the output file for count.
	SET OUTPUT_FILE=Count_%YYYY%%MM%%DD%.csv
	
) ELSE (
	ECHO Executing %EXTRACT_ID% extract at the following endpoint: %TALEO_HOST%
	
	REM Build the output file name.
	SET OUTPUT_FILE=%TABLE_NAME%%OUTPUT_FILE_SUFFIX%.%OUTPUT_FILE_EXTENSION%
)

REM Build the Java classpath.
set CLASSPATH=.;core
for %%i in ("%LIB_FOLDER%\*.jar") do call :addJar %%i
set CLASSPATH=%CLASSPATH%;%TCC_HOME%\lib\taleo-integrationclient.jar

REM Build the Java options.
SET JAVA_OPTS=-Xms1024m -Xmx1024m

REM TCC configuration.
SET JAVA_OPTS=%JAVA_OPTS% -Dcom.taleo.integration.client.install.dir="%TCC_HOME%"
IF "%CONFIG_BOARD:~0,1%"=="." (
	SET JAVA_OPTS=%JAVA_OPTS% -Dcom.taleo.integration.client.configuration.board.default.file="%cd%\%CONFIG_BOARD%"
) ELSE (
	SET JAVA_OPTS=%JAVA_OPTS% -Dcom.taleo.integration.client.configuration.board.default.file="%CONFIG_BOARD%"
)
SET JAVA_OPTS=%JAVA_OPTS% -Dcom.taleo.client.symbol.LOG_FOLDER="%LOG_FOLDER%"
SET JAVA_OPTS=%JAVA_OPTS% -Dcom.taleo.client.symbol.LOG_ID="%LOG_ID%"
SET JAVA_OPTS=%JAVA_OPTS% -Dcom.taleo.integration.client.lastrundates.dir="%cd%\%LASTRUNDATE_FOLDER%"
SET JAVA_OPTS=%JAVA_OPTS% -Dcom.taleo.client.symbol.MONITOR_FOLDER="%cd%\%MONITOR_FOLDER%"
SET JAVA_OPTS=%JAVA_OPTS% -Dcom.taleo.client.symbol.TEMP_FOLDER="%TEMP_FOLDER%"
SET JAVA_OPTS=%JAVA_OPTS% -Djava.endorsed.dirs="%TCC_HOME%\lib\endorsed"
SET JAVA_OPTS=%JAVA_OPTS% -Djavax.xml.xpath.XPathFactory:http://java.sun.com/jaxp/xpath/dom=net.sf.saxon.xpath.XPathFactoryImpl
SET JAVA_OPTS=%JAVA_OPTS% -Djavax.xml.parsers.SAXParserFactory=org.apache.xerces.jaxp.SAXParserFactoryImpl
SET JAVA_OPTS=%JAVA_OPTS% -Djavax.xml.transform.TransformerFactory=net.sf.saxon.TransformerFactoryImpl
SET JAVA_OPTS=%JAVA_OPTS% -Dorg.apache.commons.logging.Log=org.apache.commons.logging.impl.Log4JLogger
REM Note: The argument for featurepacks folder has changed name in TCC 11, both are supported here.
SET JAVA_OPTS=%JAVA_OPTS% -Dcom.taleo.integration.client.featurepacks.dir="%cd%\%FEATUREPACKS_FOLDER%"
SET JAVA_OPTS=%JAVA_OPTS% -Dcom.taleo.integration.client.productpacks.dir="%cd%\%FEATUREPACKS_FOLDER%"

REM Taleo endpoint configuration.
SET JAVA_OPTS=%JAVA_OPTS% -Dcom.taleo.client.symbol.TALEO_HOST="%TALEO_HOST%"
SET JAVA_OPTS=%JAVA_OPTS% -Dcom.taleo.client.symbol.TALEO_ZONE="%TALEO_ZONE%"

REM Run configuration.
SET JAVA_OPTS=%JAVA_OPTS% -Dcom.taleo.client.symbol.NOW="%NOW%"
SET JAVA_OPTS=%JAVA_OPTS% -Dcom.taleo.client.symbol.EXTRACT_ID="%EXTRACT_ID%"
SET JAVA_OPTS=%JAVA_OPTS% -Dcom.taleo.client.symbol.TABLE_NAME="%TABLE_NAME%"
SET JAVA_OPTS=%JAVA_OPTS% -Dcom.taleo.client.symbol.OUTBOUND_FOLDER="%OUTBOUND_FOLDER%"
SET JAVA_OPTS=%JAVA_OPTS% -Dcom.taleo.client.symbol.DOCUMENT_OUTBOUND_FOLDER="%DOCUMENT_OUTBOUND_FOLDER%"
SET JAVA_OPTS=%JAVA_OPTS% -Dcom.taleo.client.symbol.DEFERRED_MERGE_FOLDER="%DEFERRED_MERGE_FOLDER%"
SET JAVA_OPTS=%JAVA_OPTS% -Dcom.taleo.client.symbol.OUTPUT_FILE="%OUTPUT_FILE%"
SET JAVA_OPTS=%JAVA_OPTS% -Dcom.taleo.client.symbol.CURRENT_RUN_DATE="%CURRENT_RUN_DATE%"
SET JAVA_OPTS=%JAVA_OPTS% -Dcom.taleo.client.symbol.ABORT_ON_RERUN="%ABORT_ON_RERUN%"
SET JAVA_OPTS=%JAVA_OPTS% -Dcom.taleo.client.symbol.MAX_DAILY_COUNT="%MAX_DAILY_COUNT%"
SET JAVA_OPTS=%JAVA_OPTS% -Dcom.taleo.client.symbol.CREATE_ONLY="%CREATE_ONLY%"
SET JAVA_OPTS=%JAVA_OPTS% -Dcom.taleo.client.symbol.MERGE_FILES="%MERGE_FILES%"
SET JAVA_OPTS=%JAVA_OPTS% -Dcom.taleo.client.symbol.MERGE_PATTERN="%MERGE_PATTERN%"
SET JAVA_OPTS=%JAVA_OPTS% -Dcom.taleo.client.symbol.REMOVE_DUPLICATES="%REMOVE_DUPLICATES%"
SET JAVA_OPTS=%JAVA_OPTS% -Dcom.taleo.client.customstep.DailyCountPreStep.MaximumExitCode="%DAILY_LIMIT_EXIT_CODE%"
SET JAVA_OPTS=%JAVA_OPTS% -Dcom.taleo.client.symbol.DATE_TIME_MASK="%DATE_TIME_MASK%"

REM Looping configuration.
SET JAVA_OPTS=%JAVA_OPTS% -Dcom.taleo.client.symbol.LOOP_INDEX="%LOOP_INDEX%"
SET JAVA_OPTS=%JAVA_OPTS% -Dcom.taleo.client.symbol.TIME_INCREMENT="%TIME_INCREMENT%"
SET JAVA_OPTS=%JAVA_OPTS% -Dcom.taleo.client.customstep.LRDPreStep.RerunExitCode="%COMPLETE_EXIT_CODE%"
SET JAVA_OPTS=%JAVA_OPTS% -Dcom.taleo.client.customstep.PagingPreStep.CompleteExitCode="%COMPLETE_EXIT_CODE%"
SET JAVA_OPTS=%JAVA_OPTS% -Dcom.taleo.client.symbol.PAGING_SIZE="%PAGING_SIZE%"
SET JAVA_OPTS=%JAVA_OPTS% -Dcom.taleo.client.symbol.PAGING_ACTIVE="%PAGING_ACTIVE%"
SET JAVA_OPTS=%JAVA_OPTS% -Dcom.taleo.client.symbol.LOOPING_ACTIVE="%LOOPING_ACTIVE%"
SET JAVA_OPTS=%JAVA_OPTS% -Dcom.taleo.client.symbol.TRANSACTION_LIMIT_PATTERN="%TRANSACTION_LIMIT_PATTERN%"
SET JAVA_OPTS=%JAVA_OPTS% -Dcom.taleo.client.symbol.FILE_SIZE_LIMIT_PATTERN="%FILE_SIZE_LIMIT_PATTERN%"
SET JAVA_OPTS=%JAVA_OPTS% -Dcom.taleo.client.symbol.LIMIT_EXIT_CODE="%LIMIT_EXIT_CODE%"

REM FTP configuration.
SET JAVA_OPTS=%JAVA_OPTS% -Dcom.taleo.client.symbol.FTP_ACTIVE="%FTP_ACTIVE%"

REM Proxy configuration.
SET JAVA_OPTS=%JAVA_OPTS% -Dhttp.proxyHost="%PROXY_HOST%"
SET JAVA_OPTS=%JAVA_OPTS% -Dhttp.proxyPort="%PROXY_PORT%"
SET JAVA_OPTS=%JAVA_OPTS% -Dhttp.proxyUser="%PROXY_USER%"
SET JAVA_OPTS=%JAVA_OPTS% -Dhttp.proxyPassword="%PROXY_PASSWORD%"
SET JAVA_OPTS=%JAVA_OPTS% -Dhttp.proxyNTDomain="%PROXY_NTDOMAIN%"

REM Other configuration.
SET JAVA_OPTS=%JAVA_OPTS% -Dcom.taleo.integration.compress.tempfile=%COMPRESS_TEMP_FILES%

REM Exit the process if a Break file is present.
IF exist Break (
	SETLOCAL ENABLEDELAYEDEXPANSION
	set /P BREAK="Found a Break file, do you want to exit (Y/N)? "
	IF /I '!BREAK!'=='Y' (
		echo.
		echo ### Exiting the process. ###
		exit /B %BREAK_EXIT_CODE%
	)
	ENDLOCAL
)

REM Run TCC.
"%JAVA_HOME%\bin\java.exe" %JAVA_OPTS% -classpath "%CLASSPATH%" com.taleo.integration.client.Client "%CONFIG_FILE%" "%QUERY_FILE%" "%OUTBOUND_FOLDER%\%OUTPUT_FILE%"
IF %ERRORLEVEL%==0 exit /B %ERRORLEVEL%

REM Store the error code.
SET ERR=%ERRORLEVEL%

exit /B %ERR%

:addJar
	set CLASSPATH=%CLASSPATH%;%1
exit /B