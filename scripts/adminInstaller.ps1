# This file gets called in ./intaller.ps1 due to it needing admin permission to install from exe files

# File downloader function using .NET WebClient
function DownloadFile {

    param(
        [parameter(Mandatory = $true)]
        $Url,
        [parameter(Mandatory = $true)]
        $Destination
    )

    $FileName = Split-Path $Url -leaf

    $Wc = New-Object System.Net.WebClient
    $Wc.DownloadFile($Url, "$Destination\$FileName")
    $Wc.Dispose()
}

# Main function which downloads the exe files to '$ENV:Temp\win10prepDownloads\executables' and runs them
function Main {
    # Installing PresentationCore and PresentationFramework to be able to display MessageBoxes
    Write-Host "Adding 'PresentationCore' and 'PresentationFramework' assembly for MessageBoxes..." -NoNewline
    Start-Sleep -Seconds 1
    Add-Type -AssemblyName PresentationCore, PresentationFramework
    Write-Output " Done"

    # List with URLs to direct downloads
    $DownloadUrls = @(
        "https://cdn.cloudflare.steamstatic.com/client/installer/SteamSetup.exe"
        "https://app.prntscr.com/build/setup-lightshot.exe"
        "https://download01.logi.com/web/ftp/pub/techsupport/gaming/lghub_installer.exe"
    )

    # Creating the temporary installation folder
    $TempDownloadFolder = "$ENV:Temp\win10prep\downloads\executables"
    Write-Host "Creating temporary download folder '$TempDownloadFolder'..." -NoNewline
    Start-Sleep -Seconds 1
    New-Item -Path "$TempDownloadFolder" -ItemType Directory | Out-Null
    Write-Output " Done`r`n"

    # Goes through the DownloadUrls list and downloads the files the URLs point to into '$ENV:Temp\win10prepDownloads\executables'
    ForEach ($DownloadUrl in $DownloadUrls) {
        Write-Host "Downloading from '$DownloadUrl'..." -NoNewline
        downloadFile -Url $DownloadUrl -Destination $TempDownloadFolder
        Write-Output " Done"
    }
    Write-Output "Finished downloading installers.`r`n"
    
    # Running the installed files in '$ENV:Temp\win10prepDownloads\executables'
    [Windows.MessageBox]::Show("REMINDER: If the app has finished installing and the is script stuck, terminate the process in the system tray!", "Installer notice", [Windows.MessageBoxButton]::OK, [Windows.MessageBoxImage]::Warning) | Out-Null
    Write-Host "Remember to terminate the running process in the system tray after the installer has finished installing the app!" -ForegroundColor Yellow
    Get-ChildItem -Path $TempDownloadFolder -File "*.exe" | ForEach-Object {
        Write-Output "Running '$($_.FullName)'"
        Start-Process -Wait -FilePath $_.FullName
    }
    Write-Output "Exiting Admin level installer..."
    Start-Sleep -Seconds 2
    exit
}

Start-Transcript "$ENV:Temp\win10prep\logs\adminInstaller.log" | Out-Null

main

Stop-Transcript | Out-Null