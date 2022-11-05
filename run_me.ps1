#no errors throughout
$ErrorActionPreference = 'silentlycontinue'

# Check for ExecutionPolicy and prompt user to change it with yes or no if it is set wrong
$policy = "RemoteSigned"
if ((Get-ExecutionPolicy -Scope CurrentUser) -ne $policy) {
    $choice = (Read-Host -Prompt "This script requires the ExecutionPolicy to be RemoteSigned in order to have things work properly.`r`nWould you like to change the ExecutionPolicy? (y/n)").toLower()
    if ($choice.Contains("y")) {
        Write-Host "Setting ExecutonPolicy... " -NoNewline
        Set-ExecutionPolicy -ExecutionPolicy $policy -Scope "CurrentUser"
        Write-Output "Done"
        Write-Output "Restarting script..."
        Start-Sleep -Seconds 1
        Start-Process powershell.exe -ArgumentList ("-NoProfile -ExecutionPolicy Bypass -File $PSCommandPath")
        exit
    }
}

Clear-Host
$titleText = @"
██╗    ██╗███████╗██╗      ██████╗ ██████╗ ███╗   ███╗███████╗
██║    ██║██╔════╝██║     ██╔════╝██╔═══██╗████╗ ████║██╔════╝
██║ █╗ ██║█████╗  ██║     ██║     ██║   ██║██╔████╔██║█████╗  
██║███╗██║██╔══╝  ██║     ██║     ██║   ██║██║╚██╔╝██║██╔══╝  
╚███╔███╔╝███████╗███████╗╚██████╗╚██████╔╝██║ ╚═╝ ██║███████╗
 ╚══╝╚══╝ ╚══════╝╚══════╝ ╚═════╝ ╚═════╝ ╚═╝     ╚═╝╚══════╝
                                                              
"@
Write-Output $titleText

# Loading the main script which contains a debloater and installer
$choice = (Read-Host "The main script is ready. Would you like to run it? (y/n)").toLower()
if ($choice.Contains("y")) {
    Clear-Host
    Write-Output "Initializing..."
    Start-Sleep -Seconds 2
    Start-Process powershell.exe -ArgumentList ("-NoProfile -ExecutionPolicy Bypass -File $PSScriptRoot/scripts/main.ps1")
    exit
}

exit