# ==============================================================================
# WinFlexOS - Tweaks & Themes Module
# ==============================================================================

# --- THEME PRESET SHORTCUTS ---
Set-Click "btnThemeOriginal" {
    $cmb = Get-GuiElement "cmbThemes"
    if ($cmb) { $cmb.SelectedIndex = 1 } # Pitch Black
}

Set-Click "btnThemeTokyo" {
    $cmb = Get-GuiElement "cmbThemes"
    if ($cmb) { $cmb.SelectedIndex = 6 } # Tokyo Night
}

Set-Click "btnThemeCyber" {
    $cmb = Get-GuiElement "cmbThemes"
    if ($cmb) { $cmb.SelectedIndex = 23 } # Cyberpunk 2077
}

Set-Click "btnThemeForest" {
    $cmb = Get-GuiElement "cmbThemes"
    if ($cmb) { $cmb.SelectedIndex = 7 } # Gruvbox / Forest
}

Set-Click "btnThemeNordic" {
    $cmb = Get-GuiElement "cmbThemes"
    if ($cmb) { $cmb.SelectedIndex = 5 } # Nordic Frost
}

Set-Click "btnThemeMario" {
    $cmb = Get-GuiElement "cmbThemes"
    if ($cmb) { $cmb.SelectedIndex = 16 } # Super Mario
}

Set-Click "btnThemePS2" {
    $cmb = Get-GuiElement "cmbThemes"
    if ($cmb) { $cmb.SelectedIndex = 17 } # PlayStation 2
}

Set-Click "btnCustomBg" {
    $dlg = New-Object Microsoft.Win32.OpenFileDialog
    $dlg.Filter = "Image Files (*.jpg;*.jpeg;*.png;*.bmp)|*.jpg;*.jpeg;*.png;*.bmp|All Files (*.*)|*.*"
    $dlg.Title = "Select Custom Background Image"
    if ($dlg.ShowDialog()) {
        $global:customImagePath = $dlg.FileName
        $cmb = Get-GuiElement "cmbThemes"
        if ($cmb) {
            # Select Custom Image theme (last index)
            $cmb.SelectedIndex = $cmb.Items.Count - 1
        }
        Show-Toast "Custom background applied!" "success"
    }
}

# --- TASKBAR & START MENU TWEAKS ---
Set-Click "btnApplyTaskbar" {
    $r = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
    $prop = Get-ItemProperty -Path $r -ErrorAction SilentlyContinue
    $current = if ($prop -and $null -ne $prop.TaskbarAl) { $prop.TaskbarAl } else { 1 }
    $newVal = if ($current -eq 1) { 0 } else { 1 }
    Set-ItemProperty -Path $r -Name "TaskbarAl" -Value $newVal -Force
    Stop-Process -Name explorer -Force
    Show-Toast "Taskbar alignment changed" "success"
}

Set-Click "btnSecondsClock" {
    $r = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
    $prop = Get-ItemProperty -Path $r -ErrorAction SilentlyContinue
    $current = if ($prop -and $null -ne $prop.ShowSecondsInSystemClock) { $prop.ShowSecondsInSystemClock } else { 0 }
    $newVal = if ($current -eq 1) { 0 } else { 1 }
    Set-ItemProperty -Path $r -Name "ShowSecondsInSystemClock" -Value $newVal -Force
    Stop-Process -Name explorer -Force
    Show-Toast "Clock seconds toggled" "success"
}

Set-Click "btnDisableBing" {
    $r = "HKCU:\Software\Policies\Microsoft\Windows\Explorer"
    if (-not (Test-Path $r)) { New-Item -Path $r -Force | Out-Null }
    $prop = Get-ItemProperty -Path $r -ErrorAction SilentlyContinue
    $current = if ($prop -and $null -ne $prop.DisableSearchBoxSuggestions) { $prop.DisableSearchBoxSuggestions } else { 0 }
    $newVal = if ($current -eq 1) { 0 } else { 1 }
    Set-ItemProperty -Path $r -Name "DisableSearchBoxSuggestions" -Value $newVal -Force
    Stop-Process -Name explorer -Force
    Show-Toast "Bing Search Suggestions toggled" "success"
}

