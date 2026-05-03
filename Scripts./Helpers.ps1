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
        
        if ($global:isHebrew -eq $true) {
            # Hebrew greetings using char codes to avoid encoding issues
            $msg = $(if ($hour -lt 5) { "$([char]0x05DC)$([char]0x05D9)$([char]0x05DC)$([char]0x05D4) $([char]0x05D8)$([char]0x05D5)$([char]0x05D1)" } elseif ($hour -lt 12) { "$([char]0x05D1)$([char]0x05D5)$([char]0x05E7)$([char]0x05E8) $([char]0x05D8)$([char]0x05D5)$([char]0x05D1)" } elseif ($hour -lt 18) { "$([char]0x05E6)$([char]0x05D4)$([char]0x05E8)$([char]0x05D9)$([char]0x05D9)$([char]0x05DD) $([char]0x05D8)$([char]0x05D5)$([char]0x05D1)$([char]0x05D9)$([char]0x05DD)" } elseif ($hour -lt 22) { "$([char]0x05E2)$([char]0x05E8)$([char]0x05D1) $([char]0x05D8)$([char]0x05D5)$([char]0x05D1)" } else { "$([char]0x05DC)$([char]0x05D9)$([char]0x05DC)$([char]0x05D4) $([char]0x05D8)$([char]0x05D5)$([char]0x05D1)" })
            $lbl.Text = "$msg, $env:USERNAME"
        } else {
            $msg = $(if ($hour -lt 5) { "Good Night" } elseif ($hour -lt 12) { "Good Morning" } elseif ($hour -lt 18) { "Good Afternoon" } elseif ($hour -lt 22) { "Good Evening" } else { "Good Night" })
            $lbl.Text = "$msg, $env:USERNAME"
        }
    } catch {}
}

function Show-Toast {
    param(
        [string]$Message,
        [string]$Type = "info",
        [int]$DurationMs = 3500
    )
    try {
        $bgColor = switch ($Type) {
            "success" { "#18A062" }
            "warning" { "#D97706" }
            "error"   { "#DC2626" }
            default   { "#2563EB" }
        }
        $accentColor = switch ($Type) {
            "success" { "#25D98A" }
            "warning" { "#FCD34D" }
            "error"   { "#F87171" }
            default   { "#60A5FA" }
        }
        # MDL2 Segoe icons
        $mdlIcon = switch ($Type) {
            "success" { [char]0xE73E }  # Checkmark
            "warning" { [char]0xE7BA }  # Warning
            "error"   { [char]0xE783 }  # Error / X circle
            default   { [char]0xE946 }  # Info
        }

        # Stack toasts vertically if multiple
        if (-not $script:_toastCount) { $script:_toastCount = 0 }
        $script:_toastCount++
        $stackOffset = ($script:_toastCount - 1) * 75

        [xml]$toastXaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        WindowStyle="None" AllowsTransparency="True" Background="Transparent"
        Width="340" Height="68" Topmost="True"
        WindowStartupLocation="Manual" ShowInTaskbar="False"
        RenderOptions.BitmapScalingMode="HighQuality">
    <Window.Resources>
        <Storyboard x:Key="SlideIn">
            <DoubleAnimation Storyboard.TargetName="Root" Storyboard.TargetProperty="Opacity" From="0" To="1" Duration="0:0:0.25"/>
            <DoubleAnimation Storyboard.TargetName="RootTranslate" Storyboard.TargetProperty="X" From="60" To="0" Duration="0:0:0.25">
                <DoubleAnimation.EasingFunction><ExponentialEase EasingMode="EaseOut" Exponent="4"/></DoubleAnimation.EasingFunction>
            </DoubleAnimation>
        </Storyboard>
        <Storyboard x:Key="FadeOut">
            <DoubleAnimation Storyboard.TargetName="Root" Storyboard.TargetProperty="Opacity" From="1" To="0" Duration="0:0:0.3" BeginTime="0:0:0"/>
        </Storyboard>
    </Window.Resources>
    <Border Name="Root" CornerRadius="12" Opacity="0">
        <Border.RenderTransform><TranslateTransform x:Name="RootTranslate" X="60"/></Border.RenderTransform>
        <Border.Background>
            <LinearGradientBrush StartPoint="0,0" EndPoint="1,1">
                <GradientStop Color="$bgColor" Offset="0"/>
                <GradientStop Color="#111827" Offset="1"/>
            </LinearGradientBrush>
        </Border.Background>
        <Border.Effect>
            <DropShadowEffect BlurRadius="25" Opacity="0.55" ShadowDepth="4" Direction="270"/>
        </Border.Effect>
        <Grid>
            <!-- Left accent bar -->
            <Border Width="4" HorizontalAlignment="Left" CornerRadius="12,0,0,12" Background="$accentColor"/>
            <StackPanel Orientation="Horizontal" VerticalAlignment="Center" Margin="18,0,14,0">
                <!-- Icon circle -->
                <Border Background="#22FFFFFF" CornerRadius="20" Width="36" Height="36" Margin="0,0,12,0">
                    <TextBlock Text="$mdlIcon" FontFamily="Segoe MDL2 Assets" FontSize="16" Foreground="$accentColor"
                               HorizontalAlignment="Center" VerticalAlignment="Center"/>
                </Border>
                <TextBlock Text="$Message" Foreground="White" FontSize="13" FontWeight="Medium"
                           TextWrapping="Wrap" VerticalAlignment="Center" MaxWidth="240"
                           FontFamily="Segoe UI Variable, Segoe UI"/>
            </StackPanel>
        </Grid>
    </Border>
    <Window.Triggers>
        <EventTrigger RoutedEvent="Window.Loaded">
            <BeginStoryboard Storyboard="{StaticResource SlideIn}"/>
        </EventTrigger>
    </Window.Triggers>
</Window>
"@
        $tr = New-Object System.Xml.XmlNodeReader $toastXaml
        $tw = [Windows.Markup.XamlReader]::Load($tr)
        $workArea = [System.Windows.SystemParameters]::WorkArea
        $tw.Left = $workArea.Right - 360
        $tw.Top  = $workArea.Bottom - 90 - $stackOffset
        $tw.Show()

        $ct = New-Object System.Windows.Threading.DispatcherTimer
        $ct.Interval = [TimeSpan]::FromMilliseconds($DurationMs)
        $ct.Add_Tick({
            try {
                $sb = $tw.FindResource("FadeOut")
                $sb.Begin($tw)
                $closeTimer = New-Object System.Windows.Threading.DispatcherTimer
                $closeTimer.Interval = [TimeSpan]::FromMilliseconds(350)
                $closeTimer.Add_Tick({ $tw.Close(); $closeTimer.Stop(); $script:_toastCount-- })
                $closeTimer.Start()
            } catch { $tw.Close() }
            $ct.Stop()
        })
        $ct.Start()
    } catch {}
}

