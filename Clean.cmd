@echo off
echo EXECUTION NETTOYAGE TOTAL
echo ne pas se fier aux messages disant  fichier ou repertoire introuvable...
RunDll32.exe InetCpl.cpl,ClearMyTracksByProcess 8
echo.
echo.
echo ATTRIBUTS
echo.
echo.
attrib -R -S -H "%TEMP%\*.*"
attrib -R -S -H "%systemroot%\*.*"
attrib -R -S -H "%windir%\Temp\*.*"
attrib -R -S -H "%USERPROFILE%\Local Settings\Temporary Internet Files\*.*"
attrib -R -S -H "%USERPROFILE%\AppData\Local\Microsoft\Windows\Temporary Internet Files\*.*"
attrib -R -S -H "%USERPROFILE%\AppData\Local\Temp\*.*"
attrib -R -S -H "%USERPROFILE%\AppData\LocalLow\Temp\*.*"
echo.
echo.
echo Fin du changements attribut fichiers suspects
echo.
echo PURGE DES FICHIERS TEMPORAIRES
echo.
echo.
erase /f /s /q "%TEMP%\*.*"
erase /f /s /q "%windir%\Temp\*.*"
erase /f /s /q "%USERPROFILE%\AppData\Local\Temp\*.*"
erase /f /s /q "%USERPROFILE%\AppData\LocalLow\Temp\*.*"
echo.
echo.
echo PURGE DES FICHIERS TEMPORAIRES TERMINEE
echo.
echo NETTOYAGE INTERNET EXPLORER
echo.
echo Vidage de l'historique
echo.
RunDll32.exe InetCpl.cpl,ClearMyTracksByProcess 1
erase /f /s /q "%USERPROFILE%\Local Settings\Historique\*.*"
erase /f /s /q "%USERPROFILE%\AppData\Local\Microsoft\Windows\History\*.*"
echo.
echo.
echo Vidage des fichiers internet Temporaires
echo.
echo.
RunDll32.exe InetCpl.cpl,ClearMyTracksByProcess 8 
erase /f /s /q "%USERPROFILE%\Local Settings\Temporary Internet Files\*.*"
erase /f /s /q "%USERPROFILE%\AppData\Local\Microsoft\Windows\Temporary Internet Files\*.*"
erase /f /s /q "%USERPROFILE%AppData\Local\Microsoft\Windows\Temporary Internet Files
echo.
echo.
echo Vidage des Cookies
echo.
echo.
RunDll32.exe InetCpl.cpl,ClearMyTracksByProcess 2 
erase /f /s /q "%USERPROFILE%\AppData\Roaming\Microsoft\Windows\Cookies
echo.
echo.
echo NETTOYAGE INTERNET EXPLORER EFFECTUE
echo.
echo.
echo Si vous ne voulez pas effacer vos mots de passes 
echo sauvegardes et vos saisies de formulaire achat en ligne
echo fermez ce programme avec la croix
echo sinon...
pause
RunDll32.exe InetCpl.cpl,ClearMyTracksByProcess 16
RunDll32.exe InetCpl.cpl,ClearMyTracksByProcess 32
RunDll32.exe InetCpl.cpl,ClearMyTracksByProcess 255
cls
echo NETTOYAGE TOTAL EFFECTUE...
pause