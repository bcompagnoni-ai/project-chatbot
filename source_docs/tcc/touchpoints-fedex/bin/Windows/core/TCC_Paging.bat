REM Arguments:
REM %1: Mandatory - TCC configuration file
REM %2: Mandatory - TCC query file
REM %3: Optional  - Paging size. If absent the default PAGING_SIZE set in the Environment file will be used. If 0, the paging size is infinite.
REM %4: Optional  - Name of the result file (default: the query file name excluding the _sq.xml)

REM Store a temporary copy of original variables.
set PAGING_SIZE_ORIG=%PAGING_SIZE%

REM Set the paging size and activate paging.
IF "%~3" neq "" (
	SET PAGING_SIZE=%~3
)
SET PAGING_ACTIVE=true

REM Call TCC_Loop.bat with a maximum duration of 0 days.
Call core\TCC_Loop.bat "%~1" "%~2" 0 "%~4"
set ERR=%ERRORLEVEL%

REM Reset variables.
set PAGING_SIZE=%PAGING_SIZE_ORIG%
set PAGING_ACTIVE=false

REM Exit with the ERR.
exit /B %ERR%
