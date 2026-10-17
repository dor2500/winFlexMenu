# ==============================================================================
# WinFlexOS - Beast Control Center Module
# ==============================================================================

function Test-IsAdmin {
    try {
        $id = [Security.Principal.WindowsIdentity]::GetCurrent()
        $p = New-Object Security.Principal.WindowsPrincipal($id)
        return $p.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    } catch {
        return $false
    }
}

function Write-BeastLog {
    param([string]$text, [string]$color = "Chartreuse")
    $logBox = Get-GuiElement "txtBeastLog"
    if ($logBox) {
        $timestamp = (Get-Date).ToString('HH:mm:ss')
        $logBox.Text += "[$timestamp] $text`n"
        $scroll = $logBox.Parent
        if ($scroll -and $scroll -is [System.Windows.Controls.ScrollViewer]) {
            $scroll.ScrollToEnd()
        }
    }
}

Set-Click "btnClearBeastLog" {
    $box = Get-GuiElement "txtBeastLog"
    if ($box) { $box.Text = "" }
}

# --- MAINTENANCE ---
Set-Click "btnBeastGlobalRepair" {
    if (-not (Test-IsAdmin)) {
        Write-BeastLog "ERROR: Administrative privileges required." "Red"
        return
    }
    Write-BeastLog "Starting SFC & DISM repair in separate elevated console..."
    Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -NoExit -Command `"Write-Host 'WinFlexOS - System Health Repair' -ForegroundColor Cyan; sfc /scannow; dism /online /cleanup-image /restorehealth; Write-Host 'Repair complete.' -ForegroundColor Green; Read-Host 'Press Enter to close'`"" -Verb RunAs
    Write-BeastLog "Repair processes launched [OK]"
}

Set-Click "btnBeastCleanTemp" {
    Write-BeastLog "Cleaning temporary directories..."
    $paths = @($env:TEMP, "C:\Windows\Temp", "C:\Windows\Prefetch")
    foreach ($p in $paths) {
        try { Remove-Item "$p\*" -Recurse -Force -ErrorAction SilentlyContinue } catch {}
    }
    Write-BeastLog "System temporary files cleaned [OK]"
}

Set-Click "btnBeastEmptyRecycle" {
    Write-BeastLog "Emptying Recycle Bin..."
    try { Clear-RecycleBin -Force -ErrorAction SilentlyContinue } catch {}
    Write-BeastLog "Recycle Bin cleared [OK]"
}

Set-Click "btnBeastResetStore" {
    Write-BeastLog "Resetting Windows Store..."
    Start-Process "wsreset.exe"
    Write-BeastLog "WSReset command executed [OK]"
}

Set-Click "btnBeastIconCache" {
    Write-BeastLog "Rebuilding Icon Cache..."
    try {
        ie4uinit.exe -show | Out-Null
        Write-BeastLog "Icon cache rebuild command sent [OK]"
    } catch {
        Write-BeastLog "Failed to rebuild Icon Cache [FAIL]" "Red"
    }
}

Set-Click "btnBeastWinUpdate" {
    if (-not (Test-IsAdmin)) {
        Write-BeastLog "ERROR: Administrative privileges required." "Red"
        return
    }
    Write-BeastLog "Clearing Windows Update download cache..."
    try {
        net.exe stop wuauserv | Out-Null
        Remove-Item "C:\Windows\SoftwareDistribution\Download\*" -Recurse -Force -ErrorAction SilentlyContinue
        net.exe start wuauserv | Out-Null
        Write-BeastLog "Windows Update Cache cleared [OK]"
    } catch {
        Write-BeastLog "Failed to clear Update Cache [FAIL]" "Red"
    }
}

# --- HARDWARE & STRESS ---
Set-Click "btnBeastStress" {
    Write-BeastLog "Running WinSAT formal benchmark..."
    Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -NoExit -Command `"Write-Host 'Running Windows System Assessment (WinSAT)...' -ForegroundColor Cyan; winsat formal; Write-Host 'Benchmark Finished!' -ForegroundColor Green; Read-Host 'Press Enter to close'`""
    Write-BeastLog "WinSAT process launched in new window [OK]"
}

Set-Click "btnBeastRAM" {
    Write-BeastLog "--- Physical RAM Modules ---"
    try {
        $m = Get-CimInstance Win32_PhysicalMemory -ErrorAction Stop
        foreach ($s in $m) {
            $capGB = [math]::Round($s.Capacity / 1GB, 1)
            Write-BeastLog "Slot: $($s.DeviceLocator) | Size: ${capGB} GB | Speed: $($s.Speed) MHz | Manu: $($s.Manufacturer)"
        }
    } catch {
        Write-BeastLog "Error retrieving RAM details: $($_.Exception.Message)" "Red"
    }
}

