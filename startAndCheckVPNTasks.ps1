# Name: Start VPN at startup and check for connection
# Author: Mukul Dharwadkar
# Copyright: JnanaTech Ventures (2025)
# No unauthorized copying and distribution is permitted

# Define file path for VBS script
$ScriptPath = "C:\Scripts\startAndCheckVPN.vbs"

# Define task names
$TaskName = "Automatically connect VPN on Startup and if not connected on user logon"

# Set task descriptions
$TaskDescription = "Automatically connect VPN on startup and / or user logon if VPN connection at startup failed. Also check if the network changed to trusted network and disconnect VPN"

# Define actions to execute the VBS script
$TaskAction = New-ScheduledTaskAction -Execute "wscript.exe" -Argument "`"$ScriptPath`""

# Define triggers
$TaskTrigger1 = New-ScheduledTaskTrigger -AtStartup  # Runs at system startup
$TaskTrigger2 = New-ScheduledTaskTrigger -AtLogOn    # Runs at user logon

# Define a repeating trigger for every 1 minute
$RepetitionInterval = (New-TimeSpan -Minutes 1)
$TaskTrigger3 = New-ScheduledTaskTrigger -Once -At (Get-Date).AddMinutes(1) -RepetitionInterval $RepetitionInterval

# Define principals (who runs the task)
$TaskPrincipal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -LogonType ServiceAccount

# Define task settings
$TaskSettings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable

# Register Task 2 (Logon & Repeating Task) with Current User
Register-ScheduledTask -TaskName $TaskName -Description $TaskDescription -Action $TaskAction -Trigger $TaskTrigger1, $TaskTrigger2, $TaskTrigger3 -Principal $TaskPrincipal -Settings $TaskSettings -Force
