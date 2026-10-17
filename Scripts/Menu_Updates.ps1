# ==============================================================================
# WinFlexOS - Windows Update Manager Module
# ==============================================================================

function Refresh-UpdateHistory {
    $lst = Get-GuiElement "lstUpdateHistory"
    if (-not $lst) { return }
    $lst.Items.Clear()
    $lst.Items.Add("Loading recent updates...") | Out-Null

    Start-Job -ScriptBlock {
        try {
            $session = New-Object -ComObject Microsoft.Update.Session
            $searcher = $session.CreateUpdateSearcher()
            $historyCount = $searcher.GetTotalHistoryCount()
            $take = [math]::Min(10, $historyCount)
            if ($take -gt 0) {
                return @($searcher.QueryHistory(0, $take) | ForEach-Object {
                    $date = $_.Date.ToString("yyyy-MM-dd")
                    $title = $_.Title
                    "$date - $title"
                })
            } else {
                return @("No installed updates found.")
            }
        } catch {
            try {
                return @(Get-HotFix | Sort-Object InstalledOn -Descending | Select-Object -First 10 | ForEach-Object {
                    "$($_.InstalledOn.ToString('yyyy-MM-dd')) - $($_.HotFixID): $($_.Description)"
                })
            } catch {
                return @("Could not query update history.")
            }
        }
    } | Out-Null

    $t = New-Object System.Windows.Threading.DispatcherTimer
    $t.Interval = [TimeSpan]::FromMilliseconds(500)
    $attempts = 0
    $t.Add_Tick({
        $attempts++
        $j = Get-Job | Where-Object { $_.Command -like "*Microsoft.Update.Session*" } | Select-Object -Last 1
        if ($j -and $j.State -eq "Completed") {
            $lines = Receive-Job $j
            Remove-Job $j
            $lst.Items.Clear()
            foreach ($l in $lines) { [void]$lst.Items.Add($l) }
            $t.Stop()
        } elseif ($attempts -gt 20) {
            $lst.Items.Clear()
            $lst.Items.Add("Update history query timed out.") | Out-Null
            $t.Stop()
        }
    })
    $t.Start()
}

Set-Click "btnRefreshHistory" {
    Refresh-UpdateHistory
}

# Auto-load history when selecting an item to populate the KB box
$lstHistory = Get-GuiElement "lstUpdateHistory"
if ($lstHistory) {
    $lstHistory.Add_SelectionChanged({
        if ($lstHistory.SelectedItem) {
            $txt = $lstHistory.SelectedItem.ToString()
            if ($txt -match "(KB\d+)") {
                $box = Get-GuiElement "txtKBID"
                if ($box) { $box.Text = $Matches[1] }
            }
        }
    })
}

Set-Click "btnAnalyzeUpdate" {
    $kbBox = Get-GuiElement "txtKBID"
    $repBox = Get-GuiElement "txtAnalysisReport"
    $kb = if ($kbBox) { $kbBox.Text.Trim() } else { "" }
    if (-not $kb) {
        Show-Toast "Please enter a KB ID (e.g. KB5034441)" "warning"
        return
    }
    if ($repBox) { $repBox.Text = "Searching Microsoft Update Catalog for $kb..." }

    Start-Job -ScriptBlock {
        param($kbId)
        try {
            $url = "https://www.catalog.update.microsoft.com/Search.aspx?q=$kbId"
            $resp = Invoke-WebRequest -Uri $url -UseBasicParsing -TimeoutSec 10
            if ($resp.Content -match $kbId) {
                return "OK: Found in official Microsoft Update Catalog.`nSource: $url`nStatus: Verified Microsoft Update Package."
            } else {
                return "Notice: Update $kbId was not found in the online Catalog, or query was blocked."
            }
        } catch {
            return "Analysis check completed (Offline or Catalog unreachable: $($_.Exception.Message))"
        }
    } -ArgumentList $kb | Out-Null

    $t = New-Object System.Windows.Threading.DispatcherTimer
    $t.Interval = [TimeSpan]::FromMilliseconds(500)
    $attempts = 0
    $t.Add_Tick({
        $attempts++
        $j = Get-Job | Where-Object { $_.Command -like "*catalog.update.microsoft.com*" } | Select-Object -Last 1
        if ($j -and $j.State -eq "Completed") {
            $result = Receive-Job $j
            Remove-Job $j
            if ($repBox) { $repBox.Text = $result }
            $t.Stop()
        } elseif ($attempts -gt 15) {
            if ($repBox) { $repBox.Text = "Catalog query timed out." }
            $t.Stop()
        }
    })
    $t.Start()
}

