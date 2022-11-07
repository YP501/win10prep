#no errors throughout
$ErrorActionPreference = 'silentlycontinue'

# Checks if log folder exists, if not it creates one
$LogFolder = "$(Split-Path $PSScriptRoot)\logs"
If (Test-Path $LogFolder) {
    Write-Host "$LogFolder exists. Skipping."
}
Else {
    Write-Host "The folder '$LogFolder' doesn't exist. Creating now."
    New-Item -Path "$LogFolder" -ItemType Directory
}


# Check if user has internet connection
Write-Host "Checking internet connection..."
$Connected = Get-NetRoute | Where-Object DestinationPrefix -eq '0.0.0.0/0' | Get-NetIPInterface | Where-Object ConnectionState -eq 'Connected'
if ($null -eq $Connected) {
    Write-Error "You must be connected to the internet in order to use this script!" -Category ObjectNotFound
    Read-Host -Prompt "Press any key to continue..."
    exit
}
else {
    Write-Host "User has internet connection. Continuing..."
}
Write-Host "`r`n"


# Main function which loads a debloater, installer, settings changer and app config setter after everything is ready
function Main {
    Write-Host @"
██╗    ██╗███████╗██╗      ██████╗ ██████╗ ███╗   ███╗███████╗
██║    ██║██╔════╝██║     ██╔════╝██╔═══██╗████╗ ████║██╔════╝
██║ █╗ ██║█████╗  ██║     ██║     ██║   ██║██╔████╔██║█████╗  
██║███╗██║██╔══╝  ██║     ██║     ██║   ██║██║╚██╔╝██║██╔══╝  
╚███╔███╔╝███████╗███████╗╚██████╗╚██████╔╝██║ ╚═╝ ██║███████╗
 ╚══╝╚══╝ ╚══════╝╚══════╝ ╚═════╝ ╚═════╝ ╚═╝     ╚═╝╚══════╝
                                                              
"@

    Write-Host @"
There are three scripts bundled with this preparation bundle:
1. A windows debloater GUI
2. An application installer
3. A windows settings tweaker
4. An app configurator
"@
    Write-Host "`r`n"

    # Whether the user wants to run the debloater or no
    $Choice = (Read-Host -Prompt "Would you like to run the Windows Debloater GUI? (requires administrator privileges) (y/n)").ToLower()
    if ($Choice.Contains("y")) {
        Write-Host "Running debloater GUI... " -NoNewline
        Write-Warning "Do not close this window!"
        Start-Process powershell.exe -ArgumentList("-NoProfile -ExecutionPolicy Bypass -File $PSScriptRoot/debloater.ps1") -Wait -Verb RunAs
        Write-Host "Closed debloater GUI."
    }
    else {
        Write-Host "Skipped debloater GUI."
    }
    Write-Host "`r`n"

    # Whether the user wants to run the app installer or no
    $Choice = (Read-Host -Prompt "Would you like to run the application installer? (y/n)").ToLower()
    if ($Choice.Contains("y")) {
        Write-Host "Running application installer... " -NoNewline
        Write-Warning "Do not close this window!"
        Start-Process powershell.exe -NoNewWindow -ArgumentList ("-NoProfile -ExecutionPolicy Bypass -File $PSScriptRoot/installer.ps1") -Wait
        Write-Host "Finished installing applications."
    }
    else {
        Write-Host "Skipped application installation."
    }
    Write-Host "`r`n"

    # Whether the user wants to run the settings tweaker or no
    $Choice = (Read-Host -Prompt "Would you like to run the windows settings tweaker? (requires administrator privileges) (y/n)").ToLower()
    if ($Choice.Contains("y")) {
        Write-Host "Running settings tweaker... " -NoNewline
        Write-Warning "Do not close this window!"
        Start-Process powershell.exe -ArgumentList("-NoProfile -ExecutionPolicy Bypass -File $PSScriptRoot/settingsTweaker.ps1") -Wait -Verb RunAs
        Write-Host "Finished tweaking settings."
    }
    else {
        Write-Host "Skipped windows settings tweaker."
    }
    Write-Host  "`r`n"

    # Whether or not the user wants to run the app configurator
    $Choice = (Read-Host -Prompt "Would you like to run the app configurator? (y/n)").ToLower()
    if ($Choice.Contains("y")) {
        Write-Host "Running app configurator... " -NoNewline
        Write-Warning "Do not close this window!"
        Start-Process powershell.exe -NoNewWindow -ArgumentList("-NoProfile -ExecutionPolicy Bypass -File $PSScriptRoot/appConfigurator.ps1") -Wait
        Write-Host "Finished configuring apps."
    }
    else {
        Write-Host "Skipped app configurator."
    }
    Write-Host "`r`n"

    Write-Host "The windows 10 preparation script has finished successfully!" -ForegroundColor Green

    Stop-Transcript | Out-Null
    Write-Host "Logs can be found at '$(Split-Path $PSScriptRoot)\logs'" -ForegroundColor Yellow
    Write-Host "`r`n"
    
    # Ask if the user wants to reboot
    $Choice = (Read-Host -Prompt "A reboot is advised after finishing running this script. Would you like to reboot now? (y/n)").ToLower()
    if ($Choice.Contains('y')) {
        Restart-Computer -Force
    }
}
Start-Transcript "$(Split-Path $PSScriptRoot)\logs\main.log" | Out-Null
Main
# 'Stop-Transcript' gets called at end of main function due to reboot