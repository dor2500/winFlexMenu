function Get-GuiElement { param($Name) return $window.FindName($Name) }
function Set-Click { param($Name, $Script) $el = Get-GuiElement $Name; if ($el) { $el.Add_Click($Script) } }

function Invoke-WpfDialog {
    param($Title, $Message, $IsPassword = $false)
    $inputControl = '<TextBox Name="Input" Height="30" Background="#333" Foreground="White" BorderThickness="0" Padding="5"/>'
    if ($IsPassword) { $inputControl = '<PasswordBox Name="Input" Height="30" Background="#333" Foreground="White" BorderThickness="0" Padding="5"/>' }
    [xml]$dXaml = @"
    <Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation" Title="$Title" Height="180" Width="350" WindowStartupLocation="CenterScreen" WindowStyle="None" AllowsTransparency="True" Background="Transparent" Topmost="True">
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
    $reader = (New-Object System.Xml.XmlNodeReader $dXaml); $dlg = [Windows.Markup.XamlReader]::Load($reader)
    $inp = $dlg.FindName("Input"); $script:dialogResult = $null
    $dlg.FindName("btnOK").Add_Click({ if ($IsPassword) { $script:dialogResult = $inp.Password } else { $script:dialogResult = $inp.Text }; $dlg.Close() })
    $dlg.FindName("btnCancel").Add_Click({ $dlg.Close() }); $dlg.ShowDialog() | Out-Null
    return $script:dialogResult
}

function Refresh-Users {
    if ($lstUsers) {
        $lstUsers.Items.Clear()
        try {
            $computer = [ADSI]"WinNT://$env:COMPUTERNAME"; $admins = @()
            try { $adminGroup = [ADSI]"WinNT://$env:COMPUTERNAME/Administrators,group"; $admins = @($adminGroup.Members() | ForEach-Object { $_.GetType().InvokeMember("Name", 'GetProperty', $null, $_, $null) }) } catch {}
            $computer.Children | Where-Object { $_.SchemaClassName -eq 'User' } | ForEach-Object {
                $flags = $_.UserFlags.Value; $disabled = ($flags -band 2) -ne 0
                [PSCustomObject]@{ Name = $_.Name.Value; Enabled = -not $disabled; IsAdmin = $admins -contains $_.Name.Value }
            } | ForEach-Object { [void]$lstUsers.Items.Add($_) }
        } catch {}
    }
}

