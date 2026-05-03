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

# --- UNIFIED AI BUTTON INFO SYSTEM ---
$script:ToolInfoMap = @{
    "btnGPT"          = @{ En = "Leading AI by OpenAI for chat, coding, and analysis. Supports GPT-4o."; He = "Advanced AI by OpenAI" }
    "btnGemini"       = @{ En = "Google's powerful AI for creative tasks, information, and multimodal understanding."; He = "Google AI Assistant" }
    "btnCopilot"      = @{ En = "Microsoft's AI companion integrated with Windows and Bing Search."; He = "Microsoft AI Companion" }
    "btnClaude"       = @{ En = "Anthropic's AI specializing in long context and advanced technical writing."; He = "Anthropic AI" }
    "btnGrok"         = @{ En = "xAI's conversational assistant with real-time access to X platform data."; He = "xAI Assistant" }
    "btnPerplexity"   = @{ En = "AI search engine that provides direct answers with cited sources."; He = "AI Search Engine" }
    "btnGitHubCopilot"= @{ En = "AI pair programmer that helps you write code faster inside your IDE."; He = "GitHub AI Copilot" }
    "btnCursor"       = @{ En = "AI-powered code editor designed for pair programming with Large Language Models."; He = "AI Code Editor" }
    "btnMidjourney"   = @{ En = "High-quality AI image generation model, accessed primarily through Discord."; He = "AI Image Model" }
    "btnDALLE"        = @{ En = "OpenAI's DALL-E 3 for generating creative and realistic images from text."; He = "DALL-E 3" }
    "btnLeonardo"     = @{ En = "Creative platform for AI image generation with advanced style controls."; He = "Leonardo AI" }
    "btnIdeogram"     = @{ En = "AI image generator specializing in typography and design layouts."; He = "Ideogram AI" }
    "btnFlux"         = @{ En = "State-of-the-art image generation model focusing on detail and realism."; He = "Flux AI" }
    "btnDeepSeek"     = @{ En = "High-performance AI model specializing in coding and mathematics."; He = "DeepSeek AI" }
    "btnMistral"      = @{ En = "Efficient and powerful open-source AI models from Mistral AI."; He = "Mistral AI" }
    "btnV0"           = @{ En = "Vercel's AI tool for generating UI components and frontend code."; He = "Vercel v0" }
    "btnBolt"         = @{ En = "AI-powered full-stack web development platform for rapid prototyping."; He = "Bolt AI" }
    "btnHuggingFace"  = @{ En = "The community platform for open-source AI models, datasets, and apps."; He = "HuggingFace" }
}
