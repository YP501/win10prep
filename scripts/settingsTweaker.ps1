# Enables clipboard history
function EnableClipboardHistory {
    Write-Host 'Enabling clipboard history'

    $RegPath = "HKCU:\Software\Microsoft\Clipboard"
    $RegEntry = @{
        Key   = "EnableClipboardHistory";
        Type  = "DWORD"
        Value = "1"
    }
    New-ItemProperty -Path $RegPath -Name $RegEntry.Key -PropertyType $RegEntry.Type -Value $RegEntry.Value -Force
}

#========================================================================================================

# Disables sticky keys
function DisableStickyKeys {
    Write-Host "Disabling sticky keys"

    # Object with format '$RegPath = $NewFlagValue'
    $RegEntries = @{
        "HKCU:\Control Panel\Accessibility\StickyKeys"        = "506"
        "HKCU:\Control Panel\Accessibility\Keyboard Response" = "122"
        "HKCU:\Control Panel\Accessibility\ToggleKeys"        = "58"
    }

    # Looping through the object and changing 'Flags' string value for every path
    $RegEntries.Keys | ForEach-Object {
        $RegPath = $_
        $NewFlagValue = $RegEntries.$_

        Set-Itemproperty -Path $RegPath -Name "Flags" -Value $NewFlagValue -Force -PassThru
    }
}

#========================================================================================================

# Enables dark mode in apps
function EnableDarkMode {
    Write-Host "Enabling dark mode"
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name AppsUseLightTheme -Value 0 -Force -PassThru
}

#========================================================================================================

# Changes windows accent color
function ChangeAccentColor {
    Write-Host "Changing accent color"

    $RegPath = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Accent"
    $RegEntries = @{
        "AccentColorMenu" = @{
            Type  = "DWORD"
            Value = "0xff484a4c"
        }
        "AccentPalette"   = @{
            Type  = "BINARY"
            Value = "9b,9a,99,00,84,83,81,00,6d,6b,6a,00,4c,4a,48,00,36,35,33,00,26,25,24,00,19,19,19,00,10,7c,10,00"
        }
        "StartColorMenu"  = @{
            Type  = "DWORD"
            Value = "0xff484a4c"
        }
    }

    $RegEntries.Keys | ForEach-Object {
        $Key = $_
        $Type = ($RegEntries.$_).Type
        $Value = ($RegEntries.$_).Value

        # Special çheck for AccentPalette because it requires a byte array for a value. Changes it to correct hex format, then make it a byte array
        if ($Key -eq "AccentPalette") { $Value = [byte[]]($Value.Split(",") | ForEach-Object { "0x$_" }) }
        
        # Checking if registry entry exists or no
        if ($null -eq (Get-itemProperty -Path $RegPath -Name $Key -ErrorAction SilentlyContinue)) {
            New-ItemProperty -Path $RegPath -Name $Key -Value $Value -PropertyType $Type -Force
        }
        else {
            Set-ItemProperty -Path $RegPath -Name $Key -Value $Value -Force -PassThru
        }
    }

    # Restarting explorer.exe to apply changes
    Stop-Process -ProcessName explorer -Force -ErrorAction SilentlyContinue -PassThru
}

#========================================================================================================

# Function that sets up power plan and disables auto-wake
function SetupPowerPlan {
    Write-Host "Setting up power plan"

    # Set power plan to 'Ultimate Performance'
    $PowerPlan = Get-CimInstance -Name root\cimv2\power -Class win32_PowerPlan -Filter "ElementName = 'Ultimate Performance'"      
    powercfg /setactive ([string]$PowerPlan.InstanceID).Replace("Microsoft:PowerPlan\{", "").Replace("}", "")

    # Get list of devices that can wake up your pc
    $WakeArmed = powercfg -devicequery wake_armed

    # Check if there are devices that can wake up your pc. If there are some, they will be disabled
    if ($WakeArmed -ne "NONE") { 
        $WakeArmed | ForEach-Object { powercfg /devicedisablewake $_ }
        Write-Host "Removed all devices from 'powercfg -devicequery wake_armed' list"
    }

    # Sets the power timeouts to 'never'
    powercfg -change -monitor-timeout-ac 0
    powercfg -change -monitor-timeout-dc 0
    powercfg -change -standby-timeout-ac 0
    powercfg -change -standby-timeout-dc 0

    # De-hibernating to clear up file space
    powercfg /hibernate off
}

#========================================================================================================

