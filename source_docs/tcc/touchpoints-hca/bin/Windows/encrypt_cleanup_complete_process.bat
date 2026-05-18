@ECHO OFF

rem save current path
set run_save_current_path=%cd%

rem -- call IL -----------------------------------------------
cd /d "%~dp0"
call IL_run.bat -execute s02_egoh_test_encrypt_cleanup -1

rem restore saved path
cd /d "%run_save_current_path%"