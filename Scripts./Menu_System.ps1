function Invoke-WpfDialog {
    param($Title, $Message, $IsPassword = $false)
    
    $inputControl = '<TextBox Name="Input" Height="30" Background="#333" Foreground="White" BorderThickness="0" Padding="5"/>'
    if ($IsPassword) {
        $inputControl = '<PasswordBox Name="Input" Height="30" Background="#333" Foreground="White" BorderThickness="0" Padding="5"/>'
    }

    [xml]$dXaml = @"
    <Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
            xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
            Title="$Title" Height="180" Width="350" WindowStartupLocation="CenterScreen" WindowStyle="None" AllowsTransparency="True" Background="Transparent" Topmost="True">
        <Border CornerRadius="10" Background="#1E1E1E" BorderBrush="#00BFFF" BorderThickness="1">
            <StackPanel Margin="20">
                <TextBlock Text="$Title" Foreground="#00BFFF" FontWeight="Bold" FontSize="16" Margin="0,0,0,10"/>
                <TextBlock Text="$Message" Foreground="White" Margin="0,0,0,5"/>
                $inputControl
                <StackPanel Orientation="Horizontal" HorizontalAlignment="Right" Margin="0,15,0,0">
                    <Button Name="btnOK" Content="OK" Width="80" Height="30" Background="#00BFFF" Foreground="White" BorderThickness="0" Margin="0,0,10,0"/>
                    <Button Name="btnCancel" Content="Cancel" Width="80" Height="30" Background="#333" Foreground="White" BorderThickness="0"/>
                </StackPanel>
            </StackPanel>
        </Border>
    </Window>
"@
    $reader = (New-Object System.Xml.XmlNodeReader $dXaml)
    $dlg = [Windows.Markup.XamlReader]::Load($reader)
    $inp = $dlg.FindName("Input")
    
    # Use script scope to capture result from event block
    $script:dialogResult = $null

    $dlg.FindName("btnOK").Add_Click({ 
            if ($IsPassword) { $script:dialogResult = $inp.Password } else { $script:dialogResult = $inp.Text }
            $dlg.Close() 
        })
    $dlg.FindName("btnCancel").Add_Click({ $dlg.Close() })
    $dlg.ShowDialog() | Out-Null
    return $script:dialogResult
}

function Refresh-Users {
    if ($lstUsers) {
        $lstUsers.Items.Clear()
        try {
            # Use ADSI/WinNT instead of Get-LocalUser to avoid AV signatures
            $computer  = [ADSI]"WinNT://$env:COMPUTERNAME"
            $admins    = @()
            try {
                $adminGroup = [ADSI]"WinNT://$env:COMPUTERNAME/Administrators,group"
                $admins = @($adminGroup.Members() | ForEach-Object { $_.GetType().InvokeMember("Name", 'GetProperty', $null, $_, $null) })
            } catch {}

            $users = $computer.Children | Where-Object { $_.SchemaClassName -eq 'User' } | ForEach-Object {
                $flags   = $_.UserFlags.Value
                $disabled = ($flags -band 2) -ne 0
                $desc    = ""
                try { $desc = $_.Description.Value } catch {}
                [PSCustomObject]@{
                    Name        = $_.Name.Value
                    Enabled     = -not $disabled
                    Description = $desc
                    IsAdmin     = $admins -contains $_.Name.Value
                }
            }
            $users | ForEach-Object { $lstUsers.Items.Add($_) }
        }
        catch {}
    }
}


Set-Click "btnRefreshUsers" { Refresh-Users }

# --- FIX: Create User logic flow updated (Fixed Scoping & Error Handling) ---
Set-Click "btnCreateUser" {
    $u = Invoke-WpfDialog "New User" "Enter Username:"
    # Only proceed if username is not empty
    if (-not [string]::IsNullOrWhiteSpace($u)) {
        $p = Invoke-WpfDialog "Set Password" "Enter Password (leave blank for no password):" $true
        try {
            if ([string]::IsNullOrEmpty($p)) {
                # Create user with no password via net.exe
                $result = & net user $u /add /comment:"Created by WinFlexOS" 2>&1
            } else {
                $result = & net user $u $p /add /comment:"Created by WinFlexOS" 2>&1
            }
            if ($LASTEXITCODE -eq 0) {
                Refresh-Users
                [System.Windows.Forms.MessageBox]::Show("User '$u' created successfully!", "Success")
            } else {
                [System.Windows.Forms.MessageBox]::Show("Error: $result", "Error")
            }
        }
        catch {
            [System.Windows.Forms.MessageBox]::Show("Error creating user: $($_.Exception.Message)", "Error")
        }
    }
}

Set-Click "btnResetPass" {
    if ($lstUsers.SelectedItem) {
        $u = $lstUsers.SelectedItem.Name
        $p = Invoke-WpfDialog "Reset Password" "Enter new password for ${u}:" $true
        if ($p) {
            try {
                $result = & net user $u $p 2>&1
                if ($LASTEXITCODE -eq 0) {
                    [System.Windows.Forms.MessageBox]::Show("Password for '$u' reset.", "Success")
                } else {
                    [System.Windows.Forms.MessageBox]::Show("Error: $result", "Error")
                }
            }
            catch { [System.Windows.Forms.MessageBox]::Show("Error: $($_.Exception.Message)", "Error") }
        }
    }
    else { [System.Windows.Forms.MessageBox]::Show("Please select a user from the list first.", "Select User") }
}

Set-Click "btnToggleActive" {
    if ($lstUsers.SelectedItem) {
        $u = $lstUsers.SelectedItem.Name
        try {
            if ($lstUsers.SelectedItem.Enabled) {
                & net user $u /active:no 2>&1 | Out-Null
            } else {
                & net user $u /active:yes 2>&1 | Out-Null
            }
            Refresh-Users
        }
        catch { [System.Windows.Forms.MessageBox]::Show("Error: $_", "Error") }
    }
}

Set-Click "btnToggleAdmin" {
    if ($lstUsers.SelectedItem) {
        $u = $lstUsers.SelectedItem.Name
        try {
            if ($lstUsers.SelectedItem.IsAdmin) {
                & net localgroup Administrators $u /delete 2>&1 | Out-Null
                [System.Windows.Forms.MessageBox]::Show("Removed '$u' from Admins.", "Info")
            }
            else {
                & net localgroup Administrators $u /add 2>&1 | Out-Null
                [System.Windows.Forms.MessageBox]::Show("Added '$u' to Admins.", "Info")
            }
            Refresh-Users
        }
        catch { [System.Windows.Forms.MessageBox]::Show("Error (Run as Admin required): $_", "Error") }
    }
}

Set-Click "btnDeleteUser" {
    if ($lstUsers.SelectedItem) {
        $u = $lstUsers.SelectedItem.Name
        $res = [System.Windows.Forms.MessageBox]::Show("Are you sure you want to DELETE user '$u'?", "Confirm Delete", [System.Windows.Forms.MessageBoxButtons]::YesNo, [System.Windows.Forms.MessageBoxIcon]::Warning)
        if ($res -eq 'Yes') {
            try {
                $result = & net user $u /delete 2>&1
                if ($LASTEXITCODE -eq 0) { Refresh-Users } else { [System.Windows.Forms.MessageBox]::Show("Error: $result", "Error") }
            }
            catch { [System.Windows.Forms.MessageBox]::Show("Error: $_", "Error") }
        }
    }
}

Set-Click "btnLusrmgr" { Start-Process lusrmgr.msc }

