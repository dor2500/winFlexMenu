# ==============================================================================
# WinFlexOS - Power Management Module
# ==============================================================================

Set-Click "btnShutdown" {
    $res = [System.Windows.MessageBox]::Show(
        $(if ($global:isHebrew) { "$([char]1492)$([char]1488)$([char]1501)$([char]32)$([char]1488)$([char]1514)$([char]1492)$([char]32)$([char]1489)$([char]1496)$([char]1493)$([char]1495)$([char]32)$([char]1513)$([char]1489)$([char]1512)$([char]1510)$([char]1493)$([char]1504)$([char]1498)$([char]32)$([char]1500)$([char]1499)$([char]1489)$([char]1495)$([char]1514)$([char]32)$([char]1488)$([char]1514)$([char]32)$([char]1492)$([char]1502)$([char]1495)$([char]1513)$([char]1489)$([char]63)" } else { "Are you sure you want to shut down this computer?" }),
        "WinFlexOS",
        [System.Windows.MessageBoxButton]::YesNo,
        [System.Windows.MessageBoxImage]::Warning
    )
    if ($res -eq [System.Windows.MessageBoxResult]::Yes) {
        Stop-Computer -Force
    }
}

Set-Click "btnRestart" {
    $res = [System.Windows.MessageBox]::Show(
        $(if ($global:isHebrew) { "$([char]1492)$([char]1488)$([char]1501)$([char]32)$([char]1500)$([char]1489)$([char]1510)$([char]1506)$([char]32)$([char]1492)$([char]1508)$([char]1506)$([char]1500)$([char]1492)$([char]32)$([char]1502)$([char]1495)$([char]1491)$([char]1513)$([char]63)" } else { "Are you sure you want to restart this computer?" }),
        "WinFlexOS",
        [System.Windows.MessageBoxButton]::YesNo,
        [System.Windows.MessageBoxImage]::Question
    )
    if ($res -eq [System.Windows.MessageBoxResult]::Yes) {
        Restart-Computer -Force
    }
}

Set-Click "btnSleep" {
    try {
        [System.Windows.Forms.Application]::SetSuspendState([System.Windows.Forms.PowerState]::Suspend, $false, $false)
    } catch {
        rundll32.exe powrprof.dll,SetSuspendState 0,1,0
    }
}

Set-Click "btnLock" {
    rundll32.exe user32.dll,LockWorkStation
}

Set-Click "btnSignOut" {
    shutdown.exe /l
}

Set-Click "btnHibernate" {
    shutdown.exe /h
}

Set-Click "btnAbortShutdown" {
    shutdown.exe /a
    Show-Toast "Scheduled shutdown cancelled." "success"
}

Set-Click "btnAdvStartup" {
    $res = [System.Windows.MessageBox]::Show(
        $(if ($global:isHebrew) { "$([char]1500)$([char]1492)$([char]1508)$([char]1506)$([char]1497)$([char]1500)$([char]32)$([char]1488)$([char]1514)$([char]32)$([char]1514)$([char]1508)$([char]1512)$([char]1497)$([char]1496)$([char]32)$([char]1492)$([char]1488)$([char]1514)$([char]1495)$([char]1500)$([char]1492)$([char]32)$([char]1492)$([char]1502)$([char]1514)$([char]1511)$([char]1491)$([char]1502)$([char]1514)$([char]63)" } else { "Reboot to Advanced Startup Recovery?" }),
        "WinFlexOS",
        [System.Windows.MessageBoxButton]::YesNo,
        [System.Windows.MessageBoxImage]::Warning
    )
    if ($res -eq [System.Windows.MessageBoxResult]::Yes) {
        shutdown.exe /r /o /t 0
    }
}

Set-Click "btnUEFI" {
    $res = [System.Windows.MessageBox]::Show(
        $(if ($global:isHebrew) { "$([char]1500)$([char]1492)$([char]1508)$([char]1506)$([char]1497)$([char]1500)$([char]32)$([char]1502)$([char]1495)$([char]1491)$([char]1513)$([char]32)$([char]1497)$([char]1513)$([char]1497)$([char]1512)$([char]1493)$([char]1514)$([char]32)$([char]1500)$([char]45)UEFI/BIOS?" } else { "Reboot directly to UEFI BIOS firmware?" }),
        "WinFlexOS",
        [System.Windows.MessageBoxButton]::YesNo,
        [System.Windows.MessageBoxImage]::Warning
    )
    if ($res -eq [System.Windows.MessageBoxResult]::Yes) {
        shutdown.exe /r /fw /t 0
    }
}

Set-Click "btnRemoteMsg" {
    $ipBox = Get-GuiElement "txtRemoteIP"
    $msgBox = Get-GuiElement "txtRemoteMsg"
    $ip = if ($ipBox) { $ipBox.Text.Trim() } else { "" }
    $msg = if ($msgBox) { $msgBox.Text.Trim() } else { "" }
    if (-not $ip) {
        Show-Toast "Please enter a target IP or hostname" "warning"
        return
    }
    if (-not $msg) { $msg = "Message from WinFlexOS Administrator" }
    try {
        Start-Process "msg.exe" -ArgumentList "* /server:$ip `"$msg`"" -NoNewWindow
        Show-Toast "Message sent to $ip" "success"
    } catch {
        Show-Toast "Failed to send message: $($_.Exception.Message)" "error"
    }
}

Set-Click "btnRemoteRestart" {
    $ipBox = Get-GuiElement "txtRemoteIP"
    $msgBox = Get-GuiElement "txtRemoteMsg"
    $ip = if ($ipBox) { $ipBox.Text.Trim() } else { "" }
    $msg = if ($msgBox -and $msgBox.Text.Trim()) { $msgBox.Text.Trim() } else { "Remote restart requested by administrator." }
    if (-not $ip) {
        Show-Toast "Please enter a target IP or hostname" "warning"
        return
    }
    $res = [System.Windows.MessageBox]::Show("Restart remote computer $ip?", "Remote Restart", [System.Windows.MessageBoxButton]::YesNo, [System.Windows.MessageBoxImage]::Warning)
    if ($res -eq [System.Windows.MessageBoxResult]::Yes) {
        try {
            shutdown.exe /r /m "\\$ip" /t 30 /c "$msg"
            Show-Toast "Remote restart command sent to $ip" "success"
        } catch {
            Show-Toast "Error: $($_.Exception.Message)" "error"
        }
    }
}

Set-Click "btnRemoteShutdown" {
    $ipBox = Get-GuiElement "txtRemoteIP"
    $msgBox = Get-GuiElement "txtRemoteMsg"
    $ip = if ($ipBox) { $ipBox.Text.Trim() } else { "" }
    $msg = if ($msgBox -and $msgBox.Text.Trim()) { $msgBox.Text.Trim() } else { "Remote shutdown requested by administrator." }
    if (-not $ip) {
        Show-Toast "Please enter a target IP or hostname" "warning"
        return
    }
    $res = [System.Windows.MessageBox]::Show("Shut down remote computer $ip?", "Remote Shutdown", [System.Windows.MessageBoxButton]::YesNo, [System.Windows.MessageBoxImage]::Warning)
    if ($res -eq [System.Windows.MessageBoxResult]::Yes) {
        try {
            shutdown.exe /s /m "\\$ip" /t 30 /c "$msg"
            Show-Toast "Remote shutdown command sent to $ip" "success"
        } catch {
            Show-Toast "Error: $($_.Exception.Message)" "error"
        }
    }
}
