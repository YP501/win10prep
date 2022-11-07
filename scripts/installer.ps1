# TODO: Change pwsh module installation to Install-Module instead of scoop
function DownloadAndinstallScoopApps {
    # Changing execution policy so that user can use cmdlets after running this script
    Write-Host "Setting 'ExecutionPolicy' for 'CurrentUser' to 'RemoteSigned' so that user can use installed cmdlets afterwards"
    try { Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force -ErrorAction SilentlyContinue } catch { }
    
    $ScoopApps = @(
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
        "spicetify-cli"
        "translucenttb"
        "vlc"
        "BitstreamVeraSansMono-NF"
        "yarn"
        "windows-terminal"
        "pwsh"
        "microsoft-teams"
        "tinynvidiaupdatechecker"
    )

    # Installing scoop cmdlet
    Write-Host "Checking if scoop is already installed..."
    if (Get-Command scoop -ErrorAction SilentlyContinue) {
        Write-Host "Scoop is already installed. Skipping..."
    }
    else {
        Write-Host "Scoop is not installed. Installing now."
        Invoke-RestMethod get.scoop.sh | Invoke-Expression
    }

    $ScoopAppsDir = "$home\scoop\apps"

    # Installing git for getting scoop buckets
    scoop install git

    # Installing scoop buckets
    scoop bucket add nerd-fonts
    scoop bucket add extras

    # Installing the apps with scoop
    ForEach ($ScoopApp in $ScoopApps) {
        scoop install $ScoopApp
        
        # App specific scripts to run after installing the app
        switch ($ScoopApp) {
            "7zip" {
                Write-Host "Importing 7zip context menu registry entries..."
                Reg Import "$ScoopAppsDir\7zip\current\install-context.reg"
            }
            "vscode" {
                Write-Host "Importing vscode context menu registry entries..."
                Reg Import "$ScoopAppsDir\vscode\current\install-associations.reg"
                Reg Import "$ScoopAppsDir\vscode\current\install-context.reg"

                # Installation of vscode extensions
                $VscodeExtensions = @(
                    "christian-kohler.npm-intellisense"
                    "dbaeumer.vscode-eslint"
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
                $VscodeExtensions | ForEach-Object {
                    Write-Host "Installing extension $_... " -NoNewline
                    code --install-extension $_ | Out-Null
                    Write-Host "Done"
                }
            }
            "firefox" {
                # Opens a window which lets you set the 'scoop profile' to the default firefox profile to not lose data when updating firefox with scoop
                firefox -P
            }
            "python" {
                Write-Host "Importing python registry entries..."
                Reg Import "$ScoopAppsDir\python\current\install-pep-514.reg"
            }
            "windows-terminal" {
                Write-Host "Importing windows-terminal registry entries..."
                Reg Import "$ScoopAppsDir\windows-terminal\current\install-context.reg"
            }
            "pwsh" {
                Write-Host "Importing pwsh registry entries..."
                Reg Import "$ScoopAppsDir\pwsh\current\install-explorer-context.reg"\
                Reg Import "$ScoopAppsDir\pwsh\current\install-file-context.reg"
            }
        }
    }
    Write-Host "Finished installing apps with scoop."
}

# Installing powershell modules that can't be done with scoop or break when downloaded by scoop (im looking at you PSReadline >:c)
function InstallPwshModules {
    # oh-my-posh and terminal-icons get installed by scoop
    $ModulesToInstall = @(
        "PSReadline"
        "z"
    )

    $ModulesToInstall | ForEach-Object {
        Write-Host "Installing pwsh module '$_'... " -NoNewline
        start-process pwsh -ArgumentList ("-NoProfile -Command Install-Module '$_' -Force") -Wait -PassThru
        Write-Host "Done"
    }
}

# Function to get the latest release download URL with a filter from a Github repository
function GetGithubDownloadUrl {

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

# Function to add .exe file to '%appdata%\Microsoft\Windows\Start Menu\Programs'
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
    Write-Host "Preparing to download and extract github apps..."

    # Folder to temporarily download Github zip files in to be extracted later
    $TempDownloadFolder = "$ENV:Temp\win10prep\downloads\githubApps"

    # Folder to extract downloaded Github zip files into
    $ExtractionFolder = "D:"

    # Switch for Hyper-V testing and actual installation
    if (!(Test-Path $ExtractionFolder)) { $ExtractionFolder = "C:" }

    # Creating temporarily download folder
    Write-Host "Creating temporary download folder '$TempDownloadFolder'..."
    New-Item -Path "$tempDownloadFolder" -ItemType Directory

    # Downloading latest windows release for 'chaiNNer'
    Write-Host "Downloading chaiNNer from (chaiNNer-org/chaiNNer)... " -NoNewline
    (downloadFile -Url (GetGithubDownloadUrl -Repo "chaiNNer-org/chaiNNer" -Filter "windows-x64") -Destination $TempDownloadFolder)
    Write-Host "Done"

    # Downloading latest windows release for 'Assist'
    Write-Host "Downloading Assist from (HeyM1ke/Assist)... " -NoNewline
    (downloadFile -Url (GetGithubDownloadUrl -Repo "HeyM1ke/Assist" -Filter "Assist.zip") -Destination $TempDownloadFolder)
    Write-Host "Done"

    Write-Host "Downloading Roblox FPS Unlocker from (axstin/rbxfpsunlocker)... " -NoNewline
    (downloadFile -Url (GetGithubDownloadUrl -Repo "axstin/rbxfpsunlocker" -Filter "x64.zip") -Destination $TempDownloadFolder)
    Write-Host "Done"

    Write-Host "Finished downloading Github zip files."

    # Installing the Github zip files
    $GithubApps = Get-ChildItem $TempDownloadFolder
    ForEach ($GithubApp in $GithubApps) {
        $ZippedFileName = $GithubApp.Name
        $ZippedFilePath = "$TempDownloadFolder\$zippedFileName"
        $UnzippedFolderName = [io.path]::GetFileNameWithoutExtension($ZippedFileName)
        $UnzippedFolderPath = "$ExtractionFolder\$UnzippedFolderName"

        # Extracting the files to '$ExtractionFolder'
        Write-Host "Extracting '$ZippedFileName' to '$UnzippedFolderPath'..."
        7z x $ZippedFilePath -o"$UnzippedFolderPath"

        # Adding first .exe found in extracted folder to '%appdata%\Microsoft\Windows\Start Menu\Programs'
        $UnzippedFiles = Get-ChildItem $UnzippedFolderPath
        ForEach ($File in $UnzippedFiles) {
            if ($File.Name.Contains(".exe")) {
                Write-Host "Adding '$($File.FullName)' to start menu... " -NoNewline
                addToStartMenu -target $File.FullName
                Write-Host "Done"
                break
            }
        }
    }
    Write-Host "Finished downloading and extracing apps from github."
}

# Function to run a seperate script with administrator privilages since some exe installers require that
function DownloadAndInstallExeFiles {
    # Installing PresentationCore and PresentationFramework to be able to display MessageBoxes
    Write-Host "Adding 'PresentationCore' and 'PresentationFramework' assembly for MessageBoxes... " -NoNewline
    Add-Type -AssemblyName PresentationCore, PresentationFramework
    Write-Host "Done"

    # List with URLs to direct downloads
    $DownloadUrls = @(
        "https://cdn.cloudflare.steamstatic.com/client/installer/SteamSetup.exe"
        "https://app.prntscr.com/build/setup-lightshot.exe"
        "https://download01.logi.com/web/ftp/pub/techsupport/gaming/lghub_installer.exe"
        "https://aka.ms/vs/17/release/vc_redist.x64.exe"
    )

    # Creating the temporary installation folder
    $TempDownloadFolder = "$ENV:Temp\win10prep\downloads\executables"
    Write-Host "Creating temporary download folder '$TempDownloadFolder'..."
    New-Item -Path "$TempDownloadFolder" -ItemType Directory

    # Goes through the DownloadUrls list and downloads the files the URLs point to into '$ENV:Temp\win10prepDownloads\executables'
    ForEach ($DownloadUrl in $DownloadUrls) {
        Write-Host "Downloading from '$DownloadUrl'... " -NoNewline
        downloadFile -Url $DownloadUrl -Destination $TempDownloadFolder
        Write-Host "Done"
    }
    Write-Host "Finished downloading installers."
    
    # Running the installed files in '$ENV:Temp\win10prepDownloads\executables'
    [Windows.MessageBox]::Show("REMINDER: If the app has finished installing and the is script stuck, terminate the process in the system tray!", "Installer notice", [Windows.MessageBoxButton]::OK, [Windows.MessageBoxImage]::Warning) | Out-Null
    Write-Warning "The script might take a while to catch up after you terminate the process!"
    Get-ChildItem -Path $TempDownloadFolder -File "*.exe" | ForEach-Object {
        Write-Host "Running '$($_.FullName)'"
        Start-Process -Wait -FilePath $_.FullName
    }
    Write-Host "Finished downloading and installing EXE's."
}

function DeleteTempDownloads {
    $TempFolder = "$ENV:Temp\win10prep"
    if (Test-Path $TempFolder) {
        Write-Host "Deleting temporary dowload folder '$TempFolder'... " -NoNewline
        Remove-Item $TempFolder -Force -Recurse
        Write-Host "Done"
    }
    else {
        Write-Host "'$TempFolder' doesn't exist. Skipping..."
    }
}

Start-Transcript "$(Split-Path $PSScriptRoot)\logs\installer.log" | Out-Null
DownloadAndinstallScoopApps
InstallPwshModules
DownloadAndExtractGithubApps
DownloadAndInstallExeFiles
DeleteTempDownloads
Stop-Transcript | Out-Null
exit