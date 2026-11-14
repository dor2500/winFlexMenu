if (-not $global:LibPath) { $global:LibPath = "C:\MENU\Lib" }

function Install-WebView2-Libs {
    try {
        if (-not (Test-Path $global:LibPath)) { New-Item -ItemType Directory -Force -Path $global:LibPath | Out-Null }
        $dllPath = "$global:LibPath\Microsoft.Web.WebView2.Wpf.dll"
        $corePath = "$global:LibPath\Microsoft.Web.WebView2.Core.dll"
        if ((Test-Path $dllPath) -and (Test-Path $corePath)) { return $true }
        
        $url = "https://www.nuget.org/api/v2/package/Microsoft.Web.WebView2/1.0.2903.40"
        $zipPath = "$global:LibPath\webview2.zip"
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        Invoke-WebRequest -Uri $url -OutFile $zipPath -TimeoutSec 30 -UseBasicParsing
        $shell = New-Object -ComObject Shell.Application
        $zip = $shell.NameSpace($zipPath)
        $wpfSource = $zip.Items() | Where-Object { $_.Path -like "*lib/net462/Microsoft.Web.WebView2.Wpf.dll" }
        if ($wpfSource) { $shell.NameSpace($global:LibPath).CopyHere($wpfSource, 16) }
        $coreSource = $zip.Items() | Where-Object { $_.Path -like "*lib/net462/Microsoft.Web.WebView2.Core.dll" }
        if ($coreSource) { $shell.NameSpace($global:LibPath).CopyHere($coreSource, 16) }
        Remove-Item $zipPath -Force
        return ((Test-Path $dllPath) -and (Test-Path $corePath))
    } catch { return $false }
}

function Load-IsraelTV-Dependencies {
    try {
        if (Install-WebView2-Libs) {
            [System.Reflection.Assembly]::LoadFrom("$global:LibPath\Microsoft.Web.WebView2.Wpf.dll") | Out-Null
            [System.Reflection.Assembly]::LoadFrom("$global:LibPath\Microsoft.Web.WebView2.Core.dll") | Out-Null
            $global:UseWebView2 = $true
            return
        }
        # Fallback: Search for trusted System DLLs (GIGABYTE, Logi, etc.)
        $candidates = @(
            "C:\Program Files\GIGABYTE\Control Center\Microsoft.Web.WebView2.Wpf.dll",
            "C:\Program Files\Logi\LogiPluginService\Microsoft.Web.WebView2.Wpf.dll",
            "C:\Program Files\Devolutions\Remote Desktop Manager\Microsoft.Web.WebView2.Wpf.dll",
            "C:\Program Files\Fortinet\FortiClient\Microsoft.Web.WebView2.Wpf.dll",
            "C:\Program Files (x86)\Windows Kits\10\Windows Performance Toolkit\Microsoft.Web.WebView2.Wpf.dll"
        )
        foreach ($dll in $candidates) {
            if (Test-Path $dll) { 
                $coreDll = $dll -replace "Wpf.dll", "Core.dll"
                if (Test-Path $coreDll) {
                    [System.Reflection.Assembly]::LoadFrom($dll) | Out-Null
                    [System.Reflection.Assembly]::LoadFrom($coreDll) | Out-Null
                    $global:UseWebView2 = $true
                    break 
                }
            }
        }
    } catch { $global:UseWebView2 = $false }
}