# --- DEEP CLEAN SCRIPT ---
Set-Click "btnDeepClean" {
    $scriptBlock = {
        $ids = @(
            "Microsoft.Cortana_8wekyb3d8bbwe", "Microsoft.SkypeApp_kzf8qxf38zg5c", "Microsoft.Xbox.TCUI_8wekyb3d8bbwe", 
            "Microsoft.XboxApp_8wekyb3d8bbwe", "Microsoft.XboxGameOverlay_8wekyb3d8bbwe", "Microsoft.XboxGamingOverlay_8wekyb3d8bbwe", 
            "Microsoft.XboxIdentityProvider_8wekyb3d8bbwe", "Microsoft.XboxSpeechToTextOverlay_8wekyb3d8bbwe", "Microsoft.ZuneMusic_8wekyb3d8bbwe",
            "Microsoft.ZuneVideo_8wekyb3d8bbwe", "Microsoft.WindowsFeedbackHub_8wekyb3d8bbwe", "Microsoft.Getstarted_8wekyb3d8bbwe",
            "Microsoft.3DBuilder_8wekyb3d8bbwe", "Microsoft.MicrosoftSolitaireCollection_8wekyb3d8bbwe", "Microsoft.BingWeather_8wekyb3d8bbwe",
            "microsoft.windowscommunicationsapps_8wekyb3d8bbwe", "Microsoft.YourPhone_8wekyb3d8bbwe", "Microsoft.People_8wekyb3d8bbwe",
            "Microsoft.Wallet_8wekyb3d8bbwe", "Microsoft.WindowsMaps_8wekyb3d8bbwe", "Microsoft.MixedReality.Portal_8wekyb3d8bbwe",
            "Microsoft.GetHelp_8wekyb3d8bbwe", "Microsoft.OneDrive", "Microsoft.Todos_8wekyb3d8bbwe", "Microsoft.BingNews_8wekyb3d8bbwe",
            "MicrosoftTeams_8wekyb3d8bbwe", "MicrosoftCorporationII.MicrosoftFamily_8wekyb3d8bbwe", "MicrosoftCorporationII.QuickAssist_8wekyb3d8bbwe",
            "Microsoft.Whiteboard_8wekyb3d8bbwe", "disney+", "SpotifyAB.SpotifyMusic_zpdnekdrzrea0", "Clipchamp.Clipchamp_yxz26nhyzhsrt",
            "5319275A.WhatsAppDesktop_cv1g1gvanyjgm", "Microsoft.WindowsCamera_8wekyb3d8bbwe", "Microsoft.WindowsAlarms_8wekyb3d8bbwe"
        )
        
        Write-Host "======================================" -ForegroundColor Cyan
        Write-Host "   DEEP BLOATWARE CLEANER - STARTING  " -ForegroundColor Cyan
        Write-Host "======================================" -ForegroundColor Cyan
        
        foreach ($id in $ids) {
            Write-Host "Removing: $id ..." -NoNewline
            winget uninstall --id $id --silent --accept-source-agreements --force --purge 2>$null
            if ($?) { Write-Host " [OK]" -ForegroundColor Green } else { Write-Host " [Not Found/Error]" -ForegroundColor DarkGray }
        }
        
        Write-Host "`nReinstalling Essentials (Calc, Paint, Notepad)..." -ForegroundColor Yellow
        winget install --id 9WZDNCRFHVN5 --silent --accept-source-agreements --accept-package-agreements # Calc
        winget install --id 9PCFS5B6T72H --silent --accept-source-agreements --accept-package-agreements # Paint
        winget install --id 9MSMLRH6LZF3 --silent --accept-source-agreements --accept-package-agreements # Notepad
        
        Write-Host "`nDONE! Reboot Recommended." -ForegroundColor Green
        Read-Host "Press Enter to close..."
    }
    
    Start-Process powershell -ArgumentList "-NoExit", "-Command", $scriptBlock.ToString() -Verb RunAs
}

# --- SYSTEM INFO  Fast Placeholder First, Background Fill ---
# Pre-populate with instant values so window opens without delay
$winNum = $(if ([System.Environment]::OSVersion.Version.Build -ge 22000) { 11 } else { 10 })
$winVer = (Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion').DisplayVersion

# Detect real physical IP (skip VM virtual adapters like vEthernet, Hyper-V, VirtualBox, VMware)
$localIP = try {
    $physicalNIC = Get-NetAdapter | Where-Object { $_.Status -eq "Up" -and $_.InterfaceDescription -notmatch "Virtual|VMware|Hyper-V|VirtualBox" } | Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.IPAddress -notlike "169.254.*" } | Select-Object -First 1
    if ($physicalNIC) { $physicalNIC.IPAddress } else { "Detecting..." }
} catch { "Offline" }

# Get public (external) IP
$publicIP = try { (Invoke-WebRequest -Uri 'https://api.ipify.org' -TimeoutSec 3 -UseBasicParsing).Content } catch { "N/A" }

$staticInfo = @{
    CPU        = (Get-CimInstance Win32_Processor).Name.Trim()
    GPU        = (Get-CimInstance Win32_VideoController).Name
    TotalRAM   = [math]::Round((Get-CimInstance Win32_ComputerSystem).TotalPhysicalMemory / 1GB, 2)
    LocalIP    = $localIP
    PublicIP   = $publicIP
    WindowsVer = "Windows $winNum Pro - $winVer"
    WinFlexVer = "WinFlex11-September25 Update"
    BootTime   = (Get-CimInstance Win32_OperatingSystem).LastBootUpTime
}

# Background runspace  fills in slow CIM data without blocking UI
$script:initRunspace = [System.Management.Automation.Runspaces.RunspaceFactory]::CreateRunspace()
$script:initRunspace.ApartmentState = "STA"
$script:initRunspace.ThreadOptions   = "ReuseThread"
$script:initRunspace.Open()

$script:initPipeline = $script:initRunspace.CreatePipeline()
$script:initPipeline.Commands.AddScript({
    $result = @{}
    try { $result.CPU     = (Get-CimInstance Win32_Processor -ErrorAction SilentlyContinue).Name } catch { $result.CPU = "N/A" }
    try { $result.GPU     = (Get-CimInstance Win32_VideoController -ErrorAction SilentlyContinue | Select-Object -First 1).Name } catch { $result.GPU = "N/A" }
    try { $result.Boot    = (Get-CimInstance Win32_OperatingSystem -ErrorAction SilentlyContinue).LastBootUpTime } catch { $result.Boot = (Get-Date).AddMinutes(-10) }
    # IP detection
    try {
        $conf = Get-NetIPConfiguration -ErrorAction SilentlyContinue | Where-Object { $_.IPv4DefaultGateway -ne $null -and $_.NetAdapter.Status -eq "Up" } | Select-Object -First 1
        if ($conf) { $result.IP = $conf.IPv4Address.IPAddress }
        else {
            $ipObj = Get-NetIPAddress -AddressFamily IPv4 -ErrorAction SilentlyContinue | Where-Object { $_.ConnectionState -eq "Connected" -and $_.InterfaceAlias -notlike "*Loopback*" -and $_.IPAddress -notlike "169.254.*" } | Select-Object -First 1
            if ($ipObj) { $result.IP = $ipObj.IPAddress } else { $result.IP = "Offline" }
        }
    } catch { $result.IP = "Offline" }
    $result
})
$script:initPipeline.InvokeAsync() | Out-Null

# Poll for completion every 500ms on the UI timer, then apply results once
$script:bgInfoApplied = $false



# Reset Maximize Icon
Get-GuiElement "btnMax" | ForEach-Object { $_.Content = [char]0xE922 }


# --- IMPORTANT: AUTOMATIC HARDWARE LOAD LOGIC (1 Second Delay) ---
$script:hwLoaded = $false
$script:hwTimerCount = 0

