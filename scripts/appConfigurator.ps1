# Set pwsh profile
function SetPowershellProfile {
    Write-Host "Setting pwsh profile file"

    $From = "$(Split-Path $PSScriptRoot)\items\powershell-profile.ps1"
    $To = "$Home\Documents\PowerShell\Microsoft.PowerShell_profile.ps1"

    # Destination folder check
    If (!(Test-Path $To)) { New-Item -Path (Split-Path $To) -ItemType Directory -Force }
    Copy-Item -Path $From -Destination $To -PassThru -Force

    # Unblocking file so that windows allows it to run on pwsh startup
    Unblock-File $To
}

#========================================================================================================

# Copy over translucenttb config json
function SetTranslucentTbSettings {
    Write-Host "Settings TranslucentTB settings"

    $From = "$(Split-Path $PSScriptRoot)\items\translucentTB-config.json"

    # Filtering through '$ENV:LocalAppData\Packages' since it has id-based folder names
    $To = "$((Get-ChildItem "$ENV:LocalAppData\Packages" -Filter "*TranslucentTB*").FullName)\RoamingState\settings.json"

    If (!(Test-Path $To)) { Write-Host "Couldn't find installation for TranslucentTB. Skipping." }
    else { Copy-Item -Path $From -Destination $To -PassThru -Force }
}

#========================================================================================================

# Copy over vscode user settings
function SetVscodeUserSettings {
    Write-Host "Setting vscode user settings"

    $From = "$(Split-Path $PSScriptRoot)\items\vscode-user-settings.json"
    $To = "$Home\Scoop\persist\vscode\data\user-data\User\settings.json"

    If (!(Test-Path $To)) { New-Item -Path (Split-Path $To) -ItemType Directory -Force }
    Copy-Item -Path $From -Destination $To -PassThru -Force
}

#========================================================================================================

# Copy over windows terminal settings
function SetWindowsTerminalSettings {
    Write-Host "Setting windows terminal settings"

    $From = "$(Split-Path $PSScriptRoot)\items\windows-terminal-settings.json"
    $To = "$ENV:LocalAppData\Microsoft\Windows Terminal\settings.json"

    If (!(Test-Path $To)) { New-Item -Path (Split-Path $To) -ItemType Directory -Force }
    Copy-Item -Path $From -Destination $To -PassThru -Force
}

#========================================================================================================

# Copies over the userpref.blend file
function SetBlenderConfig {
    Write-Host "Setting blender settings"

    # Get installed blender version for correct folder assignment
    $Version = (scoop info blender).Version.substring(0, 3)

    $From = "$(Split-Path $PSScriptRoot)\items\userpref.blend"
    $To = "$ENV:AppData\Blender Foundation\Blender\$Version\config\userpref.blend"

    if (!(Test-Path $To)) { New-Item -Path (Split-Path $To) -ItemType Directory -Force }
    Copy-Item -Path $From -Destination $To -PassThru -Force
}

#========================================================================================================

Start-Transcript "$(Split-Path $PSScriptRoot)\logs\appConfigurator.log" | Out-Null
SetPowershellProfile
SetTranslucentTbSettings
SetVscodeUserSettings
SetWindowsTerminalSettings
SetBlenderConfig
Stop-Transcript | Out-Null
exit