function Initialize-IsraelTV-WebView2 {
    if (-not $global:UseWebView2) { Load-IsraelTV-Dependencies }
    if ($global:UseWebView2) {
        try {
            $hostGrid = Get-GuiElement "pnlPlayerHost"
            if ($hostGrid) {
                # Create Control
                $wv2 = New-Object Microsoft.Web.WebView2.Wpf.WebView2
                $wv2.Name = "wvIsraelTV"
                
                # CRITICAL: Set UserDataFolder to TEMP to avoid Access Denied in Program Files
                try {
                    $props = New-Object Microsoft.Web.WebView2.Wpf.CoreWebView2CreationProperties
                    $props.UserDataFolder = "$env:TEMP\WinFlexOS_WebView2"
                    $wv2.CreationProperties = $props
                } catch { Write-Warning "Could not set CreationProperties: $_" }

                $wv2.Source = [Uri]"about:blank"
                $global:WV2Control = $wv2
                
                # Inject into Grid
                $hostGrid.Children.Clear()
                $hostGrid.Children.Add($wv2) | Out-Null
                
                # Ensure Environment
                $wv2.EnsureCoreWebView2Async($null) | Out-Null
            }
        }
        catch {
            Write-Warning "Failed to init WebView2: $_"
            $global:UseWebView2 = $false
        }
    }
}

