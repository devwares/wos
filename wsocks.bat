@echo off
if "%1"=="" goto manquant
if "%1"=="/?" goto aide
if not exist %1 goto fichier

FOR /f "tokens=1,2,3,4,5 delims=;" %%a in (%1) do (
set SSHIP=%%a
set SSHPORT=%%b
set SOCKSPORT=%%c
set SSHKEY=%%d
set SSHUSER=%%e
)

REM *****************************************************
REM Specify where to find rsync and related files
REM Default value is the directory of this batch file
REM *****************************************************
SET SCRIPTHOME=%~dp0

REM *****************************************************
REM Create a home directory for .ssh 
REM *****************************************************
IF NOT EXIST %SCRIPTHOME%\home\%USERNAME%\.ssh MKDIR %SCRIPTHOME%\home\%USERNAME%\.ssh

REM *****************************************************
REM Make cwRsync home as a part of system PATH to find required DLLs
REM *****************************************************
SET CWOLDPATH=%PATH%
SET PATH=%SCRIPTHOME%\bin;%PATH%

ssh.exe -D localhost:%SOCKSPORT% %SSHIP% -p %SSHPORT% -i %SSHKEY% -l %SSHUSER%

goto fin

:aide
echo Cree un proxy socks selon les parametres importes d'un fichier csv
echo.
echo   Syntaxe : %0 [fichier.csv] [/?]
echo.
goto fin

:manquant
echo Parametre manquant
goto fin

:fin