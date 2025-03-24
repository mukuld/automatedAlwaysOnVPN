@echo off
mkdir "C:\Scripts"
attrib +h "C:\Scripts"
copy "%~dp0startAndCheckVPN.ps1" "C:\Scripts\startAndCheckVPN.ps1" /Y
copy "%~dp0startAndCheckVPN.vbs" "C:\Scripts\startAndCheckVPN.vbs" /Y

powershell.exe -File "%~dp0startAndCheckVPNTasks.ps1"