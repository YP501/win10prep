# Enables clipboard history
function EnableClipboardHistory {
    $RegPath = "HKCU:\Software\Microsoft\Clipboard"
    $RegEntry = @{
        Key   = "EnableClipboardHistory";
        Type  = "DWORD"
        Value = "1"
    }
    New-ItemProperty -Path $RegPath -Name $RegEntry.Key -PropertyType $RegEntry.Type -Value $RegEntry.Value -Force
}

# Disables sticky keys
function DisableStickyKeys {
    $RegEntries = @{
        1 = @{
            Path = "HKCU:\Control Panel\Accessibility\StickyKeys"
            Flag = "506"
        }
        2 = @{
            Path = "HKCU:\Control Panel\Accessibility\Keyboard Response"
            Flag = "122"
        }
        3 = @{
            Path = "HKCU:\Control Panel\Accessibility\ToggleKeys"
            Flag = "58"
        }
    }

    # Looping through the object and change 'Flags' string value for every path
    $RegEntries.Keys | ForEach-Object {
        $RegPath = ($RegEntries.$_).Path
        $Flag = ($RegEntries.$_).Flag

        Set-Itemproperty -Path $RegPath -Name "Flags" -Value $Flag -Force -PassThru
    }
}

# Enables dark mode in apps
function EnableDarkMode {
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name AppsUseLightTheme -Value 0 -Force -PassThru
}

# Changes windows accent color
function ChangeAccentColor {
    $RegPath = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Accent"
    $RegEntries = @{
        1 = @{
            Key   = "AccentColorMenu"
            Type  = "DWORD"
            Value = "0xff484a4c"
        }
        2 = @{
            Key   = "AccentPalette"
            Type  = "BINARY"
            Value = "9b,9a,99,00,84,83,81,00,6d,6b,6a,00,4c,4a,48,00,36,35,33,00,26,25,24,00,19,19,19,00,10,7c,10,00"
        }
        3 = @{
            Key   = "StartColorMenu"
            Type  = "DWORD"
            Value = "0xff333536"
        } 
    }

    $RegEntries.Keys | ForEach-Object {
        $Key = ($RegEntries.$_).Key
        $Type = ($RegEntries.$_).Type
        $Value = ($RegEntries.$_).Value

        # Check for AccentPalette because it requires a byte array for a value. Change to correct hex format, then make it a byte array
        if ($Key -eq "AccentPalette") { $Value = [byte[]]($Value.Split(",") | ForEach-Object { "0x$_" }) }
        
        # Checking if registry entry exists or no
        if ($null -eq (Get-itemProperty -Path $RegPath -Name $Key -ErrorAction SilentlyContinue)) {
            New-ItemProperty -Path $RegPath -Name $Key -Value $Value -PropertyType $Type -Force
        }
        else {
            Set-ItemProperty -Path $RegPath -Name $Key -Value $Value -Force -PassThru
        }
    }

    # Restarting explorer.exe to see changes made by this function
    Stop-Process -ProcessName explorer -Force -ErrorAction SilentlyContinue -PassThru
}

# Function that sets up power plan and disables auto-wake
function SetupPowerPlan {
    # Sets power plan to 'Ultimate Performance'
    $PowerPlan = Get-CimInstance -Name root\cimv2\power -Class win32_PowerPlan -Filter "ElementName = 'Ultimate Performance'"      
    powercfg /setactive ([string]$PowerPlan.InstanceID).Replace("Microsoft:PowerPlan\{", "").Replace("}", "")

    # Get list of devices that can wake up your pc
    $WakeArmed = powercfg -devicequery wake_armed

    # Check if there are any that can wake up your pc. If there are some, they will be disabled
    if ($WakeArmed -ne "NONE") { 
        $WakeArmed | ForEach-Object { powercfg /devicedisablewake $_ } | Out-Null 
        Write-Output "Removed all devices from 'powercfg -devicequery wake_armed' list"
    }

    # Sets the monitor timeout to 'never'
    powercfg -change -monitor-timeout-ac 0
    powercfg -change -monitor-timeout-dc 0
    powercfg -change -standby-timeout-ac 0
    powercfg -change -standby-timeout-dc 0
}

