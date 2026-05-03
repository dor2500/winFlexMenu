# GAMING CENTER - Fully Embedded (no external file dependency)
# ==============================================================================
Set-Click "btnGameCenter" { Switch-Panel $pnlGaming }
Set-Click "btnThemeXP" { $cmbThemes.SelectedIndex = 18 }
Set-Click "btnThemeVista7" { $cmbThemes.SelectedIndex = 19 }
Set-Click "btnThemeXboxOG" { $cmbThemes.SelectedIndex = 20 }
Set-Click "btnThemeXbox360" { $cmbThemes.SelectedIndex = 21 }



function Get-GExeIcon($exePath) {
    try {
        if ($exePath -and (Test-Path $exePath) -and $exePath -match '\.exe$') {
            $ico = [System.Drawing.Icon]::ExtractAssociatedIcon($exePath)
            if ($ico) {
                $bmp  = $ico.ToBitmap()
                $hBmp = $bmp.GetHbitmap()
                $src  = [System.Windows.Interop.Imaging]::CreateBitmapSourceFromHBitmap(
                            $hBmp, [IntPtr]::Zero, [System.Windows.Int32Rect]::Empty,
                            [System.Windows.Media.Imaging.BitmapSizeOptions]::FromEmptyOptions())
                [System.Runtime.InteropServices.Marshal]::DeleteObject($hBmp) | Out-Null
                $ico.Dispose(); $bmp.Dispose()
                return $src
            }
        }
    } catch {}
    return $null
}

function Get-GPlatformBrush($p) {
    $hex = switch ($p) {
        'Steam'   { '#1b9fd6' } 'Epic'  { '#c6752e' } 'GOG'  { '#8b5cf6' }
        'EA'      { '#f97316' } 'Ubisoft'{ '#60a5fa' } 'Xbox/MS'{ '#1db87e' }
        default   { '#6b7280' }
    }
    return New-Object System.Windows.Media.SolidColorBrush(
        [System.Windows.Media.ColorConverter]::ConvertFromString($hex))
}

function Launch-GApp($paths) {
    $f = $paths | Where-Object { Test-Path $_ } | Select-Object -First 1
    if ($f) { Start-Process $f } else { Show-Toast "App not installed on this PC" -Type "warning" }
}

# Launchers
Set-Click "btnGSteam"     { Launch-GApp @("$env:ProgramFiles\Steam\steam.exe","${env:ProgramFiles(x86)}\Steam\steam.exe") }
Set-Click "btnGEpic"      { Launch-GApp @("$env:ProgramData\Epic\EpicGamesLauncher\Portal\Binaries\Win64\EpicGamesLauncher.exe","${env:ProgramFiles(x86)}\Epic Games\Launcher\Portal\Binaries\Win64\EpicGamesLauncher.exe") }
Set-Click "btnGGOG"       { Launch-GApp @("$env:ProgramFiles\GOG Galaxy\GalaxyClient.exe","${env:ProgramFiles(x86)}\GOG Galaxy\GalaxyClient.exe") }
Set-Click "btnGEA"        { Launch-GApp @("$env:ProgramFiles\Electronic Arts\EA Desktop\EA Desktop\EADesktop.exe","${env:ProgramFiles(x86)}\Origin\Origin.exe") }
Set-Click "btnGUbisoft"   { Launch-GApp @("$env:ProgramFiles\Ubisoft\Ubisoft Game Launcher\UbisoftConnect.exe","${env:ProgramFiles(x86)}\Ubisoft\Ubisoft Game Launcher\UbisoftConnect.exe") }
Set-Click "btnGBattleNet" { Launch-GApp @("$env:ProgramFiles\Battle.net\Battle.net.exe","${env:ProgramFiles(x86)}\Battle.net\Battle.net.exe") }
Set-Click "btnGXbox"      { try { Start-Process "shell:AppsFolder\Microsoft.GamingApp_8wekyb3d8bbwe!Microsoft.Xbox.App" -EA Stop } catch { Show-Toast "Xbox App not installed" -Type "warning" } }