Set-Click "btnBeastSMART" {
    Write-BeastLog "--- Disk SMART Health Status ---"
    try {
        Get-PhysicalDisk | ForEach-Object {
            Write-BeastLog "Drive: $($_.FriendlyName) | Health: $($_.HealthStatus) | Operational: $($_.OperationalStatus)"
        }
    } catch {
        Write-BeastLog "Could not read disk status: $($_.Exception.Message)" "Red"
    }
}

Set-Click "btnBeastCPU" {
    Write-BeastLog "--- CPU Hardware Information ---"
    try {
        $cpu = Get-CimInstance Win32_Processor | Select-Object -First 1
        Write-BeastLog "Processor: $($cpu.Name.Trim())"
        Write-BeastLog "Physical Cores: $($cpu.NumberOfCores) | Logical Threads: $($cpu.NumberOfLogicalProcessors)"
        Write-BeastLog "Base Clock: $($cpu.MaxClockSpeed) MHz"
    } catch {
        Write-BeastLog "Error reading CPU info." "Red"
    }
}

Set-Click "btnBeastBattery" {
    Write-BeastLog "Generating Battery Diagnostic Report..."
    $outPath = "$env:TEMP\battery_report.html"
    powercfg.exe /batteryreport /output "$outPath" | Out-Null
    if (Test-Path $outPath) {
        Start-Process $outPath
        Write-BeastLog "Battery report generated and opened in browser [OK]"
    } else {
        Write-BeastLog "No battery detected (Desktop PC) or command unsupported." "Yellow"
    }
}

Set-Click "btnBeastHighPerf" {
    Write-BeastLog "Activating High Performance Power Plan..."
    try {
        powercfg.exe /setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c
        Write-BeastLog "Power plan set to High Performance [OK]"
    } catch {
        Write-BeastLog "Failed to change power scheme" "Red"
    }
}

# --- NETWORK & DIAGNOSTICS ---
Set-Click "btnBeastNetReset" {
    if (-not (Test-IsAdmin)) {
        Write-BeastLog "ERROR: Administrative privileges required." "Red"
        return
    }
    Write-BeastLog "Resetting IP stack & Winsock..."
    netsh.exe int ip reset | Out-Null
    netsh.exe winsock reset | Out-Null
    ipconfig.exe /flushdns | Out-Null
    Write-BeastLog "Network stack reset completed [OK] (Reboot recommended)"
}

Set-Click "btnBeastDNS" {
    Write-BeastLog "Flushing DNS resolver cache..."
    ipconfig.exe /flushdns | Out-Null
    Write-BeastLog "DNS Cache Flushed [OK]"
}

Set-Click "btnBeastPorts" {
    Write-BeastLog "--- Listening TCP Ports ---"
    try {
        Get-NetTCPConnection -State Listen -ErrorAction SilentlyContinue | Select-Object -First 15 | ForEach-Object {
            Write-BeastLog "Port $($_.LocalPort) on $($_.LocalAddress)"
        }
    } catch {
        Write-BeastLog "Could not query TCP ports." "Yellow"
    }
}

Set-Click "btnBeastPublicIP" {
    Write-BeastLog "Querying public IPv4 address..."
    Start-Job -ScriptBlock {
        try {
            return (Invoke-WebRequest -Uri "https://api.ipify.org" -TimeoutSec 4 -UseBasicParsing).Content
        } catch {
            return "N/A"
        }
    } | Out-Null
    
    $t = New-Object System.Windows.Threading.DispatcherTimer
    $t.Interval = [TimeSpan]::FromMilliseconds(500)
    $attempts = 0
    $t.Add_Tick({
        $attempts++
        $j = Get-Job | Where-Object { $_.Command -like "*api.ipify.org*" } | Select-Object -Last 1
        if ($j -and $j.State -eq "Completed") {
            $ip = Receive-Job $j
            Remove-Job $j
            Write-BeastLog "Public IP: $ip [OK]"
            $t.Stop()
        } elseif ($attempts -gt 10) {
            $t.Stop()
            Write-BeastLog "Public IP request timed out." "Red"
        }
    })
    $t.Start()
}

Set-Click "btnBeastWiFi" {
    Write-BeastLog "--- Saved Wi-Fi Profiles ---"
    try {
        $profiles = netsh.exe wlan show profiles 2>&1 | Select-String "All User Profile"
        foreach ($p in $profiles) {
            $name = ($p -replace ".*:\s*", "").Trim()
            Write-BeastLog "[WIFI] $name"
        }
        if (-not $profiles) { Write-BeastLog "No Wi-Fi profiles found." "info" }
    } catch {
        Write-BeastLog "Wi-Fi query unsupported on this adapter." "Yellow"
    }
}

