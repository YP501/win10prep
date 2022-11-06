$LogFolder = "$ENV:Temp\win10prep\logs"
If (Test-Path $LogFolder) {
    Write-Output "$LogFolder exists. Skipping."
}
Else {
    Write-Output "The folder '$LogFolder' doesn't exist. This folder will be used for logs. Creating now."
    Start-Sleep 1
    New-Item -Path "$LogFolder" -ItemType Directory
    Write-Output "The folder $LogFolder was successfully created."
}
Start-Sleep -Seconds 2
Clear-Host

Start-Sleep -Seconds 1
Start-Transcript "$LogFolder\main.log" | Out-Null

Write-Output @"
There are three scripts bundled with this preparation bundle:
1. A windows debloater
2. An application installer
3. A windows settings tweaker

"@

# Whether the user wants to run the debloater or no
$Choice = (Read-Host -Prompt "Would you like to run the Windows Debloater? (requires administrator privileges) (y/n)").ToLower()
if ($Choice.Contains("y")) {
    Write-Host "Running debloater..." -NoNewline
    Write-Host " Please do not close this window!" -ForegroundColor Yellow
    Start-Process powershell.exe -ArgumentList("-NoProfile -ExecutionPolicy Bypass -File $PSScriptRoot/debloater.ps1") -Wait -Verb RunAs
    Write-Output "Finished debloating.`r`n"
}
else {
    Write-Output "Skipped debloater.`r`n"
}

# Whether the user wants to run the app installer or no
$Choice = (Read-Host -Prompt "Would you like to run the application installer? (y/n)").ToLower()
if ($Choice.Contains("y")) {
    Write-Host "Running application installer..." -NoNewline
    Write-Host " Please do not close this window!" -ForegroundColor Yellow
    Start-Process powershell.exe -ArgumentList("-NoProfile -ExecutionPolicy Bypass -File $PSScriptRoot/installer.ps1") -Wait
    Write-Output "Finished installing applications.`r`n"
}
else {
    Write-Output "Skipped application installation.`r`n"
}

# Whether the user wants to run the settings tweaker or no
$Choice = (Read-Host -Prompt "Would you like to run the windows settings tweaker? (requires administrator privileges) (y/n)").ToLower()
if ($Choice.Contains("y")) {
    Write-Host "Running settings tweaker..." -NoNewline
    Write-Host " Please do not close this window!" -ForegroundColor Yellow
    Start-Process powershell.exe -ArgumentList("-NoProfile -ExecutionPolicy Bypass -File $PSScriptRoot/settingsTweaker.ps1") -Wait -Verb RunAs
    Write-Output "Finished tweaking settings.`r`n"
}
else {
    Write-Output "Skipped windows settings tweaker.`r`n"
}

# Ask if the user wants to reboot now
Write-Host "The windows 10 preparation script has finished successfully!" -ForegroundColor Green

Stop-Transcript | Out-Null
Write-Host "A folder with logs can be found at '$ENV:Temp\win10prep\logs'" -ForegroundColor Yellow

$Choice = (Read-Host -Prompt "A reboot is advised after finishing running this script. Would you like to reboot now? (y/n)").ToLower()
if ($Choice.Contains('y')) {
    Restart-Computer -Force
}
else {
    Write-Output "Skipped reboot. Exiting..."
    Start-Sleep -Seconds 2
    exit
}
