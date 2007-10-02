c:\data\wre\prereqs\bin\instsrv.exe WREspectre c:\data\wre\prereqs\bin\srvany.exe
reg add HKLM\SYSTEM\CurrentControlSet\Services\WREspectre\Parameters\Application c:\data\wre\prereqs\bin\perl.exe
reg add HKLM\SYSTEM\CurrentControlSet\Services\WREspectre\Parameters\AppParameters c:\data\WebGUI\sbin\spectre.pl --run
reg add HKLM\SYSTEM\CurrentControlSet\Services\WREspectre\Parameters\AppDirectory c:\data\WebGUI\sbin
