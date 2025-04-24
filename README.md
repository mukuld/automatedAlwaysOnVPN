# Automated AlwaysON VPN Connection for Non-Domain Joined PCs
### Overview
This solution provides a robust and automated way to establish and maintain a VPN connection for non-domain joined Windows PCs using Microsoft's AlwaysON VPN with Device Tunnel. It addresses a critical gap in Microsoft's native support, which does not offer automated VPN connectivity for non-domain joined devices using Device Tunnel. This PowerShell-based solution ensures seamless VPN connectivity at system startup, user logon, and through continuous monitoring, making it ideal for organizations seeking secure, reliable remote access.

With Intune, Microsoft is encouraging its customers to adopt a cloud-native approach by migrating or setting up their directory and authentication exclusively on Azure. While this is a potentially future-proof way to architect and operate your environment, many organizations will continue to maintain on-premises systems or servers for the foreseeable future. This solution bridges the gap for hybrid environments, ensuring secure and automated VPN connectivity for non-domain joined devices, whether in the cloud or on-premises.
### Problem Statement
Microsoft's AlwaysON VPN is a powerful tool for secure remote access, but it lacks native support for automated Device Tunnel connections on non-domain joined PCs. This limitation poses challenges for organizations with distributed, non-domain joined devices, as manual VPN connections are prone to errors, disrupt workflows, and compromise security. Without automation, IT teams face increased overhead in managing and troubleshooting connectivity issues.

This solution was developed to bridge this gap, offering a fully automated, reliable, and secure VPN connection process that integrates seamlessly with Windows environments.
Solution Features

- **Automated VPN Connection**: Establishes AlwaysON VPN Device Tunnel connections at system startup and user logon, with continuous monitoring to ensure connectivity.
- **Trusted Network Detection**: Automatically disconnects the VPN when connected to a trusted network, optimizing performance and reducing unnecessary VPN usage.
- **Retry Logic**: Implements robust retry mechanisms to handle connection failures, ensuring high reliability.
- **Event Logging**: Logs all actions to the Windows Event Viewer for easy monitoring and troubleshooting.
- **Seamless Deployment**: Includes scripts for easy installation and configuration, with a hidden scripts directory for security.
- **Non-Domain Joined Support**: Specifically designed for non-domain joined PCs, addressing a key limitation in Microsoft's AlwaysON VPN.

### How It Works
The solution comprises four scripts that work together to automate VPN connectivity:

1. **startAndCheckVPNTasks.ps1**: Creates a scheduled task to run the VPN connection script at system startup, user logon, and every minute to check connectivity.
2. **startAndCheckVPN.bat**: Deploys the scripts to a hidden directory (`C:\Scripts`) and triggers the task creation script.
3. **startAndCheckVPN.ps1**: The core script that checks network status, establishes VPN connections, and handles trusted network detection and retries.
4. **startAndCheckVPN.vbs**: A VBScript wrapper to run the PowerShell script silently, ensuring a smooth user experience.

### Key Workflow

- **Deployment**: Run `startAndCheckVPN.bat` to copy scripts and set up the scheduled task.
- **Execution**: The scheduled task triggers `startAndCheckVPN.vbs`, which runs `startAndCheckVPN.ps1` silently.
- **Network Check**: The script verifies if the device is on a trusted network. If not, it attempts to establish a VPN connection.
- **Continuous Monitoring**: The script runs every minute to ensure the VPN remains connected or disconnects when on a trusted network.
- **Logging**: All actions are logged to the Windows Event Viewer under the `VPNConnectionScript` source for auditing.

### Installation

1. **Prerequisites**:
    - Windows 10/11 with AlwaysON VPN configured.
    - Administrative privileges to run the batch file and create scheduled tasks.
    - Replace placeholder variables in `startAndCheckVPN.ps1` (e.g., `YOURTRUSTEDRANGE`, `YOURVPNRANGE`, `YOURVPNNAME`) with your environment-specific values.


2. **Steps**:

    - The batch file creates a hidden `C:\Scripts` directory, copies the scripts, and sets up the scheduled task.
    - Ensure the VPN profile is configured in Windows before running the script.

    ```
    git clone https://github.com/mukuld/automatedAlwaysOnVPN.git
    cd automatedAlwaysOnVPN
    .\startAndCheckVPN.bat
    ```


3. **Configuration**:

    * Edit `startAndCheckVPN.ps1` to update variables like `$TrustedNetworkRange`, `$VpnName`, and `$TestIP` to match your environment.
    * Test the script manually to verify connectivity before deploying to production.


### Usage
Once deployed, the solution runs automatically:

* At system startup and user logon, it checks for a trusted network or establishes a VPN connection.
* Every minute, it verifies connectivity and reconnects if necessary.
* Logs are available in the Windows Event Viewer under `Application` > `VPNConnectionScript`.

### Contributing
We welcome contributions to enhance this solution! To contribute:

1. Fork the repository.
2. Create a feature branch (git checkout -b feature/YourFeature).
3. Commit your changes (git commit -m "Add YourFeature").
4. Push to the branch (git push origin feature/YourFeature).
5. Open a Pull Request.

Please ensure your code adheres to the existing style and includes appropriate documentation.
### License
Copyright © 2025 JnanaTech Ventures. All rights reserved. No unauthorized copying or distribution is permitted. Contact us for licensing inquiries.
Contact
For feature requests or support, please reach out to:

* Email: mukul@dharwadkar.com
* GitHub Issues: [File an issue](/issues)


**Join us in revolutionizing VPN connectivity for non-domain joined PCs in hybrid environments!**
