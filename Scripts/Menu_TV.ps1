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
        Invoke-WebRequest -Uri $url -OutFile $zipPath -TimeoutSec 30
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
        # Update UI Status
        $statusTxt = Get-GuiElement "lblTVStatusText"
        if ($statusTxt) { $statusTxt.Text = "Launching $channelName..." }

        # --- A. EMBEDDED MODE (WebView2) ---
        if ($global:UseWebView2 -and $global:WV2Control) {
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
    <div class='msg' id='msg'>Connecting to Stream...</div>
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
                setTimeout(function() { window.location.href = siteUrl; }, 1500);
            } else { msg.innerHTML = 'Stream error.'; }
        }

        if(videoSrc) {
            if (Hls.isSupported()) {
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

        # --- B. FALLBACK MODE (Same Window WebBrowser) ---
        $hostGrid = Get-GuiElement "pnlPlayerHost"
        if ($hostGrid) {
            $wb = New-Object System.Windows.Controls.WebBrowser
            $hostGrid.Children.Clear()
            $hostGrid.Children.Add($wb) | Out-Null
            $wb.Navigate($siteUrl)
        } 
        else {
            # Last Resort: Edge App Mode (New Window)
            Start-Process "msedge" "--app=$siteUrl"
        }
    }
    catch {
        Write-Warning "Playback Error: $_"
        Start-Process "msedge" "--app=$siteUrl"
    }
}

function Show-IsraelTV-Panel {
    Switch-Panel (Get-GuiElement "pnlIsraelTV")
    if (-not $global:WV2Control) { Initialize-IsraelTV-WebView2 }
}

Set-Click "btnIsraelTV" { Show-IsraelTV-Panel }

Set-Click "btnCh11" { Play-Channel-Internal "https://kan11.media.kan.org.il/hls/live/2024514/2024514/master.m3u8" $false "Kan 11" "https://www.kan.org.il/live/" }
Set-Click "btnCh12" { Play-Channel-Internal "https://mako-keshet-live-hls.akamaized.net/hls/live/2033791/k12dvr/master.m3u8" $false "Keshet 12" "https://www.mako.co.il/mako-vod-live-tv/VOD-6540b8dcb64fd31006.htm" }
Set-Click "btnCh13" { Play-Channel-Internal "https://d18b0e6mopany4.cloudfront.net/out/v1/08bc71cf0a0f4712b6b03c732b0e6d25/index.m3u8" $false "Reshet 13" "https://13tv.co.il/live/" }
Set-Click "btnCh14" { Play-Channel-Internal "https://edge1.streamgate.net/now14/live/playlist.m3u8" $false "Now 14" "https://www.c-14.co.il/live" }
Set-Click "btnCh23" { Play-Channel-Internal "https://kan23.media.kan.org.il/hls/live/2024691/2024691/master.m3u8" $false "Kan 23" "https://www.kan.org.il/live/tv.aspx?stationid=20" }
Set-Click "btnCh99" { Play-Channel-Internal "https://knesset.gostreaming.tv/knesset/myStream/playlist.m3u8" $false "Knesset 99" "https://www.knesset.gov.il/broadcast/heb/knesset99.htm" }

# Radio Stations
Set-Click "btnRadGlz"     { Play-Channel-Internal "https://glz.streamgate.net/glz/glz/playlist.m3u8" $true "Galatz" "https://glz.co.il/%D7%92%D7%9C%D7%A6" }
Set-Click "btnRadGlglz"   { Play-Channel-Internal "https://glz.streamgate.net/glz/glglz/playlist.m3u8" $true "Galgalatz" "https://glz.co.il/%D7%92%D7%9C%D7%92%D7%9C%D7%A6" }
Set-Click "btnRadKan88"   { Play-Channel-Internal "https://kan88.media.kan.org.il/hls/live/202488/202488/master.m3u8" $true "Kan 88" "https://www.kan.org.il/radio/player.aspx?stationId=4" }
Set-Click "btnRadReshetB" { Play-Channel-Internal "https://kanb.media.kan.org.il/hls/live/202482/202482/master.m3u8" $true "Kan Reshet Bet" "https://www.kan.org.il/radio/player.aspx?stationId=3" }

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
