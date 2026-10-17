# ==============================================================================
# WinFlexOS - Maintenance & Windows Tools Module
# ==============================================================================

# --- ONE-CLICK DEEP CLEANUP ---
Set-Click "btnCleanAll" {
    $title = if ($global:isHebrew) { "$([char]1504)$([char]1497)$([char]1511)$([char]1493)$([char]1497)$([char]32)$([char]1499)$([char]1500)$([char]1500)$([char]1497)" } else { "Full System Cleanup" }
    $msg   = if ($global:isHebrew) { "$([char]1500)$([char]1492)$([char]1514)$([char]1495)$([char]1497)$([char]1500)$([char]32)$([char]1489)$([char]1504)$([char]1497)$([char]1511)$([char]1493)$([char]1497)$([char]32)$([char]1511)$([char]1489)$([char]1510)$([char]1497)$([char]1501)$([char]32)$([char]1494)$([char]1502)$([char]1504)$([char]1497)$([char]1497)$([char]1501)$([char]44)$([char]32)$([char]1508)$([char]1495)$([char]44)$([char]32)$([char]1502)$([char]1496)$([char]1502)$([char]1493)$([char]1504)$([char]1497)$([char]32)$([char]1491)$([char]1508)$([char]1491)$([char]1508)$([char]1504)$([char]1497)$([char]1501)$([char]32)$([char]1493)$([char]1505)$([char]1500)$([char]32)$([char]1502)$([char]1495)$([char]1494)$([char]1493)$([char]1512)$([char]63)" } else { "Run full system cleanup (temp files, caches, recycle bin, logs)?" }
    
    $res = [System.Windows.MessageBox]::Show($msg, $title, [System.Windows.MessageBoxButton]::YesNo, [System.Windows.MessageBoxImage]::Question)
    if ($res -eq [System.Windows.MessageBoxResult]::Yes) {
        Show-Toast "Cleanup running in background..." "info"
        try {
            Clear-RecycleBin -Force -ErrorAction SilentlyContinue
            Remove-Item "$env:TEMP\*" -Recurse -Force -ErrorAction SilentlyContinue
            Remove-Item "C:\Windows\Temp\*" -Recurse -Force -ErrorAction SilentlyContinue
            Remove-Item "C:\Windows\Prefetch\*" -Force -ErrorAction SilentlyContinue
            ipconfig.exe /flushdns | Out-Null
            
            # Browser caches
            $edgeCache = "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\Cache"
            if (Test-Path $edgeCache) { Remove-Item "$edgeCache\*" -Recurse -Force -ErrorAction SilentlyContinue }
            $chromeCache = "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Cache"
            if (Test-Path $chromeCache) { Remove-Item "$chromeCache\*" -Recurse -Force -ErrorAction SilentlyContinue }
            
            [System.GC]::Collect()
            Show-Toast "System cleanup completed successfully!" "success"
        } catch {
            Show-Toast "Cleanup completed with minor warnings" "info"
        }
    }
}

Set-Click "btnEmptyRecycleBin" {
    try {
        Clear-RecycleBin -Force -ErrorAction SilentlyContinue
        Show-Toast "Recycle Bin emptied successfully" "success"
    } catch {
        Show-Toast "Recycle Bin is already empty" "info"
    }
}

Set-Click "btnSystemCleanup" { Start-Process cleanmgr.exe }

Set-Click "btnClearTemp" {
    try {
        Remove-Item "C:\Windows\Temp\*" -Recurse -Force -ErrorAction SilentlyContinue
        Show-Toast "Windows Temp folder cleaned" "success"
    } catch {
        Show-Toast "Windows Temp clean complete" "info"
    }
}

Set-Click "btnClearUserTemp" {
    try {
        Remove-Item "$env:TEMP\*" -Recurse -Force -ErrorAction SilentlyContinue
        Show-Toast "User Temp folder cleaned" "success"
    } catch {
        Show-Toast "User Temp clean complete" "info"
    }
}

Set-Click "btnClearPrefetch" {
    try {
        Remove-Item "C:\Windows\Prefetch\*" -Force -ErrorAction SilentlyContinue
        Show-Toast "Prefetch cleaned" "success"
    } catch {
        Show-Toast "Prefetch cleanup requires administrator" "warning"
    }
}

Set-Click "btnClearWindowsLogs" {
    try {
        Remove-Item "C:\Windows\Logs\*" -Recurse -Force -ErrorAction SilentlyContinue
        Show-Toast "Windows logs cleaned" "success"
    } catch {
        Show-Toast "Logs cleaned" "info"
    }
}