Set-Click "btnBeastPing" {
    Write-BeastLog "Pinging Google DNS (8.8.8.8)..."
    Start-Job -ScriptBlock {
        try {
            Test-Connection 8.8.8.8 -Count 4 | ForEach-Object {
                "$($_.Address): bytes=32 time=$($_.ResponseTime)ms"
            }
        } catch {
            "Ping failed: $($_.Exception.Message)"
        }
    } | Out-Null

    $t = New-Object System.Windows.Threading.DispatcherTimer
    $t.Interval = [TimeSpan]::FromMilliseconds(500)
    $attempts = 0
    $t.Add_Tick({
        $attempts++
        $j = Get-Job | Where-Object { $_.Command -like "*Test-Connection 8.8.8.8*" } | Select-Object -Last 1
        if ($j -and $j.State -eq "Completed") {
            $lines = Receive-Job $j
            Remove-Job $j
            foreach ($l in $lines) { Write-BeastLog "$l" }
            $t.Stop()
        } elseif ($attempts -gt 15) {
            $t.Stop()
            Write-BeastLog "Ping timed out." "Red"
        }
    })
    $t.Start()
}

# --- SECURITY & SYSTEM INFO ---
Set-Click "btnBeastProductKey" {
    Write-BeastLog "Reading OEM Windows Product Key from BIOS..."
    try {
        $key = (Get-CimInstance SoftwareLicensingService).OA3xOriginalProductKey
        if ($key) {
            Write-BeastLog "Product Key: $key [OK]"
            Set-Clipboard -Value $key
            Write-BeastLog "Product Key copied to Clipboard!" "Green"
        } else {
            Write-BeastLog "No OEM BIOS key embedded on this motherboard." "Yellow"
        }
    } catch {
        Write-BeastLog "Error reading product key: $($_.Exception.Message)" "Red"
    }
}

Set-Click "btnBeastRestorePoint" {
    if (-not (Test-IsAdmin)) {
        Write-BeastLog "ERROR: Administrative privileges required." "Red"
        return
    }
    Write-BeastLog "Creating System Restore Point 'WinFlexOS_Checkpoint'..."
    Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -Command `"Checkpoint-Computer -Description 'WinFlexOS_Checkpoint' -RestorePointType 'MODIFY_SETTINGS'`"" -WindowStyle Hidden
    Write-BeastLog "Restore Point creation dispatched [OK]"
}

Set-Click "btnBeastTopRAM" {
    Write-BeastLog "--- Top 10 Memory Consuming Processes ---"
    try {
        Get-Process | Sort-Object WorkingSet -Descending | Select-Object -First 10 | ForEach-Object {
            $ramMB = [math]::Round($_.WorkingSet / 1MB, 0)
            Write-BeastLog "$($_.ProcessName) (PID $($_.Id)): ${ramMB} MB"
        }
    } catch {
        Write-BeastLog "Error reading processes." "Red"
    }
}

Set-Click "btnBeastStartup" {
    Write-BeastLog "--- Windows Startup Applications ---"
    try {
        Get-CimInstance Win32_StartupCommand | ForEach-Object {
            Write-BeastLog "$($_.Name) -> $($_.Command)"
        }
    } catch {
        Write-BeastLog "Error querying startup items." "Red"
    }
}

Set-Click "btnBeastUptime" {
    try {
        $os = Get-CimInstance Win32_OperatingSystem
        $up = (Get-Date) - $os.LastBootUpTime
        Write-BeastLog "System Uptime: $($up.Days) days, $($up.Hours) hours, $($up.Minutes) minutes"
    } catch {
        Write-BeastLog "Error querying system uptime." "Red"
    }
}

Set-Click "btnBeastEventLog" {
    if (-not (Test-IsAdmin)) {
        Write-BeastLog "ERROR: Administrative privileges required." "Red"
        return
    }
    Write-BeastLog "Clearing Windows Event Logs..."
    Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -Command `"wevtutil el | ForEach-Object { wevtutil cl `$_ }`"" -WindowStyle Hidden
    Write-BeastLog "Event Logs clear command sent [OK]"
}

# Quick Tool Buttons
Set-Click "btnBeastTaskMgr" { Start-Process "taskmgr.exe" }
Set-Click "btnBeastDevMgr"  { Start-Process "devmgmt.msc" }
Set-Click "btnBeastDiskMgr" { Start-Process "diskmgmt.msc" }
Set-Click "btnBeastRegEdit" { Start-Process "regedit.exe" }
Set-Click "btnBeastNetplwiz" { Start-Process "netplwiz.exe" }
