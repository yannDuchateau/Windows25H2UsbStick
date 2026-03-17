@echo off
FOR /F "tokens=3" %%l IN ('reg query "HKCU\Control Panel\Desktop" /v PreferredUILanguages ^| find "PreferredUILanguages"') DO set UILanguage=%%l
FOR /F "tokens=3" %%l IN ('reg query "HKCU\Control Panel\International\User Profile" /v Languages ^| find "Languages"') DO set UILanguage=%%l

Set Languages=%UILanguage:~0,5%
echo.
goto %Languages%

:fr-FR
set jour=%DATE:~7,2%
set mois=%DATE:~4,2%
set annee=%DATE:~10,4%
set heure=%TIME:~0,2%
set minute=%TIME:~3,2%
goto Debut

:en-US
set jour=%DATE:~7,2%
set mois=%DATE:~4,2%
set annee=%DATE:~10,4%
set heure=%TIME:~1,2%
set minute=%TIME:~3,2%
goto Debut

:de-CH
set jour=%DATE:~0,2%
set mois=%DATE:~3,4%
set annee=%DATE:~8,4%
set heure=%TIME:~0,2%
if "%time:~0,2%" == " " set heure=%time:~-1,1%
set minute=%TIME:~3,2%
goto Debut

:de-DE
set jour=%DATE:~0,2%
set mois=%DATE:~3,4%
set annee=%DATE:~6,6%
set heure=%time:~0,1%
if "%time:~0,1%" == " " set heure=%time:~-1,1%
set minute=%TIME:~3,2%
:debut
Echo echo Computer Language is %Languages% Date is %jour%_%mois%_%annee%.%Heure%h%minute%
pause