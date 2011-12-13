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

reg add "HKLM\SOFTWARE\ImageMagick\6.3.7\Q:8" /v "BinPath" /t REG_SZ /d c:\data\wre\prereqs\bin /f
reg add "HKLM\SOFTWARE\ImageMagick\6.3.7\Q:8" /v "ConfigurePath" /t REG_SZ /d c:\data\wre\prereqs\bin\config /f
reg add "HKLM\SOFTWARE\ImageMagick\6.3.7\Q:8" /v "LibPath" /t REG_SZ /d c:\data\wre\prereqs\bin /f
reg add "HKLM\SOFTWARE\ImageMagick\6.3.7\Q:8" /v "CoderModulesPath" /t REG_SZ /d c:\data\wre\prereqs\bin\modules\coders /f
reg add "HKLM\SOFTWARE\ImageMagick\6.3.7\Q:8" /v "FilterModulesPath" /t REG_SZ /d c:\data\wre\prereqs\bin\modules\filters /f

c:\data\wre\prereqs\bin\Apache.exe -k install -n WREmodperl -f c:\data\wre\etc\modperl.conf
