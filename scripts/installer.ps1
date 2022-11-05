function downloadAndinstallScoopApps {
    $scoopApps = @(
        "7zip"
        "audacity"
        "blender"
        "filezilla"
        "github"
        "vscode"
        "mongodb-compass"
        "firefox"
        "nodejs"
        "obs-studio"
        "oh-my-posh"
        "terminal-icons"
        "python"
        "qbittorrent-enhanced"
        "spotify"
        "translucenttb"
        "vlc"
        "BitstreamVeraSansMono-NF"
        "yarn"
    )

    # Installing scoop cmdlet
    Write-Output "Checking if scoop is already installed..."
    Start-Sleep -Seconds 1
    if (Get-Command scoop -ErrorAction SilentlyContinue) {
        Write-Output "Scoop is already installed. Skipping..."
        Write-Output "`r`n"
    }
    else {
        Write-Output "Scoop is not installed. Installing now."
        Invoke-RestMethod get.scoop.sh | Invoke-Expression
        Write-Output "`r`n"
    }

    $scoopAppsDir = "$home\scoop\apps"

    # Installing git for getting scoop buckets
    scoop install git
    Write-Output "`r`n"

    # Installing scoop buckets
    scoop bucket add nerd-fonts
    Write-Output "`r`n"
    scoop bucket add extras
    Write-Output "`r`n"

    # Installing the apps with scoop
    ForEach ($scoopApp in $scoopApps) {
        scoop install $scoopApp
        Write-Output "`r`n"
        
        # App specific scripts to run after installing the app
        switch ($scoopApp) {
            "7zip" {
                Write-Output "`r`nInstalling 7zip context menu registry entries..."
                reg import "$scoopAppsDir\7zip\current\install-context.reg"
            }
            "vscode" {
                Write-Output "`r`nInstalling vscode context menu registry entries..."
                reg import "$scoopAppsDir\vscode\current\install-associations.reg"
                reg import "$scoopAppsDir\vscode\current\install-context.reg"

                # Installation of vscode extensions
                Write-Output "`r`nPreparing installation of vscode extensions..."
                Start-Sleep -Seconds 2
                $vscodeExtensions = @(
                    "christian-kohler.npm-intellisense"
                    "dbaeumer.vscode-eslint"
                    "dbankier.vscode-quick-select"
                    "eamodio.gitlens"
                    "esbenp.prettier-vscode"
                    "formulahendry.code-runner"
                    "Gruntfuggly.todo-tree"
                    "illixion.vscode-vibrancy-continued"
                    "jbockle.jbockle-format-files"
                    "LeonardSSH.vscord"
                    "miguelsolorio.fluent-icons"
                    "ms-python.isort"
                    "ms-python.python"
                    "ms-python.vscode-pylance"
                    "ms-vscode.powershell"
                    "ms-vsliveshare.vsliveshare"
                    "naumovs.color-highlight"
                    "PKief.material-icon-theme"
                    "ritwickdey.LiveServer"
                    "usernamehw.errorlens"
                    "wix.vscode-import-cost"
                    "xuanzhi33.simple-calculator"
                    "zhuangtongfa.material-theme"
                )

                ForEach ($extension in $vscodeExtensions) {
                    Write-Host "Installing $extension..." -NoNewline
                    code --install-extension $extension | Out-Null
                    Write-Output " Done"
                }
                Write-Output "`r`n"
            }
            "firefox" {
                # Opens a window which lets you set the 'scoop profile' to the default firefox profile to not lose data over updates
                firefox -P
            }
            "python" {
                Write-Output "`r`nInstalling python registry entries..."
                reg import "$scoopAppsDir\python\current\install-pep-514.reg"
            }
        }
    }

    Write-Output "Finished installing apps with scoop.`r`n"
    Start-Sleep -Seconds 3
}

# Function to get the latest release download URL with a filter from a Github repository
function getDownloadUrl {

    param(
        [parameter(Mandatory = $true)]
        $repo,
        [parameter(Mandatory = $true)]
        $filter
    )

    $uri = "https://api.github.com/repos/$repo/releases"

    # Get all download URLs from latest release
    $downloadUrls = ((Invoke-RestMethod -Method GET -Uri $uri)[0].assets).browser_download_url

    # Filter all download URls and return filtered URL
    ($downloadUrls | Select-String -Pattern $filter).toString()
}

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

