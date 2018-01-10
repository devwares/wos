@ECHO OFF

REM Version 16-11-28 18:33

if "%1"=="" goto manquant
if "%1"=="/?" goto aide

if not exist %1 goto inconnu

REM *****************************************************
REM Make environment variable changes local to this batch file
REM *****************************************************
SETLOCAL

REM *****************************************************
REM Format du fichier liste : 1A;2B;3C;4D;5E;6F;7G;8H;9I;10J;11K;12L
REM
REM 1A  : type de sync (1 = local-ssh, 2 = ssh-local, 3 = local-local)
REM 2B  : unite source (vide si type 2)
REM 3C  : chemin source
REM 4D  : unite destination (vide si type 1)
REM 5E  : chemin destination
REM 6F  : serveur ssh (vide si type 3)
REM 7G  : port ssh (vide si type 3)
REM 8H  : user ssh (vide si type 3)
REM 9I  : unite cle rsa (vide si type 3)
REM 10J : fichier clef rsa (vide si type 3)
REM 11K : fichier script sh (vide si type 3)
REM 12L : parametres rsync additionnels
REM *****************************************************
set SYNC_LIST=%1

REM *****************************************************
REM Specifie un fichier de log pour la sortie
REM Sortie standard si vide
REM *****************************************************
set SYNC_LOGS=%2

REM *****************************************************
REM Specify where to find rsync and related files
REM Default value is the directory of this batch file
REM *****************************************************
SET SCRIPTHOME=%~dp0
REM SET SCRIPTHOME=C:\Users\%USERNAME%\Desktop\Cwrsync

REM *****************************************************
REM Create a home directory for .ssh 
REM *****************************************************
IF NOT EXIST %SCRIPTHOME%\home\%USERNAME%\.ssh MKDIR %SCRIPTHOME%\home\%USERNAME%\.ssh

REM *****************************************************
REM Make cwRsync home as a part of system PATH to find required DLLs
REM *****************************************************
SET CWOLDPATH=%PATH%
SET PATH=%SCRIPTHOME%\bin;%PATH%

REM *****************************************************
REM Windows paths may contain a colon (:) as a part of drive designation and 
REM backslashes (example c:\, g:\). However, in rsync syntax, a colon in a 
REM path means searching for a remote host. Solution: use absolute path 'a la unix', 
REM replace backslashes (\) with slashes (/) and put -/cygdrive/- in front of the 
REM drive letter:
REM 
REM Example : C:\WORK\* --> /cygdrive/c/work/*
REM 
REM Example 1 - rsync recursively to a unix server with an openssh server :
REM
REM       rsync -r /cygdrive/c/work/ remotehost:/home/user/work/
REM
REM Example 2 - Local rsync recursively 
REM
REM       rsync -r /cygdrive/c/work/ /cygdrive/d/work/doc/
REM
REM Example 3 - rsync to an rsync server recursively :
REM    (Double colons?? YES!!)
REM
REM       rsync -r /cygdrive/c/doc/ remotehost::module/doc
REM
REM Rsync is a very powerful tool. Please look at documentation for other options. 
REM
REM *****************************************************

REM *****************************************************
REM Debut du traitement
REM *****************************************************
if [%SYNC_LOGS%] NEQ [] (
	set SYNC_SORTIE=^>^> %SYNC_LOGS%
	echo Sortie redirigee vers le fichier %SYNC_LOGS%
)

echo.%SYNC_SORTIE%
echo _______________________________________________________________________________%SYNC_SORTIE%
echo DEBUT DU TRAITEMENT %date% A %time:~0,5%%SYNC_SORTIE%

FOR /f "tokens=1,2,3,4,5,6,7,8,9,10,11,12 delims=;" %%a in (%SYNC_LIST%) do (

	if %%a EQU 1 (
	
		echo.%SYNC_SORTIE%
		echo ########################### RSYNC : LOCAL VERS SSH ############################%SYNC_SORTIE%
		echo #                                                                             #%SYNC_SORTIE%
		echo # %%b:%%c --^> %%f:%%e%SYNC_SORTIE%
		echo #                                                                             #%SYNC_SORTIE%
		echo ###############################################################################%SYNC_SORTIE%
		echo.
		rem echo j : '%%j' k : '%%k'
		rsync %%l -e 'ssh -i /cygdrive/%%i%%j -p %%g' -r -t -v --progress --delete -s /cygdrive/%%b%%c %%h@%%f:%%e%SYNC_SORTIE%
		echo.
		if not "%%k"==" " ssh %%h@%%f -i /cygdrive/%%i%%j -p%%g "sh -s " < %%k%SYNC_SORTIE%
		rem echo k : '%%k'
	)
	
	if %%a EQU 2 (

		echo.%SYNC_SORTIE%
		echo ########################### RSYNC : SSH VERS LOCAL ############################%SYNC_SORTIE%
		echo #                                                                             #%SYNC_SORTIE%
		echo # %%f:%%c --^> %%d:%%e%SYNC_SORTIE%
		echo #                                                                             #%SYNC_SORTIE%
		echo ###############################################################################%SYNC_SORTIE%
		echo.
		rsync %%l -e 'ssh -i /cygdrive/%%i%%j -p %%g' -r -t -v --progress --delete -s %%h@%%f:%%c /cygdrive/%%d%%e%SYNC_SORTIE%
		echo.
		if not "%%k"==" " ssh %%h@%%f -i /cygdrive/%%i%%j -p%%g "sh -s " < %%k%SYNC_SORTIE%
		
	)
	
	if %%a EQU 3 (
		
		echo.%SYNC_SORTIE%
		echo ########################## RSYNC : LOCAL VERS LOCAL ###########################%SYNC_SORTIE%
		echo #                                                                             #%SYNC_SORTIE%
		echo # %%b:%%c --^> %%d:%%e%SYNC_SORTIE%
		echo #                                                                             #%SYNC_SORTIE%
		echo ###############################################################################%SYNC_SORTIE%
		echo.%SYNC_SORTIE%
		rsync %%l -r -t -v --progress --delete -s "/cygdrive/%%b%%c" "/cygdrive/%%d%%e"%SYNC_SORTIE%
	
	)

)

echo.%SYNC_SORTIE%
echo.%SYNC_SORTIE%
echo FIN DU TRAITEMENT %date% A %time:~0,5%%SYNC_SORTIE%
echo _______________________________________________________________________________%SYNC_SORTIE%
goto fin

:aide
echo Effectue un ou plusieurs backup(s) selon un script de configuration
echo.
echo %0 fichier_config [fichier_logs] [/?]
goto fin

:manquant
echo Parametre manquant
goto fin

:inconnu
echo Fichier inconnu - %1
goto fin

:fin
