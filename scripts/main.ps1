Write-Output "There are two scripts in this installation bundle:`r`n1. A windows debloater`r`n2. An application installer`r`n"

# Whether the user wants to run the debloater or no
$choice = (Read-Host -Prompt "Would you like to run the Windows Debloater? (requires administrator privileges) (y/n)").ToLower()
if ($choice.Contains("y")) {
    Write-Host "Running debloater..." -NoNewline
    Write-Host " Please do not close this window!" -ForegroundColor Yellow
    Start-Process powershell.exe -ArgumentList("-NoProfile -ExecutionPolicy Bypass -File $PSScriptRoot/debloater.ps1") -Wait -Verb RunAs
    Write-Output "Finished debloating.`r`n"
}
else {
    Write-Output "Skipped debloater.`r`n"
}

# Whether the user wants to run the app installer or no
$choice = (Read-Host -Prompt "Would you like to run the application installer? (y/n)").ToLower()
if ($choice.Contains("y")) {
    Write-Host "Running application installer..." -NoNewline
    Write-Host " Please do not close this window!" -ForegroundColor Yellow
    Start-Process powershell.exe -ArgumentList("-NoProfile -ExecutionPolicy Bypass -File $PSScriptRoot/installer.ps1") -Wait
    Write-Output "Finished installing applications.`r`n"
}
else {
    Write-Output "Skipped application installation.`r`n"
}

Write-Output "The windows 10 setup tool has finished successfully!"
Write-Output "Press any key to exit..."
Read-Host
exit