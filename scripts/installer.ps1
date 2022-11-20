#============================================ UTIL FUNCTIONS ============================================

function GetGithubDownloadUrl {

    param(
        [parameter(Mandatory = $true)]
        $Repo,
        [parameter(Mandatory = $true)]
        $Filter
    )

    $Uri = "https://api.github.com/repos/$Repo/releases"

    # Get all download URLs from latest release
    Write-Host "Getting latest github download urls from '$Uri'... "-NoNewline
    $DownloadUrls = ((Invoke-RestMethod -Method GET -Uri $Uri)[0].assets).browser_download_url
    Write-Host "Done"

    # Filter all download URls and return filtered URL
    Write-Host "Filtering found urls for '$Uri'... " -NoNewline
    $FoundUrl = ($DownloadUrls | Select-String -Pattern $Filter).toString()
    Write-Host "Done"

    Write-Host "Found download url '$FoundUrl'"
    $FoundUrl
}

# File downloader function using .NET WebClient
function DownloadFile {

    param(
        [parameter(Mandatory = $true)]
        $Url,
        [parameter(Mandatory = $true)]
        $Destination
    )

    Write-Host "Downloading from '$Url'... " -NoNewline
    $FileName = Split-Path $Url -leaf
    $Wc = New-Object System.Net.WebClient
    $Wc.DownloadFile($Url, "$Destination\$FileName")
    $Wc.Dispose()
    Write-Host "Done"
}

# Function to add .exe file to '%appdata%\Microsoft\Windows\Start Menu\Programs'
function AddToStartMenu {
    
    Param(
        [Parameter(Mandatory = $true)]
        $Target
    )
    Write-Host "Adding '$Target' to start menu... " -NoNewline
    $StartMenuProgramsFolder = "$ENV:AppData\Microsoft\Windows\Start Menu\Programs"
    $FileName = [io.path]::GetFileNameWithoutExtension($Target)

    $WshShell = New-Object -comObject WScript.Shell
    $Shortcut = $WshShell.CreateShortcut("$StartMenuProgramsFolder\$FileName.lnk")
    $Shortcut.TargetPath = $Target
    $Shortcut.Save()
    Write-Host "Done"
}

#========================================================================================================

function DownloadAndinstallScoopApps {
    # Changing execution policy so that user can use cmdlets after running this script
    Write-Host "Setting 'ExecutionPolicy' for 'CurrentUser' to 'RemoteSigned' so that user can use installed cmdlets... " -NoNewline
    try { Set-ExecutionPolicy -ExecutionPolicy -Scope CurrentUser RemoteSigned -Force -ErrorAction SilentlyContinue } catch { }
    Write-Host "Done"
    

    # Defining apps we want (and can) install with scoop
    # Intalling 7zip first because its used to unzip github downloaded files
    $ScoopApps = @(
        "7zip"
        "audacity"
        "blender"
        "filezilla"
        "github"
        "mongodb-compass"
        "firefox"
        "nodejs"
        "obs-studio"
        "vscode"
        #======== PowerShell Modules ========
        "psreadline"
        "oh-my-posh"
        "zoxide"
        "bat"
        "terminal-icons"
        "https://raw.githubusercontent.com/YP501/scoop-manifests/main/manifests/completionpredictor.json" # Completion predictor
        "fzf"
        #====================================
        "python"
        "qbittorrent-enhanced"
        "spotify"
        "spicetify-cli"
        "translucenttb"
        "vlc"
        "BitstreamVeraSansMono-NF" # For terminal
        "JetBrains-Mono" # For vscode
        "yarn"
        "windows-terminal"
        "pwsh"
        "tinynvidiaupdatechecker"
        "gsudo"
    )

    # Scoop application installation dir for accessing app roots
    $ScoopAppsDir = "$home\scoop\apps"

    # Check for scoop installation. If it doesn't exist, install scoop
    Write-Host "Checking if scoop is already installed"
    if (Get-Command scoop -ErrorAction SilentlyContinue) {
        Write-Host "Scoop is already installed. Skipping."
    }
    else {
        Write-Host "Scoop is not installed. Installing now"
        Invoke-RestMethod get.scoop.sh | Invoke-Expression
    }

    # Installing git for getting scoop buckets
    scoop install git

    # Installing required scoop buckets
    scoop bucket add nerd-fonts
    scoop bucket add extras

    # Installing the apps with scoop
    ForEach ($ScoopApp in $ScoopApps) {
        scoop install $ScoopApp
        
        # App-specific scripts/registry entries to run/import after app is installed
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
                    "jbockle.jbockle-format-files"
                    "LeonardSSH.vscord"
                    "miguelsolorio.fluent-icons"
                    "ms-python.black-formatter"
                    "ms-python.python"
                    "ms-python.vscode-pylance"
                    "ms-vscode.powershell"
                    "ms-vsliveshare.vsliveshare"
                    "naumovs.color-highlight"
                    "PKief.material-icon-theme"
                    "ritwickdey.LiveServer"
                    "ssmi.after-dark"
                    "usernamehw.errorlens"
                    "wix.vscode-import-cost"
                    "xuanzhi33.simple-calculator"
                )
                $VscodeExtensions | ForEach-Object {
                    Write-Host "Installing extension $_... " -NoNewline
                    code --install-extension $_ | Out-Null
                    Write-Host "Done"
                }
            }
            "firefox" {
                firefox -P # Set profile to scoop
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
                Reg Import "$ScoopAppsDir\pwsh\current\install-explorer-context.reg"
                Reg Import "$ScoopAppsDir\pwsh\current\install-file-context.reg"
            }
        }
    }
    Write-Host "Finished installing apps with scoop."
}