# --- FILE EXPLORER TWEAKS ---
Set-Click "btnClassicContext" {
    $key = "HKCU:\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}"
    if (Test-Path $key) {
        Remove-Item -Path $key -Recurse -Force
        Show-Toast "Restored Modern Windows 11 context menu" "info"
    } else {
        $sub = New-Item -Path "$key\InprocServer32" -Force
        Set-ItemProperty -Path $sub.PSPath -Name "(Default)" -Value ""
        Show-Toast "Enabled Classic Windows 10 context menu" "success"
    }
    Stop-Process -Name explorer -Force
}

Set-Click "btnFileExt" {
    $r = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
    $prop = Get-ItemProperty -Path $r -ErrorAction SilentlyContinue
    $current = if ($prop -and $null -ne $prop.HideFileExt) { $prop.HideFileExt } else { 1 }
    $newVal = if ($current -eq 1) { 0 } else { 1 }
    Set-ItemProperty -Path $r -Name "HideFileExt" -Value $newVal -Force
    Stop-Process -Name explorer -Force
    Show-Toast "File extension visibility toggled" "success"
}

Set-Click "btnHiddenFiles" {
    $r = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
    $prop = Get-ItemProperty -Path $r -ErrorAction SilentlyContinue
    $current = if ($prop -and $null -ne $prop.Hidden) { $prop.Hidden } else { 2 }
    $newVal = if ($current -eq 1) { 2 } else { 1 }
    Set-ItemProperty -Path $r -Name "Hidden" -Value $newVal -Force
    Stop-Process -Name explorer -Force
    Show-Toast "Hidden files visibility toggled" "success"
}

Set-Click "btnCompactMode" {
    $r = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
    $prop = Get-ItemProperty -Path $r -ErrorAction SilentlyContinue
    $current = if ($prop -and $null -ne $prop.UseCompactMode) { $prop.UseCompactMode } else { 0 }
    $newVal = if ($current -eq 1) { 0 } else { 1 }
    Set-ItemProperty -Path $r -Name "UseCompactMode" -Value $newVal -Force
    Stop-Process -Name explorer -Force
    Show-Toast "Compact Mode toggled" "success"
}

# --- SYSTEM & VISUALS ---
Set-Click "btnDarkMode" {
    $r = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize"
    $prop = Get-ItemProperty -Path $r -ErrorAction SilentlyContinue
    $current = if ($prop -and $null -ne $prop.AppsUseLightTheme) { $prop.AppsUseLightTheme } else { 0 }
    $newVal = if ($current -eq 1) { 0 } else { 1 }
    Set-ItemProperty -Path $r -Name "AppsUseLightTheme" -Value $newVal -Force
    Set-ItemProperty -Path $r -Name "SystemUsesLightTheme" -Value $newVal -Force
    Show-Toast "Dark/Light Mode toggled" "success"
}

Set-Click "btnGameMode" {
    $r = "HKCU:\Software\Microsoft\GameBar"
    if (-not (Test-Path $r)) { New-Item -Path $r -Force | Out-Null }
    Set-ItemProperty -Path $r -Name "AllowAutoGameMode" -Value 1 -Force
    Set-ItemProperty -Path $r -Name "AutoGameModeEnabled" -Value 1 -Force
    Show-Toast "Windows Game Mode enabled" "success"
}

Set-Click "btnMouseAccel" {
    $r = "HKCU:\Control Panel\Mouse"
    Set-ItemProperty -Path $r -Name "MouseSpeed" -Value "0" -Force
    Set-ItemProperty -Path $r -Name "MouseThreshold1" -Value "0" -Force
    Set-ItemProperty -Path $r -Name "MouseThreshold2" -Value "0" -Force
    Show-Toast "Mouse acceleration disabled (1:1 precision)" "success"
}

Set-Click "btnIconSettings" {
    Start-Process "desk.cpl" -ArgumentList ",,5"
}