# Enables file extensions and hidden files
function EditExplorerSettings {
    # TODO: Add drive names: 'nyoooom (C:)' and 'Haha storage go brr (D:)'
    $RegPath = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
    $RegEntries = @{
        1 = @{
            Key   = "HideFileExt"
            Value = "0"
            Type  = "DWORD"
        }
        2 = @{
            Key   = "Hidden"
            Value = "1"
            Type  = "DWORD"
        }
        3 = @{
            Key   = "LaunchTo"
            Value = "1"
            Type  = "DWORD"
        }
    }
    $RegEntries.Keys | ForEach-Object {
        $Key = ($RegEntries.$_).Key
        $Value = ($RegEntries.$_).Value
        $Type = ($RegEntries.$_).Type

        # Checking if registry entry exists or no
        if ($null -eq (Get-itemProperty -Path $RegPath -Name $Key -ErrorAction SilentlyContinue)) {
            New-ItemProperty -Path $RegPath -Name $Key -Value $Value -PropertyType $Type -Force
        }
        else {
            Set-ItemProperty -Path $RegPath -Name $Key -Value $Value -Force -PassThru
        }
    }

    # Defining labels for drive letters
    $DriveInfo = @{
        "C:" = "nyoooom"
        "D:" = "Haha storage go brr"
    }
    $DriveInfo.Keys | ForEach-Object {
        $DriveLetter = $_
        $DriveLabel = $DriveInfo.$_
    
        # Changing drive labels to the ones defined in $DriveInfo
        if (Test-Path $DriveLetter) {
            Write-Host "Changing label for '$DriveLetter' from '$($Drive.Label)' to '$DriveLabel'" -NoNewline

            # Not using 'label.exe' due to quotes showing up in drive labels with spaces
            $Drive = Get-WmiObject -Class win32_volume -Filter "DriveLetter = '$DriveLetter'"
            Set-WmiInstance -input $Drive -Arguments @{ Label = $DriveLabel } | Out-Null
            Write-Output " Done"
        }
    }

    Stop-Process -ProcessName explorer -Force -ErrorAction SilentlyContinue -PassThru
}

# Function to install and enable Breeze Obsiduan cursor pack
function InstallCustomCursor {
    # Defining paths for cursors
    $DefaultPath = "$(Split-Path "$PSScriptRoot" -Parent)\items\cursors"
    $Dest = "$ENV:SystemRoot\Cursors"
    $RegPath = "HKCU:\Control Panel\Cursors"

    # Copying cursors from '$DefaultPath' to '$Dest'
    Get-ChildItem -Path $DefaultPath -Recurse -File | Copy-Item -Destination $Dest -PassThru

    # Defining RegEntries for cursors
    $RegEntries = @{
        "(Default)"   = "Breeze Obsidian"
        "AppStarting" = "breeze_Working_in_bg.ani"
        "Arrow"       = "breeze_normal_select.cur"
        "Crosshair"   = "breeze_precise_select.cur"
        "Hand"        = "breeze_link.cur"
        "Help"        = "breeze_help.cur"
        "IBeam"       = "breeze_text.cur"
        "No"          = "breeze_unavailable.cur"
        "NWPen"       = "breeze_handwriting.cur"
        "SizeAll"     = "breeze_move.cur"
        "SizeNESW"    = "breeze_resize_di_2.cur"
        "SizeNS"      = "breeze_resize_ver.cur"
        "SizeNWSE"    = "breeze_resize_di_1.cur"
        "SizeWE"      = "breeze_resize_hor.cur"
        "UpArrow"     = "breeze_alternate_select.cur"
        "Wait"        = "breeze_Working.ani"
    }

    # Setting registry values
    $RegEntries.Keys | ForEach-Object {
        $Key = $_
        $Value = $RegEntries.$_
        $FullPath = "$Dest\$Value"

        # Check for '(Default)' so that it gets a different value
        if ($Key -eq "(Default)") { $FullPath = $Value }

        # Set registry entries in order to change cursor (requires restart to apply)
        Set-ItemProperty -Path $RegPath -Name $Key -Value $FullPath -Force -PassThru
    }
}

Start-Transcript "$ENV:Temp\win10prep\logs\settingsTweaker.log" | Out-Null

EnableClipboardHistory
DisableStickyKeys
EnableDarkMode
ChangeAccentColor
SetupPowerPlan
EditExplorerSettings
InstallCustomCursor

Stop-Transcript | Out-Null