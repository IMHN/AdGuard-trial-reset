@echo off
 CLS
 ECHO.
 ECHO =============================
 ECHO Running Admin shell
 ECHO 
 ECHO api.adguard.com
 ECHO api-b.adguard.com
 ECHO 176.103.133.92
 ECHO 104.20.30.130
 ECHO 194.177.22.245
 ECHO =============================

:init
 setlocal DisableDelayedExpansion
 set cmdInvoke=1
 set winSysFolder=System32
 set "batchPath=%~0"
 for %%k in (%0) do set batchName=%%~nk
 set "vbsGetPrivileges=%temp%\OEgetPriv_%batchName%.vbs"
 setlocal EnableDelayedExpansion

:checkPrivileges
  NET FILE 1>NUL 2>NUL
  if '%errorlevel%' == '0' ( goto gotPrivileges ) else ( goto getPrivileges )

:getPrivileges
  if '%1'=='ELEV' (echo ELEV & shift /1 & goto gotPrivileges)
  ECHO.
  ECHO **************************************
  ECHO Invoking UAC for Privilege Escalation
  ECHO **************************************

  ECHO Set UAC = CreateObject^("Shell.Application"^) > "%vbsGetPrivileges%"
  ECHO args = "ELEV " >> "%vbsGetPrivileges%"
  ECHO For Each strArg in WScript.Arguments >> "%vbsGetPrivileges%"
  ECHO args = args ^& strArg ^& " "  >> "%vbsGetPrivileges%"
  ECHO Next >> "%vbsGetPrivileges%"

  if '%cmdInvoke%'=='1' goto InvokeCmd 

  ECHO UAC.ShellExecute "!batchPath!", args, "", "runas", 1 >> "%vbsGetPrivileges%"
  goto ExecElevation

:InvokeCmd
  ECHO args = "/c """ + "!batchPath!" + """ " + args >> "%vbsGetPrivileges%"
  ECHO UAC.ShellExecute "%SystemRoot%\%winSysFolder%\cmd.exe", args, "", "runas", 1 >> "%vbsGetPrivileges%"

:ExecElevation
 "%SystemRoot%\%winSysFolder%\WScript.exe" "%vbsGetPrivileges%" %*
 exit /B

:gotPrivileges
 setlocal & cd /d %~dp0
 if '%1'=='ELEV' (del "%vbsGetPrivileges%" 1>nul 2>nul  &  shift /1)

 ::::::::::::::::::::::::::::
 ::START
 ::::::::::::::::::::::::::::

TASKKILL /F /IM Adguard.exe
Net stop "Adguard Service"

SET NEWLINE=^& echo.

FIND /C /I "api.adguard.com" %WINDIR%\system32\drivers\etc\hosts
IF %ERRORLEVEL% NEQ 0 ECHO %NEWLINE%^127.0.0.1 api.adguard.com>>%WINDIR%\system32\drivers\etc\hosts

Netsh.exe advfirewall firewall delete rule name="Adguard.exe"
Netsh.exe advfirewall firewall delete rule name="AdguardSvc.exe"

:CheckOS
IF EXIST "%PROGRAMFILES(X86)%" (GOTO 64BIT) ELSE (GOTO 32BIT)

:64BIT
Netsh.exe advfirewall firewall add rule name="Adguard.exe" program="%ProgramFiles(x86)%\Adguard\Adguard.exe" protocol=any dir=out enable=yes action=block remoteip=194.177.22.245 profile=private,public,domain
Netsh.exe advfirewall firewall add rule name="AdguardSvc.exe" program="%ProgramFiles(x86)%\Adguard\AdguardSvc.exe" protocol=any dir=out enable=yes action=block remoteip=194.177.22.245 profile=private,public,domain
GOTO END

:32BIT
Netsh.exe advfirewall firewall add rule name="Adguard.exe" program="%ProgramFiles%\Adguard\Adguard.exe" protocol=any dir=out enable=yes action=block remoteip=194.177.22.245 profile=private,public,domain
Netsh.exe advfirewall firewall add rule name="AdguardSvc.exe" program="%ProgramFiles%\Adguard\AdguardSvc.exe" protocol=any dir=out enable=yes action=block remoteip=194.177.22.245 profile=private,public,domain
GOTO END

:END