function Play-Channel-Internal ($url, $isAudio, $channelName, $siteUrl) {
    try {
        $global:currentTVUrl = $siteUrl
        $statusTxt = Get-GuiElement "lblTVStatusText"
        if ($statusTxt) { $statusTxt.Text = "Loading $channelName..." }
        $statusOverlay = Get-GuiElement "lblTVStatus"

        # --- A. EMBEDDED MODE (WebView2) ---
        if ($global:UseWebView2 -and $global:WV2Control) {
            if ($statusOverlay) { $statusOverlay.Visibility = "Collapsed" }

            if ([string]::IsNullOrWhiteSpace($url)) {
                if ($siteUrl) { $global:WV2Control.Source = [Uri]$siteUrl }
                return
            }

            if ($isAudio -and ($url -notmatch '\.m3u8')) {
                $audioHtml = @"
<!DOCTYPE html>
<html>
<head>
    <meta charset='utf-8'>
    <style>
        body { margin: 0; background: radial-gradient(circle at center, #1b2838 0%, #090d14 100%); color: #fff; font-family: 'Segoe UI', sans-serif; height: 100vh; display: flex; flex-direction: column; align-items: center; justify-content: center; gap: 18px; }
        .badge { padding: 6px 14px; border-radius: 20px; background: rgba(0, 174, 255, 0.15); border: 1px solid rgba(0, 174, 255, 0.4); color: #5cd2ff; font-size: 13px; letter-spacing: 1px; }
        h1 { margin: 0; font-size: 32px; font-weight: 700; }
        audio { width: 380px; max-width: 85vw; }
    </style>
</head>
<body>
    <div class='badge'>LIVE ISRAELI RADIO</div>
    <h1>$channelName</h1>
    <audio id='aud' controls autoplay src='$url'></audio>
    <script>
        var a = document.getElementById('aud');
        a.onerror = function() { if ('$siteUrl') { window.location.href = '$siteUrl'; } };
    </script>
</body>
</html>
"@
                $tempFile = "$env:TEMP\embedded_player.html"
                $audioHtml | Out-File -FilePath $tempFile -Encoding UTF8
                $global:WV2Control.Source = [Uri]$tempFile
                return
            }

            $htmlContent = @"
<!DOCTYPE html>
<html>
<head>
    <meta charset='utf-8'>
    <style>
        body { margin: 0; background-color: #000; color: #fff; font-family: 'Segoe UI', sans-serif; overflow: hidden; height: 100vh; display: flex; align-items: center; justify-content: center; }
        video { width: 100%; height: 100%; object-fit: contain; }
        .msg { position: absolute; top: 50%; left: 50%; transform: translate(-50%, -50%); color: #888; font-size: 14px; text-align: center; }
        .fs-btn { position: absolute; top: 10px; right: 10px; background: rgba(0,0,0,0.5); color: #fff; border: 1px solid rgba(255,255,255,0.3); padding: 5px 10px; cursor: pointer; z-index: 20; border-radius: 4px; font-size: 14px; }
        .fs-btn:hover { background: rgba(255,255,255,0.2); }
    </style>
    <script src='https://cdnjs.cloudflare.com/ajax/libs/hls.js/1.4.12/hls.min.js'></script>
</head>
<body>
    <div class='msg' id='msg'>Connecting to $channelName...</div>
    <button class='fs-btn' id='fsBtn'>&#x26F6; Fullscreen</button>
    <video id='video' controls autoplay playsinline></video>
    <script>
        var video = document.getElementById('video');
        var msg = document.getElementById('msg');
        var fsBtn = document.getElementById('fsBtn');
        var videoSrc = '$url';
        var siteUrl = '$siteUrl';

        function toggleFs() {
            if (!document.fullscreenElement) { video.requestFullscreen(); }
            else { document.exitFullscreen(); }
        }
        video.addEventListener('dblclick', toggleFs);
        fsBtn.addEventListener('click', toggleFs);

        function fallback() {
            if (siteUrl) {
                msg.innerHTML = 'Stream unavailable.<br>Redirecting to official site...';
                setTimeout(function() { window.location.href = siteUrl; }, 1200);
            } else { msg.innerHTML = 'Stream error.'; }
        }

        if (videoSrc) {
            if (typeof Hls !== 'undefined' && Hls.isSupported()) {
                var hls = new Hls();
                hls.loadSource(videoSrc);
                hls.attachMedia(video);
                hls.on(Hls.Events.MANIFEST_PARSED, function() { msg.style.display = 'none'; video.play(); });
                hls.on(Hls.Events.ERROR, function(e,d) { if(d.fatal) fallback(); });
            }
            else if (video.canPlayType('application/vnd.apple.mpegurl')) {
                video.src = videoSrc; video.play(); video.onerror = fallback;
            } else { fallback(); }
        } else { fallback(); }
    </script>
</body>
</html>
"@
            $tempFile = "$env:TEMP\embedded_player.html"
            $htmlContent | Out-File -FilePath $tempFile -Encoding UTF8
            $global:WV2Control.Source = [Uri]$tempFile
            return
        }

        # --- B. FALLBACK MODE (Same Window WebBrowser / Edge App) ---
        if ($statusOverlay) { $statusOverlay.Visibility = "Collapsed" }
        $hostGrid = Get-GuiElement "pnlPlayerHost"
        if ($hostGrid) {
            $wb = New-Object System.Windows.Controls.WebBrowser
            $hostGrid.Children.Clear()
            $hostGrid.Children.Add($wb) | Out-Null
            $wb.Navigate($siteUrl)
        } 
        else {
            Start-Process "msedge" "--app=$siteUrl"
        }
    }
    catch {
        Write-Warning "Playback Error: $_"
        if ($siteUrl) { Start-Process "msedge" "--app=$siteUrl" }
    }
}

function Show-IsraelTV-Panel {
    Switch-Panel (Get-GuiElement "pnlIsraelTV")
    if (-not $global:WV2Control) { Initialize-IsraelTV-WebView2 }
}

$pnlTVEl = Get-GuiElement "pnlIsraelTV"
if ($pnlTVEl) {
    $pnlTVEl.Add_IsVisibleChanged({
        if ($pnlTVEl.Visibility -eq [System.Windows.Visibility]::Visible -and -not $global:WV2Control) {
            Initialize-IsraelTV-WebView2
        }
    })
}

Set-Click "btnIsraelTV" { Show-IsraelTV-Panel }

# Live TV Channels
Set-Click "btnCh11"  { Play-Channel-Internal "" $false "Kan 11" "https://www.kan.org.il/live/" }
Set-Click "btnCh12"  { Play-Channel-Internal "" $false "Keshet 12" "https://www.mako.co.il/mako-vod-live-tv/VOD-6540b8dcb64fd31006.htm" }
Set-Click "btnCh13"  { Play-Channel-Internal "" $false "Reshet 13" "https://13tv.co.il/live/" }
Set-Click "btnCh14"  { Play-Channel-Internal "https://edge1.streamgate.net/now14/live/playlist.m3u8" $false "Now 14" "https://www.c14.co.il/live" }
Set-Click "btnCh23"  { Play-Channel-Internal "" $false "Kan Educational 23" "https://www.kan.org.il/live/tv.aspx?stationid=20" }
Set-Click "btnCh99"  { Play-Channel-Internal "" $false "Knesset Channel" "https://www.knesset.tv/" }
Set-Click "btnChI24" { Play-Channel-Internal "" $false "i24NEWS (IL)" "https://www.i24news.tv/he" }

# Radio Stations
Set-Click "btnRadGlz"     { Play-Channel-Internal "https://glz.streamgate.net/glz/glz/playlist.m3u8" $true "Galatz" "https://glz.co.il/%D7%92%D7%9C%D7%A6" }
Set-Click "btnRadGlglz"   { Play-Channel-Internal "https://glz.streamgate.net/glz/glglz/playlist.m3u8" $true "Galgalatz" "https://glz.co.il/%D7%92%D7%9C%D7%92%D7%9C%D7%A6" }
Set-Click "btnRadKan88"   { Play-Channel-Internal "https://playerservices.streamtheworld.com/api/livestream-redirect/KAN_88.mp3" $true "Kan 88" "https://www.kan.org.il/content/kan/kan-88/" }
Set-Click "btnRadReshetB" { Play-Channel-Internal "https://27753.live.streamtheworld.com/KAN_BET.mp3" $true "Kan Reshet Bet" "https://www.kan.org.il/content/kan/kan-b/" }
Set-Click "btnRad103"     { Play-Channel-Internal "" $true "103FM" "https://103fm.maariv.co.il/" }
Set-Click "btnRadEco99"   { Play-Channel-Internal "" $true "Eco 99FM" "https://eco99fm.maariv.co.il/live-radio" }

Set-Click "btnStopTV" {
    $global:currentTVUrl = $null
    if ($global:WV2Control) {
        try { $global:WV2Control.Source = [Uri]"about:blank" } catch {}
    } else {
        $hostGrid = Get-GuiElement "pnlPlayerHost"
        if ($hostGrid) { $hostGrid.Children.Clear() }
    }
    $statusOverlay = Get-GuiElement "lblTVStatus"
    $statusTxt = Get-GuiElement "lblTVStatusText"
    if ($statusTxt) { $statusTxt.Text = "Playback stopped. Select a channel to watch" }
    if ($statusOverlay) { $statusOverlay.Visibility = "Visible" }
    Show-Toast "Stream stopped" "info"
}

Set-Click "btnLaunchExternal" {
    if ($global:currentTVUrl) {
        Start-Process $global:currentTVUrl
    } else {
        Start-Process "https://www.kan.org.il/live/"
    }
}

# --- CINEMA MODE HANDLERS ---
function Toggle-TV-CinemaMode {
    try {
        $title = Get-GuiElement "lblTVTitle"
        $listCol = Get-GuiElement "colTVSidebar"
        $spacerCol = Get-GuiElement "colTVSpacer"
        $exitBtn = Get-GuiElement "btnExitCinema"
        $sidebar = Get-GuiElement "SidebarBorder"
        
        if (-not $global:IsCinemaMode) {
            if ($title) { $title.Visibility = "Collapsed" }
            if ($listCol) { $listCol.Width = New-Object System.Windows.GridLength(0) }
            if ($spacerCol) { $spacerCol.Width = New-Object System.Windows.GridLength(0) }
            if ($exitBtn) { $exitBtn.Visibility = "Visible" }
            if ($sidebar) { $sidebar.Visibility = "Collapsed" }
            $global:IsCinemaMode = $true
        } else {
            if ($title) { $title.Visibility = "Visible" }
            if ($listCol) { $listCol.Width = New-Object System.Windows.GridLength(220) }
            if ($spacerCol) { $spacerCol.Width = New-Object System.Windows.GridLength(10) }
            if ($exitBtn) { $exitBtn.Visibility = "Collapsed" }
            if ($sidebar) { $sidebar.Visibility = "Visible" }
            $global:IsCinemaMode = $false
        }
    } catch {}
}

Set-Click "btnCinemaMode" { Toggle-TV-CinemaMode }
Set-Click "btnExitCinema" { Toggle-TV-CinemaMode }
