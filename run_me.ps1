#no errors throughout
$ErrorActionPreference = 'silentlycontinue'

# Check for ExecutionPolicy and prompt user to change it with yes or no if it is set wrong
$Policy = "RemoteSigned"
if ((Get-ExecutionPolicy -Scope CurrentUser) -ne $Policy) {
    $Choice = (Read-Host -Prompt "This script requires the ExecutionPolicy to be RemoteSigned in order to have things work properly.`r`nWould you like to change the ExecutionPolicy? (y/n)").toLower()
    if ($Choice.Contains("y")) {
        Write-Host "Setting ExecutonPolicy... " -NoNewline
        Set-ExecutionPolicy -ExecutionPolicy $Policy -Scope "CurrentUser"
        Write-Output "Done"
        Write-Output "Restarting script..."
        Start-Sleep -Seconds 1
        Start-Process powershell.exe -ArgumentList ("-NoProfile -ExecutionPolicy Bypass -File $PSCommandPath")
        exit
    }
}

# Check if user has internet connection
Write-Output "Checking internet connection..."
Start-Sleep -Seconds 1
$Connected = Get-NetRoute | Where-Object DestinationPrefix -eq '0.0.0.0/0' | Get-NetIPInterface | Where-Object ConnectionState -eq 'Connected'
if ($null -eq $Connected) {
    Write-Host "ERROR: You must be connected to the internet in order to use this script!" -ForegroundColor Red
    Read-Host -Prompt "Press any key to continue..."
    exit
}
else {
    Write-Output "User is connected to the internet. Continuing..."
    Start-Sleep -Seconds 1
}

# Run if everything is ready to go
Clear-Host
$TitleText = @"
██╗    ██╗███████╗██╗      ██████╗ ██████╗ ███╗   ███╗███████╗
██║    ██║██╔════╝██║     ██╔════╝██╔═══██╗████╗ ████║██╔════╝
██║ █╗ ██║█████╗  ██║     ██║     ██║   ██║██╔████╔██║█████╗  
██║███╗██║██╔══╝  ██║     ██║     ██║   ██║██║╚██╔╝██║██╔══╝  
╚███╔███╔╝███████╗███████╗╚██████╗╚██████╔╝██║ ╚═╝ ██║███████╗
 ╚══╝╚══╝ ╚══════╝╚══════╝ ╚═════╝ ╚═════╝ ╚═╝     ╚═╝╚══════╝
                                                              
"@
Write-Output $TitleText

# Loads the main script which loads a debloater, installer and a settings changer
$Choice = (Read-Host "The main script is ready. Would you like to run it? (y/n)").toLower()
if ($Choice.Contains("y")) {
    Clear-Host
    Write-Output "Initializing..."
    Start-Sleep -Seconds 2
    Start-Process powershell.exe -ArgumentList ("-NoProfile -ExecutionPolicy Bypass -File $PSScriptRoot/scripts/main.ps1")
    exit
}
else {
    Write-Output "Exiting..."
    Start-Sleep -Seconds 2
    exit
}
