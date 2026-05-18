:: This will return the date and time into environment variables (YYYY, YY, MM, DD, HH, MI and SS).
:: Works on any NT/2K/XP/7 machine independent of regional date settings.
:: Modified 2011-10-08 - Romain Guay.
:: Modified 2012-11-06 - Jeff Tremblay/Romain Guay - WMIC 
@echo off

FOR /F "skip=1 tokens=1-6" %%A IN ('WMIC ^Path Win32_LocalTime Get Year^,Month^,Day^,Hour^,Minute^,Second /Format:table') DO (
  IF %%A GTR 0 (
		SET DD=%%A
		SET HH=%%B
		SET MI=%%C
		SET MM=%%D
		SET SS=%%E
		SET YYYY=%%F
  )
)
if %MM% LSS 10 set MM=0%MM%
if %DD% LSS 10 set DD=0%DD%
if %HH% LSS 10 set HH=0%HH%
if %MI% LSS 10 set MI=0%MI%
if %SS% LSS 10 set SS=0%SS%
SET YY=%YYYY:~2,2%
