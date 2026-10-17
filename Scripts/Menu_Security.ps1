# ==============================================================================
# WinFlexOS - Security Center Module
# ==============================================================================

# --- WINDOWS DEFENDER ---
Set-Click "btnDefOpen" {
    try {
        Start-Process "windowsdefender:"
    } catch {
        Start-Process "ms-settings:windowsdefender"
    }
}

Set-Click "btnDefQuickScan" {
    Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -NoExit -Command `"Write-Host 'Starting Windows Defender Quick Scan...' -ForegroundColor Cyan; Start-MpScan -ScanType QuickScan; Write-Host 'Scan Completed.' -ForegroundColor Green; Read-Host 'Press Enter to close'`"" -Verb RunAs
}

Set-Click "btnDefFullScan" {
    Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -NoExit -Command `"Write-Host 'Starting Windows Defender Full Scan...' -ForegroundColor Cyan; Start-MpScan -ScanType FullScan; Write-Host 'Scan Completed.' -ForegroundColor Green; Read-Host 'Press Enter to close'`"" -Verb RunAs
}

Set-Click "btnDefUpdate" {
    Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -NoExit -Command `"Write-Host 'Updating Windows Defender Signatures...' -ForegroundColor Cyan; Update-MpSignature; Write-Host 'Signatures Updated Successfully!' -ForegroundColor Green; Read-Host 'Press Enter to close'`"" -Verb RunAs
}

# --- NETWORK SECURITY ---
Set-Click "btnFwAdv" {
    Start-Process "wf.msc"
}

Set-Click "btnFwReset" {
    $res = [System.Windows.MessageBox]::Show("Reset Windows Firewall to default settings?", "Confirm", [System.Windows.MessageBoxButton]::YesNo, [System.Windows.MessageBoxImage]::Warning)
    if ($res -eq [System.Windows.MessageBoxResult]::Yes) {
        try {
            netsh.exe advfirewall reset | Out-Null
            Show-Toast "Firewall reset to default settings" "success"
        } catch {
            Show-Toast "Requires administrator privileges" "error"
        }
    }
}

Set-Click "btnFlushDNS" {
    ipconfig.exe /flushdns | Out-Null
    Show-Toast "DNS resolver cache flushed successfully" "success"
}

Set-Click "btnRenewIP" {
    Show-Toast "Renewing IP address configuration..." "info"
    Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -Command `"ipconfig /renew`"" -WindowStyle Hidden
}

# --- SYSTEM HARDENING ---
Set-Click "btnUAC" {
    Start-Process "useraccountcontrolsettings.exe"
}

Set-Click "btnUserAccts" {
    Start-Process control.exe "userpasswords2"
}

Set-Click "btnHosts" {
    $hosts = "$env:SystemRoot\System32\drivers\etc\hosts"
    Start-Process "notepad.exe" -ArgumentList "`"$hosts`"" -Verb RunAs
}

Set-Click "btnPrivacy" {
    Start-Process "ms-settings:privacy"
}

# --- TOOLS & HARDWARE SECURITY ---
Set-Click "btnBitLocker" {
    Start-Process control.exe "/name Microsoft.BitLockerDriveEncryption"
}

Set-Click "btnTpm" {
    Start-Process "tpm.msc"
}

# --- FORENSICS & AUDIT ---
Set-Click "btnSecRelMon" {
    Start-Process "perfmon.exe" -ArgumentList "/rel"
}

Set-Click "btnSecResMon" {
    Start-Process "resmon.exe"
}

Set-Click "btnSecMrt" {
    Start-Process "mrt.exe"
}

Set-Click "btnSecEventLogs" {
    Start-Process "eventvwr.msc"
}

# --- POLICIES & ACCESS ---
Set-Click "btnSecLocalPol" {
    try {
        Start-Process "secpol.msc"
    } catch {
        Show-Toast "Local Security Policy (secpol.msc) requires Pro or Enterprise edition" "warning"
    }
}

Set-Click "btnSecCertMgr" {
    Start-Process "certmgr.msc"
}

Set-Click "btnSecCredMgr" {
    Start-Process control.exe "/name Microsoft.CredentialManager"
}

Set-Click "btnSecNetPlWiz" {
    Start-Process "netplwiz.exe"
}