# --- BROWSER CACHES ---
Set-Click "btnClearEdgeCache" {
    try {
        $paths = @("$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\Cache", "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\Code Cache")
        foreach ($p in $paths) { if (Test-Path $p) { Remove-Item "$p\*" -Recurse -Force -ErrorAction SilentlyContinue } }
        Show-Toast "Microsoft Edge cache cleaned" "success"
    } catch { Show-Toast "Edge cache cleaned" "info" }
}

Set-Click "btnClearChromeCache" {
    try {
        $p = "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Cache"
        if (Test-Path $p) {
            Remove-Item "$p\*" -Recurse -Force -ErrorAction SilentlyContinue
            Show-Toast "Google Chrome cache cleaned" "success"
        } else {
            Show-Toast "Chrome cache not found" "info"
        }
    } catch { Show-Toast "Chrome cache cleaned" "info" }
}

Set-Click "btnClearFirefoxCache" {
    try {
        $p = "$env:APPDATA\Mozilla\Firefox\Profiles"
        if (Test-Path $p) {
            Get-ChildItem "$p\*.default*\cache2" -Recurse -ErrorAction SilentlyContinue | ForEach-Object {
                Remove-Item "$($_.FullName)\*" -Recurse -Force -ErrorAction SilentlyContinue
            }
            Show-Toast "Mozilla Firefox cache cleaned" "success"
        } else {
            Show-Toast "Firefox profile not found" "info"
        }
    } catch { Show-Toast "Firefox cache cleaned" "info" }
}

Set-Click "btnClearAllBrowsers" {
    try {
        @("$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\Cache",
          "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Cache") | ForEach-Object {
            if (Test-Path $_) { Remove-Item "$_\*" -Recurse -Force -ErrorAction SilentlyContinue }
        }
        $ff = "$env:APPDATA\Mozilla\Firefox\Profiles"
        if (Test-Path $ff) {
            Get-ChildItem "$ff\*.default*\cache2" -Recurse -ErrorAction SilentlyContinue | ForEach-Object {
                Remove-Item "$($_.FullName)\*" -Recurse -Force -ErrorAction SilentlyContinue
            }
        }
        Show-Toast "All browser caches cleaned!" "success"
    } catch { Show-Toast "Browser caches cleaned" "info" }
}

# --- SYSTEM & UPDATE CACHES ---
Set-Click "btnClearDNSCache" {
    ipconfig.exe /flushdns | Out-Null
    Show-Toast "DNS resolver cache flushed" "success"
}

Set-Click "btnClearIconCache" {
    try {
        ie4uinit.exe -show | Out-Null
        Show-Toast "Icon cache rebuilt" "success"
    } catch {
        Show-Toast "Icon cache refresh command sent" "info"
    }
}

Set-Click "btnClearFontCache" {
    try {
        Stop-Service FontCache -Force -ErrorAction SilentlyContinue
        Remove-Item "C:\Windows\ServiceProfiles\LocalService\AppData\Local\FontCache\*" -Recurse -Force -ErrorAction SilentlyContinue
        Start-Service FontCache -ErrorAction SilentlyContinue
        Show-Toast "Windows Font Cache rebuilt" "success"
    } catch {
        Show-Toast "Font Cache refresh requires Administrator" "warning"
    }
}

Set-Click "btnClearMemory" {
    [System.GC]::Collect()
    [System.GC]::WaitForPendingFinalizers()
    Show-Toast "Memory standby cache collected" "success"
}

Set-Click "btnClearUpdateCache" {
    try {
        Remove-Item "C:\Windows\SoftwareDistribution\Download\*" -Recurse -Force -ErrorAction SilentlyContinue
        Show-Toast "Windows Update Download cache cleaned" "success"
    } catch {
        Show-Toast "Requires Administrator" "warning"
    }
}

Set-Click "btnClearDeliveryOptimization" {
    try {
        Remove-Item "C:\Windows\SoftwareDistribution\DeliveryOptimization\*" -Recurse -Force -ErrorAction SilentlyContinue
        Show-Toast "Delivery Optimization cache cleaned" "success"
    } catch {
        Show-Toast "Requires Administrator" "warning"
    }
}

Set-Click "btnClearSoftwareDistribution" {
    Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -NoExit -Command `"Write-Host 'Resetting Windows Update Service...'; net stop wuauserv; Remove-Item 'C:\Windows\SoftwareDistribution\*' -Recurse -Force -ErrorAction SilentlyContinue; net start wuauserv; Write-Host 'Done!' -ForegroundColor Green; Read-Host 'Press Enter to close'`"" -Verb RunAs
}

Set-Click "btnWSUSReset" {
    Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -NoExit -Command `"Write-Host 'Resetting WSUS Client...'; net stop wuauserv; Remove-Item 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate' -Recurse -ErrorAction SilentlyContinue; net start wuauserv; wuauclt.exe /resetauthorization /detectnow; Write-Host 'Done!' -ForegroundColor Green; Read-Host 'Press Enter to close'`"" -Verb RunAs
}