#=======================================================================================================================================================

# Function to download and extract apps from Github
function DownloadAndExtractGithubApps {
    # Enter the disk you want the zip files to be extracted to on an actual windows installation here
    $DriveLetter = "D:"

    # Switch for virtual machine testing (!DO NOT CHANGE!)
    if (!(Test-Path $DriveLetter)) { $DriveLetter = "C:" }
    
    # Replace the string 'GithubApps' with a folder path if you want to change the location to where github apps get extracted to
    $ExtractionFolder = "$DriveLetter\GithubApps"

    $TempDownloadFolder = "$ENV:TEMP\win10prep\githubApps"

    # Check if temporary download folder exists
    if (!(Test-Path $TempDownloadFolder)) { New-Item -Path $TempDownloadFolder -ItemType Directory -Force }
    
    # Check if extraction folder exists
    if (!(Test-Path $ExtractionFolder)) { New-Item -Path $ExtractionFolder -ItemType Directory -Force }

    # Creating temporarily download folder
    Write-Host "Creating temporary download folder '$TempDownloadFolder'..."
    New-Item -Path "$tempDownloadFolder" -ItemType Directory

    # Downloading latest releases from github
    DownloadFile -Url (GetGithubDownloadUrl -Repo "chaiNNer-org/chaiNNer" -Filter "windows-x64") -Destination $TempDownloadFolder
    DownloadFile -Url (GetGithubDownloadUrl -Repo "HeyM1ke/Assist" -Filter "Assist.zip") -Destination $TempDownloadFolder
    DownloadFile -Url (GetGithubDownloadUrl -Repo "axstin/rbxfpsunlocker" -Filter "x64.zip") -Destination $TempDownloadFolder

    # ----------------------------------------------------------------------------------------------------------

    # Unzipping downloaded github zip files to '$ExtractionFolder'
    Get-ChildItem $TempDownloadFolder | ForEach-Object {
        $ZippedFilePath = $_.FullName
        $UnzippedFolderName = [io.path]::GetFileNameWithoutExtension($ZippedFilePath)
        $UnzippedFolderPath = "$ExtractionFolder\$UnzippedFolderName"

        # Extracting zip files
        Write-Host "Extracting '$ZippedFilePath' to '$UnzippedFolderPath'"
        7z x $ZippedFilePath -o"$UnzippedFolderPath"

        # Adding first .exe file found in extracted folder to start menu
        Get-ChildItem $UnzippedFolderPath | ForEach-Object {
            if ($_.Name.Contains(".exe")) {
                AddToStartMenu -Target $_.FullName
                return
            }
        }
    }
    Write-Host "Finished downloading and extracting github apps"
}

#=======================================================================================================================================================

# Download and install direct installers (some installers require administrator permission)
function DownloadAndRunInstallers {
    # Installing PresentationCore and PresentationFramework to be able to display MessageBoxes
    Write-Host "Adding 'PresentationCore' and 'PresentationFramework' assembly for MessageBoxes"
    Add-Type -AssemblyName PresentationCore
    Add-Type -AssemblyName PresentationFramework

    # List with direct download URLs
    $DownloadUrls = @(
        "https://aka.ms/vs/17/release/vc_redist.x64.exe"                                            # Visual C++ redistributable packages
        "https://cdn.cloudflare.steamstatic.com/client/installer/SteamSetup.exe"                    # Steam
        "https://app.prntscr.com/build/setup-lightshot.exe"                                         # Lightshot
        "https://dl.discordapp.net/distro/app/stable/win/x86/1.0.9007/DiscordSetup.exe"             # Discord
        "https://install.medal.tv/MedalSetup.exe"                                                   # Medal.TV
        "https://download01.logi.com/web/ftp/pub/techsupport/gaming/lghub_installer.exe"            # Logitech G Hub
        "https://pkg.authy.com/authy/stable/2.2.1/win32/x64/Authy%20Desktop%20Setup%202.2.1.exe"    # Authy desktop
    )

    # Check if temporary download folder exists
    $TempInstallerDownloadFolder = "$ENV:TEMP\win10prep\installers"
    if (!(Test-Path $TempInstallerDownloadFolder)) { New-Item -Path $TempInstallerDownloadFolder -ItemType Directory -Force }

    # Download installers from '$DownloadUrls
    $DownloadUrls | ForEach-Object { DownloadFile -Url $_ -Destination $TempInstallerDownloadFolder }
    Write-Host "Finished downloading installers"
    
    
    # Running downloaded installers
    [Windows.MessageBox]::Show("REMINDER: If the app has finished installing and the is script stuck, terminate the process in the system tray!", "Installer notice", [Windows.MessageBoxButton]::OK, [Windows.MessageBoxImage]::Warning) | Out-Null
    Write-Warning "The script might take a while to catch up after you terminate the process!"
    Get-ChildItem -Path $TempInstallerDownloadFolder -File "*.exe" | ForEach-Object { Start-Process -FilePath $_.FullName -Wait -PassThru }
 
    Write-Host "Finished running installers"
}

#========================================================================================================

function DeleteTempDownloadFolders {
    $TempFolder = "$ENV:TEMP\win10prep"
    if (Test-Path $TempFolder) {
        Write-Host "Deleting temporary download folders... " -NoNewline
        Remove-Item $TempFolder -Force -Recurse
        Write-Host "Done"
    }
}

#========================================================================================================

Start-Transcript "$(Split-Path $PSScriptRoot)\logs\installer.log" | Out-Null
DownloadAndinstallScoopApps
DownloadAndExtractGithubApps
DownloadAndRunInstallers
DeleteTempDownloadFolders
Stop-Transcript | Out-Null
exit