# GPU
Set-Click "btnGNvidiaCP"  { Launch-GApp @("$env:SystemRoot\System32\nvcplui.exe","$env:ProgramFiles\NVIDIA Corporation\Control Panel Client\nvcplui.exe") }
Set-Click "btnGGeForce"   { Launch-GApp @("$env:ProgramFiles\NVIDIA Corporation\NVIDIA GeForce Experience\NVIDIA GeForce Experience.exe") }
Set-Click "btnGAMD"       { Launch-GApp @("$env:ProgramFiles\AMD\CNext\CNext\RadeonSoftware.exe","${env:ProgramFiles(x86)}\AMD\CNext\CNext\RadeonSoftware.exe") }
Set-Click "btnGIntelArc"  { Launch-GApp @("$env:ProgramFiles\Intel\Intel(R) Arc Control\arc-control.exe") }
Set-Click "btnGMSIAB"     { Launch-GApp @("$env:ProgramFiles\MSI Afterburner\MSIAfterburner.exe","${env:ProgramFiles(x86)}\MSI Afterburner\MSIAfterburner.exe") }

# Optimization
Set-Click "btnGGameMode" {
    try { Set-ItemProperty "HKCU:\Software\Microsoft\GameBar" "AutoGameModeEnabled" 1 -Force; Show-Toast "Game Mode enabled" -Type "success" }
    catch { Show-Toast "Error: $($_.Exception.Message)" -Type "error" }
}
Set-Click "btnGMaxPerf" {
    try { $o=& powercfg /duplicatescheme e9a42b02-d5df-448d-aa00-03f14749eb61 2>&1; $g=([regex]"[0-9a-f-]{36}").Match("$o").Value; if($g){& powercfg /setactive $g|Out-Null}; Show-Toast "Ultimate Performance activated" -Type "success" }
    catch { Show-Toast "Error: $($_.Exception.Message)" -Type "error" }
}
Set-Click "btnGNoXbox" {
    try { Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\GameDVR" "AppCaptureEnabled" 0 -Force; Show-Toast "Xbox Bar disabled" -Type "success" }
    catch { Show-Toast "Error" -Type "error" }
}
Set-Click "btnGKillBG" {
    $k=0; @("OneDrive","Teams","Spotify","Discord","Slack","chrome","msedge") | ForEach-Object { Get-Process $_ -EA SilentlyContinue | ForEach-Object { try{$_.Kill();$k++}catch{} } }
    Show-Toast "Stopped $k background processes" -Type "success"
}
Set-Click "btnGFlushRAM" {
    [GC]::Collect(2,[GCCollectionMode]::Forced,$true,$true); [GC]::WaitForPendingFinalizers()
    Show-Toast "RAM cache flushed" -Type "success"
}
Set-Click "btnGHAGS" {
    try { Set-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" "HwSchMode" 2 -Type DWord -Force; Show-Toast "HAGS enabled - restart to apply" -Type "success" }
    catch { Show-Toast "Error (requires admin)" -Type "error" }
}

# Game data
$script:gGames = [System.Collections.Generic.List[PSCustomObject]]::new()
$script:gCacheFile = "$PSScriptRoot\games_cache.json"

function Scan-GamesNow {
    $script:gGames.Clear()
    $countLbl = Get-GuiElement "lblGGameCount"
    $scanLbl  = Get-GuiElement "lblGLastScan"
    if ($countLbl) { $countLbl.Text = "Scanning..." }

    function AddG($n,$p,$e) {
        $script:gGames.Add([PSCustomObject]@{
            Name          = $n.Trim()
            Platform      = $p
            ExePath       = $e
            Icon          = Get-GExeIcon $e
            PlatformBrush = Get-GPlatformBrush $p
        }) | Out-Null
    }

    # Steam
    try {
        $sr = @("HKLM:\SOFTWARE\Valve\Steam","HKLM:\SOFTWARE\WOW6432Node\Valve\Steam") | Where-Object { Test-Path $_ } | Select-Object -First 1
        if ($sr) {
            $sp = (Get-ItemProperty $sr).InstallPath; $libs = @($sp)
            $lf = "$sp\steamapps\libraryfolders.vdf"
            if (Test-Path $lf) { Get-Content $lf | Select-String '"path"' | ForEach-Object { $l=($_ -replace '.*"path"\s+"(.+)".*','$1').Trim(); if(Test-Path $l){$libs+=$l} } }
            foreach ($lib in $libs) {
                Get-ChildItem "$lib\steamapps" -Filter "appmanifest_*.acf" -EA SilentlyContinue | ForEach-Object {
                    $c = Get-Content $_.FullName -Raw -EA SilentlyContinue
                    $n = $(if ($c -match '"name"\s+"([^"]+)"') { $Matches[1] } else { "Unknown Steam Game" })
                    $d = $(if ($c -match '"installdir"\s+"([^"]+)"') { $Matches[1] } else { "" })
                    $gp = "$lib\steamapps\common\$d"
                    $exe = Get-ChildItem $gp -Filter "*.exe" -Depth 1 -EA SilentlyContinue | Where-Object { $_.Name -notmatch "unins|setup|crash|redist" } | Sort-Object Length -Descending | Select-Object -First 1
                    AddG $n "Steam" ($(if ($exe) { $exe.FullName } else { $gp }))
                }
            }

        }
    } catch {}

    # Epic
    try {
        $ed = @("$env:ProgramData\Epic\EpicGamesLauncher\Data\Manifests","${env:ProgramFiles(x86)}\Epic Games\Launcher\Data\Manifests") | Where-Object { Test-Path $_ } | Select-Object -First 1
        if ($ed) { Get-ChildItem $ed -Filter "*.item" -EA SilentlyContinue | ForEach-Object { try { $j=Get-Content $_.FullName -Raw|ConvertFrom-Json; if($j.DisplayName -and $j.bIsIncompleteInstall -ne $true){ $ep=if($j.InstallLocation){Join-Path $j.InstallLocation $j.LaunchExecutable}else{$j.LaunchExecutable}; AddG $j.DisplayName "Epic" $ep } } catch {} } }
    } catch {}

    # GOG
    try {
        if (Test-Path "HKLM:\SOFTWARE\WOW6432Node\GOG.com\Games") {
            Get-ChildItem "HKLM:\SOFTWARE\WOW6432Node\GOG.com\Games" -EA SilentlyContinue | ForEach-Object { $p=Get-ItemProperty $_.PSPath -EA SilentlyContinue; if($p.GAMENAME -and $p.exe){AddG $p.GAMENAME "GOG" $p.exe} }
        }
    } catch {}

    # Ubisoft
    try {
        if (Test-Path "HKLM:\SOFTWARE\WOW6432Node\Ubisoft\Launcher\Installs") {
            Get-ChildItem "HKLM:\SOFTWARE\WOW6432Node\Ubisoft\Launcher\Installs" -EA SilentlyContinue | ForEach-Object {
                $p=Get-ItemProperty $_.PSPath -EA SilentlyContinue
                if($p.InstallDir -and (Test-Path $p.InstallDir)){ $exe=Get-ChildItem $p.InstallDir -Filter "*.exe" -EA SilentlyContinue|Where-Object{$_.Name -notmatch "unins|crash"}|Select-Object -First 1; AddG (Split-Path $p.InstallDir -Leaf) "Ubisoft" ($(if ($exe){$exe.FullName}else{$p.InstallDir})) }
            }
        }
    } catch {}

    # EA
    try {
        if (Test-Path "HKLM:\SOFTWARE\WOW6432Node\EA Games") {
            Get-ChildItem "HKLM:\SOFTWARE\WOW6432Node\EA Games" -EA SilentlyContinue | ForEach-Object {
                $p=Get-ItemProperty $_.PSPath -EA SilentlyContinue
                if($p.Install_Dir -and (Test-Path $p.Install_Dir)){ $exe=Get-ChildItem $p.Install_Dir -Filter "*.exe" -EA SilentlyContinue|Select-Object -First 1; AddG $_.PSChildName "EA" ($(if ($exe){$exe.FullName}else{$p.Install_Dir})) }
            }
        }
    } catch {}

    # Xbox / Game Pass (third-party only + C:\XboxGames)
    try {
        $skipG = 'Extension|LanguagePack|LanguageExperience|VCLibs|Runtime|Framework|Handwriting|InputMethod|AccountsControl|Wallet|ConnectivityStore|StorePurchaseApp|WindowsStore|AppInstaller|WebView|Enhancer'
        Get-AppxPackage -EA SilentlyContinue | Where-Object {
            $_.SignatureKind -eq "Store" -and $_.Name -notmatch '^Microsoft\.' -and $_.Name -notmatch $skipG -and
            $_.InstallLocation -and (Test-Path $_.InstallLocation) -and
            (Get-ChildItem $_.InstallLocation -Filter "*.exe" -Depth 2 -EA SilentlyContinue | Where-Object { $_.Name -notmatch "unins|crash|setup|appinstaller|winstore" } | Select-Object -First 1)
        } | ForEach-Object {
            $exe=Get-ChildItem $_.InstallLocation -Filter "*.exe" -Depth 2 -EA SilentlyContinue|Where-Object{$_.Name -notmatch "unins|crash|setup"}|Select-Object -First 1
            AddG ($_.Name -replace '^\w+\.','').Trim() "Xbox/MS" ($(if ($exe){$exe.FullName}else{$_.InstallLocation}))
        }
    } catch {}
    try {
        if (Test-Path "C:\XboxGames") {
            Get-ChildItem "C:\XboxGames" -Directory -EA SilentlyContinue | ForEach-Object {
                $exe=Get-ChildItem $_.FullName -Filter "*.exe" -Depth 3 -EA SilentlyContinue|Where-Object{$_.Name -notmatch "unins|crash|setup|redist"}|Sort-Object Length -Descending|Select-Object -First 1
                if($exe){AddG $_.Name "Xbox/MS" $exe.FullName}
            }
        }
    } catch {}

    # Save cache (without Icon - not serializable)
    try {
        $script:gGames | Select-Object Name,Platform,ExePath | ConvertTo-Json -Depth 2 | Set-Content $script:gCacheFile -Encoding UTF8
    } catch {}

    Refresh-GList
    $total = $script:gGames.Count
    if ($countLbl) { $countLbl.Text = "$total games found" }
    if ($scanLbl)  { $scanLbl.Text  = "Last scan: $(Get-Date -Format 'dd/MM/yyyy HH:mm')" }

    # Show only installed GPU/launchers
    function Vis($name,[bool]$show){ $el=Get-GuiElement $name; if($el){$el.Visibility=if($show){"Visible"}else{"Collapsed"}} }
    function HasApp($paths){ $paths|Where-Object{Test-Path $_}|Select-Object -First 1 }
    Vis "btnGSteam"     (!!(HasApp @("$env:ProgramFiles\Steam\steam.exe","${env:ProgramFiles(x86)}\Steam\steam.exe")))
    Vis "btnGEpic"      (!!(HasApp @("$env:ProgramData\Epic\EpicGamesLauncher\Portal\Binaries\Win64\EpicGamesLauncher.exe","${env:ProgramFiles(x86)}\Epic Games\Launcher\Portal\Binaries\Win64\EpicGamesLauncher.exe")))
    Vis "btnGGOG"       (!!(HasApp @("$env:ProgramFiles\GOG Galaxy\GalaxyClient.exe","${env:ProgramFiles(x86)}\GOG Galaxy\GalaxyClient.exe")))
    Vis "btnGEA"        (!!(HasApp @("$env:ProgramFiles\Electronic Arts\EA Desktop\EA Desktop\EADesktop.exe","${env:ProgramFiles(x86)}\Origin\Origin.exe")))
    Vis "btnGUbisoft"   (!!(HasApp @("$env:ProgramFiles\Ubisoft\Ubisoft Game Launcher\UbisoftConnect.exe","${env:ProgramFiles(x86)}\Ubisoft\Ubisoft Game Launcher\UbisoftConnect.exe")))
    Vis "btnGBattleNet" (!!(HasApp @("$env:ProgramFiles\Battle.net\Battle.net.exe","${env:ProgramFiles(x86)}\Battle.net\Battle.net.exe")))
    Vis "btnGNvidiaCP"  (!!(HasApp @("$env:SystemRoot\System32\nvcplui.exe","$env:ProgramFiles\NVIDIA Corporation\Control Panel Client\nvcplui.exe")))
    Vis "btnGGeForce"   (!!(HasApp @("$env:ProgramFiles\NVIDIA Corporation\NVIDIA GeForce Experience\NVIDIA GeForce Experience.exe")))
    Vis "btnGAMD"       (!!(HasApp @("$env:ProgramFiles\AMD\CNext\CNext\RadeonSoftware.exe","${env:ProgramFiles(x86)}\AMD\CNext\CNext\RadeonSoftware.exe")))
    Vis "btnGIntelArc"  (!!(HasApp @("$env:ProgramFiles\Intel\Intel(R) Arc Control\arc-control.exe")))
    Vis "btnGMSIAB"     (!!(HasApp @("$env:ProgramFiles\MSI Afterburner\MSIAfterburner.exe","${env:ProgramFiles(x86)}\MSI Afterburner\MSIAfterburner.exe")))
}

function Refresh-GList {
    $lst = Get-GuiElement "lstGGames"; if (-not $lst) { return }
    $q  = (Get-GuiElement "txtGSearch").Text.Trim()
    $pf = (Get-GuiElement "cmbGFilter").SelectedItem.Content
    $lst.Items.Clear()
    $script:gGames | Where-Object {
        ($q -eq "" -or $_.Name -like "*$q*") -and ($pf -eq "All" -or $_.Platform -eq $pf)
    } | Sort-Object Platform,Name | ForEach-Object { [void]$lst.Items.Add($_) }
}

$s = Get-GuiElement "txtGSearch"; if ($s) { $s.Add_TextChanged({ Refresh-GList }) }
$f = Get-GuiElement "cmbGFilter"; if ($f) { $f.Add_SelectionChanged({ Refresh-GList }) }

Set-Click "btnGScan"   { Scan-GamesNow }
Set-Click "btnGRescan" { Scan-GamesNow }
Set-Click "btnGLaunch" {
    $sel = (Get-GuiElement "lstGGames").SelectedItem
    if ($sel -and $sel.ExePath -and (Test-Path $sel.ExePath)) { Start-Process $sel.ExePath }
    elseif ($sel) { Show-Toast "EXE not found for this game" -Type "warning" }
    else { Show-Toast "Select a game from the list first" -Type "info" }
}

Set-Click "btnGAddManual" {
    $dlg = New-Object System.Windows.Forms.OpenFileDialog
    $dlg.Filter = "Executable Files (*.exe)|*.exe"
    $dlg.Title = "Select Game Executable"
    if ($dlg.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        $exe = $dlg.FileName
        $name = [System.IO.Path]::GetFileNameWithoutExtension($exe)
        
        # Ask for a friendly name (optional, basic prompt via inputbox)
        [void][System.Reflection.Assembly]::LoadWithPartialName('Microsoft.VisualBasic')
        $inputName = [Microsoft.VisualBasic.Interaction]::InputBox("Enter game name:", "Add Custom Game", $name)
        if ($inputName) { $name = $inputName }

        $script:gGames.Add([PSCustomObject]@{
            Name          = $name.Trim()
            Platform      = "Custom"
            ExePath       = $exe
            Icon          = Get-GExeIcon $exe
            PlatformBrush = Get-GPlatformBrush "Custom"
        }) | Out-Null
        
        # Save cache
        try {
            $script:gGames | Select-Object Name,Platform,ExePath | ConvertTo-Json -Depth 2 | Set-Content $script:gCacheFile -Encoding UTF8
        } catch {}

        Refresh-GList
        $countLbl = Get-GuiElement "lblGGameCount"
        if ($countLbl) { $countLbl.Text = "$($script:gGames.Count) games found" }
        Show-Toast "$name added to library!" -Type "success"
    }
}

# Load cache on panel open, scan if none
if (Test-Path $script:gCacheFile) {
    try {
        $cached = Get-Content $script:gCacheFile -Raw | ConvertFrom-Json
        foreach ($g in $cached) {
            $script:gGames.Add([PSCustomObject]@{
                Name=($g.Name);Platform=($g.Platform);ExePath=($g.ExePath)
                Icon=(Get-GExeIcon $g.ExePath);PlatformBrush=(Get-GPlatformBrush $g.Platform)
            }) | Out-Null
        }
        Refresh-GList
        $lbl = Get-GuiElement "lblGGameCount"; if($lbl){$lbl.Text="$($script:gGames.Count) games (cached)"}
        $ls  = Get-GuiElement "lblGLastScan";  if($ls){$ls.Text="Click Rescan to refresh"}
    } catch {}
}