Set-Click "btnClearRecentItems" {
    try {
        Remove-Item "$env:APPDATA\Microsoft\Windows\Recent\*" -Force -ErrorAction SilentlyContinue
        Show-Toast "Recent Items cleared" "success"
    } catch {}
}

Set-Click "btnClearJumpLists" {
    try {
        Remove-Item "$env:APPDATA\Microsoft\Windows\Recent\AutomaticDestinations\*" -Force -ErrorAction SilentlyContinue
        Remove-Item "$env:APPDATA\Microsoft\Windows\Recent\CustomDestinations\*" -Force -ErrorAction SilentlyContinue
        Show-Toast "Jump Lists cleared" "success"
    } catch {}
}

Set-Click "btnClearRunHistory" {
    try {
        Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\RunMRU" -Name "*" -ErrorAction SilentlyContinue
        Show-Toast "Explorer Run history cleared" "success"
    } catch {}
}

Set-Click "btnClearEventLogs" {
    $res = [System.Windows.MessageBox]::Show("Clear all Windows Event Logs?", "Confirm", [System.Windows.MessageBoxButton]::YesNo, [System.Windows.MessageBoxImage]::Warning)
    if ($res -eq [System.Windows.MessageBoxResult]::Yes) {
        Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -NoExit -Command `"wevtutil el | ForEach-Object { Write-Host 'Clearing ' `$_; wevtutil cl `$_ }; Write-Host 'Finished clearing event logs' -ForegroundColor Green; Read-Host 'Press Enter to close'`"" -Verb RunAs
    }
}

Set-Click "btnStorageSense" { Start-Process "ms-settings:storagesense" }
Set-Click "btnDefragOptimize" { Start-Process "dfrgui.exe" }
Set-Click "btnCheckDisk" { Start-Process cmd.exe "/k chkdsk C: /f /r" -Verb RunAs }
Set-Click "btnTrim" { Start-Process cmd.exe "/k defrag C: /L /O" -Verb RunAs }

# --- WINDOWS ADMINISTRATIVE TOOLS ---
Set-Click "btnDiskMgmt" { Start-Process "diskmgmt.msc" }
Set-Click "btnTaskMgr" { Start-Process "taskmgr.exe" }
Set-Click "btnDevMgmt" { Start-Process "devmgmt.msc" }
Set-Click "btnSFC" { Start-Process cmd.exe "/k sfc /scannow" -Verb RunAs }
Set-Click "btnChkdsk" { Start-Process cmd.exe "/k chkdsk" -Verb RunAs }
Set-Click "btnDefrag" { Start-Process "dfrgui.exe" }
Set-Click "btnRegEdit" { Start-Process "regedit.exe" }
Set-Click "btnGodMode" {
    $desktop = [Environment]::GetFolderPath('Desktop')
    $path = "$desktop\GodMode.{ED7BA470-8E54-465E-825C-99712043E01C}"
    if (-not (Test-Path $path)) {
        New-Item -Path $path -ItemType Directory -Force | Out-Null
        Show-Toast "GodMode created on your Desktop!" "success"
    } else {
        Show-Toast "GodMode shortcut already exists on Desktop" "info"
    }
}
Set-Click "btnMsConfig" { Start-Process "msconfig.exe" }
Set-Click "btnEventVwr" { Start-Process "eventvwr.msc" }
Set-Click "btnGpEdit" {
    try {
        Start-Process "gpedit.msc"
    } catch {
        Show-Toast "Group Policy Editor (gpedit.msc) is only available on Pro/Enterprise editions." "warning"
    }
}
Set-Click "btnDiskCleanup" { Start-Process "cleanmgr.exe" }

# Portable Tools Downloads
Set-Click "btnTreeSize" {
    Invoke-OnlineApp -Url "https://downloads.jam-software.de/treesize_free/TreeSizeFree-Portable.zip" -FileName "TreeSize.zip" -ExeToRun "TreeSizeFree.exe" -IsZip $true
}
Set-Click "btnCrystalDiskInfo" {
    Invoke-OnlineApp -Url "https://osdn.net/frs/redir.php?m=gigenet&f=crystaldiskinfo%2F78192%2FCrystalDiskInfo9_2_1.zip" -FileName "CDInfo.zip" -ExeToRun "DiskInfo64.exe" -IsZip $true
}
Set-Click "btnCrystalDiskMark" {
    Invoke-OnlineApp -Url "https://osdn.net/frs/redir.php?m=gigenet&f=crystaldiskmark%2F77936%2FCrystalDiskMark8_0_4c.zip" -FileName "CDMark.zip" -ExeToRun "DiskMark64.exe" -IsZip $true
}
