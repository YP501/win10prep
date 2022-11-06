# Copy over ai upscale model
function CopyChainnerAiModel {
    $From = "$(Split-Path $PSScriptRoot)\items\configs\4x_RealSR_DF2K_JPEG.pth"
    
    # Switch for Hyper-V testing and actual installation
    $RootDrive = "D:"
    if (!(Test-Path $RootDrive)) { $RootDrive = "C:" }

    $To = "$RootDrive\AiModels\4x_RealSR_DF2K_JPEG.pth"

    # Check if folder exists, creates it if it doesn't
    If (!(Test-Path $To)) { New-Item -Path (Split-Path $To) -ItemType Directory -Force }
    Copy-Item -Path $From -Destination $To -PassThru -Force
}

# import powershell profile
function SetPowershellProfile {
    $From = "$(Split-Path $PSScriptRoot)\items\configs\powershell-profile.ps1"
    $To = "$Home\Documents\PowerShell\Microsoft.PowerShell_profile.ps1"

    # Check if folder exists, creates one if it doesn't
    If (!(Test-Path $To)) { New-Item -Path (Split-Path $To) -ItemType Directory -Force }
    Copy-Item -Path $From -Destination $To -PassThru -Force
}

# Copy over translucenttb config json
function SetTranslucentTbSettings {
    $From = "$(Split-Path $PSScriptRoot)\items\configs\translucentTB-config.json"

    # Filtering through '$ENV:LocalAppData\Packages' since it has id-based folder names
    $To = "$((Get-ChildItem "$ENV:LocalAppData\Packages" -Filter "*TranslucentTB*").FullName)\RoamingState\settings.json"

    If (!(Test-Path $To)) { New-Item -Path (Split-Path $To) -ItemType Directory -Force }
    Copy-Item -Path $From -Destination $To -PassThru -Force
}

# Copy over vscode user settings
function SetVscodeUserSettings {
    $From = "$(Split-Path $PSScriptRoot)\items\configs\vscode-user-settings.json"
    $To = "$Home\Scoop\persist\vscode\data\user-data\User\settings.json"

    If (!(Test-Path $To)) { New-Item -Path (Split-Path $To) -ItemType Directory -Force }
    Copy-Item -Path $From -Destination $To -PassThru -Force
}

# Copy over windows terminal settings
function SetWindowsTerminalSettings {
    $From = "$(Split-Path $PSScriptRoot)\items\configs\windows-terminal-settings.json"
    $To = "$ENV:LocalAppData\Microsoft\Windows Terminal\settings.json"

    If (!(Test-Path $To)) { New-Item -Path (Split-Path $To) -ItemType Directory -Force }
    Copy-Item -Path $From -Destination $To -PassThru -Force
}

Start-Transcript "$ENV:Temp\win10prep\logs\appConfigurator.log"

CopyChainnerAiModel
SetPowershellProfile
SetTranslucentTbSettings
SetVscodeUserSettings
SetWindowsTerminalSettings

Stop-Transcript