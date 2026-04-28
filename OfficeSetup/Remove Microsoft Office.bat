@echo off
:: V1.24



Set param1=%1
Set param2=%2
Set Temp2=0
Set Temp1=0

IF /I [%param1%] == [noreboot] Set "Temp2=1"
IF /I [%param2%] == [noreboot] Set "Temp2=1"
IF /I [%param1%] == [restarted] Set "Temp1=1"
IF /I [%param2%] == [restarted] Set "Temp1=1"



:: Remove Outlook For Windows by https://github.com/matej137/OutlookRemover
Echo Removing New Outlook For Windows
mkdir %appdata%\NewOutlook
if %PROCESSOR_ARCHITECTURE%==AMD64 copy "%~dp0AppxManifest.xml" %appdata%\NewOutlook
if %PROCESSOR_ARCHITECTURE%==x86 copy "%~dp0AppxManifestx86.xml" %appdata%\NewOutlook\AppxManifest.xml
if %PROCESSOR_ARCHITECTURE%==ARM64 copy "%~dp0AppxManifest-ARM64.xml" %appdata%\NewOutlook\AppxManifest.xml
powershell "New-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock -Name AllowDevelopmentWithoutDevLicense -PropertyType DWORD -Value 1 -Force" >NUL 2>NUL
echo Uninstalling the original version (reffer to readme for errors/red text)
powershell "get-appxpackage -allusers Microsoft.OutlookForWindows | Remove-AppxPackage -allusers"
echo installing the patched one (Errors are bad now)
powershell add-appxpackage -register "'%appdata%\NewOutlook\AppxManifest.xml'"
echo done !

:: Remove Office 365 Preinstalled. Setup.exe is part of officedeploymenttool_17830-20162.exe
Echo Removing Office 365 Preinstalled
start /Wait "" /b "%~dp0setup.exe" /configure "%~dp0uninstall.xml"
echo done !
ping 127.0.0.1 -n 3 >nul 2>&1