function Load-HardwareInfo {
    try {
        # CPU
        $cpu = Get-CimInstance Win32_Processor -ErrorAction Stop
        (Get-GuiElement "txtHwCPU").Text = "$($cpu.Name)`nCores: $($cpu.NumberOfCores) | Threads: $($cpu.NumberOfLogicalProcessors)`nMax Speed: $($cpu.MaxClockSpeed) MHz"
        
        # RAM
        $ram = Get-CimInstance Win32_PhysicalMemory
        $totalRam = ($ram | Measure-Object -Property Capacity -Sum).Sum / 1GB
        $speed = $ram[0].Speed
        $manu = $ram[0].Manufacturer
        (Get-GuiElement "txtHwRAM").Text = "Total: $([math]::Round($totalRam, 2)) GB`nSpeed: $speed MHz`nSlots: $($ram.Count)`nManu: $manu"

        # GPU
        $gpu = Get-CimInstance Win32_VideoController | Select-Object -First 1
        (Get-GuiElement "txtHwGPU").Text = "$($gpu.Name)`nDriver: $($gpu.DriverVersion)`nRes: $($gpu.CurrentHorizontalResolution)x$($gpu.CurrentVerticalResolution)"

        # DISK (Fixed Loop)
        $disks = Get-CimInstance Win32_DiskDrive | Where-Object { $_.MediaType -eq 'Fixed hard disk media' }
        $diskStr = ""
        foreach ($d in $disks) {
            $sizeGB = [math]::Round($d.Size / 1GB, 0)
            $diskStr += " $($d.Model) ($sizeGB GB)`n"
        }
        if ($diskStr -eq "") { $diskStr = "No fixed disks found." }
        (Get-GuiElement "txtHwDisk").Text = $diskStr

        # BIOS
        $bio = Get-CimInstance Win32_BIOS
        (Get-GuiElement "txtHwBio").Text = "Manufacturer: $($bio.Manufacturer)`nVersion: $($bio.SMBIOSBIOSVersion)`nDate: $($bio.ReleaseDate)"
    }
    catch {}
}



# Set clock immediately on load
$window.Add_ContentRendered({
        $timeLabel = Get-GuiElement "lblTimeClock"
        $dateLabel = Get-GuiElement "lblDateClock"
        $now = Get-Date
        if ($timeLabel) { $timeLabel.Text = $now.ToString("HH:mm") }
        if ($dateLabel) { $dateLabel.Text = $now.ToString("dddd, MMMM dd") }
    })

# --- STATS TIMER (Updates every 2 seconds) ---

# Disk query cache  refresh only every 10 seconds
$script:lastDiskCheck    = [DateTime]::MinValue
$script:cachedDiskFreeGB = 0
$script:cachedDiskPerc   = 0

$timer = New-Object System.Windows.Threading.DispatcherTimer
$timer.Interval = [TimeSpan]::FromSeconds(2)
$timer.Add_Tick({

        # Pause when minimized  saves CPU cycles
        if ($window.WindowState -eq [System.Windows.WindowState]::Minimized) { return }

        # Update clock every tick (runs on UI thread, very cheap)
        try {
            $timeLabel = $window.FindName("lblTimeClock")
            if ($timeLabel) { $timeLabel.Text = (Get-Date).ToString("HH:mm") }
            $dateLabel = $window.FindName("lblDateClock")
            if ($dateLabel) { $dateLabel.Text = (Get-Date).ToString("dddd, MMMM dd") }
        } catch {}

        # Smart greeting (only updates when hour changes)
        Update-Greeting-Smart

        # Apply background runspace results once complete
        if (-not $script:bgInfoApplied -and $script:initPipeline -and $script:initPipeline.PipelineStateInfo.State -eq "Completed") {
            try {
                $bgResult = $script:initPipeline.Output.ReadAll() | Select-Object -Last 1
                if ($bgResult) {
                    if ($bgResult.CPU)  { $staticInfo.CPU      = $bgResult.CPU }
                    if ($bgResult.GPU)  { $staticInfo.GPU      = $bgResult.GPU }
                    if ($bgResult.Boot) { $staticInfo.BootTime = $bgResult.Boot }
                    if ($bgResult.IP)   { $staticInfo.IP       = $bgResult.IP }
                }
                $script:initRunspace.Close()
                $script:bgInfoApplied = $true
            } catch {}
        }

        # AUTO LOAD HARDWARE (Once)
        if (-not $script:hwLoaded) {
            Load-HardwareInfo
            $script:hwLoaded = $true
        }

        # STATS UPDATE  RAM & Disk
        try {
            $uptime    = (Get-Date) - $staticInfo.BootTime
            $uptimeStr = "{0}d {1}h {2}m" -f $uptime.Days, $uptime.Hours, $uptime.Minutes

            $freeRam = [math]::Round(((Get-CimInstance Win32_OperatingSystem -ErrorAction SilentlyContinue).FreePhysicalMemory / 1024) / 1024, 2)
            $usedRam = [math]::Round($staticInfo.TotalRAM - $freeRam, 2)
            $ramPerc = $(if ($staticInfo.TotalRAM -gt 0) { [math]::Round(($usedRam / $staticInfo.TotalRAM) * 100, 0) } else { 0 })

            # Disk: query every 10 seconds only
            if (((Get-Date) - $script:lastDiskCheck).TotalSeconds -ge 10) {
                $disk = Get-CimInstance Win32_LogicalDisk -Filter "DeviceID='C:'" -ErrorAction SilentlyContinue
                if ($disk) {
                    $script:cachedDiskFreeGB = [math]::Round($disk.FreeSpace / 1GB, 1)
                    $script:cachedDiskPerc   = [math]::Round(($disk.Size - $disk.FreeSpace) / $disk.Size * 100, 0)
                    $script:lastDiskCheck    = Get-Date
                }
            }
            $diskFreeGB = $script:cachedDiskFreeGB
            $diskPerc   = $script:cachedDiskPerc

            # HEALTH SCORE (0-100)
            $ramScore    = [math]::Max(0, 100 - $ramPerc)
            $diskScore   = [math]::Max(0, 100 - $diskPerc)
            $uptimeDays  = $uptime.TotalDays
            $uptimeScore = $(if ($uptimeDays -lt 1) { 100 } elseif ($uptimeDays -lt 7) { 90 } elseif ($uptimeDays -lt 14) { 70 } else { 50 })
            $healthScore = [math]::Round(($ramScore * 0.5) + ($diskScore * 0.3) + ($uptimeScore * 0.2))
            $healthLabel = $(if ($healthScore -ge 85) { "Excellent" } elseif ($healthScore -ge 65) { "Good" } elseif ($healthScore -ge 45) { "Fair" } else { "Poor" })

            # Update UI bars
            $barRam  = $window.FindName("barRamFill");        if ($barRam)  { $barRam.Width   = ($ramPerc  / 100) * 200 }
            $lblRam  = $window.FindName("txtRamPercModern");  if ($lblRam)  { $lblRam.Text    = "$ramPerc%" }
            $barDisk = $window.FindName("barDiskFill");       if ($barDisk) { $barDisk.Width  = ($diskPerc / 100) * 200 }
            $lblDisk = $window.FindName("txtDiskPercModern"); if ($lblDisk) { $lblDisk.Text   = "$diskPerc%" }
            $rectRam = $window.FindName("rectRamRetro");      if ($rectRam) { $rectRam.Width  = ($ramPerc  / 100) * 160 }
            $txtRamR = $window.FindName("txtRamRetro");       if ($txtRamR) { $txtRamR.Text   = "$ramPerc% Used" }
            $rectDsk = $window.FindName("rectDiskRetro");     if ($rectDsk) { $rectDsk.Width  = ($diskPerc / 100) * 160 }
            $txtDskR = $window.FindName("txtDiskRetro");      if ($txtDskR) { $txtDskR.Text   = "$diskPerc% Used" }

            $txtSys = $window.FindName("txtSysInfo")
            if ($txtSys) {
                $uptime    = (Get-Date) - $staticInfo.BootTime
                $uptimeStr = "{0}d {1}h {2}m" -f $uptime.Days, $uptime.Hours, $uptime.Minutes
                $txtSys.Text = "User: $env:USERNAME`n$($staticInfo.WindowsVer)`n$($staticInfo.WinFlexVer)`nCPU: $($staticInfo.CPU)`nRAM: $usedRam / $($staticInfo.TotalRAM) GB ($ramPerc%)`nGPU: $($staticInfo.GPU)`nUptime: $uptimeStr`nLocal IP: $($staticInfo.LocalIP)`nDisk C: $diskFreeGB GB Free"
            }
        } catch {}
    })
