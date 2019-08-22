@echo off
title PocketMine-MP Installer v2.0.2 - by Nerahikada
cd /d %~dp0

: 
:  _   _                _     _ _             _       
: | \ | | ___ _ __ __ _| |__ (_) | ____ _  __| | __ _ 
: |  \| |/ _ \ '__/ _` | '_ \| | |/ / _` |/ _` |/ _` |
: | |\  |  __/ | | (_| | | | | |   < (_| | (_| | (_| |
: |_| \_|\___|_|  \__,_|_| |_|_|_|\_\__,_|\__,_|\__,_|
: 
:  Automatic PocketMine-MP Installer
:   Link: https://github.com/Nerahikada/PMMP-Installer
:   LICENSE: CC BY-NC-SA 4.0
:    - https://creativecommons.org/licenses/by-nc-sa/4.0/
: 
: 

echo PocketMine-MP Installer  v2.0.2
echo   - Author: Nerahikada
echo   - Twitter: https://twitter.com/Nerahikada
echo   - GitHub: https://github.com/Nerahikada
echo   - YouTube: https://www.youtube.com/Nerahikada
echo.


REM 遅延展開-有効
setlocal EnableDelayedExpansion

set /p TEXT = [CHECKING] Microsoft Visual C++ 2017 Redistributable ^> < nul
reg query "HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Uninstall" /s | find "Microsoft Visual C++ 2017" | find "64 Minimum Runtime" > nul
if %ERRORLEVEL% == 0 (
	echo Installed
) else if %ERRORLEVEL% == 1 (
	reg query "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Uninstall" /s | find "Microsoft Visual C++ 2017" | find "64 Minimum Runtime" > nul
	if !ERRORLEVEL! == 0 (
		echo Installed
	) else (
		echo Not installed

		set /p TEXT = [DOWNLOADING] Microsoft Visual C++ 2017 Redistributable ^> < nul
		bitsadmin /RawReturn /TRANSFER d0 https://aka.ms/vs/15/release/vc_redist.x64.exe %CD%\vc_redist.x64.exe
		echo Done

		set /p TEXT = [INSTALLING] Microsoft Visual C++ 2017 Redistributable ^> < nul
		call vc_redist.x64.exe
		del vc_redist.x64.exe
		echo Done

		set /p TEXT = [CHECKING] Microsoft Visual C++ 2017 Redistributable ^> < nul
		reg query "HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Uninstall" /s | find "Microsoft Visual C++ 2017 x64 Minimum Runtime" > nul
		if !ERRORLEVEL! == 1 (
			reg query "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Uninstall" /s | find "Microsoft Visual C++ 2017 x64 Minimum Runtime" > nul
			if !ERRORLEVEL! == 1 (
				echo Not installed
				echo [ERROR] Microsoft Visual C++ 2017 Redistributable could not install!
				pause
				exit
			) else (
				echo Success
			)
		) else (
			echo Success
		)
	)
)

REM 遅延展開-無効
setlocal DisableDelayedExpansion


set /p TEXT = [DOWNLOADING] PHP Binary ^> < nul
bitsadmin /RawReturn /TRANSFER d1 https://jenkins.pmmp.io/job/PHP-7.3-Aggregate/lastSuccessfulBuild/artifact/PHP-7.3-Windows-x64.zip %CD%\bin.zip
echo Done

REM unzip module
echo Set s=CreateObject("Shell.Application") > unzip.vbs
echo Set z=s.NameSpace("%CD%\bin.zip").items >> unzip.vbs
echo Set f=s.NameSpace("%CD%") >> unzip.vbs
echo If(Not f Is Nothing)Then >> unzip.vbs
echo f.CopyHere z,^&H04+^&H10 >> unzip.vbs
echo End If >> unzip.vbs

set /p TEXT = [EXTRACTING] PHP Binary ^> < nul
call unzip.vbs
del unzip.vbs
del bin.zip
del vc_redist.x64.exe
echo Done


set /p TEXT = [DOWNLOADING] PocketMine-MP.phar from GitHub ^> < nul

echo ^<?php > pmmp.php
echo function C($u){ >> pmmp.php
echo $c=curl_init(); >> pmmp.php
echo curl_setopt($c,CURLOPT_URL,$u); >> pmmp.php
echo curl_setopt($c,CURLOPT_SSL_VERIFYPEER,false); >> pmmp.php
echo curl_setopt($c,CURLOPT_RETURNTRANSFER,true); >> pmmp.php
echo curl_setopt($c,CURLOPT_FOLLOWLOCATION,true); >> pmmp.php
echo return$c; >> pmmp.php
echo } >> pmmp.php
echo $r=curl_exec(C('https://github.com/pmmp/PocketMine-MP/releases/latest')); >> pmmp.php
echo $p1='href=^"/pmmp/PocketMine-MP/releases/download/'; >> pmmp.php
echo $p2='/PocketMine-MP.phar^"'; >> pmmp.php
echo $s=strpos($r,$p1)+strlen($p1); >> pmmp.php
echo $e=strpos($r,$p2,$s+1); >> pmmp.php
echo $v=substr($r,$s,$e-$s); >> pmmp.php
echo $r=curl_exec(C(^"https://github.com/pmmp/PocketMine-MP/releases/download/$v/PocketMine-MP.phar^")); >> pmmp.php
echo file_put_contents('PocketMine-MP.phar',$r); >> pmmp.php

"bin/php/php" pmmp.php
del pmmp.php
echo Done

set /p TEXT = [DOWNLOADING] start.cmd ^> < nul
bitsadmin /RawReturn /TRANSFER d2 https://raw.githubusercontent.com/pmmp/PocketMine-MP/master/start.cmd %CD%\start.cmd
echo Done

set /p TEXT = [DOWNLOADING] DevTools.phar ^> < nul
if not exist %CD%\plugins (
	mkdir %CD%\plugins
)
bitsadmin /RawReturn /TRANSFER d3 https://jenkins.pmmp.io/job/PocketMine-MP/lastSuccessfulBuild/artifact/DevTools.phar %CD%\plugins\DevTools.phar
echo Done

if exist %USERPROFILE%\AppData\Local\Packages\Microsoft.MinecraftUWP_8wekyb3d8bbwe (
	setlocal EnableDelayedExpansion
	CheckNetIsolation LoopbackExempt -s | find "8wekyb3d8bbwe" > nul
	if !ERRORLEVEL! == 1 (
		set /p TEXT = [ENABLING] Minecraft Loopback  *Require Administrator Permission* ^> < nul
		powershell start-process CheckNetIsolation 'LoopbackExempt -a -n=Microsoft.MinecraftUWP_8wekyb3d8bbwe' -verb runas
		echo Done
	)
	setlocal DisableDelayedExpansion
)

echo.
echo #   PMMP Installer - COMPLETE!
echo.