Set-Click "btnUninstallUpdate" {
    $kbBox = Get-GuiElement "txtKBID"
    $kb = if ($kbBox) { $kbBox.Text.Trim() } else { "" }
    if (-not $kb) {
        Show-Toast "Please enter a KB ID to uninstall" "warning"
        return
    }
    $cleanKb = $kb -replace "[^\d]", ""
    $res = [System.Windows.MessageBox]::Show("Are you sure you want to uninstall update KB$cleanKb?", "Confirm Uninstall", [System.Windows.MessageBoxButton]::YesNo, [System.Windows.MessageBoxImage]::Warning)
    if ($res -eq [System.Windows.MessageBoxResult]::Yes) {
        Start-Process "wusa.exe" -ArgumentList "/uninstall /kb:$cleanKb"
    }
}

Set-Click "btnCheckOSUpdates" {
    $txt = Get-GuiElement "txtOSUpdates"
    if ($txt) { $txt.Text = "Checking for available Windows Updates (this may take up to a minute)..." }
    
    Start-Job -ScriptBlock {
        try {
            $updateSession = New-Object -ComObject Microsoft.Update.Session
            $searcher = $updateSession.CreateUpdateSearcher()
            $searchResult = $searcher.Search("IsInstalled=0 and Type='Software' and IsHidden=0")
            if ($searchResult.Updates.Count -eq 0) {
                return "Your system is up to date! No pending Windows Updates."
            } else {
                $res = "Found $($searchResult.Updates.Count) available updates:`n`n"
                foreach ($u in $searchResult.Updates) {
                    $res += " - $($u.Title)`n"
                }
                return $res
            }
        } catch {
            return "Could not check for updates: $($_.Exception.Message)"
        }
    } | Out-Null

    $t = New-Object System.Windows.Threading.DispatcherTimer
    $t.Interval = [TimeSpan]::FromSeconds(1)
    $attempts = 0
    $t.Add_Tick({
        $attempts++
        $j = Get-Job | Where-Object { $_.Command -like "*IsInstalled=0*" } | Select-Object -Last 1
        if ($j -and $j.State -eq "Completed") {
            $msg = Receive-Job $j
            Remove-Job $j
            if ($txt) { $txt.Text = $msg }
            $t.Stop()
        } elseif ($attempts -gt 60) {
            if ($txt) { $txt.Text = "Windows Update search timed out." }
            $t.Stop()
        }
    })
    $t.Start()
}

Set-Click "btnCheckAppUpdates" {
    $txt = Get-GuiElement "txtAppUpdates"
    if ($txt) { $txt.Text = "Running 'winget upgrade' check in background..." }
    
    Start-Job -ScriptBlock {
        try {
            $out = winget.exe upgrade --include-unknown 2>&1 | Out-String
            if ($out -match "No installed package found" -or $out -match "No applicable update found") {
                return "All installed Winget packages are up to date!"
            } else {
                return $out.Trim()
            }
        } catch {
            return "Winget command failed: $($_.Exception.Message)"
        }
    } | Out-Null

    $t = New-Object System.Windows.Threading.DispatcherTimer
    $t.Interval = [TimeSpan]::FromSeconds(1)
    $attempts = 0
    $t.Add_Tick({
        $attempts++
        $j = Get-Job | Where-Object { $_.Command -like "*winget.exe upgrade*" } | Select-Object -Last 1
        if ($j -and $j.State -eq "Completed") {
            $msg = Receive-Job $j
            Remove-Job $j
            if ($txt) { $txt.Text = $msg }
            $t.Stop()
        } elseif ($attempts -gt 45) {
            if ($txt) { $txt.Text = "Winget check timed out." }
            $t.Stop()
        }
    })
    $t.Start()
}

Set-Click "btnOpenWinUpdateSettings" {
    Start-Process "ms-settings:windowsupdate"
}
