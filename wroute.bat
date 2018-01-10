@echo off

REM version 10/01/18 15:24

if "%1"=="" goto manquant
if "%1"=="/?" goto aide

if not exist %1 goto fichier

FOR /f "tokens=1,2,3 delims=;" %%a in (%1) do (
	echo Suppression de l'itineraire vers %%b
	route delete %%b
	echo.
	echo Ajout du nouvel itineraire : %%b/%%c =^> %%a
	route add %%b mask %%c %%a
	echo.
)

goto fin

:aide
echo Ajoute des destinations passant par des routes alternatives, importees depuis un fichier CSV
echo.
echo   Syntaxe : %0 [fichier.csv] [/?]
echo.
goto fin

:manquant
echo Parametre manquant
goto fin

:fichier
echo %1 n'existe pas !
goto fin

:fin