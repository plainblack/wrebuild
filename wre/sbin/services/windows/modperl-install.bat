@echo off
setlocal enableextensions
for /f "usebackq tokens=1,2*" %%d in (`reg query "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" /v PATH`) do (
  if "%%d"=="PATH" set globalpath=";%%f;"
)

set globalpath=%globalpath:;C:\data\wre\bin;=;%
set globalpath=%globalpath:;C:\data\wre\bin\;=;%
set globalpath=%globalpath:;C:\data\wre\prereqs\bin;=;%
set globalpath=%globalpath:;C:\data\wre\prereqs\bin\;=;%
set globalpath=%globalpath:;C:\data\wre\prereqs\modules;=;%
set globalpath=%globalpath:;C:\data\wre\prereqs\modules\;=;%

set globalpath="%globalpath:~2,-2%;C:\data\wre\bin;C:\data\wre\prereqs\bin;C:\data\wre\prereqs\modules"

reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" /v "PATH" /t REG_EXPAND_SZ /d %globalpath% /f
c:\data\wre\prereqs\bin\Apache.exe -k install -n WREmodperl -f c:\data\wre\etc\modperl.conf