function Open-Url { param($url) try { Start-Process $url } catch { [System.Windows.Forms.MessageBox]::Show("Could not open URL: $url", "Error") } }

function Write-Log { param($msg) $script:actionHistory += "[$((Get-Date).ToString('HH:mm:ss'))] $msg"; if ($script:actionHistory.Count -gt 20) { $script:actionHistory = $script:actionHistory[1..20] } }

function Invoke-OnlineApp {
    param([string]$Url, [string]$FileName, [string]$ExeToRun = "", [bool]$IsZip = $false)
    $tempDir = "C:\MENU"
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

function Switch-Panel {
    param($TargetName)
    $panels = @("pnlHome", "pnlAIBots", "pnlEssentials", "pnlWindowsTools", "pnlSysInfoTools", "pnlTweaks", "pnlMaintenance", "pnlSecurity", "pnlUserMgmt", "pnlMusic", "pnlPower", "pnlBeast", "pnlGaming", "pnlUpdateMgr", "pnlIsraelTV", "pnlKeyboardShortcuts")
    foreach ($p in $panels) {
        $el = Get-GuiElement $p
        if ($el) { $el.Visibility = "Collapsed" }
    }
    $target = Get-GuiElement $TargetName
    if ($target) {
        $target.Visibility = "Visible"
        # Fade in the new panel (GPU-accelerated, zero CPU cost)
        try {
            $da = New-Object System.Windows.Media.Animation.DoubleAnimation(0.0, 1.0, [System.Windows.Duration]::new([TimeSpan]::FromMilliseconds(200)))
            $da.EasingFunction = New-Object System.Windows.Media.Animation.ExponentialEase
            $da.EasingFunction.EasingMode = "EaseOut"
            $target.BeginAnimation([System.Windows.UIElement]::OpacityProperty, $da)
        } catch {}
    }
}


