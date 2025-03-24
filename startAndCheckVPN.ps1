# Name: Start VPN at startup and check for connection
# Author: Mukul Dharwadkar

# Define variables
$TrustedNetworkRange = "10.0.0.0/8"
$VpnNetworkRange = "10.75.0.0"
$VpnSubnetMask = "255.255.254.0"
$TrustedDnsSuffix = "city.santaclara.local"
$VpnName = "Device Tunnel"
$CurrentUser = $env:USERNAME
$MaxRetries = 3
$RetryInterval = 3  # Initial retry interval in seconds
$TestIP = "csi.santaclaraca.gov"
$TestDestination = "1.1.1.1"
$EventSource = "VPNConnectionScript"

# Ensure event log source exists
function Set-EventLogSource {
    $EventLogKey = "HKLM:\\SYSTEM\\CurrentControlSet\\Services\\EventLog\\Application\\$EventSource"
    if (!(Test-Path $EventLogKey)) {
        New-Item -Path $EventLogKey -Force | Out-Null
        New-ItemProperty -Path $EventLogKey -Name "EventMessageFile" -Value "C:\\Windows\\System32\\eventvwr.exe" -PropertyType String -Force | Out-Null
    }
}
Set-EventLogSource

# Function to log messages to Event Viewer
function Write-Log {
    param ([string]$Message, [string]$EntryType = "Information", [int]$EventId = 17678)
    Write-EventLog -LogName Application -Source $EventSource -EntryType $EntryType -EventId $EventId -Message "$Message User: CITY\$CurrentUser"
}

# Function to check network connectivity
function Test-Network {
    param ([string]$IPAddress)
    return (Test-Connection -ComputerName $IPAddress -Count 2 -Quiet)
}

function Check-Network {
    while (-not (Test-Network -IPAddress $TestDestination)) {
        Start-Sleep -Seconds $RetryInterval  # Wait 3 seconds before retrying
    }
    return $true
}

function Check-InternalNetwork {
    $Adapter = Get-NetAdapter | Where-Object { $_.Status -eq "Up" } | Select-Object -First 1
    if ($Adapter) {
        return (Get-DnsClient | Where-Object { $_.InterfaceAlias -eq $Adapter.Name }).ConnectionSpecificSuffix
    }
    return $null
}

# Function to check if the IP addresss is within VPN Subnet
function Check-VPNSubnet {
    param([string]$IPAddress)
    # Convert IP address and subnet mask to byte arrays
    $ipBytes = [System.Net.IPAddress]::Parse($IPAddress).GetAddressBytes()
    #$subnetBytes = [System.Net.IPAddress]::Parse($VpnNetworkRange).GetAddressBytes()
    $maskBytes = [System.Net.IPAddress]::Parse($VpnSubnetMask).GetAddressBytes()

    # Perform bitwise AND operation
    $networkAddress = [byte[]]::new(4)
    for ($i = 0; $i -lt 4; $i++) {
    	$networkAddress[$i] = $ipBytes[$i] -band $maskBytes[$i]
    }

    # Convert back to IP address
    $networkAddressString = [System.Net.IPAddress]::new($networkAddress)

    # Check if the network address matches the subnet
    return ($networkAddressString.ToString() -eq $VpnNetworkRange) 
}

# Function to verify if connected to a trusted network
function Check-TrustedNetwork {
    $Timeout = 300  # Max wait time in seconds (5 minutes)
    $Elapsed = 0
    while ($Elapsed -lt $Timeout) {
        $IPAddresses = Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.PrefixOrigin -in ("Dhcp", "Manual", "Other") -and $_.AddressState -eq "Preferred" }
        
        if ($IPAddresses) {
            foreach ($IP in $IPAddresses) {
                if ($IP.IPAddress -match '^10\.\d+\.\d+\.\d+$' -and (-not (Check-VPNSubnet -IPAddress $IP.IPAddress)) -and ((Check-InternalNetwork))) {
                    #Write-Log "Connected to trusted network ($TrustedNetworkRange). VPN connection is not required." "Information" 20221
                    # Check if VPN is connected and disconnect it
                    $VpnState = (Get-VpnConnection -Name "Device Tunnel" -AllUserConnection).ConnectionStatus
                    if ($VpnState -eq "Connected") {
                        #Write-Log "Connected to trusted network ($TrustedNetworkRange) and VPN is connected. VPN connection is not required. Disconnecting VPN." "Information" 20221
                        rasdial $VpnName /DISCONNECT > $null 2>&1
                    }
                    return $true  # Exit immediately
                } 
                elseif ($IP.IPAddress -match '^10\.\d+\.\d+\.\d+$' -and (Check-VPNSubnet -IPAddress $IP.IPAddress)) {
                    #Write-Log "Connected to VPN ($VPNNetworkRange). No action needed." "Information" 20221
                    return $true  # Exit immediately
                }
            }
            
            # Exit the loop if IP address is allocated outside of trusted network range.
            return $false
        }

        Start-Sleep -Seconds $RetryInterval
        $Elapsed += $RetryInterval
    }

    Write-Log "No IP address allocated after 5 minutes. Exiting." "Error" 27678
    return $false  # If no trusted IP found, return false
}

# Function to establish VPN connection with retries
function Connect-VPN {
    for ($Attempt = 1; $Attempt -le $MaxRetries; $Attempt++) {
        #Write-Log "Attempting VPN connection for $VpnName (Attempt $Attempt)." "Information" 20221
        rasdial $VpnName > $null 2>&1
        Start-Sleep -Seconds 5
        if (Test-Network -IPAddress $TestIP) {
            #Write-Log "VPN connection established successfully on attempt $Attempt." "Information" 20221
            return $true
        } else {
            #Write-Log "VPN connection failed on attempt $Attempt." "Warning" 20222
            rasdial $VpnName /DISCONNECT > $null 2>&1
            Start-Sleep -Seconds ($RetryInterval * $Attempt)
        }
    }
    Write-Log "VPN connection could not be established after $MaxRetries attempts." "Error" 27678
    return $false
}

# Main Execution
if ((Check-Network)) {
    if (-not (Check-TrustedNetwork)) {
    	#Write-Log "No trusted network. Trying VPN Connection." "Error" 20223
	Connect-VPN
    }
}