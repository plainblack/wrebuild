reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" /v "TZ" /t REG_SZ /d "America/Chicago" /f
c:\data\wre\prereqs\bin\instsrv.exe WREspectre c:\data\wre\prereqs\bin\srvany.exe
reg add "HKLM\SYSTEM\CurrentControlSet\Services\WREspectre\Parameters" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\WREspectre\Parameters" /v "Application" /t REG_SZ /d "c:\data\wre\prereqs\bin\perl.exe" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\WREspectre\Parameters" /v "AppParameters" /t REG_SZ /d "c:\data\WebGUI\sbin\spectre.pl --run" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\WREspectre\Parameters" /v "AppDirectory" /t REG_SZ /d "c:\data\WebGUI\sbin" /f