# --- INITIALIZATION ---
$winNum = $(if ([System.Environment]::OSVersion.Version.Build -ge 22000) { 11 } else { 10 })
$winVer = try { (Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion').DisplayVersion } catch { "" }
$staticInfo = @{
    CPU = "Loading..."; GPU = "Loading..."; TotalRAM = 8; LocalIP = "Offline"; PublicIP = "Loading..."; 
    WindowsVer = "Windows $winNum Pro - $winVer"; 
    WinFlexVer = "WinFlex11-September25 Update"; BootTime = (Get-Date).AddHours(-1)
}
try { $staticInfo.TotalRAM = [math]::Round((Get-CimInstance Win32_ComputerSystem).TotalPhysicalMemory / 1GB, 2) } catch {}
try { $staticInfo.BootTime = (Get-CimInstance Win32_OperatingSystem).LastBootUpTime } catch {}
try { $staticInfo.LocalIP = (Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.IPAddress -notlike "127*" -and $_.IPAddress -notlike "169.254*" } | Select-Object -First 1).IPAddress } catch {}

# --- ASYNC TELEMETRY ---
$script:ps = [powershell]::Create()
$script:ps.AddScript({
    $res = @{}
    try { $res.CPU = (Get-CimInstance Win32_Processor).Name.Trim() } catch {}
    try { $res.GPU = (Get-CimInstance Win32_VideoController | Select-Object -First 1).Name } catch {}
    try {
        $ram = Get-CimInstance Win32_PhysicalMemory
        $totalRam = ($ram | Measure-Object -Property Capacity -Sum).Sum / 1GB
        $speed = $ram[0].Speed
        $manu = $ram[0].Manufacturer
        $res.hwRAM = "Total: $([math]::Round($totalRam, 2)) GB`nSpeed: $speed MHz`nSlots: $($ram.Count)`nManu: $manu"
    } catch {}
    try { $res.PublicIP = (Invoke-WebRequest -Uri "https://api.ipify.org" -TimeoutSec 3 -UseBasicParsing).Content } catch {}
    try {
        $disk = Get-CimInstance -Query "ASSOCIATORS OF {Win32_LogicalDisk.DeviceID='C:'} WHERE AssocClass=Win32_LogicalDiskToPartition" -ErrorAction SilentlyContinue | ForEach-Object { Get-CimInstance -Query "ASSOCIATORS OF {Win32_DiskPartition.DeviceID='$($_.DeviceID)'} WHERE AssocClass=Win32_DiskDriveToDiskPartition" } | Select-Object -First 1
        if ($disk) { $res.hwDisk = "$($disk.Model) ($([math]::Round($disk.Size/1GB,1)) GB)" }
    } catch {}
    try { $bio = Get-CimInstance Win32_BIOS; $res.hwBio = "$($bio.Manufacturer) v$($bio.SMBIOSBIOSVersion)" } catch {}
    return $res
}) | Out-Null
$script:asyncResult = $script:ps.BeginInvoke()

$script:bgInfoApplied = $false
$script:lastDiskCheck = [DateTime]::MinValue
$script:cachedDiskFreeGB = 0
$script:cachedDiskPerc = 0

# --- MAIN UI TIMER ---
$timer = New-Object System.Windows.Threading.DispatcherTimer
$timer.Interval = [TimeSpan]::FromSeconds(2)
$timer.Add_Tick({
    if ($window.WindowState -eq "Minimized") { return }
    try {
        $now = Get-Date
        $lblTime = Get-GuiElement "lblTimeClock"
        if ($lblTime) { $lblTime.Text = $now.ToString("HH:mm") }
        $lblDate = Get-GuiElement "lblDateClock"
        if ($lblDate) { $lblDate.Text = $now.ToString("dddd, MMMM dd") }
        
        Update-Greeting-Smart
        
        if (-not $script:bgInfoApplied -and $script:asyncResult.IsCompleted) {
            $bg = $script:ps.EndInvoke($script:asyncResult) | Select-Object -Last 1
            if ($bg) {
                if ($bg.CPU) { $staticInfo.CPU = $bg.CPU; $el = Get-GuiElement "txtHwCPU"; if ($el) { $el.Text = $bg.CPU } }
                if ($bg.GPU) { $staticInfo.GPU = $bg.GPU; $el = Get-GuiElement "txtHwGPU"; if ($el) { $el.Text = $bg.GPU } }
                if ($bg.hwRAM) { $el = Get-GuiElement "txtHwRAM"; if ($el) { $el.Text = $bg.hwRAM } }
                if ($bg.PublicIP) { $staticInfo.PublicIP = $bg.PublicIP }
                if ($bg.hwDisk) { $el = Get-GuiElement "txtHwDisk"; if ($el) { $el.Text = $bg.hwDisk } }
                if ($bg.hwBio) { $el = Get-GuiElement "txtHwBio"; if ($el) { $el.Text = $bg.hwBio } }
            }
            $script:ps.Dispose(); $script:bgInfoApplied = $true
        }

        # RAM Usage
        if (-not $script:ramCounter) { $script:ramCounter = New-Object System.Diagnostics.PerformanceCounter("Memory", "Available MBytes") }
        $usedRam = [math]::Max(0, [math]::Round($staticInfo.TotalRAM - ($script:ramCounter.NextValue()/1024), 2))
        $ramPerc = [math]::Min(100, [math]::Round(($usedRam / $staticInfo.TotalRAM) * 100))
        
        # Disk Usage (C:)
        if (($now - $script:lastDiskCheck).TotalSeconds -ge 10) {
            $drive = [System.IO.DriveInfo]::new("C")
            if ($drive.IsReady) {
                $script:cachedDiskFreeGB = [math]::Round($drive.AvailableFreeSpace / 1GB, 1)
                $script:cachedDiskPerc = [math]::Round(($drive.TotalSize - $drive.AvailableFreeSpace) / $drive.TotalSize * 100)
                $script:lastDiskCheck = $now
            }
        }

        $lblRam = Get-GuiElement "txtRamPercModern"; if ($lblRam) { $lblRam.Text = "$ramPerc%" }
        $lblDisk = Get-GuiElement "txtDiskPercModern"; if ($lblDisk) { $lblDisk.Text = "$($script:cachedDiskPerc)%" }
        
        # Rings
        function Local:Update-Ring { param($n, $p) 
            $el = Get-GuiElement $n; if ($el) { 
                $dash = New-Object System.Windows.Media.DoubleCollection; 
                $dash.Add(($p/100.0)*24.78367); $dash.Add(1000); 
                $el.StrokeDashArray = $dash 
            } 
        }
        Update-Ring "arcRamFill" $ramPerc
        Update-Ring "arcDiskFill" $script:cachedDiskPerc

        $txtSys = Get-GuiElement "txtSysInfo"
        if ($txtSys) {
            $up = $now - $staticInfo.BootTime
            $upStr = "{0}d {1}h {2}m" -f $up.Days, $up.Hours, $up.Minutes
            $txtSys.Text = "User: $env:USERNAME`n$($staticInfo.WindowsVer)`n$($staticInfo.WinFlexVer)`nCPU: $($staticInfo.CPU)`nRAM: $usedRam / $($staticInfo.TotalRAM) GB ($ramPerc%)`nGPU: $($staticInfo.GPU)`nUptime: $upStr`nLocal IP: $($staticInfo.LocalIP)`nDisk C: $($script:cachedDiskFreeGB) GB Free"
        }
    } catch {}
})
$timer.Start()

# --- CLICK HANDLERS ---
Set-Click "btnRefreshUsers" { Refresh-Users }
Set-Click "btnCreateUser" {
    $u = Invoke-WpfDialog "New User" "Enter Username:"
    if ($u) { $p = Invoke-WpfDialog "Set Password" "Enter Password:" $true; try { if ($p) { & net user $u $p /add } else { & net user $u /add }; Refresh-Users } catch {} }
}
Set-Click "btnDeleteUser" {
    if ($lstUsers.SelectedItem) { $u = $lstUsers.SelectedItem.Name; if ([System.Windows.Forms.MessageBox]::Show("Delete $u?", "Confirm", 4) -eq 'Yes') { & net user $u /delete; Refresh-Users } }
}
Set-Click "btnLusrmgr" { Start-Process lusrmgr.msc }
Set-Click "btnClearTemp" { 
    try { 
        Remove-Item "$env:TEMP\*" -Recurse -Force -ErrorAction SilentlyContinue
        Remove-Item "C:\Windows\Temp\*" -Recurse -Force -ErrorAction SilentlyContinue
        [System.Windows.MessageBox]::Show("Temp cleaned!", "Success")
    } catch {}
}
Set-Click "btnSfcDism" { Start-Process powershell "-NoExit -Command sfc /scannow; dism /online /cleanup-image /restorehealth" -Verb RunAs }

# AI HUB
Set-Click "btnGPT" { Start-Process "https://chat.openai.com" }
Set-Click "btnGemini" { Start-Process "https://gemini.google.com" }
Set-Click "btnCopilot" { Start-Process "https://copilot.microsoft.com" }
Set-Click "btnClaude" { Start-Process "https://claude.ai" }
Set-Click "btnV0" { Start-Process "https://v0.dev" }

# Load initial users
Refresh-Users