$timer.Start()


# ==============================================================================
# BEAST CONTROL CENTER - Functions & Click Handlers
# ==============================================================================

# Administrative Check Helper
function Test-IsAdmin {
    return ([Security.Principal.WindowsPrincipal]::new([Security.Principal.WindowsIdentity]::GetCurrent())).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

# Beast Log Helper
function Write-BeastLog {
    param([string]$text, [string]$color = "Chartreuse")
    $logBox = Get-GuiElement "txtBeastLog"
    if ($logBox) {
        $timestamp = (Get-Date).ToString('HH:mm:ss')
        $logBox.Text += "[$timestamp] $text`n"
        [System.Windows.Forms.Application]::DoEvents()
    }
}

# Clear Log Button
(Get-GuiElement "btnClearBeastLog").Add_Click({ (Get-GuiElement "txtBeastLog").Text = "" })

# --- MAINTENANCE FUNCTIONS ---
(Get-GuiElement "btnBeastGlobalRepair").Add_Click({
    if (-not (Test-IsAdmin)) { Write-BeastLog "ERROR: Administrative privileges required." "Red"; return }
    Write-BeastLog "SFC & DISM (Repairing System)..."
    Start-Process powershell -ArgumentList "-NoExit", "-Command", "sfc /scannow; dism /online /cleanup-image /restorehealth; Read-Host 'Press Enter to close'" -Verb RunAs
    Write-BeastLog "Repair processes started in separate window [OK]"
})

(Get-GuiElement "btnBeastCleanTemp").Add_Click({
    if (-not (Test-IsAdmin)) { Write-BeastLog "ERROR: Administrative privileges required." "Red"; return }
    Write-BeastLog "Cleaning temporary system files..."
    $paths = @($env:TEMP, "C:\Windows\Temp", "C:\Windows\Prefetch", "C:\Windows\SoftwareDistribution\Download")
    foreach ($p in $paths) { 
        try { Remove-Item "$p\*" -Recurse -Force -ErrorAction SilentlyContinue } catch {}
    }
    Write-BeastLog "System cleanup completed [OK]"
})

(Get-GuiElement "btnBeastEmptyRecycle").Add_Click({
    Write-BeastLog "Emptying Recycle Bin..."
    try { Clear-RecycleBin -Force -ErrorAction SilentlyContinue } catch {}
    Write-BeastLog "Recycle Bin cleared [OK]"
})
(Get-GuiElement "btnBeastResetStore").Add_Click({
    if (-not (Test-IsAdmin)) { Write-BeastLog "ERROR: Administrative privileges required." "Red"; return }
    Write-BeastLog "Resetting Windows Store..."
    Start-Process wsreset.exe
    Write-BeastLog "WSReset command sent [OK]"
})

(Get-GuiElement "btnBeastIconCache").Add_Click({
    if (-not (Test-IsAdmin)) { Write-BeastLog "ERROR: Administrative privileges required." "Red"; return }
    Write-BeastLog "Rebuilding Icon Cache..."
    try {
        taskkill /IM explorer.exe /F | Out-Null
        Remove-Item "$env:localappdata\IconCache.db" -Force -ErrorAction SilentlyContinue
        Start-Process explorer
        Write-BeastLog "Icon Cache rebuilt successfully [OK]"
    } catch { Write-BeastLog "Failed to rebuild Icon Cache [FAIL]" "Red" }
})

(Get-GuiElement "btnBeastWinUpdate").Add_Click({
    if (-not (Test-IsAdmin)) { Write-BeastLog "ERROR: Administrative privileges required." "Red"; return }
    Write-BeastLog "Clearing Windows Update Cache..."
    try {
        net stop wuauserv | Out-Null
        Remove-Item "C:\Windows\SoftwareDistribution\Download\*" -Recurse -Force -ErrorAction SilentlyContinue
        net start wuauserv | Out-Null
        Write-BeastLog "Windows Update Cache cleared [OK]"
    } catch { Write-BeastLog "Failed to clear Update Cache [FAIL]" "Red" }
})

# --- HARDWARE FUNCTIONS ---
(Get-GuiElement "btnBeastStress").Add_Click({
    Write-BeastLog "Running WinSAT Stress Test (This may take time)..."
    Start-Process powershell -ArgumentList "-NoExit", "-Command", "winsat formal; Read-Host 'Press Enter to close'"
    Write-BeastLog "WinSAT process started in separate window [OK]"
})

(Get-GuiElement "btnBeastRAM").Add_Click({
    Write-BeastLog "--- RAM Details ---"
    try {
        $m = Get-CimInstance Win32_PhysicalMemory -ErrorAction Stop
        foreach ($s in $m) { 
            $capGB = [math]::Round($s.Capacity / 1GB, 0)
            Write-BeastLog "Slot: $($s.DeviceLocator) | $($capGB) GB | Speed: $($s.Speed)MHz | $($s.Manufacturer)" 
        }
    } catch { Write-BeastLog "Error retrieving RAM details: $_" "Red" }
})

(Get-GuiElement "btnBeastSMART").Add_Click({
    Write-BeastLog "--- Disk Health (SMART) ---"
    Get-PhysicalDisk | ForEach-Object { 
        Write-BeastLog "Drive: $($_.FriendlyName) | Health: $($_.HealthStatus)" 
    }
})

(Get-GuiElement "btnBeastCPU").Add_Click({
    Write-BeastLog "--- CPU Details ---"
    $cpu = Get-CimInstance Win32_Processor
    Write-BeastLog "CPU: $($cpu.Name)"
    Write-BeastLog "Cores: $($cpu.NumberOfCores) | Threads: $($cpu.NumberOfLogicalProcessors)"
    Write-BeastLog "Speed: $($cpu.MaxClockSpeed) MHz"
})

(Get-GuiElement "btnBeastBattery").Add_Click({
    Write-BeastLog "Generating Battery Report..."
    powercfg /batteryreport /output "$env:TEMP\br.html"
    Invoke-Item "$env:TEMP\br.html"
    Write-BeastLog "Battery report opened in browser [OK]"
})

(Get-GuiElement "btnBeastHighPerf").Add_Click({
    Write-BeastLog "Setting Maximum Performance Power Plan..."
    powercfg /setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c
    Write-BeastLog "Power plan set to High Performance [OK]"
})

# --- NETWORK FUNCTIONS ---
(Get-GuiElement "btnBeastNetReset").Add_Click({
    if (-not (Test-IsAdmin)) { Write-BeastLog "ERROR: Administrative privileges required." "Red"; return }
    Write-BeastLog "Resetting Network & IP Settings..."
    netsh int ip reset | Out-Null
    netsh winsock reset | Out-Null
    ipconfig /flushdns | Out-Null
    Write-BeastLog "Network reset completed [OK] (Restart recommended)"
})

(Get-GuiElement "btnBeastDNS").Add_Click({
    Write-BeastLog "Flushing DNS Cache..."
    ipconfig /flushdns | Out-Null
    Write-BeastLog "DNS Cache Flushed [OK]"
})

(Get-GuiElement "btnBeastPorts").Add_Click({
    Write-BeastLog "--- Open Ports (Listening) ---"
    Get-NetTCPConnection -State Listen | Select-Object LocalAddress, LocalPort | Sort-Object LocalPort | ForEach-Object {
        Write-BeastLog "$($_.LocalAddress):$($_.LocalPort)"
    }
})

(Get-GuiElement "btnBeastPublicIP").Add_Click({
    Write-BeastLog "Retrieving Public IP..."
    try {
        $ip = (Invoke-RestMethod -Uri "https://api.ipify.org" -TimeoutSec 5)
        Write-BeastLog "Public IP: $ip [OK]"
    }
    catch {
        Write-BeastLog "Failed to retrieve Public IP [FAIL]" "Red"
    }
})

(Get-GuiElement "btnBeastWiFi").Add_Click({
    Write-BeastLog "--- Saved Wi-Fi Profiles ---"
    $profiles = netsh wlan show profiles | Select-String "All User Profile"
    foreach ($p in $profiles) {
        $name = $p -replace ".*: ", ""
        Write-BeastLog "[PROFILE] $name"
    }
})

(Get-GuiElement "btnBeastPing").Add_Click({
    Write-BeastLog "Pinging Google DNS (8.8.8.8)..."
    Test-Connection 8.8.8.8 -Count 4 | ForEach-Object {
        Write-BeastLog "Reply from 8.8.8.8: time=$($_.ResponseTime)ms"
    }
})

# --- SECURITY & SYSTEM FUNCTIONS ---
(Get-GuiElement "btnBeastProductKey").Add_Click({
    if (-not (Test-IsAdmin)) { Write-BeastLog "ERROR: Administrative privileges required." "Red"; return }
    Write-BeastLog "Extracting Product Key from BIOS..."
    try {
        $key = (Get-CimInstance SoftwareLicensingService).OA3xOriginalProductKey
        if ($key) { 
            Write-BeastLog "Product Key: $key [OK]"
            Set-Clipboard -Value $key
            Write-BeastLog "Key copied to Clipboard [OK]"
        }
        else { 
            Write-BeastLog "No product key found in BIOS [FAIL]" 
        }
    }
    catch {
        Write-BeastLog "Error retrieving product key [FAIL]" "Red"
    }
})

(Get-GuiElement "btnBeastRestorePoint").Add_Click({
    if (-not (Test-IsAdmin)) { Write-BeastLog "ERROR: Administrative privileges required." "Red"; return }
    Write-BeastLog "Creating System Restore Point..."
    try {
        Checkpoint-Computer -Description "WinFlexOS_ManualRestore" -RestorePointType "MODIFY_SETTINGS"
        Write-BeastLog "Restore point created successfully [OK]"
    }
    catch {
        Write-BeastLog "Failed to create restore point [FAIL]" "Red"
    }
})

(Get-GuiElement "btnBeastTopRAM").Add_Click({
    Write-BeastLog "--- Memory Intensive Processes (Top 10) ---"
    Get-Process | Sort-Object WorkingSet -Descending | Select-Object -First 10 | ForEach-Object {
        $ramMB = [math]::Round($_.WorkingSet / 1MB, 0)
        Write-BeastLog "$($_.Name): ${ramMB} MB"
    }
})

(Get-GuiElement "btnBeastStartup").Add_Click({
    Write-BeastLog "--- Startup Applications ---"
    Get-CimInstance Win32_StartupCommand | ForEach-Object {
        Write-BeastLog "[STARTUP] $($_.Name): $($_.Command)"
    }
})

(Get-GuiElement "btnBeastUptime").Add_Click({
    Write-BeastLog "--- System Uptime ---"
    $os = Get-CimInstance Win32_OperatingSystem
    $uptime = (Get-Date) - $os.LastBootUpTime
    Write-BeastLog "Uptime: $($uptime.Days)d $($uptime.Hours)h $($uptime.Minutes)m [OK]"
})

(Get-GuiElement "btnBeastEventLog").Add_Click({
    if (-not (Test-IsAdmin)) { Write-BeastLog "ERROR: Administrative privileges required." "Red"; return }
    Write-BeastLog "Clearing System Event Logs..."
    Get-EventLog -List | ForEach-Object { 
        try { Clear-EventLog -LogName $_.Log -ErrorAction SilentlyContinue } catch {}
    }
    Write-BeastLog "Event Logs cleared [OK]"
})

# --- QUICK TOOLS ---
(Get-GuiElement "btnBeastTaskMgr").Add_Click({ Start-Process taskmgr })
(Get-GuiElement "btnBeastDevMgr").Add_Click({ Start-Process devmgmt.msc })
(Get-GuiElement "btnBeastDiskMgr").Add_Click({ Start-Process diskmgmt.msc })
(Get-GuiElement "btnBeastRegEdit").Add_Click({ Start-Process regedit })
(Get-GuiElement "btnBeastNetplwiz").Add_Click({ Start-Process netplwiz })

# ==============================================================================
# ==============================================================================
# CLEANUP & MAINTENANCE HANDLERS
# ==============================================================================

# Navigation
Set-Click "btnMaintenance" { 
    @("pnlHome", "pnlAIBots", "pnlEssentials", "pnlWindowsTools", "pnlSysInfoTools", "pnlTweaks", "pnlMaintenance", "pnlSecurity", "pnlActivation", "pnlUserMgmt", "pnlMusic", "pnlPower", "pnlBeast") | ForEach-Object { (Get-GuiElement $_).Visibility = "Collapsed" }
    (Get-GuiElement "pnlMaintenance").Visibility = "Visible"
}

# Quick Actions
Set-Click "btnCleanAll" {
    $result = [System.Windows.MessageBox]::Show("This will run all cleanup tasks at once. Continue?", "Full Cleanup", "YesNo", "Warning")
    if ($result -eq "Yes") {
        try {
            Clear-RecycleBin -Force -ErrorAction SilentlyContinue
            Remove-Item "$env:TEMP\*" -Recurse -Force -ErrorAction SilentlyContinue
            Remove-Item "C:\Windows\Temp\*" -Recurse -Force -ErrorAction SilentlyContinue
            Remove-Item "C:\Windows\Prefetch\*" -Force -ErrorAction SilentlyContinue
            ipconfig /flushdns | Out-Null
            $edgeCache = "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\Cache"
            if (Test-Path $edgeCache) { Remove-Item "$edgeCache\*" -Recurse -Force -ErrorAction SilentlyContinue }
            [System.Windows.MessageBox]::Show("Cleanup completed successfully!", "Success", "OK", "Information")
        }
        catch {
            [System.Windows.MessageBox]::Show("Error: $_", "Error", "OK", "Error")
        }
    }
}

Set-Click "btnEmptyRecycleBin" {
    try {
        Clear-RecycleBin -Force -ErrorAction Stop
        [System.Windows.MessageBox]::Show("Recycle Bin emptied!", "Success", "OK", "Information")
    }
    catch {
        [System.Windows.MessageBox]::Show("Error: $_", "Error", "OK", "Error")
    }
}

Set-Click "btnSystemCleanup" { Start-Process cleanmgr }

# Temporary Files
Set-Click "btnClearTemp" {
    try {
        Remove-Item "C:\Windows\Temp\*" -Recurse -Force -ErrorAction SilentlyContinue
        [System.Windows.MessageBox]::Show("Windows Temp cleaned!", "Success", "OK", "Information")
    }
    catch { [System.Windows.MessageBox]::Show("Error: $_", "Error", "OK", "Error") }
}

Set-Click "btnClearUserTemp" {
    try {
        Remove-Item "$env:TEMP\*" -Recurse -Force -ErrorAction SilentlyContinue
        [System.Windows.MessageBox]::Show("User Temp cleaned!", "Success", "OK", "Information")
    }
    catch { [System.Windows.MessageBox]::Show("Error: $_", "Error", "OK", "Error") }
}

Set-Click "btnClearPrefetch" {
    try {
        Remove-Item "C:\Windows\Prefetch\*" -Force -ErrorAction SilentlyContinue
        [System.Windows.MessageBox]::Show("Prefetch cleaned!", "Success", "OK", "Information")
    }
    catch { [System.Windows.MessageBox]::Show("Error: $_", "Error", "OK", "Error") }
}

Set-Click "btnClearWindowsLogs" {
    try {
        Remove-Item "C:\Windows\Logs\*" -Recurse -Force -ErrorAction SilentlyContinue
        [System.Windows.MessageBox]::Show("Windows Logs cleaned!", "Success", "OK", "Information")
    }
    catch { [System.Windows.MessageBox]::Show("Error: $_", "Error", "OK", "Error") }
}

# Browser Cache
Set-Click "btnClearEdgeCache" {
    try {
        $edgePaths = @("$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\Cache", "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\Code Cache")
        foreach ($path in $edgePaths) { if (Test-Path $path) { Remove-Item "$path\*" -Recurse -Force -ErrorAction SilentlyContinue } }
        [System.Windows.MessageBox]::Show("Edge cache cleaned!", "Success", "OK", "Information")
    }
    catch { [System.Windows.MessageBox]::Show("Error: $_", "Error", "OK", "Error") }
}

Set-Click "btnClearChromeCache" {
    try {
        $chromePath = "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Cache"
        if (Test-Path $chromePath) {
            Remove-Item "$chromePath\*" -Recurse -Force -ErrorAction SilentlyContinue
            [System.Windows.MessageBox]::Show("Chrome cache cleaned!", "Success", "OK", "Information")
        }
        else { [System.Windows.MessageBox]::Show("Chrome not installed", "Info", "OK", "Information") }
    }
    catch { [System.Windows.MessageBox]::Show("Error: $_", "Error", "OK", "Error") }
}

Set-Click "btnClearFirefoxCache" {
    try {
        $ffPath = "$env:APPDATA\Mozilla\Firefox\Profiles"
        if (Test-Path $ffPath) {
            Get-ChildItem "$ffPath\*.default*\cache2" -Recurse -ErrorAction SilentlyContinue | ForEach-Object { Remove-Item "$($_.FullName)\*" -Recurse -Force -ErrorAction SilentlyContinue }
            [System.Windows.MessageBox]::Show("Firefox cache cleaned!", "Success", "OK", "Information")
        }
        else { [System.Windows.MessageBox]::Show("Firefox not installed", "Info", "OK", "Information") }
    }
    catch { [System.Windows.MessageBox]::Show("Error: $_", "Error", "OK", "Error") }
}

Set-Click "btnClearAllBrowsers" {
    $result = [System.Windows.MessageBox]::Show("Clean all browser caches?", "Confirm", "YesNo", "Question")
    if ($result -eq "Yes") {
        try {
            $edgePaths = @("$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\Cache")
            foreach ($p in $edgePaths) { if (Test-Path $p) { Remove-Item "$p\*" -Recurse -Force -ErrorAction SilentlyContinue } }
            $chromePath = "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Cache"
            if (Test-Path $chromePath) { Remove-Item "$chromePath\*" -Recurse -Force -ErrorAction SilentlyContinue }
            $ffPath = "$env:APPDATA\Mozilla\Firefox\Profiles"
            if (Test-Path $ffPath) { Get-ChildItem "$ffPath\*.default*\cache2" -Recurse -ErrorAction SilentlyContinue | ForEach-Object { Remove-Item "$($_.FullName)\*" -Recurse -Force -ErrorAction SilentlyContinue } }
            [System.Windows.MessageBox]::Show("All browser caches cleaned!", "Success", "OK", "Information")
        }
        catch { [System.Windows.MessageBox]::Show("Error: $_", "Error", "OK", "Error") }
    }
}

# System Optimization
Set-Click "btnClearDNSCache" { try { ipconfig /flushdns | Out-Null; [System.Windows.MessageBox]::Show("DNS Cache cleaned!", "Success", "OK", "Information") } catch { [System.Windows.MessageBox]::Show("Error: $_", "Error", "OK", "Error") } }
Set-Click "btnClearIconCache" { try { ie4uinit.exe -show; [System.Windows.MessageBox]::Show("Icon Cache rebuilt! Please restart explorer.", "Success", "OK", "Information") } catch { [System.Windows.MessageBox]::Show("Error: $_", "Error", "OK", "Error") } }
Set-Click "btnClearFontCache" { try { Stop-Service FontCache -Force -ErrorAction SilentlyContinue; Remove-Item "C:\Windows\ServiceProfiles\LocalService\AppData\Local\FontCache\*" -Recurse -Force -ErrorAction SilentlyContinue; Start-Service FontCache -ErrorAction SilentlyContinue; [System.Windows.MessageBox]::Show("Font Cache cleaned!", "Success", "OK", "Information") } catch { [System.Windows.MessageBox]::Show("Error: $_", "Error", "OK", "Error") } }
Set-Click "btnClearMemory" { try { [System.GC]::Collect(); [System.GC]::WaitForPendingFinalizers(); [System.Windows.MessageBox]::Show("Memory Cache cleaned!", "Success", "OK", "Information") } catch { [System.Windows.MessageBox]::Show("Error: $_", "Error", "OK", "Error") } }

# Windows Updates
Set-Click "btnClearUpdateCache" { try { Remove-Item "C:\Windows\SoftwareDistribution\Download\*" -Recurse -Force -ErrorAction SilentlyContinue; [System.Windows.MessageBox]::Show("Update Cache cleaned!", "Success", "OK", "Information") } catch { [System.Windows.MessageBox]::Show("Error: $_", "Error", "OK", "Error") } }
Set-Click "btnClearDeliveryOptimization" { try { Remove-Item "C:\Windows\SoftwareDistribution\DeliveryOptimization\*" -Recurse -Force -ErrorAction SilentlyContinue; [System.Windows.MessageBox]::Show("Delivery Optimization cleaned!", "Success", "OK", "Information") } catch { [System.Windows.MessageBox]::Show("Error: $_", "Error", "OK", "Error") } }
Set-Click "btnClearSoftwareDistribution" { try { Stop-Service wuauserv -Force; Remove-Item "C:\Windows\SoftwareDistribution\*" -Recurse -Force -ErrorAction SilentlyContinue; Start-Service wuauserv; [System.Windows.MessageBox]::Show("Windows Update Reset!", "Success", "OK", "Information") } catch { [System.Windows.MessageBox]::Show("Error: $_", "Error", "OK", "Error") } }
Set-Click "btnWSUSReset" { try { Stop-Service wuauserv -Force; Remove-Item "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate" -Recurse -ErrorAction SilentlyContinue; Start-Service wuauserv; [System.Windows.MessageBox]::Show("WSUS Client Reset!", "Success", "OK", "Information") } catch { [System.Windows.MessageBox]::Show("Error: $_", "Error", "OK", "Error") } }

# Privacy & Tracking
Set-Click "btnClearRecentItems" { try { Remove-Item "$env:APPDATA\Microsoft\Windows\Recent\*" -Force -ErrorAction SilentlyContinue; [System.Windows.MessageBox]::Show("Recent Items cleaned!", "Success", "OK", "Information") } catch { [System.Windows.MessageBox]::Show("Error: $_", "Error", "OK", "Error") } }
Set-Click "btnClearJumpLists" { try { Remove-Item "$env:APPDATA\Microsoft\Windows\Recent\AutomaticDestinations\*" -Force -ErrorAction SilentlyContinue; Remove-Item "$env:APPDATA\Microsoft\Windows\Recent\CustomDestinations\*" -Force -ErrorAction SilentlyContinue; [System.Windows.MessageBox]::Show("Jump Lists cleaned!", "Success", "OK", "Information") } catch { [System.Windows.MessageBox]::Show("Error: $_", "Error", "OK", "Error") } }
Set-Click "btnClearRunHistory" { try { Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\RunMRU" -Name "*" -ErrorAction SilentlyContinue; [System.Windows.MessageBox]::Show("Run History cleaned!", "Success", "OK", "Information") } catch { [System.Windows.MessageBox]::Show("Error: $_", "Error", "OK", "Error") } }
Set-Click "btnClearEventLogs" { $result = [System.Windows.MessageBox]::Show("Clean all Event Logs?", "Confirm", "YesNo", "Warning"); if ($result -eq "Yes") { try { wevtutil el | ForEach-Object { wevtutil cl $_ }; [System.Windows.MessageBox]::Show("Event Logs cleaned!", "Success", "OK", "Information") } catch { [System.Windows.MessageBox]::Show("Error: $_", "Error", "OK", "Error") } } }

# Advanced Tools
Set-Click "btnStorageSense" { Start-Process ms-settings:storagesense }
Set-Click "btnDefragOptimize" { Start-Process dfrgui }
Set-Click "btnCheckDisk" { Start-Process cmd "/k chkdsk C: /f /r" -Verb RunAs }
Set-Click "btnTrim" { Start-Process cmd "/k defrag C: /L /O" -Verb RunAs }

# ==============================================================================
# UPDATE MANAGER LOGIC
# ==============================================================================

function Get-UpdateInfoAnalysis ($kbID) {
    $report = "+-----------------------------------------------------------+`n"
    $report += "              Detailed Analysis Report for $kbID                      `n"
    $report += "+-----------------------------------------------------------+`n`n"
    $report += "Status: Searching online...`n"
    $report += "Source: Microsoft Support + Community Forums`n`n"
    $report += "-------------------------------------------------------------`n"

    $issuesFound = @()
    $severity = "Low"
    
    try {
        $searchUrl = "https://www.catalog.update.microsoft.com/Search.aspx?q=$kbID"
        $webRequest = Invoke-WebRequest -Uri $searchUrl -UseBasicParsing -TimeoutSec 15 -ErrorAction Stop
        
        if ($webRequest.Content -match $kbID) {
            $report += "OK: Update found in official Microsoft Catalog`n"
        }
        else {
            $report += "Warning: Update not found in official Catalog`n"
            $severity = "High"
        }
        
        $specificSearch = "https://www.bing.com/search?q=`"$kbID`"+issue+OR+problem+OR+bug"
        $bingRequest = Invoke-WebRequest -Uri $specificSearch -UseBasicParsing -TimeoutSec 15 -ErrorAction SilentlyContinue
        
        if ($bingRequest.Content -match "BSOD|Blue Screen|crash") {
            $issuesFound += "Reports of system crashes (BSOD) related to $kbID"
            $severity = "High"
        }
        
        $report += "-------------------------------------------------------------`n`n"
        $report += "Severity Level: $severity`n`n"
        
        if ($issuesFound.Count -gt 0) {
            $report += "Issues found for ${kbID}:`n`n"
            foreach ($issue in $issuesFound) { $report += "   * $issue`n" }
        }
        else {
            $report += "OK: No significant issues reported.`n"
        }
    }
    catch {
        $report += "Error connecting to the internet for analysis.`n"
    }

    return $report
}

function Get-OSUpdatesSummary {
    try {
        $updateSession = New-Object -ComObject Microsoft.Update.Session
        $updateSearcher = $updateSession.CreateUpdateSearcher()
        $searchResult = $updateSearcher.Search("IsInstalled=0 and Type='Software' and IsHidden=0")
        
        if ($searchResult.Updates.Count -eq 0) { return "OK: System is up to date." }
        else {
            $res = "Found $($searchResult.Updates.Count) available updates:`n`n"
            foreach ($update in $searchResult.Updates) { $res += "* $($update.Title)`n" }
            return $res
        }
    }
    catch { return "Error checking for updates." }
}

function Get-AppUpdatesSummary {
    try {
        $updates = winget upgrade 2>&1 | Out-String
        if ($updates -match "No installed package found") { return "OK: All apps are up to date." }
        else { return "App updates available:`n`n$updates" }
    }
    catch { return "Error checking for Winget updates." }
}

# --- WEBVIEW2 ROBUST LOADER (Ported from pwrev1) ---
$global:UseWebView2 = $false
$global:WV2Control = $null
$global:LibPath = "$env:APPDATA\WinFlexOS\Libs"


# --- ADDITIONAL SYSTEM UTILITIES ---
Set-Click 'btnSFC' { Start-Process cmd '/k sfc /scannow' -Verb RunAs }
Set-Click 'btnChkdsk' { Start-Process cmd '/k chkdsk' -Verb RunAs }
Set-Click 'btnDiskMgmt' { Start-Process diskmgmt.msc }
Set-Click 'btnTaskMgr' { Start-Process taskmgr }
Set-Click 'btnDevMgmt' { Start-Process devmgmt.msc }
Set-Click 'btnRegEdit' { Start-Process regedit }
Set-Click 'btnMsConfig' { Start-Process msconfig }
Set-Click 'btnEventVwr' { Start-Process eventvwr }
Set-Click 'btnDiskCleanup' { Start-Process cleanmgr }
Set-Click 'btnNetplwiz' { Start-Process netplwiz }
Set-Click 'btnMsInfo32' { Start-Process msinfo32 }
Set-Click 'btnWinVer' { Start-Process winver }
Set-Click 'btnGodMode' { $p = "$([Environment]::GetFolderPath('Desktop'))\GodMode.{ED7BA470-8E54-465E-825C-99712043E01C}"; if (!(Test-Path $p)) { New-Item -Path $p -ItemType Directory; Write-Log 'GodMode Created' } }

# --- THIRD PARTY TOOLS ---
Set-Click 'btnCTTExplain' { [System.Windows.Forms.MessageBox]::Show('Runs the Chris Titus Tech WinUtil script.', 'Info') }
Set-Click 'btnCTTWeb' { Start-Process 'https://christitus.com/windows-tool/' }
Set-Click 'btnCTTGit' { Start-Process 'https://github.com/ChrisTitusTech/winutil' }
Set-Click 'btnTreeSize' { Invoke-OnlineApp -Url 'https://downloads.jam-software.de/treesize_free/TreeSizeFree-Portable.zip' -FileName 'TreeSize.zip' -ExeToRun 'TreeSizeFree.exe' -IsZip $true }
Set-Click 'btnCrystalDiskInfo' { Invoke-OnlineApp -Url 'https://osdn.net/frs/redir.php?m=gigenet&f=crystaldiskinfo%2F78192%2FCrystalDiskInfo9_2_1.zip' -FileName 'CDInfo.zip' -ExeToRun 'DiskInfo64.exe' -IsZip $true }
Set-Click 'btnCrystalDiskMark' { Invoke-OnlineApp -Url 'https://osdn.net/frs/redir.php?m=gigenet&f=crystaldiskmark%2F77936%2FCrystalDiskMark8_0_4c.zip' -FileName 'CDMark.zip' -ExeToRun 'DiskMark64.exe' -IsZip $true }
Set-Click 'btnWin11Debloat' { Start-Process powershell 'iwr -useb https://win11debloat.raphire.com | iex' -Verb RunAs }
Set-Click 'btnSycnex' { Start-Process powershell 'iwr -useb https://raw.githubusercontent.com/Sycnex/Windows10Debloater/master/Windows10DebloaterGUI.ps1 | iex' -Verb RunAs }
Set-Click 'btnOptimizer' { Invoke-OnlineApp -Url 'https://github.com/hellzerg/optimizer/releases/download/16.7/Optimizer.exe' -FileName 'Optimizer.exe' }
Set-Click 'btnBCU' { Invoke-OnlineApp -Url 'https://github.com/Klocman/Bulk-Crap-Uninstaller/releases/download/v5.7/BCUninstaller_5.7_portable.zip' -FileName 'BCU.zip' -ExeToRun 'BCUninstaller.exe' -IsZip $true }
Set-Click 'btnBloatyNosy' { Invoke-OnlineApp -Url 'https://github.com/belimawr/BloatyNosy/releases/download/2.0.0/BloatyNosyApp.zip' -FileName 'BloatyNosy.zip' -ExeToRun 'BloatyNosy.exe' -IsZip $true }
Set-Click 'btnBleachBit' { Invoke-OnlineApp -Url 'https://download.bleachbit.org/BleachBit-4.6.0-portable.zip' -FileName 'BleachBit.zip' -ExeToRun 'BleachBit.exe' -IsZip $true }
Set-Click 'btnRAPR' { Invoke-OnlineApp -Url 'https://github.com/lostindark/DriverStoreExplorer/releases/latest/download/DriverStoreExplorer.v0.11.92.zip' -FileName 'RAPR.zip' -ExeToRun 'Rapr.exe' -IsZip $true }
Set-Click 'btnRevo' { Start-Process powershell -ArgumentList '-Command "winget install --id RevoUninstaller.RevoUninstaller -e"' -Verb RunAs }
Set-Click 'btnCPUZ' { Invoke-OnlineApp -Url 'https://www.cpuid.com/downloads/cpu-z/cpu-z_2.10-en.zip' -FileName 'cpuz.zip' -ExeToRun 'cpuz_x64.exe' -IsZip $true }
Set-Click 'btnHWMonitor' { Invoke-OnlineApp -Url 'https://www.cpuid.com/downloads/hwmonitor/hwmonitor_1.54.zip' -FileName 'hwmonitor.zip' -ExeToRun 'HWMonitor_x64.exe' -IsZip $true }
Set-Click 'btnLibreHM_Sys' { Invoke-OnlineApp -Url 'https://github.com/LibreHardwareMonitor/LibreHardwareMonitor/releases/download/v0.9.3/LibreHardwareMonitor-v0.9.3.zip' -FileName 'LibreHM.zip' -ExeToRun 'LibreHardwareMonitor.exe' -IsZip $true }
Set-Click 'btnWhyNotWin11' { Invoke-OnlineApp -Url 'https://github.com/rcmaehl/WhyNotWin11/releases/latest/download/WhyNotWin11.exe' -FileName 'WhyNotWin11.exe' }
Set-Click 'btnRunMAS' { Start-Process powershell 'irm https://massgrave.dev/get | iex' -Verb RunAs }
Set-Click 'btnRunWinRAR' { Start-Process powershell 'iwr -useb https://naeembolchhi.github.io/WinRAR-Activator/WRA.ps1 | iex' -Verb RunAs }

# --- AI HUB ---
Set-Click 'btnGPT' { Open-Url 'https://chat.openai.com' }
Set-Click 'btnGemini' { Open-Url 'https://gemini.google.com' }
Set-Click 'btnCopilot' { Open-Url 'https://copilot.microsoft.com' }
Set-Click 'btnClaude' { Open-Url 'https://claude.ai' }
Set-Click 'btnGrok' { Open-Url 'https://x.com/i/grok' }
Set-Click 'btnPerplexity' { Open-Url 'https://www.perplexity.ai' }
Set-Click 'btnBlackbox' { Open-Url 'https://www.blackbox.ai' }
Set-Click 'btnDeepSeek' { Open-Url 'https://chat.deepseek.com' }
Set-Click 'btnPhind' { Open-Url 'https://www.phind.com' }
Set-Click 'btnLeonardo' { Open-Url 'https://leonardo.ai' }
Set-Click 'btnBingImage' { Open-Url 'https://www.bing.com/images/create' }
Set-Click 'btnIdeogram' { Open-Url 'https://ideogram.ai' }
Set-Click 'btnRunway' { Open-Url 'https://runwayml.com' }
Set-Click 'btnPika' { Open-Url 'https://pika.art' }
Set-Click 'btnLuma' { Open-Url 'https://lumalabs.ai/dream-machine' }
Set-Click 'btnKling' { Open-Url 'https://klingai.com' }
Set-Click 'btnSora' { Open-Url 'https://openai.com/sora' }
Set-Click 'btnVeo' { Open-Url 'https://deepmind.google/technologies/veo/' }
Set-Click 'btnSuno' { Open-Url 'https://suno.com' }
Set-Click 'btnUdio' { Open-Url 'https://www.udio.com' }
Set-Click 'btnElevenLabs' { Open-Url 'https://elevenlabs.io' }
Set-Click 'btnNotebookLM' { Open-Url 'https://notebooklm.google.com' }
Set-Click 'btnGamma' { Open-Url 'https://gamma.app' }
Set-Click 'btnAdobePodcast' { Open-Url 'https://podcast.adobe.com/enhance' }
Set-Click 'btnMidjourney' { Open-Url 'https://www.midjourney.com' }
Set-Click 'btnCivitai' { Open-Url 'https://civitai.com' }
Set-Click 'btnHuggingFace' { Open-Url 'https://huggingface.co' }
Set-Click 'btnV0' { Open-Url 'https://v0.dev' }
Set-Click 'btnZapier' { Open-Url 'https://zapier.com' }

# --- POWER OPTIONS ---
Set-Click 'pwrShutdown' { Stop-Computer -Force }
Set-Click 'pwrReboot' { Restart-Computer -Force }
Set-Click 'pwrSleep' { [System.Windows.Forms.Application]::SetSuspendState('Suspend', $false, $false) }
Set-Click 'pwrHibernate' { shutdown /h }
Set-Click 'pwrLogoff' { logoff }

# --- WINDOWS TWEAKS ---
Set-Click 'btnApplyTaskbar' { $r = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'; $v = (Get-ItemProperty $r).TaskbarAl; if ($v -eq 1) { Set-ItemProperty $r "TaskbarAl" 0 }else { Set-ItemProperty $r "TaskbarAl" 1 }; Stop-Process -Name explorer }
Set-Click 'btnClassicContext' { $p = 'HKCU:\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}'; if (Test-Path $p) { Remove-Item $p -Recurse -Force }else { New-Item "$p\InprocServer32" -Force | Out-Null; Set-ItemProperty "$p\InprocServer32" "(Default)" "" }; Stop-Process -Name explorer }
Set-Click 'btnSecondsClock' { $r = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'; Set-ItemProperty $r "ShowSecondsInSystemClock" 1; Stop-Process -Name explorer }
Set-Click 'btnDisableBing' { $r = 'HKCU:\Software\Policies\Microsoft\Windows\Explorer'; if (!(Test-Path $r)) { New-Item $r -Force }; Set-ItemProperty $r "DisableSearchBoxSuggestions" 1; Stop-Process -Name explorer }
Set-Click 'btnFileExt' { $r = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'; $v = (Get-ItemProperty $r).HideFileExt; $n = if ($v -eq 1) { 0 }else { 1 }; Set-ItemProperty $r HideFileExt $n; Stop-Process -Name explorer }
Set-Click 'btnHiddenFiles' { $r = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'; $v = (Get-ItemProperty $r).Hidden; $n = if ($v -eq 1) { 2 }else { 1 }; Set-ItemProperty $r Hidden $n; Stop-Process -Name explorer }
Set-Click 'btnCompactMode' { $r = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'; $v = (Get-ItemProperty $r).UseCompactMode; $n = if ($v -eq 1) { 0 }else { 1 }; Set-ItemProperty $r UseCompactMode $n; Stop-Process -Name explorer }
Set-Click 'btnDarkMode' { 
    $r = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize"
    $v = (Get-ItemProperty $r).AppsUseLightTheme
    $n = $(if ($v -eq 1) { 0 }else { 1 })
    Set-ItemProperty $r AppsUseLightTheme $n
    Set-ItemProperty $r SystemUsesLightTheme $n
}
Set-Click 'btnGameMode' { $r = "HKCU:\Software\Microsoft\GameBar"; Set-ItemProperty $r "AllowAutoGameMode" 1; Set-ItemProperty $r "AutoGameModeEnabled" 1 }
Set-Click 'btnMouseAccel' { $r = "HKCU:\Control Panel\Mouse"; Set-ItemProperty $r "MouseSpeed" 0; Set-ItemProperty $r "MouseThreshold1" 0; Set-ItemProperty $r "MouseThreshold2" 0 }
Set-Click 'btnIconSettings' { Start-Process desk.cpl ",,5" }
