# Checks if log folder exists, if not it creates one
$LogFolder = "$(Split-Path $PSScriptRoot)\logs"
function CheckLogFolder {
    If (Test-Path $LogFolder) {
        Write-Host "$LogFolder exists. Skipping."
    }
    Else {
        Write-Host "The folder '$LogFolder' doesn't exist. Creating now."
        New-Item -Path "$LogFolder" -ItemType Directory
    }
    
    # Newline for formatting (looks good)
    Write-Host "`r`n"
}

#========================================================================================================

# Check if user has internet connection (required for app installer)
function CheckInternetConnection {
    Write-Host "Checking internet connection..."
    $Connected = Get-NetRoute | Where-Object DestinationPrefix -eq '0.0.0.0/0' | Get-NetIPInterface | Where-Object ConnectionState -eq 'Connected'
    if ($null -eq $Connected) {
        Write-Error "You must be connected to the internet in order to use this script!" -Category ObjectNotFound
        Read-Host -Prompt "Press any key to continue..."
        exit
    }
    else { Write-Host "User has internet connection. Continuing." }

    # Newline for formatting (looks good)
    Write-Host "`r`n"
}

#=======================================================================================================================================================

# Main function which loads scripts
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
1. An application installer
2. A windows settings tweaker
3. An app configurator

It is recommended to run all of these because some scripts require things that get added by other scripts.
"@

    # Newline for formatting (looks good)
    Write-Host "`r`n"

    #=======================================================================================================================================================

    # Prompt for app installer
    Write-Host "Would you like to run the application installer? [Y/N]" -ForegroundColor Cyan
    $Choice = (Read-Host).ToLower()
    if ($Choice.Contains("y")) {
        Write-Host "Running application installer... " -NoNewline
        Write-Warning "Do not close this window!"
        Start-Process powershell.exe -ArgumentList("-NoProfile -ExecutionPolicy Bypass -File $PSScriptRoot\installer.ps1") -Wait -NoNewWindow
        Write-Host "Finished running application installer."
    }
    else { Write-Host "Skipped application installer." }

    # Newline for formatting (looks good)
    Write-Host "`r`n"

    #=======================================================================================================================================================

    # Prompt for settings tweaker
    Write-Host "Would you like to run the windows settings tweaker? (requires administrator privileges) [Y/N]" -ForegroundColor Cyan
    $Choice = (Read-Host).ToLower()
    if ($Choice.Contains("y")) {
        Write-Host "Running settings tweaker... " -NoNewline
        Write-Warning "Do not close neither this or the newly opened window!"
        Start-Process powershell.exe -ArgumentList("-NoProfile -ExecutionPolicy Bypass -File $PSScriptRoot\settingsTweaker.ps1") -Wait -Verb RunAs
        Write-Host "Finished running windows settings tweaker."
    }
    else { Write-Host "Skipped windows settings tweaker." }

    # Newline for formatting (looks good)
    Write-Host "`r`n"

    #=======================================================================================================================================================

    # Prompt for app configurator
    Write-Host "Would you like to run the app configurator? [Y/N]" -ForegroundColor Cyan
    $Choice = (Read-Host).ToLower()
    if ($Choice.Contains("y")) {
        Write-Host "Running app configurator... " -NoNewline
        Write-Warning "Do not close this window!"
        Start-Process powershell.exe -ArgumentList("-NoProfile -ExecutionPolicy Bypass -File $PSScriptRoot\appConfigurator.ps1") -Wait -NoNewWindow
        Write-Host "Finished running app configurator."
    }
    else { Write-Host "Skipped app configurator." }

    # Newline for formatting (looks good)
    Write-Host "`r`n"

    #=======================================================================================================================================================

    # Runs after all the scripts are done running/skipped
    Write-Host "The windows 10 preparation script has finished successfully!" -ForegroundColor Green
    Write-Host "Logs can be found at '$LogFolder'" -ForegroundColor Yellow

    # Newline for formatting (looks good)
    Write-Host "`r`n"

    # Prompt with reboot
    $Choice = (Read-Host -Prompt "A reboot is advised after running this preparation package. Would you like to reboot now? [Y/N]").ToLower()
    if ($Choice.Contains("y")) { Restart-Computer -Force }
    else { 
        Write-Host "Skipped reboot. Exiting."
        Start-Sleep -Seconds 2
        exit
    }
}
# CheckLogFolder comes before Start-Transcript since transcript gets saved into the folder which is getting created in CheckLogFolder
CheckLogFolder
Start-Transcript "$LogFolder\main.log" | Out-Null
CheckInternetConnection
Main
Stop-Transcript | Out-Null
exit