# Function to add any .exe file to '%appdata%\Microsoft\Windows\Start Menu\Programs'
function addToStartMenu {
    
    param(
        [Parameter(Mandatory = $true)]
        $target
    )

    $startMenuProgramsFolder = "$ENV:AppData\Microsoft\Windows\Start Menu\Programs"
    $fileName = [io.path]::GetFileNameWithoutExtension($target)

    $WshShell = New-Object -comObject WScript.Shell
    $Shortcut = $WshShell.CreateShortcut("$startMenuProgramsFolder\$fileName.lnk")
    $Shortcut.TargetPath = $target
    $Shortcut.Save()
}

# Function to download and extract apps from Github
function downloadAndExtractGithubApps {
    Write-Output "Preparing to download and extract github apps..."
    Start-Sleep -Seconds 2

    # Folder to temporarily download Github zip files in to be extracted later
    $tempDownloadFolder = "C:\Temp\prepscriptDownloads\githubApps"

    # Folder to extract downloaded Github zip files into
    $extractionFolder = "D:"

    # Creating temporarily download folder
    Write-Host "Creating temporary download folder '$tempDownloadFolder'..." -NoNewline
    Start-Sleep -Seconds 1
    New-Item -Path "$tempDownloadFolder" -ItemType Directory | Out-Null
    Write-Output " Done"

    # Downloading latest windows release for 'chaiNNer'
    Write-Host "Downloading chaiNNer from (chaiNNer-org/chaiNNer)..." -NoNewline
    (downloadFile -url (getDownloadUrl -repo "chaiNNer-org/chaiNNer" -filter "windows-x64") -destination $tempDownloadFolder)
    Write-Output " Done"

    # Downloading latest windows release for 'Assist'
    Write-Host "Downloading Assist from (HeyM1ke/Assist)..." -NoNewline
    (downloadFile -url (getDownloadUrl -repo "HeyM1ke/Assist" -filter "Assist.zip") -destination $tempDownloadFolder)
    Write-Output " Done"

    Write-Output "Finished downloading zip files.`r`n"

    # Installing the Github zip files
    $githubApps = Get-ChildItem $tempDownloadFolder
    ForEach ($githubApp in $githubApps) {
        $zippedFileName = $githubApp.Name
        $zippedFilePath = "$tempDownloadFolder\$zippedFileName"
        $unzippedFolderName = [io.path]::GetFileNameWithoutExtension($zippedFileName)
        $unzippedFolderPath = "$extractionFolder\$unzippedFolderName"

        # Extracting the files to '$extractionFolder'
        Write-Host "Extracting '$zippedFileName' to '$unzippedFolderPath'..." -NoNewline
        7z x $zippedFilePath -o"$unzippedFolderPath" | Out-Null
        Write-Output " Done"

        # Adding first .exe found in extracted folder to '%appdata%\Microsoft\Windows\Start Menu\Programs'
        ForEach ($file in (Get-ChildItem $unzippedFolderPath)) {
            if ($file.Name.Contains('.exe')) {
                Write-Host "Adding '$($file.FullName)' to start menu..." -NoNewline
                addToStartMenu -target $file.FullName
                Write-Output " Done"
                break
            }
        }
    }
    Write-Output "`r`nFinished downloading and extracing apps from github.`r`n`r`n"
    Start-Sleep -Seconds 2
}

# Function to run a seperate script with administrator privilages since some exe installers require that
function downloadAndInstallExeFiles {
    Write-Host "Running Administrator level installer script..." -NoNewline
    Write-Host " Please do not close this window!" -ForegroundColor Yellow
    Start-Sleep -Seconds 4
    Start-Process powershell.exe -ArgumentList("-NoProfile -ExecutionPolicy Bypass -File $PSScriptRoot/adminInstaller.ps1") -Wait -Verb RunAs
    Write-Output "Finished downloading and installing EXE's.`r`n"
    Start-Sleep -Seconds 2
}

# downloadAndinstallScoopApps
# downloadAndExtractGithubApps
downloadAndInstallExeFiles

Write-Output "Finished installing all apps. Exiting..."
Start-Sleep -Seconds 2
exit