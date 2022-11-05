function DownloadAndinstallScoopApps {
    $ScoopApps = @(
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
        Write-Output "Scoop is already installed. Skipping...`r`n"
    }
    else {
        Write-Output "Scoop is not installed. Installing now."
        Invoke-RestMethod get.scoop.sh | Invoke-Expression
        Write-Output "`r`n"
    }

    $ScoopAppsDir = "$home\scoop\apps"

    # Installing git for getting scoop buckets
    scoop install git
    Write-Output "`r`n"

    # Installing scoop buckets
    scoop bucket add nerd-fonts
    Write-Output "`r`n"
    scoop bucket add extras
    Write-Output "`r`n"

    # Installing the apps with scoop
    ForEach ($ScoopApp in $ScoopApps) {
        scoop install $ScoopApp
        Write-Output "`r`n"
        
        # App specific scripts to run after installing the app
        switch ($ScoopApp) {
            "7zip" {
                Write-Output "`r`nInstalling 7zip context menu registry entries..."
                Reg Import "$ScoopAppsDir\7zip\current\install-context.reg"
            }
            "vscode" {
                Write-Output "`r`nInstalling vscode context menu registry entries..."
                Reg Import "$ScoopAppsDir\vscode\current\install-associations.reg"
                Reg Import "$ScoopAppsDir\vscode\current\install-context.reg"

                # Installation of vscode extensions
                Write-Output "`r`nPreparing installation of vscode extensions..."
                Start-Sleep -Seconds 2
                $VscodeExtensions = @(
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

                ForEach ($Extension in $VscodeExtensions) {
                    Write-Host "Installing $Extension..." -NoNewline
                    code --install-extension $Extension | Out-Null
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
                Reg Import "$ScoopAppsDir\python\current\install-pep-514.reg"
            }
        }
    }

    Write-Output "Finished installing apps with scoop.`r`n"
    Start-Sleep -Seconds 3
}

# Function to get the latest release download URL with a filter from a Github repository
function GetDownloadUrl {

    param(
        [parameter(Mandatory = $true)]
        $Repo,
        [parameter(Mandatory = $true)]
        $Filter
    )

    $Uri = "https://api.github.com/repos/$Repo/releases"

    # Get all download URLs from latest release
    $DownloadUrls = ((Invoke-RestMethod -Method GET -Uri $Uri)[0].assets).browser_download_url

    # Filter all download URls and return filtered URL
    ($DownloadUrls | Select-String -Pattern $Filter).toString()
}

# File downloader function using .NET WebClient
function downloadFile {

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

# Function to add any .exe file to '%appdata%\Microsoft\Windows\Start Menu\Programs'
function AddToStartMenu {
    
    Param(
        [Parameter(Mandatory = $true)]
        $Target
    )

    $StartMenuProgramsFolder = "$ENV:AppData\Microsoft\Windows\Start Menu\Programs"
    $FileName = [io.path]::GetFileNameWithoutExtension($Target)

    $WshShell = New-Object -comObject WScript.Shell
    $Shortcut = $WshShell.CreateShortcut("$StartMenuProgramsFolder\$FileName.lnk")
    $Shortcut.TargetPath = $Target
    $Shortcut.Save()
}

# Function to download and extract apps from Github
function DownloadAndExtractGithubApps {
    Write-Output "Preparing to download and extract github apps..."
    Start-Sleep -Seconds 2

    # Folder to temporarily download Github zip files in to be extracted later
    $TempDownloadFolder = "$ENV:Temp\win10prep\downloads\githubApps"

    # Folder to extract downloaded Github zip files into
    $ExtractionFolder = "D:"

    # Switch for Hyper-V and actual installation
    if (!(Test-Path $ExtractionFolder)) { $ExtractionFolder = "C:" }

    # Creating temporarily download folder
    Write-Host "Creating temporary download folder '$TempDownloadFolder'..." -NoNewline
    Start-Sleep -Seconds 1
    New-Item -Path "$tempDownloadFolder" -ItemType Directory | Out-Null
    Write-Output " Done"

    # Downloading latest windows release for 'chaiNNer'
    Write-Host "Downloading chaiNNer from (chaiNNer-org/chaiNNer)..." -NoNewline
    (downloadFile -Url (getDownloadUrl -Repo "chaiNNer-org/chaiNNer" -Filter "windows-x64") -Destination $TempDownloadFolder)
    Write-Output " Done"

    # Downloading latest windows release for 'Assist'
    Write-Host "Downloading Assist from (HeyM1ke/Assist)..." -NoNewline
    (downloadFile -Url (getDownloadUrl -Repo "HeyM1ke/Assist" -Filter "Assist.zip") -Destination $TempDownloadFolder)
    Write-Output " Done"

    Write-Host "Downloading Roblox FPS Unlocker from (axstin/rbxfpsunlocker)..." -NoNewline
    (downloadFile -Url (GetDownloadUrl -Repo "axstin/rbxfpsunlocker" -Filter "x64.zip") -Destination $TempDownloadFolder)
    Write-Output " Done"

    Write-Output "Finished downloading zip files.`r`n"

    # Installing the Github zip files
    $GithubApps = Get-ChildItem $TempDownloadFolder
    ForEach ($GithubApp in $GithubApps) {
        $ZippedFileName = $GithubApp.Name
        $ZippedFilePath = "$TempDownloadFolder\$zippedFileName"
        $UnzippedFolderName = [io.path]::GetFileNameWithoutExtension($ZippedFileName)
        $UnzippedFolderPath = "$ExtractionFolder\$UnzippedFolderName"

        # Extracting the files to '$ExtractionFolder'
        Write-Host "Extracting '$ZippedFileName' to '$UnzippedFolderPath'..." -NoNewline
        7z x $ZippedFilePath -o"$UnzippedFolderPath" | Out-Null
        Write-Output " Done"

        # Adding first .exe found in extracted folder to '%appdata%\Microsoft\Windows\Start Menu\Programs'
        ForEach ($File in (Get-ChildItem $UnzippedFolderPath)) {
            if ($File.Name.Contains('.exe')) {
                Write-Host "Adding '$($File.FullName)' to start menu..." -NoNewline
                addToStartMenu -target $File.FullName
                Write-Output " Done"
                break
            }
        }
    }
    Write-Output "`r`nFinished downloading and extracing apps from github.`r`n`r`n"
    Start-Sleep -Seconds 2
}

# Function to run a seperate script with administrator privilages since some exe installers require that
function DownloadAndInstallExeFiles {
    Write-Host "Running Administrator level installer script..." -NoNewline
    Write-Host " Please do not close this window!" -ForegroundColor Yellow
    Start-Sleep -Seconds 2
    Start-Process powershell.exe -ArgumentList("-NoProfile -ExecutionPolicy Bypass -File $PSScriptRoot/adminInstaller.ps1") -Wait -Verb RunAs
    Write-Output "Finished downloading and installing EXE's.`r`n"
    Start-Sleep -Seconds 2
}

function DeleteTempFolder {
    $TempFolder = "$ENV:Temp\win10prep\downloads"
    Write-Host "Deleting temporary dowload folder '$TempFolder'..." -NoNewline
    Start-Sleep -Seconds 1
    Remove-Item $TempFolder -Force
    Write-Output " Done`r`n"
}

Start-Transcript "$ENV:Temp\win10prep\logs\installer.log" | Out-Null

DownloadAndinstallScoopApps
DownloadAndExtractGithubApps
DownloadAndInstallExeFiles
DeleteTempFolder

Write-Output "Finished installing all apps. Exiting..."
Start-Sleep -Seconds 2

Stop-Transcript | Out-Null

exit