# Enables file extensions and hidden files
function SetExplorerSettings {
    Write-Host "Setting explorer settings"

    # For disabling 'Show recently used files in Quick Access' and 'Show recently used folders in Quick Access'
    $ExplorerRegPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer"
    $ExplorerRegEntries = @{
        "ShowFrequent" = @{
            Type  = "DWORD"
            Value = "0"
        }
        "ShowRecent"   = @{
            Type  = "DWORD"
            Value = 0
        }
    }

    $ExplorerRegEntries.Keys | ForEach-Object {
        $Key = $_
        $Value = ($ExplorerRegEntries.$_).Value
        $Type = ($ExplorerRegEntries.$_).Type

        # Checking if registry entry exists
        if ($null -eq (Get-ItemProperty -Path $ExplorerRegPath -Name $Key -ErrorAction SilentlyContinue)) {
            New-ItemProperty -Path $ExplorerRegPath -Name $Key -Value $Value -PropertyType $Type -Force
        }
        else {
            Set-ItemProperty -Path $ExplorerRegPath -Name $Key -Value $Value -Force -PassThru
        }
    }

    # ----------------------------------------------------------------------------------------------------------

    # For enabling file extensions, hidden files and launching explorer into 'This pc' instead of 'Quick Access'
    $AdvancedRegPath = "$ExplorerRegPath\Advanced"
    $AdvancedRegEntries = @{
        "HideFileExt" = @{
            Type  = "DWORD"
            Value = "0"
        }
        "Hidden"      = @{
            Type  = "DWORD"
            Value = "1"
        }
        "LaunchTo"    = @{
            Type  = "DWORD"
            Value = "1"
        }
    }

    $AdvancedRegEntries.Keys | ForEach-Object {
        $Key = $_
        $Value = ($AdvancedRegEntries.$_).Value
        $Type = ($AdvancedRegEntries.$_).Type

        # Checking if registry entry exists
        if ($null -eq (Get-itemProperty -Path $AdvancedRegPath -Name $Key -ErrorAction SilentlyContinue)) {
            New-ItemProperty -Path $AdvancedRegPath -Name $Key -Value $Value -PropertyType $Type -Force
        }
        else {
            Set-ItemProperty -Path $AdvancedRegPath -Name $Key -Value $Value -Force -PassThru
        }
    }

    # ----------------------------------------------------------------------------------------------------------

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
            Write-Host "Changing label for '$DriveLetter' from '$($Drive.Label)' to '$DriveLabel' " -NoNewline

            # Not using 'label.exe' due to quotes showing up in drive labels with spaces when using 'label.exe' cmdlet
            $Drive = Get-WmiObject -Class win32_volume -Filter "DriveLetter = '$DriveLetter'"
            Set-WmiInstance -input $Drive -Arguments @{ Label = $DriveLabel }
            Write-Host "Done"
        }
    }
}

#========================================================================================================

# Copying and enabling Breeze Obsiduan cursor pack
function InstallCustomCursor {
    Write-Host "Installing custom cursor pack"

    # Defining paths for cursors
    $DefaultPath = "$(Split-Path "$PSScriptRoot")\items\cursors"
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

        # Check for '(Default)' so that it gets a different value without the full cursor path since it doesnt need it
        if ($Key -eq "(Default)") { $FullPath = $Value }

        # Set registry entries in order to change cursor (requires restart to apply)
        Set-ItemProperty -Path $RegPath -Name $Key -Value $FullPath -Force -PassThru
    }
}

#========================================================================================================

# Rename the recycle bin
function RenameRecycleBin {
    Write-Host "Renaming recycle bin"
    $RegPath = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CLSID\{645FF040-5081-101B-9F08-00AA002F954E}"
    Set-ItemProperty -Path $RegPath -Name "(Default)" -Value "The Bruh Basket$([char]0x2122)" -Force -PassThru
}

#========================================================================================================

# Renames the computer
function RenameComputer {
    Write-Host "Renaming computer"
    $NewName = "THE-YP-MACHINE"
    Rename-Computer $NewName -PassThru -Force
}

#========================================================================================================

Start-Transcript "$(Split-Path $PSScriptRoot)\logs\settingsTweaker.log" | Out-Null
EnableClipboardHistory
DisableStickyKeys
EnableDarkMode
ChangeAccentColor
SetupPowerPlan
SetExplorerSettings
InstallCustomCursor
RenameRecycleBin
RenameComputer
Write-Host "Finished tweaking settings. Exiting..."
Stop-Transcript | Out-Null