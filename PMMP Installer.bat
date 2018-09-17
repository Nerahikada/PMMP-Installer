@echo off
title PocketMine-MP Installer by Nerahikada
cd /d %~dp0

REM 遅延展開-有効
setlocal EnableDelayedExpansion

set /p TEXT = [CHECKING] Microsoft Visual C++ 2017 Redistributable ^> < nul
REM TODO: このチェックは不完全な可能性がある
reg query "HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Uninstall" /s | find "Microsoft Visual C++ 2017 x64 Minimum Runtime"
if %ERRORLEVEL% == 0 (
	echo Installed
) else if %ERRORLEVEL% == 1 (
	echo Not installed

	set /p TEXT = [DOWNLOADING] Microsoft Visual C++ 2017 Redistributable ^> < nul
	bitsadmin /RawReturn /TRANSFER d0 https://aka.ms/vs/15/release/vc_redist.x64.exe %CD%\vs_redist.x64.exe
	echo Done

	set /p TEXT = [INSTALLING] Microsoft Visual C++ 2017 Redistributable ^> < nul
	call vs_redist.x64.exe
	del vs_redist.x64.exe
	echo Done

	set /p TEXT = [CHECKING] Microsoft Visual C++ 2017 Redistributable ^> < nul
	reg query "HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Uninstall" /s | find "Microsoft Visual C++ 2017 x64 Minimum Runtime" > nul
	if !ERRORLEVEL! == 1 (
		echo Not installed
		echo [ERROR] Microsoft Visual C++ 2017 Redistributable could not install!
		pause
		exit
	) else (
		echo Success
	)
)

REM 遅延展開-無効
setlocal DisableDelayedExpansion


set /p TEXT = [DOWNLOADING] PHP Binary ^> < nul
bitsadmin /RawReturn /TRANSFER d1 https://jenkins.pmmp.io/job/PHP-7.2-Aggregate/lastSuccessfulBuild/artifact/PHP-7.2-Windows-x64.zip %CD%\bin.zip
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

echo.
echo #   PMMP Installer - COMPLETE!
echo.

pause