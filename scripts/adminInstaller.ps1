# This file gets called in ./intaller.ps1 due to it needing admin permission to install from exe files

# File downloader function using .NET WebClient
function downloadFile {

    param(
        [parameter(Mandatory = $true)]
        $url,
        [parameter(Mandatory = $true)]
        $destination
    )

    $fileName = Split-Path $url -leaf

    $wc = New-Object System.Net.WebClient
    $wc.DownloadFile($url, "$destination\$fileName")
    $wc.Dispose()
}

# Main function which downloads the exe files to 'C:\Temp\prepscriptDownloads\executables' and runs them
function main {
    # Installing PresentationCore and PresentationFramework to be able to display MessageBoxes
    Write-Host "Adding 'PresentationCore' and 'PresentationFramework' assembly for MessageBoxes..." -NoNewline
    Start-Sleep -Seconds 1
    Add-Type -AssemblyName PresentationCore, PresentationFramework
    Write-Output " Done"

    # List with URLs to direct downloads
    $downloadUrls = @(
        "https://cdn.cloudflare.steamstatic.com/client/installer/SteamSetup.exe"
        "https://app.prntscr.com/build/setup-lightshot.exe"
        "https://download01.logi.com/web/ftp/pub/techsupport/gaming/lghub_installer.exe"
    )

    # Creating the temporary installation folder
    $tempDownloadFolder = "C:\Temp\prepscriptDownloads\executables"
    Write-Host "Creating temporary download folder '$tempDownloadFolder'..." -NoNewline
    Start-Sleep -Seconds 1
    New-Item -Path "$tempDownloadFolder" -ItemType Directory | Out-Null
    Write-Output " Done`r`n"

    # Goes through the downloadUrls list and downloads the files the URLs point to into 'C:\Temp\prepscriptDownloads\executables'
    ForEach ($downloadUrl in $downloadUrls) {
        Write-Host "Downloading from '$downloadUrl'..." -NoNewline
        downloadFile -url $downloadUrl -destination $tempDownloadFolder
        Write-Output " Done"
    }
    Write-Output "Finished downloading installers.`r`n"
    
    # Running the installed files in 'C:\Temp\prepscriptDownloads\executables'
    [Windows.MessageBox]::Show("REMINDER: If the app finished installing and the script stuck, terminate the process in the system tray!", "Installer notice", [Windows.MessageBoxButton]::OK, [Windows.MessageBoxImage]::Warning) | Out-Null
    Write-Host "Remember to terminate the running process in the system tray after the installer has finished installing the app!" -ForegroundColor Yellow
    Get-ChildItem -Path $tempDownloadFolder -File "*.exe" | ForEach-Object {
        Write-Output "Running '$($_.FullName)'"
        Start-Process -Wait -FilePath $_.FullName
    }
    Write-Output "Exiting Admin level installer..."
    Start-Sleep -Seconds 1
    exit
}

main