Rem Name: Start VPN at startup and check for connection
REm Author: Mukul Dharwadkar
Rem Copyright: JnanaTech Ventures (2025)
Rem No unauthorized copying and distribution is permitted

Set objShell = CreateObject("WScript.Shell")
objShell.Run "powershell.exe -File C:\Scripts\startAndCheckVPN.ps1", 0, False

