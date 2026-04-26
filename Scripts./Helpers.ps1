function Get-AssetBitmap {
    param([string]$Name)
    if (-not $script:AssetCache) { $script:AssetCache = @{} }
    if ($script:AssetCache.ContainsKey($Name)) { return $script:AssetCache[$Name] }
    
    if ($script:assets -and $script:assets.ContainsKey($Name)) {
        try {
            $content = $script:assets[$Name]
            if ($content -is [array]) { $content = $content -join '' }
            $bytes = [Convert]::FromBase64String($content)
            $ms = New-Object System.IO.MemoryStream($bytes, 0, $bytes.Length)
            $bitmap = New-Object System.Windows.Media.Imaging.BitmapImage
            $bitmap.BeginInit()
            $bitmap.StreamSource = $ms
            $bitmap.CacheOption = [System.Windows.Media.Imaging.BitmapCacheOption]::OnLoad
            $bitmap.EndInit()
            $bitmap.Freeze()
            $script:AssetCache[$Name] = $bitmap
            return $bitmap
        } catch {
            return $null
        }
    }
    return $null
}

# UI Element cache - each element found once, O(1) afterwards
$script:_uiCache = [System.Collections.Generic.Dictionary[string,object]]::new()
function Get-GuiElement {
    param($Name)
    $cached = $null
    if ($script:_uiCache.TryGetValue($Name, [ref]$cached)) { return $cached }
    $el = $window.FindName($Name)
    $script:_uiCache[$Name] = $el
    return $el
}

function Set-Click { param($Name, $Block) $btn = Get-GuiElement $Name; if ($btn) { $btn.Add_Click($Block) } }

function Update-Greeting-Smart {
    try {
        $lbl = Get-GuiElement "lblGreeting"
        if (-not $lbl) { return }
        $hour = (Get-Date).Hour
        $msg = $(if ($hour -lt 12) { "Good Morning" } elseif ($hour -lt 18) { "Good Afternoon" } else { "Good Evening" })
        $lbl.Text = $msg
    } catch {}
}

function Show-Toast {
    param(
        [string]$Message,
        [string]$Type = "info",   # "info" | "success" | "warning" | "error"
        [int]$DurationMs = 3000
    )
    try {
        $bgColor = switch ($Type) {
            "success" { "#1db87e" }
            "warning" { "#f59e0b" }
            "error"   { "#ef4444" }
            default   { "#3b7aff" }
        }
        $icon = switch ($Type) {
            "success" { "OK" }
            "warning" { "W" }
            "error"   { "X" }
            default   { "i" }
        }
        [xml]$toastXaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        WindowStyle="None" AllowsTransparency="True" Background="Transparent"
        Width="320" Height="65" Topmost="True"
        WindowStartupLocation="Manual" ShowInTaskbar="False">
    <Border Background="$bgColor" CornerRadius="10" Opacity="0.97">
        <Border.Effect>
            <DropShadowEffect BlurRadius="18" Opacity="0.5" ShadowDepth="3"/>
        </Border.Effect>
        <StackPanel Orientation="Horizontal" VerticalAlignment="Center" Margin="14,0">
            <Border Background="#22FFFFFF" CornerRadius="6" Width="28" Height="28" Margin="0,0,10,0">
                <TextBlock Text="$icon" Foreground="White" FontSize="13" FontWeight="Bold"
                           HorizontalAlignment="Center" VerticalAlignment="Center"/>
            </Border>
            <TextBlock Text="$Message" Foreground="White" FontSize="13" FontWeight="SemiBold"
                       TextWrapping="Wrap" VerticalAlignment="Center" MaxWidth="240"
                       FontFamily="Segoe UI"/>
        </StackPanel>
    </Border>
</Window>
"@
        $tr = New-Object System.Xml.XmlNodeReader $toastXaml
        $tw = [Windows.Markup.XamlReader]::Load($tr)
        $tw.Left = [System.Windows.SystemParameters]::WorkArea.Right - 340
        $tw.Top  = [System.Windows.SystemParameters]::WorkArea.Bottom - 85
        $tw.Show()
        $ct = New-Object System.Windows.Threading.DispatcherTimer
        $ct.Interval = [TimeSpan]::FromMilliseconds($DurationMs)
        $ct.Add_Tick({ $tw.Close(); $ct.Stop() })
        $ct.Start()
    } catch {}
}

function Open-Url { param($url) try { Start-Process $url } catch { [System.Windows.Forms.MessageBox]::Show("Could not open URL: $url", "Error") } }

function Write-Log { param($msg) $script:actionHistory += "[$((Get-Date).ToString('HH:mm:ss'))] $msg"; if ($script:actionHistory.Count -gt 20) { $script:actionHistory = $script:actionHistory[1..20] } }

function Invoke-OnlineApp {
    param([string]$Url, [string]$FileName, [string]$ExeToRun = "", [bool]$IsZip = $false)
    $tempDir = "$env:TEMP\WinFlex_Apps"
    if (!(Test-Path $tempDir)) { New-Item $tempDir -ItemType Directory | Out-Null }
    $outPath = "$tempDir\$FileName"
    
    try {
        Show-Toast "Downloading $FileName..." "info"
        Invoke-WebRequest -Uri $Url -OutFile $outPath -TimeoutSec 15
        
        if ($IsZip) {
            $zipExtract = "$tempDir\$($FileName -replace '\.zip', '')"
            Expand-Archive -Path $outPath -DestinationPath $zipExtract -Force
            if ($ExeToRun) { Start-Process "$zipExtract\$ExeToRun" } else { Start-Process "explorer.exe" $zipExtract }
        } else {
            Start-Process $outPath
        }
        Show-Toast "App launched successfully!" "success"
    } catch {
        Show-Toast "Download failed: $($_.Exception.Message)" "error"
    }
}
