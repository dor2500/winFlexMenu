# Window Logic
$window.Add_MouseLeftButtonDown({ try { $window.DragMove() } catch {} })
(Get-GuiElement "btnClose").Add_Click({ $window.Close() })
(Get-GuiElement "btnMin").Add_Click({ $window.WindowState = 'Minimized' })

# Maximize Button Logic
$btnMax = Get-GuiElement "btnMax"
$btnMax.Add_Click({
        if ($window.WindowState -eq 'Maximized') {
            $window.WindowState = 'Normal'
            $btnMax.Content = [char]0xE922 # Single Square
        }
        else {
            $window.WindowState = 'Maximized'
            $btnMax.Content = [char]0xE923 # Double Square
        }
    })
$btnMax.Content = [char]0xE922

# CLOCK TIMER (Updates every second)
$clockTimer = New-Object System.Windows.Threading.DispatcherTimer
$clockTimer.Interval = [TimeSpan]::FromSeconds(1)
$clockTimer.Add_Tick({
        $now = [DateTime]::Now
        $lblTime = Get-GuiElement "lblTimeClock"
        $lblDate = Get-GuiElement "lblDateClock"
        if ($lblTime) { $lblTime.Text = $now.ToString("HH:mm:ss") }
        if ($lblDate) { 
            $culture = if ($script:isHebrew) { New-Object System.Globalization.CultureInfo("he-IL") } else { New-Object System.Globalization.CultureInfo("en-US") }
            $lblDate.Text = $now.ToString("dddd, MMMM dd, yyyy", $culture) 
        }
        # Header date sub-line
        $hdrDate = $window.FindName("lblHeaderDate")
        if ($hdrDate) { 
            $culture = if ($script:isHebrew) { New-Object System.Globalization.CultureInfo("he-IL") } else { New-Object System.Globalization.CultureInfo("en-US") }
            $hdrDate.Text = $now.ToString("dddd, dd MMMM yyyy", $culture) 
        }
    })
$clockTimer.Start()

# Initial clock update
$now = [DateTime]::Now
$lblTimeClock = Get-GuiElement "lblTimeClock"
$lblDateClock = Get-GuiElement "lblDateClock"
if ($lblTimeClock) { $lblTimeClock.Text = $now.ToString("HH:mm:ss") }
if ($lblDateClock) { 
    $culture = if ($script:isHebrew) { New-Object System.Globalization.CultureInfo("he-IL") } else { New-Object System.Globalization.CultureInfo("en-US") }
    $lblDateClock.Text = $now.ToString("dddd, MMMM dd, yyyy", $culture) 
}
$hdrDateInit = $window.FindName("lblHeaderDate")
if ($hdrDateInit) { 
    $culture = if ($script:isHebrew) { New-Object System.Globalization.CultureInfo("he-IL") } else { New-Object System.Globalization.CultureInfo("en-US") }
    $hdrDateInit.Text = $now.ToString("dddd, dd MMMM yyyy", $culture) 
}

# Double Click to Maximize (ON THE WINDOW BORDER)
$mainBorder = Get-GuiElement "MainBorder"
if ($mainBorder) {
    $mainBorder.Add_MouseLeftButtonDown({ 
            if ($_.ClickCount -eq 2) {
                if ($window.WindowState -eq 'Maximized') {
                    $window.WindowState = 'Normal'
                    $btnMax.Content = [char]0xE922
                }
                else {
                    $window.WindowState = 'Maximized'
                    $btnMax.Content = [char]0xE923
                }
            }
            else {
                if ($_.LeftButton -eq 'Pressed') { 
                    try { $window.DragMove() } catch {}
                }
            }
        })
}

# --- QUICK ACTIONS HANDLERS ---
Set-Click "btnCreateDesktopShortcut" {
    try {
        $desktopPath = [Environment]::GetFolderPath("Desktop")
        $cmdContent = "@echo off`r`npowershell -WindowStyle Hidden -Command `"irm https://did.li/WinFlexOS11 | iex`"`r`nexit"
        $filePath = Join-Path $desktopPath "WinFlexMenu.cmd"
        $cmdContent | Out-File -FilePath $filePath -Encoding ascii
        [System.Windows.Forms.MessageBox]::Show("Shortcut 'WinFlexMenu.cmd' created on Desktop!`n`nIt will run: irm https://did.li/WinFlexOS11 | iex", "Success", "OK", "Information")
    } catch {
        [System.Windows.Forms.MessageBox]::Show("Error creating shortcut: $_", "Error", "OK", "Error")
    }
}


# --- THEME ENGINE ---
$cmbThemes = Get-GuiElement "cmbThemes"
$themeNames = @("Dracula", "Pitch Black", "Dark Gray", "Light Mode", "Midnight Blue", "Nordic Frost", "Tokyo Night", "Gruvbox", "Windows 98 Classic", "Windows 98 Dark", "Van Gogh", "The Great Wave", "Windows 95 Teal", "Abstract Mode", "Material You", "Nintendo Wii", "Super Mario", "Sony PlayStation 2", "Windows XP Bliss", "Windows 7 Aero", "Xbox Original", "Xbox 360", "GTA San Andreas", "Cyberpunk 2077", "Fallout Pip-Boy", "Goat Simulator", "Minecraft", "Halo 3", "Counter-Strike 1.6", "Half-Life 2", "Doom Classic", "Portal", "PS5 Dashboard", "Netflix Red", "Deep Space", "Custom Image")
$themeNames | ForEach-Object { [void]$cmbThemes.Items.Add($_) }

# STARTUP: Set a Random Theme by default
$randomIndex = Get-Random -Minimum 0 -Maximum $themeNames.Count

function Set-ResourceColor { 
    param($Key, $Hex) 
    $brush = New-Object System.Windows.Media.SolidColorBrush([System.Windows.Media.ColorConverter]::ConvertFromString($Hex))
    $window.Resources.Remove($Key) 
    $window.Resources.Add($Key, $brush) 
}

# Helper to set non-color resources
function Apply-Theme-From-Image {
    param($imagePath)
    try {
        if (-not (Test-Path $imagePath)) { return }
        $bmp = [System.Drawing.Bitmap]::FromFile($imagePath)
        
        # Get Average Color by scaling to 1x1
        $thumb = New-Object System.Drawing.Bitmap(1, 1)
        $g = [System.Drawing.Graphics]::FromImage($thumb)
        $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
        $g.DrawImage($bmp, 0, 0, 1, 1)
        $avgColor = $thumb.GetPixel(0, 0)
        
        $r = $avgColor.R; $g_ = $avgColor.G; $b = $avgColor.B
        $hexAccent = "#{0:X2}{1:X2}{2:X2}" -f $r, $g_, $b
        
        # Determine Foreground based on Luminance
        $lum = (0.299 * $r + 0.587 * $g_ + 0.114 * $b) / 255
        $hexFg = $($(if ($lum -gt 0.6) { "#000000" } else { "#FFFFFF" }))
        
        # Set Theme Resources
        Set-ResourceColor "ThemeAccent" $hexAccent
        Set-ResourceColor "ThemeFg" $hexFg
        Set-ResourceColor "ThemeWinCtrl" $hexFg
        Set-ResourceColor "ThemeTitleFg" $hexAccent
        
        # Darker/Opaque version for Sidebar
        $dr = [Math]::Max(0, $r - 30); $dg = [Math]::Max(0, $g_ - 30); $db = [Math]::Max(0, $b - 30)
        Set-ResourceColor "ThemeSidebar" ("#CC{0:X2}{1:X2}{2:X2}" -f $dr, $dg, $db)
        
        # Semi-transparent version for Cards
        Set-ResourceColor "ThemeCardBg" ("#AA{0:X2}{1:X2}{2:X2}" -f $r, $g_, $b)
        Set-ResourceColor "ThemeSubText" ($(if ($lum -gt 0.6) { "#444444" } else { "#CCCCCC" }))
        
        # Apply Background Image
        $imgBrush = New-Object System.Windows.Media.ImageBrush
        $imgBrush.ImageSource = New-Object System.Windows.Media.Imaging.BitmapImage(New-Object System.Uri($imagePath))
        $imgBrush.Stretch = "UniformToFill"
        $window.Resources.Remove("ThemeBg")
        $window.Resources.Add("ThemeBg", $imgBrush)
        $window.Background = $window.Resources["ThemeBg"]
        
        $bmp.Dispose(); $thumb.Dispose(); $g.Dispose()
    } catch {
        Write-Host "Error generating theme: $($_.Exception.Message)"
    }
}

function Trigger-Custom-Theme {
    Add-Type -AssemblyName System.Windows.Forms
    $fd = New-Object System.Windows.Forms.OpenFileDialog
    $fd.Filter = "Image Files|*.jpg;*.jpeg;*.png;*.bmp;*.gif"
    $heTitle = "$([char]0x05D1)$([char]0x05D7)$([char]0x05E8) $([char]0x05EA)$([char]0x05DE)$([char]0x05D5)$([char]0x05E0)$([char]0x05D4) $([char]0x05DC)$([char]0x05E2)$([char]0x05D9)$([char]0x05E6)$([char]0x05D5)$([char]0x05D1) $([char]0x05D0)$([char]0x05D9)$([char]0x05E9)$([char]0x05D9)"
    $fd.Title = $($(if ($global:CurrentLanguage -eq "He") { $heTitle } else { "Select Image for Custom Theme" }))
    if ($fd.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        Apply-Theme-From-Image -imagePath $fd.FileName
        return $true
    }
    return $false
}

function Set-Resource {
    param($Key, $Value)
    $window.Resources.Remove($Key)
    $window.Resources.Add($Key, $Value)
}

$cmbThemes.Add_SelectionChanged({
        $i = $cmbThemes.SelectedIndex
        $btnC = Get-GuiElement "btnThemeCustom"
        if ($btnC) { $btnC.Visibility = if ($i -eq ($themeNames.Count - 1)) { [System.Windows.Visibility]::Visible } else { [System.Windows.Visibility]::Collapsed } }
        Set-Resource "ThemeCornerRadius" (New-Object System.Windows.CornerRadius(16))
        Set-Resource "ThemeFont" (New-Object System.Windows.Media.FontFamily("Bahnschrift, Segoe UI, sans-serif"))
        Set-ResourceColor "ThemeTitleBg" "Transparent"
        Set-Resource "ThemeBorderThickness" (New-Object System.Windows.Thickness(1))
        $el = Get-GuiElement "txtClock"; if ($el) { $el.SetResourceReference([System.Windows.Controls.TextBlock]::ForegroundProperty, "ThemeFg") }
        $el = Get-GuiElement "txtDate";  if ($el) { $el.SetResourceReference([System.Windows.Controls.TextBlock]::ForegroundProperty, "ThemeSubText") }
        (Get-GuiElement "LogoIcon").Text = [char]0xE7F4
        (Get-GuiElement "LogoBorder").Background = $window.Resources["ThemeAccent"]
    
        Set-Resource "VisModern" ([System.Windows.Visibility]::Visible)
        Set-Resource "VisRetro" ([System.Windows.Visibility]::Collapsed)

        if ($i -lt 10) { $window.Background = $window.Resources["ThemeBg"] }

        switch ($i) {
            0 { Set-ResourceColor "ThemeBg" "#0F0F0F"; Set-ResourceColor "ThemeSidebar" "#141414"; Set-ResourceColor "ThemeCardBg" "#1E1E1E"; Set-ResourceColor "ThemeFg" "#FFFFFF"; Set-ResourceColor "ThemeAccent" "#00BFFF"; Set-ResourceColor "ThemeSidebarFg" "#B0B0B0"; Set-ResourceColor "ThemeWinCtrl" "#AAAAAA"; Set-ResourceColor "ThemeSubText" "#B0B0B0"; Set-ResourceColor "ThemeTitleFg" "#00BFFF" }
            1 { Set-ResourceColor "ThemeBg" "#000000"; Set-ResourceColor "ThemeSidebar" "#000000"; Set-ResourceColor "ThemeCardBg" "#151515"; Set-ResourceColor "ThemeFg" "#FFFFFF"; Set-ResourceColor "ThemeAccent" "#00AAFF"; Set-ResourceColor "ThemeSidebarFg" "#DDDDDD"; Set-ResourceColor "ThemeWinCtrl" "#AAAAAA"; Set-ResourceColor "ThemeSubText" "#CCCCCC"; Set-ResourceColor "ThemeTitleFg" "#00AAFF" }
            2 { Set-ResourceColor "ThemeBg" "#202020"; Set-ResourceColor "ThemeSidebar" "#181818"; Set-ResourceColor "ThemeCardBg" "#2D2D2D"; Set-ResourceColor "ThemeFg" "#EEEEEE"; Set-ResourceColor "ThemeAccent" "#4CAF50"; Set-ResourceColor "ThemeSidebarFg" "#CCCCCC"; Set-ResourceColor "ThemeWinCtrl" "#AAAAAA"; Set-ResourceColor "ThemeSubText" "#AAAAAA"; Set-ResourceColor "ThemeTitleFg" "#4CAF50" }
            3 { Set-ResourceColor "ThemeBg" "#F0F2F5"; Set-ResourceColor "ThemeSidebar" "#FFFFFF"; Set-ResourceColor "ThemeCardBg" "#FFFFFF"; Set-ResourceColor "ThemeFg" "#000000"; Set-ResourceColor "ThemeAccent" "#0078D7"; Set-ResourceColor "ThemeSidebarFg" "#000000"; Set-ResourceColor "ThemeWinCtrl" "#333333"; Set-ResourceColor "ThemeSubText" "#444444"; Set-ResourceColor "ThemeTitleFg" "#0078D7" }
            4 { Set-ResourceColor "ThemeBg" "#000510"; Set-ResourceColor "ThemeSidebar" "#000A1A"; Set-ResourceColor "ThemeCardBg" "#001125"; Set-ResourceColor "ThemeFg" "#E0F7FA"; Set-ResourceColor "ThemeAccent" "#00FFFF"; Set-ResourceColor "ThemeSidebarFg" "#00FFFF"; Set-ResourceColor "ThemeWinCtrl" "#00FFFF"; Set-ResourceColor "ThemeSubText" "#00FFFF"; Set-ResourceColor "ThemeTitleFg" "#00FFFF" }
            5 { Set-ResourceColor "ThemeBg" "#2E3440"; Set-ResourceColor "ThemeSidebar" "#3B4252"; Set-ResourceColor "ThemeCardBg" "#434C5E"; Set-ResourceColor "ThemeFg" "#ECEFF4"; Set-ResourceColor "ThemeAccent" "#88C0D0"; Set-ResourceColor "ThemeSidebarFg" "#D8DEE9"; Set-ResourceColor "ThemeWinCtrl" "#ECEFF4"; Set-ResourceColor "ThemeSubText" "#E5E9F0"; Set-ResourceColor "ThemeTitleFg" "#88C0D0" }
            6 { Set-ResourceColor "ThemeBg" "#1A1B26"; Set-ResourceColor "ThemeSidebar" "#16161E"; Set-ResourceColor "ThemeCardBg" "#24283B"; Set-ResourceColor "ThemeFg" "#C0CAF5"; Set-ResourceColor "ThemeAccent" "#7AA2F7"; Set-ResourceColor "ThemeSidebarFg" "#787C99"; Set-ResourceColor "ThemeWinCtrl" "#7AA2F7"; Set-ResourceColor "ThemeSubText" "#565F89"; Set-ResourceColor "ThemeTitleFg" "#7AA2F7" }
            7 { Set-ResourceColor "ThemeBg" "#282828"; Set-ResourceColor "ThemeSidebar" "#1D2021"; Set-ResourceColor "ThemeCardBg" "#32302F"; Set-ResourceColor "ThemeFg" "#EBDBB2"; Set-ResourceColor "ThemeAccent" "#D79921"; Set-ResourceColor "ThemeSidebarFg" "#A89984"; Set-ResourceColor "ThemeWinCtrl" "#EBDBB2"; Set-ResourceColor "ThemeSubText" "#928374"; Set-ResourceColor "ThemeTitleFg" "#D79921" }
            8 { Set-ResourceColor "ThemeBg" "#D4D0C8"; Set-ResourceColor "ThemeSidebar" "#D4D0C8"; Set-ResourceColor "ThemeCardBg" "#FFFFFF"; Set-ResourceColor "ThemeFg" "#000000"; Set-ResourceColor "ThemeAccent" "#000080"; Set-ResourceColor "ThemeSidebarFg" "#000000"; Set-ResourceColor "ThemeWinCtrl" "#000000"; Set-ResourceColor "ThemeSubText" "#444444"; Set-ResourceColor "ThemeTitleFg" "#000080" }
            9 { Set-ResourceColor "ThemeBg" "#3B3B3B"; Set-ResourceColor "ThemeSidebar" "#3B3B3B"; Set-ResourceColor "ThemeCardBg" "#202020"; Set-ResourceColor "ThemeFg" "#FFFFFF"; Set-ResourceColor "ThemeAccent" "#5792EA"; Set-ResourceColor "ThemeSidebarFg" "#FFFFFF"; Set-ResourceColor "ThemeWinCtrl" "#FFFFFF"; Set-ResourceColor "ThemeSubText" "#CCCCCC"; Set-ResourceColor "ThemeTitleFg" "#5792EA" }
            10 { $imgBrush = New-Object System.Windows.Media.ImageBrush; $uri = New-Object System.Uri("https://upload.wikimedia.org/wikipedia/commons/thumb/e/ea/Van_Gogh_-_Starry_Night_-_Google_Art_Project.jpg/1280px-Van_Gogh_-_Starry_Night_-_Google_Art_Project.jpg"); $imgBrush.ImageSource = New-Object System.Windows.Media.Imaging.BitmapImage($uri); $imgBrush.Stretch = "UniformToFill"; $window.Resources.Remove("ThemeBg"); $window.Resources.Add("ThemeBg", $imgBrush); Set-ResourceColor "ThemeSidebar" "#CC0C1445"; Set-ResourceColor "ThemeCardBg" "#CC1C2566"; Set-ResourceColor "ThemeFg" "#FFFFFF"; Set-ResourceColor "ThemeAccent" "#8AB4F8"; Set-ResourceColor "ThemeSidebarFg" "#8AB4F8"; Set-ResourceColor "ThemeWinCtrl" "#FFFFFF"; Set-ResourceColor "ThemeSubText" "#D0E0FF"; Set-ResourceColor "ThemeTitleFg" "#8AB4F8" }
            11 { $imgBrush = New-Object System.Windows.Media.ImageBrush; $uri = New-Object System.Uri("https://upload.wikimedia.org/wikipedia/commons/thumb/a/a5/Tsunami_by_hokusai_19th_century.jpg/1280px-Tsunami_by_hokusai_19th_century.jpg"); $imgBrush.ImageSource = New-Object System.Windows.Media.Imaging.BitmapImage($uri); $imgBrush.Stretch = "UniformToFill"; $window.Resources.Remove("ThemeBg"); $window.Resources.Add("ThemeBg", $imgBrush); Set-ResourceColor "ThemeSidebar" "#CC001133"; Set-ResourceColor "ThemeCardBg" "#CC002244"; Set-ResourceColor "ThemeFg" "#FFFFFF"; Set-ResourceColor "ThemeAccent" "#FFFFFF"; Set-ResourceColor "ThemeSidebarFg" "#FFFFFF"; Set-ResourceColor "ThemeWinCtrl" "#FFFFFF"; Set-ResourceColor "ThemeSubText" "#DDDDDD"; Set-ResourceColor "ThemeTitleFg" "#FFFFFF" }
            12 { Set-ResourceColor "ThemeBg" "#008080"; Set-ResourceColor "ThemeSidebar" "#C0C0C0"; Set-ResourceColor "ThemeCardBg" "#C0C0C0"; Set-ResourceColor "ThemeFg" "#000000"; Set-ResourceColor "ThemeAccent" "#000080"; Set-ResourceColor "ThemeSidebarFg" "#000000"; Set-ResourceColor "ThemeWinCtrl" "#FFFFFF"; Set-ResourceColor "ThemeSubText" "#333333"; Set-ResourceColor "ThemeBorder" "#FFFFFF"; Set-Resource "ThemeCornerRadius" (New-Object System.Windows.CornerRadius(0)); Set-ResourceColor "ThemeTitleBg" "#000080"; Set-ResourceColor "ThemeTitleFg" "#FFFFFF"; Set-Resource "VisModern" ([System.Windows.Visibility]::Collapsed); Set-Resource "VisRetro" ([System.Windows.Visibility]::Visible); Set-Resource "ThemeBorderThickness" (New-Object System.Windows.Thickness(2)) }
            13 { $imgBrush = New-Object System.Windows.Media.ImageBrush; $uri = New-Object System.Uri("https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?q=80&w=2564&auto=format&fit=crop"); $imgBrush.ImageSource = New-Object System.Windows.Media.Imaging.BitmapImage($uri); $imgBrush.Stretch = "UniformToFill"; $window.Resources.Remove("ThemeBg"); $window.Resources.Add("ThemeBg", $imgBrush); Set-ResourceColor "ThemeSidebar" "#CC050510"; Set-ResourceColor "ThemeCardBg" "#991E1E2C"; Set-ResourceColor "ThemeFg" "#FFFFFF"; Set-ResourceColor "ThemeAccent" "#00E0FF"; Set-ResourceColor "ThemeSidebarFg" "#E0E0FF"; Set-ResourceColor "ThemeWinCtrl" "#FFFFFF"; Set-ResourceColor "ThemeSubText" "#B0B0C0"; Set-ResourceColor "ThemeTitleFg" "#FFFFFF"; Set-ResourceColor "ThemeBorder" "#33FFFFFF" }
            14 { Set-ResourceColor "ThemeBg" "#09090B"; Set-ResourceColor "ThemeSidebar" "#111111"; Set-ResourceColor "ThemeCardBg" "#18181B"; Set-ResourceColor "ThemeFg" "#FAFAFA"; Set-ResourceColor "ThemeAccent" "#4C8BF5"; Set-ResourceColor "ThemeSidebarFg" "#A1A1AA"; Set-ResourceColor "ThemeWinCtrl" "#E4E4E7"; Set-ResourceColor "ThemeSubText" "#71717A"; Set-ResourceColor "ThemeTitleFg" "#4C8BF5"; Set-ResourceColor "ThemeBorder" "#27272A"; Set-Resource "ThemeCornerRadius" (New-Object System.Windows.CornerRadius(24)) }
            15 { 
                $imgBrush = New-Object System.Windows.Media.ImageBrush
                $imgBrush.ImageSource = Get-AssetBitmap -Name "wii.png"
                $imgBrush.Stretch = "UniformToFill"
                $window.Resources.Remove("ThemeBg")
                $window.Resources.Add("ThemeBg", $imgBrush)
                
                Set-ResourceColor "ThemeSidebar" "#EEF2F5"
                Set-ResourceColor "ThemeCardBg" "#FFFFFF"
                Set-ResourceColor "ThemeFg" "#333333"
                Set-ResourceColor "ThemeAccent" "#00AEEF"
                Set-ResourceColor "ThemeSidebarFg" "#00AEEF"
                Set-ResourceColor "ThemeWinCtrl" "#00AEEF"
                Set-ResourceColor "ThemeSubText" "#666666"
                Set-ResourceColor "ThemeTitleFg" "#00AEEF"
                Set-ResourceColor "ThemeBorder" "#D0DCE5"
                
                Set-Resource "ThemeCornerRadius" (New-Object System.Windows.CornerRadius(30))
                Set-Resource "ThemeBorderThickness" (New-Object System.Windows.Thickness(2))
                
                $wiiBlue = New-Object System.Windows.Media.SolidColorBrush([System.Windows.Media.ColorConverter]::ConvertFromString("#00AEEF"))
                $clock = Get-GuiElement "lblTimeClock"
                if ($clock) { $clock.Foreground = $wiiBlue; $clock.FontSize = 96 }
                $date = Get-GuiElement "lblDateClock"
                if ($date) { $date.Foreground = $wiiBlue }
            }
            16 { # Super Mario
                $imgBrush = New-Object System.Windows.Media.ImageBrush
                $imgBrush.ImageSource = Get-AssetBitmap -Name "mario.png"
                $imgBrush.Stretch = "UniformToFill"
                $window.Resources.Remove("ThemeBg")
                $window.Resources.Add("ThemeBg", $imgBrush)
                Set-ResourceColor "ThemeSidebar" "#B01E1A"
                Set-ResourceColor "ThemeCardBg" "#049CD8"
                Set-ResourceColor "ThemeFg" "#FFFFFF"
                Set-ResourceColor "ThemeAccent" "#FBD000"
                Set-ResourceColor "ThemeSidebarFg" "#FFFFFF"
                Set-ResourceColor "ThemeWinCtrl" "#FBD000"
                Set-ResourceColor "ThemeSubText" "#EEEEEE"
                Set-ResourceColor "ThemeTitleFg" "#FBD000"
                Set-ResourceColor "ThemeBorder" "#FFFFFF"
            }
            17 { # PS2
                $imgBrush = New-Object System.Windows.Media.ImageBrush
                $imgBrush.ImageSource = Get-AssetBitmap -Name "ps2.png"
                $imgBrush.Stretch = "UniformToFill"
                $window.Resources.Remove("ThemeBg")
                $window.Resources.Add("ThemeBg", $imgBrush)
                Set-ResourceColor "ThemeSidebar" "#000000"
                Set-ResourceColor "ThemeCardBg" "#001A4D"
                Set-ResourceColor "ThemeFg" "#FFFFFF"
                Set-ResourceColor "ThemeAccent" "#00A4FF"
                Set-ResourceColor "ThemeSidebarFg" "#00A4FF"
                Set-ResourceColor "ThemeWinCtrl" "#00A4FF"
                Set-ResourceColor "ThemeSubText" "#AAAAAA"
                Set-ResourceColor "ThemeTitleFg" "#00A4FF"
                Set-ResourceColor "ThemeBorder" "#004080"
            }
            18 { # Windows XP Bliss
                $imgBrush = New-Object System.Windows.Media.ImageBrush
                $imgBrush.ImageSource = Get-AssetBitmap -Name "winxp.png"
                $imgBrush.Stretch = "UniformToFill"
                $window.Resources.Remove("ThemeBg")
                $window.Resources.Add("ThemeBg", $imgBrush)
                Set-ResourceColor "ThemeSidebar" "#FF245EDB"
                Set-ResourceColor "ThemeCardBg" "#E0F0F0F0"
                Set-ResourceColor "ThemeFg" "#003399"
                Set-ResourceColor "ThemeAccent" "#FF8C00"
                Set-ResourceColor "ThemeSidebarFg" "#FFFFFF"
                Set-ResourceColor "ThemeWinCtrl" "#FFFFFF"
                Set-ResourceColor "ThemeSubText" "#444444"
                Set-ResourceColor "ThemeTitleFg" "#FFFFFF"
                Set-ResourceColor "ThemeBorder" "#0054E3"
                Set-ResourceColor "ThemeTitleBg" "#0054E3"
                Set-Resource "ThemeCornerRadius" (New-Object System.Windows.CornerRadius(15))
                Set-Resource "ThemeBorderThickness" (New-Object System.Windows.Thickness(3))
            }
            19 { # Windows 7 Official Harmony
                $imgBrush = New-Object System.Windows.Media.ImageBrush
                $imgBrush.ImageSource = Get-AssetBitmap -Name "vista7.png"
                $imgBrush.Stretch = "UniformToFill"
                $window.Resources.Remove("ThemeBg")
                $window.Resources.Add("ThemeBg", $imgBrush)
                Set-ResourceColor "ThemeFg" "#001A33"
                Set-ResourceColor "ThemeAccent" "#00A2E8"
                Set-ResourceColor "ThemeSidebarFg" "#002244"
                Set-ResourceColor "ThemeWinCtrl" "#001A33"
                Set-ResourceColor "ThemeSubText" "#003366"
                Set-ResourceColor "ThemeTitleFg" "#002244"
                Set-ResourceColor "ThemeBorder" "#AAFFFFFF"
                Set-Resource "ThemeCornerRadius" (New-Object System.Windows.CornerRadius(6))
                Set-Resource "ThemeBorderThickness" (New-Object System.Windows.Thickness(1))
                $sideGrad = New-Object System.Windows.Media.LinearGradientBrush
                $sideGrad.StartPoint = "0,0"; $sideGrad.EndPoint = "0,1"
                $sideGrad.GradientStops.Add((New-Object System.Windows.Media.GradientStop([System.Windows.Media.ColorConverter]::ConvertFromString("#DDAACCFF"), 0.0)))
                $sideGrad.GradientStops.Add((New-Object System.Windows.Media.GradientStop([System.Windows.Media.ColorConverter]::ConvertFromString("#9972A1C2"), 0.5)))
                $sideGrad.GradientStops.Add((New-Object System.Windows.Media.GradientStop([System.Windows.Media.ColorConverter]::ConvertFromString("#BB336699"), 1.0)))
                Set-Resource "ThemeSidebar" $sideGrad
                $cardGrad = New-Object System.Windows.Media.LinearGradientBrush
                $cardGrad.StartPoint = "0,0"; $cardGrad.EndPoint = "1,1"
                $cardGrad.GradientStops.Add((New-Object System.Windows.Media.GradientStop([System.Windows.Media.ColorConverter]::ConvertFromString("#D9FFFFFF"), 0.0)))
                $cardGrad.GradientStops.Add((New-Object System.Windows.Media.GradientStop([System.Windows.Media.ColorConverter]::ConvertFromString("#B3EEF5FF"), 1.0)))
                Set-Resource "ThemeCardBg" $cardGrad
            }
            20 { # Xbox Original
                $imgBrush = New-Object System.Windows.Media.ImageBrush
                $imgBrush.ImageSource = Get-AssetBitmap -Name "xbox_orig.png"
                $imgBrush.Stretch = "UniformToFill"
                $window.Resources.Remove("ThemeBg")
                $window.Resources.Add("ThemeBg", $imgBrush)
                Set-ResourceColor "ThemeSidebar" "#CC051005"
                Set-ResourceColor "ThemeCardBg" "#990A200A"
                Set-ResourceColor "ThemeFg" "#33FF33"
                Set-ResourceColor "ThemeAccent" "#00FF00"
                Set-ResourceColor "ThemeSidebarFg" "#00FF00"
                Set-ResourceColor "ThemeWinCtrl" "#00FF00"
                Set-ResourceColor "ThemeSubText" "#008800"
                Set-ResourceColor "ThemeTitleFg" "#00FF00"
                Set-ResourceColor "ThemeBorder" "#00AA00"
            }
            21 { # Xbox 360
                $imgBrush = New-Object System.Windows.Media.ImageBrush
                $imgBrush.ImageSource = Get-AssetBitmap -Name "xbox_360.png"
                $imgBrush.Stretch = "UniformToFill"
                $window.Resources.Remove("ThemeBg")
                $window.Resources.Add("ThemeBg", $imgBrush)
                Set-ResourceColor "ThemeSidebar" "#CCF0F0F0"
                Set-ResourceColor "ThemeCardBg" "#EEFFFFFF"
                Set-ResourceColor "ThemeFg" "#333333"
                Set-ResourceColor "ThemeAccent" "#107C10"
                Set-ResourceColor "ThemeSidebarFg" "#107C10"
                Set-ResourceColor "ThemeWinCtrl" "#107C10"
                Set-ResourceColor "ThemeSubText" "#666666"
                Set-ResourceColor "ThemeTitleFg" "#107C10"
                Set-ResourceColor "ThemeBorder" "#E0E0E0"
                Set-Resource "ThemeCornerRadius" (New-Object System.Windows.CornerRadius(10))
            }
            22 { # GTA San Andreas
                $imgBrush = New-Object System.Windows.Media.ImageBrush
                $imgBrush.ImageSource = New-Object System.Windows.Media.Imaging.BitmapImage(New-Object System.Uri("C:\MENU\backgrounds\gta_sa.png"))
                $imgBrush.Stretch = "UniformToFill"
                $window.Resources.Remove("ThemeBg")
                $window.Resources.Add("ThemeBg", $imgBrush)
                
                Set-ResourceColor "ThemeSidebar" "#CC103010"
                Set-ResourceColor "ThemeCardBg" "#E6E5D4B2"
                Set-ResourceColor "ThemeFg" "#000000"
                Set-ResourceColor "ThemeAccent" "#275C21"
                Set-ResourceColor "ThemeSidebarFg" "#FFFFFF"
                Set-ResourceColor "ThemeWinCtrl" "#000000"
                Set-ResourceColor "ThemeSubText" "#333333"
                Set-ResourceColor "ThemeTitleFg" "#275C21"
                Set-ResourceColor "ThemeBorder" "#000000"
                Set-Resource "ThemeFont" (New-Object System.Windows.Media.FontFamily("Impact, Arial Black, sans-serif"))
                Set-Resource "ThemeCornerRadius" (New-Object System.Windows.CornerRadius(0))
                Set-Resource "ThemeBorderThickness" (New-Object System.Windows.Thickness(3))
            }
            23 { # Cyberpunk 2077
                $imgBrush = New-Object System.Windows.Media.ImageBrush
                $imgBrush.ImageSource = New-Object System.Windows.Media.Imaging.BitmapImage(New-Object System.Uri("C:\MENU\backgrounds\cyberpunk.png"))
                $imgBrush.Stretch = "UniformToFill"
                $window.Resources.Remove("ThemeBg")
                $window.Resources.Add("ThemeBg", $imgBrush)
                
                Set-ResourceColor "ThemeSidebar" "#CC0F0F0F"
                Set-ResourceColor "ThemeCardBg" "#E61A1A1A"
                Set-ResourceColor "ThemeFg" "#FCEE09"
                Set-ResourceColor "ThemeAccent" "#00FFFF"
                Set-ResourceColor "ThemeSidebarFg" "#FCEE09"
                Set-ResourceColor "ThemeWinCtrl" "#FCEE09"
                Set-ResourceColor "ThemeSubText" "#B3A700"
                Set-ResourceColor "ThemeTitleFg" "#00FFFF"
                Set-ResourceColor "ThemeBorder" "#00FFFF"
                Set-Resource "ThemeCornerRadius" (New-Object System.Windows.CornerRadius(0))
            }
            24 { # Fallout Pip-Boy
                $imgBrush = New-Object System.Windows.Media.ImageBrush
                $imgBrush.ImageSource = New-Object System.Windows.Media.Imaging.BitmapImage(New-Object System.Uri("C:\MENU\backgrounds\pipboy.png"))
                $imgBrush.Stretch = "UniformToFill"
                $window.Resources.Remove("ThemeBg")
                $window.Resources.Add("ThemeBg", $imgBrush)
                
                Set-ResourceColor "ThemeSidebar" "#EE0A140A"
                Set-ResourceColor "ThemeCardBg" "#EE0F1E0F"
                Set-ResourceColor "ThemeFg" "#14FF14"
                Set-ResourceColor "ThemeAccent" "#14FF14"
                Set-ResourceColor "ThemeSidebarFg" "#14FF14"
                Set-ResourceColor "ThemeWinCtrl" "#14FF14"
                Set-ResourceColor "ThemeSubText" "#0A880A"
                Set-ResourceColor "ThemeTitleFg" "#14FF14"
                Set-ResourceColor "ThemeBorder" "#14FF14"
                Set-Resource "ThemeFont" (New-Object System.Windows.Media.FontFamily("Consolas, Courier New, monospace"))
                Set-Resource "ThemeCornerRadius" (New-Object System.Windows.CornerRadius(10))
            }
            25 { # Goat Simulator
                $imgBrush = New-Object System.Windows.Media.ImageBrush
                $imgBrush.ImageSource = New-Object System.Windows.Media.Imaging.BitmapImage(New-Object System.Uri("C:\MENU\backgrounds\goat.png"))
                $imgBrush.Stretch = "UniformToFill"
                $window.Resources.Remove("ThemeBg")
                $window.Resources.Add("ThemeBg", $imgBrush)
                
                Set-ResourceColor "ThemeSidebar" "#B34A3018"
                Set-ResourceColor "ThemeCardBg" "#E688C43F"
                Set-ResourceColor "ThemeFg" "#222222"
                Set-ResourceColor "ThemeAccent" "#FF3366"
                Set-ResourceColor "ThemeSidebarFg" "#FFFFFF"
                Set-ResourceColor "ThemeWinCtrl" "#FF3366"
                Set-ResourceColor "ThemeSubText" "#333333"
                Set-ResourceColor "ThemeTitleFg" "#FF3366"
                Set-ResourceColor "ThemeBorder" "#FF3366"
                Set-Resource "ThemeFont" (New-Object System.Windows.Media.FontFamily("Comic Sans MS, Comic Sans, cursive"))
                Set-Resource "ThemeCornerRadius" (New-Object System.Windows.CornerRadius(20))
                Set-Resource "ThemeBorderThickness" (New-Object System.Windows.Thickness(4))
            }
            26 { # Minecraft
                $imgBrush = New-Object System.Windows.Media.ImageBrush
                $imgBrush.ImageSource = New-Object System.Windows.Media.Imaging.BitmapImage(New-Object System.Uri("C:\MENU\backgrounds\minecraft.png"))
                $imgBrush.Stretch = "UniformToFill"
                $window.Resources.Remove("ThemeBg")
                $window.Resources.Add("ThemeBg", $imgBrush)
                
                Set-ResourceColor "ThemeSidebar" "#995C3A21"
                Set-ResourceColor "ThemeCardBg" "#E68D9F65"
                Set-ResourceColor "ThemeFg" "#222222"
                Set-ResourceColor "ThemeAccent" "#51923E"
                Set-ResourceColor "ThemeSidebarFg" "#FFFFFF"
                Set-ResourceColor "ThemeWinCtrl" "#51923E"
                Set-ResourceColor "ThemeSubText" "#333333"
                Set-ResourceColor "ThemeTitleFg" "#51923E"
                Set-ResourceColor "ThemeBorder" "#332211"
                Set-Resource "ThemeFont" (New-Object System.Windows.Media.FontFamily("Consolas, Courier New, monospace"))
                Set-Resource "ThemeCornerRadius" (New-Object System.Windows.CornerRadius(0))
                Set-Resource "ThemeBorderThickness" (New-Object System.Windows.Thickness(2))
            }
            27 { # Halo 3
                $imgBrush = New-Object System.Windows.Media.ImageBrush
                $imgBrush.ImageSource = New-Object System.Windows.Media.Imaging.BitmapImage(New-Object System.Uri("C:\MENU\backgrounds\halo3.png"))
                $imgBrush.Stretch = "UniformToFill"
                $window.Resources.Remove("ThemeBg")
                $window.Resources.Add("ThemeBg", $imgBrush)
                
                Set-ResourceColor "ThemeSidebar" "#CC15202B"
                Set-ResourceColor "ThemeCardBg" "#DD1D3043"
                Set-ResourceColor "ThemeFg" "#90D1E5"
                Set-ResourceColor "ThemeAccent" "#F8A12F"
                Set-ResourceColor "ThemeSidebarFg" "#90D1E5"
                Set-ResourceColor "ThemeWinCtrl" "#F8A12F"
                Set-ResourceColor "ThemeSubText" "#7B9BAD"
                Set-ResourceColor "ThemeTitleFg" "#F8A12F"
                Set-ResourceColor "ThemeBorder" "#456277"
                Set-Resource "ThemeFont" (New-Object System.Windows.Media.FontFamily("Impact, sans-serif"))
                Set-Resource "ThemeCornerRadius" (New-Object System.Windows.CornerRadius(8))
            }
            28 { # Counter-Strike 1.6
                $imgBrush = New-Object System.Windows.Media.ImageBrush
                $imgBrush.ImageSource = New-Object System.Windows.Media.Imaging.BitmapImage(New-Object System.Uri("C:\MENU\backgrounds\cs16.png"))
                $imgBrush.Stretch = "UniformToFill"
                $window.Resources.Remove("ThemeBg")
                $window.Resources.Add("ThemeBg", $imgBrush)
                
                Set-ResourceColor "ThemeSidebar" "#CC434839"
                Set-ResourceColor "ThemeCardBg" "#E6CDAA7A"
                Set-ResourceColor "ThemeFg" "#111111"
                Set-ResourceColor "ThemeAccent" "#D9A05B"
                Set-ResourceColor "ThemeSidebarFg" "#FFFFFF"
                Set-ResourceColor "ThemeWinCtrl" "#111111"
                Set-ResourceColor "ThemeSubText" "#333333"
                Set-ResourceColor "ThemeTitleFg" "#111111"
                Set-ResourceColor "ThemeBorder" "#2D2E24"
                Set-Resource "ThemeFont" (New-Object System.Windows.Media.FontFamily("Tahoma, Arial, sans-serif"))
                Set-Resource "ThemeCornerRadius" (New-Object System.Windows.CornerRadius(0))
            }
            29 { # Half-Life 2
                $imgBrush = New-Object System.Windows.Media.ImageBrush
                $imgBrush.ImageSource = New-Object System.Windows.Media.Imaging.BitmapImage(New-Object System.Uri("C:\MENU\backgrounds\hl2.png"))
                $imgBrush.Stretch = "UniformToFill"
                $window.Resources.Remove("ThemeBg")
                $window.Resources.Add("ThemeBg", $imgBrush)
                
                Set-ResourceColor "ThemeSidebar" "#CC292E31"
                Set-ResourceColor "ThemeCardBg" "#DD40474A"
                Set-ResourceColor "ThemeFg" "#E3E0D5"
                Set-ResourceColor "ThemeAccent" "#FF9900"
                Set-ResourceColor "ThemeSidebarFg" "#E3E0D5"
                Set-ResourceColor "ThemeWinCtrl" "#FF9900"
                Set-ResourceColor "ThemeSubText" "#A7A59A"
                Set-ResourceColor "ThemeTitleFg" "#FF9900"
                Set-ResourceColor "ThemeBorder" "#1A1D1E"
                Set-Resource "ThemeFont" (New-Object System.Windows.Media.FontFamily("Trebuchet MS, sans-serif"))
                Set-Resource "ThemeCornerRadius" (New-Object System.Windows.CornerRadius(2))
            }
            30 { # Doom Classic
                $imgBrush = New-Object System.Windows.Media.ImageBrush
                $imgBrush.ImageSource = New-Object System.Windows.Media.Imaging.BitmapImage(New-Object System.Uri("C:\MENU\backgrounds\doom.png"))
                $imgBrush.Stretch = "UniformToFill"
                $window.Resources.Remove("ThemeBg")
                $window.Resources.Add("ThemeBg", $imgBrush)
                
                Set-ResourceColor "ThemeSidebar" "#CC220000"
                Set-ResourceColor "ThemeCardBg" "#E6440505"
                Set-ResourceColor "ThemeFg" "#FFAAAA"
                Set-ResourceColor "ThemeAccent" "#FF0000"
                Set-ResourceColor "ThemeSidebarFg" "#FFFFFF"
                Set-ResourceColor "ThemeWinCtrl" "#00FF00"
                Set-ResourceColor "ThemeSubText" "#CC7777"
                Set-ResourceColor "ThemeTitleFg" "#FF0000"
                Set-ResourceColor "ThemeBorder" "#880000"
                Set-Resource "ThemeFont" (New-Object System.Windows.Media.FontFamily("Impact, sans-serif"))
                Set-Resource "ThemeCornerRadius" (New-Object System.Windows.CornerRadius(0))
            }
            31 { # Portal
                $imgBrush = New-Object System.Windows.Media.ImageBrush
                $imgBrush.ImageSource = New-Object System.Windows.Media.Imaging.BitmapImage(New-Object System.Uri("C:\MENU\backgrounds\portal.png"))
                $imgBrush.Stretch = "UniformToFill"
                $window.Resources.Remove("ThemeBg")
                $window.Resources.Add("ThemeBg", $imgBrush)
                
                Set-ResourceColor "ThemeSidebar" "#CCEEEEEE"
                Set-ResourceColor "ThemeCardBg" "#F5FFFFFF"
                Set-ResourceColor "ThemeFg" "#333333"
                Set-ResourceColor "ThemeAccent" "#00AEEF"
                Set-ResourceColor "ThemeSidebarFg" "#111111"
                Set-ResourceColor "ThemeWinCtrl" "#F78E1E"
                Set-ResourceColor "ThemeSubText" "#666666"
                Set-ResourceColor "ThemeTitleFg" "#00AEEF"
                Set-ResourceColor "ThemeBorder" "#CCCCCC"
                Set-Resource "ThemeFont" (New-Object System.Windows.Media.FontFamily("Arial, sans-serif"))
                Set-Resource "ThemeCornerRadius" (New-Object System.Windows.CornerRadius(10))
            }
            32 { # PS5 Dashboard
                $imgBrush = New-Object System.Windows.Media.ImageBrush
                $imgBrush.ImageSource = New-Object System.Windows.Media.Imaging.BitmapImage(New-Object System.Uri("C:\MENU\backgrounds\ps5.png"))
                $imgBrush.Stretch = "UniformToFill"
                $window.Resources.Remove("ThemeBg")
                $window.Resources.Add("ThemeBg", $imgBrush)
                
                Set-ResourceColor "ThemeSidebar" "#99000C24"
                Set-ResourceColor "ThemeCardBg" "#B300133A"
                Set-ResourceColor "ThemeFg" "#FFFFFF"
                Set-ResourceColor "ThemeAccent" "#FFFFFF"
                Set-ResourceColor "ThemeSidebarFg" "#E0E0E0"
                Set-ResourceColor "ThemeWinCtrl" "#FFFFFF"
                Set-ResourceColor "ThemeSubText" "#B0C4DE"
                Set-ResourceColor "ThemeTitleFg" "#FFFFFF"
                Set-ResourceColor "ThemeBorder" "#33FFFFFF"
                Set-Resource "ThemeFont" (New-Object System.Windows.Media.FontFamily("Segoe UI, sans-serif"))
                Set-Resource "ThemeCornerRadius" (New-Object System.Windows.CornerRadius(14))
            }
            33 { # Netflix Red
                $imgBrush = New-Object System.Windows.Media.ImageBrush
                $imgBrush.ImageSource = New-Object System.Windows.Media.Imaging.BitmapImage(New-Object System.Uri("C:\MENU\backgrounds\netflix.png"))
                $imgBrush.Stretch = "UniformToFill"
                $window.Resources.Remove("ThemeBg")
                $window.Resources.Add("ThemeBg", $imgBrush)
                
                Set-ResourceColor "ThemeSidebar" "#E6000000"
                Set-ResourceColor "ThemeCardBg" "#CC141414"
                Set-ResourceColor "ThemeFg" "#E5E5E5"
                Set-ResourceColor "ThemeAccent" "#E50914"
                Set-ResourceColor "ThemeSidebarFg" "#B3B3B3"
                Set-ResourceColor "ThemeWinCtrl" "#E50914"
                Set-ResourceColor "ThemeSubText" "#808080"
                Set-ResourceColor "ThemeTitleFg" "#E5E5E5"
                Set-ResourceColor "ThemeBorder" "#33E50914"
                Set-Resource "ThemeFont" (New-Object System.Windows.Media.FontFamily("Helvetica Neue, Segoe UI, sans-serif"))
                Set-Resource "ThemeCornerRadius" (New-Object System.Windows.CornerRadius(4))
            }
            34 { # Deep Space
                $imgBrush = New-Object System.Windows.Media.ImageBrush
                $imgBrush.ImageSource = New-Object System.Windows.Media.Imaging.BitmapImage(New-Object System.Uri("C:\MENU\backgrounds\deepspace.png"))
                $imgBrush.Stretch = "UniformToFill"
                $window.Resources.Remove("ThemeBg")
                $window.Resources.Add("ThemeBg", $imgBrush)
                
                Set-ResourceColor "ThemeSidebar" "#99020012"
                Set-ResourceColor "ThemeCardBg" "#B3050024"
                Set-ResourceColor "ThemeFg" "#FFFFFF"
                Set-ResourceColor "ThemeAccent" "#B98DFF"
                Set-ResourceColor "ThemeSidebarFg" "#E0D5FF"
                Set-ResourceColor "ThemeWinCtrl" "#FFFFFF"
                Set-ResourceColor "ThemeSubText" "#A397D8"
                Set-ResourceColor "ThemeTitleFg" "#FFFFFF"
                Set-ResourceColor "ThemeBorder" "#44B98DFF"
                Set-Resource "ThemeFont" (New-Object System.Windows.Media.FontFamily("Consolas, sans-serif"))
                Set-Resource "ThemeCornerRadius" (New-Object System.Windows.CornerRadius(10))
            }
            35 { # Custom Background
                # Dialog is handled by the dedicated button now
            }
        }
    })
# Handler for the dedicated Custom Theme button
Set-Click "btnThemeCustom" { Trigger-Custom-Theme | Out-Null }

$cmbThemes.SelectedIndex = $randomIndex

# --- NAVIGATION (OPTIMIZED FOR INSTANT SWITCHING) ---
# Cache all panel references ONCE for better performance
$pnlHome = Get-GuiElement "pnlHome"
$pnlEssentials = Get-GuiElement "pnlEssentials"
$pnlAIBots = Get-GuiElement "pnlAIBots"
$pnlWindowsTools = Get-GuiElement "pnlWindowsTools"
$pnlUserMgmt = Get-GuiElement "pnlUserMgmt"
$pnlSysInfoTools = Get-GuiElement "pnlSysInfoTools"
$pnlTweaks = Get-GuiElement "pnlTweaks"
$pnlMaintenance = Get-GuiElement "pnlMaintenance"
$pnlUpdateMgr = Get-GuiElement "pnlUpdateMgr"
$pnlSecurity = Get-GuiElement "pnlSecurity"
$pnlMusic = Get-GuiElement "pnlMusic"
$pnlPower = Get-GuiElement "pnlPower"
$pnlNanoBanana = Get-GuiElement "pnlNanoBanana"
$pnlBeast = Get-GuiElement "pnlBeast"
$pnlTV = Get-GuiElement "pnlIsraelTV"
$pnlGaming = Get-GuiElement "pnlGaming"
$pnlKeyboardShortcuts = Get-GuiElement "pnlKeyboardShortcuts"
$lstUsers = Get-GuiElement "lstUsers"


# Store in array for Switch-Panel function
$panels = @($pnlHome, $pnlEssentials, $pnlAIBots, $pnlWindowsTools, $pnlUserMgmt, $pnlSysInfoTools, $pnlTweaks, $pnlMaintenance, $pnlUpdateMgr, $pnlSecurity, $pnlMusic, $pnlPower, $pnlNanoBanana, $pnlBeast, $pnlTV, $pnlGaming, $pnlKeyboardShortcuts)
$script:CurrentPanel = $pnlHome
function Switch-Panel { 
    param($P) 
    if (!$P) { return }

    # 1. Hide Current Panel (Instant)
    if ($script:CurrentPanel -and $script:CurrentPanel -ne $P -and $script:CurrentPanel.Visibility -eq "Visible") {
        $script:CurrentPanel.Visibility = "Collapsed"
    }
    
    # 2. Show New Panel
    $trans = New-Object System.Windows.Media.TranslateTransform
    $trans.Y = 20
    $P.RenderTransform = $trans
    $P.Opacity = 0
    $P.Visibility = "Visible"
    
    # 3. Update tracker + sidebar highlight
    $script:CurrentPanel = $P
    Set-SidebarActive $P

    # 4. Animate
    $sb = $window.Resources["FadeInUp"].Clone()
    [System.Windows.Media.Animation.Storyboard]::SetTarget($sb, $P)
    $sb.Begin()
}


# ==============================================================================
# ACTIVE SIDEBAR BUTTON STATE
# ==============================================================================
$script:PanelBtnMap = @{
    "pnlHome"              = "btnHome"
    "pnlAIBots"            = "btnAIBots"
    "pnlEssentials"        = "btnEssentials"
    "pnlWindowsTools"      = "btnWindowsTools"
    "pnlMaintenance"       = "btnMaintenance"
    "pnlMusic"             = "btnMusic"
    "pnlPower"             = "btnPower"
    "pnlSecurity"          = "btnSecurity"
    "pnlUserMgmt"          = "btnUserMgmt"
    "pnlSysInfoTools"      = "btnSysInfoTools"
    "pnlTweaks"            = "btnTweaks"
    "pnlBeast"             = "btnBeast"
    "pnlUpdateMgr"         = "btnUpdateMgr"
    "pnlKeyboardShortcuts" = "btnKeyboardShortcuts"
    "pnlGaming"            = "btnGameCenter"
    "pnlIsraelTV"          = "btnIsraelTV"
}
$script:ActiveSidebarBtn = $null

function Set-SidebarActive {
    param($Panel)
    if ($script:ActiveSidebarBtn) {
        try {
            $script:ActiveSidebarBtn.Background = [System.Windows.Media.Brushes]::Transparent
            $ind = $script:ActiveSidebarBtn.Template.FindName("Indicator", $script:ActiveSidebarBtn)
            if ($ind) { $ind.Background = [System.Windows.Media.Brushes]::Transparent }
        } catch {}
    }
    $panelName = $Panel.Name
    if ($script:PanelBtnMap.ContainsKey($panelName)) {
        $btn = Get-GuiElement $script:PanelBtnMap[$panelName]
        if ($btn) {
            try {
                $accentBrush = $window.Resources["ThemeAccent"]
                $btn.Background = New-Object System.Windows.Media.SolidColorBrush(
                    [System.Windows.Media.Color]::FromArgb(40,
                        $accentBrush.Color.R, $accentBrush.Color.G, $accentBrush.Color.B))
                $ind = $btn.Template.FindName("Indicator", $btn)
                if ($ind) { $ind.Background = $accentBrush }
                $script:ActiveSidebarBtn = $btn
            } catch {}
        }
    }
}
# Use cached variables for instant navigation
(Get-GuiElement "btnHome").Add_Click({ Switch-Panel $pnlHome })
(Get-GuiElement "btnAIBots").Add_Click({ Switch-Panel $pnlAIBots })
(Get-GuiElement "btnEssentials").Add_Click({ Switch-Panel $pnlEssentials })
(Get-GuiElement "btnWindowsTools").Add_Click({ Switch-Panel $pnlWindowsTools })
(Get-GuiElement "btnMaintenance").Add_Click({ Switch-Panel $pnlMaintenance })
(Get-GuiElement "btnMusic").Add_Click({ Switch-Panel $pnlMusic })
(Get-GuiElement "btnPower").Add_Click({ Switch-Panel $pnlPower })
(Get-GuiElement "btnSecurity").Add_Click({ Switch-Panel $pnlSecurity })
(Get-GuiElement "btnUserMgmt").Add_Click({ Switch-Panel $pnlUserMgmt; Refresh-Users })
(Get-GuiElement "btnSysInfoTools").Add_Click({ Switch-Panel $pnlSysInfoTools })
(Get-GuiElement "btnTweaks").Add_Click({ Switch-Panel $pnlTweaks })
(Get-GuiElement "btnBeast").Add_Click({ Switch-Panel $pnlBeast })
(Get-GuiElement "btnUpdateMgr").Add_Click({ Switch-Panel $pnlUpdateMgr })
(Get-GuiElement "btnKeyboardShortcuts").Add_Click({ Switch-Panel $pnlKeyboardShortcuts })

# Restored handlers for missing panels
$btnGaming = Get-GuiElement "btnGaming"
if ($btnGaming) { $btnGaming.Add_Click({ Switch-Panel $pnlGaming }) }

$btnIsraelTV = Get-GuiElement "btnIsraelTV"
if ($btnIsraelTV) { $btnIsraelTV.Add_Click({ Switch-Panel $pnlTV }) }

$btnCinema = Get-GuiElement "btnCinema"
$pnlCinema = Get-GuiElement "pnlCinema"
if ($btnCinema -and $pnlCinema) { $btnCinema.Add_Click({ Switch-Panel $pnlCinema }) }

$btnTV = Get-GuiElement "btnTV"
if ($btnTV) { $btnTV.Add_Click({ Switch-Panel $pnlTV }) }

$btnSettings = Get-GuiElement "btnSettings"
$pnlSettings = Get-GuiElement "pnlSettings"
if ($btnSettings -and $pnlSettings) { $btnSettings.Add_Click({ Switch-Panel $pnlSettings }) }

$btnAbout = Get-GuiElement "btnAbout"
$pnlAbout = Get-GuiElement "pnlAbout"
if ($btnAbout -and $pnlAbout) { $btnAbout.Add_Click({ Switch-Panel $pnlAbout }) }





# --- LANGUAGE ENGINE (Hebrew/English) ---
$script:isHebrew = $false
$langData = @{
    "btnHome"                = @{ En = "Dashboard"; He = "$([char]1500)$([char]1493)$([char]1495)$([char]32)$([char]1489)$([char]1511)$([char]1512)$([char]1492)" }
    "btnAIBots"              = @{ En = "AI and Automation"; He = "$([char]1489)$([char]1497)$([char]1504)$([char]1492)$([char]32)$([char]1502)$([char]1500)$([char]1488)$([char]1499)$([char]1493)$([char]1514)$([char]1497)$([char]1514)" }
    "btnEssentials"          = @{ En = "Essentials (CTT)"; He = "$([char]1499)$([char]1500)$([char]1497)$([char]1501)$([char]32)$([char]1495)$([char]1497)$([char]1493)$([char]1504)$([char]1497)$([char]1497)$([char]1501)" }
    "btnWindowsTools"        = @{ En = "Win Tools"; He = "$([char]1499)$([char]1500)$([char]1497)$([char]32)$([char]1493)$([char]1493)$([char]1497)$([char]1504)$([char]1491)$([char]1493)$([char]1505)" }
    "btnSysInfoTools"        = @{ En = "Hardware"; He = "$([char]1495)$([char]1493)$([char]1502)$([char]1512)$([char]1492)" }
    "btnTweaks"              = @{ En = "Tweaks"; He = "$([char]1513)$([char]1497)$([char]1508)$([char]1493)$([char]1512)$([char]1497)$([char]1501)" }
    "btnMaintenance"         = @{ En = "Cleanup"; He = "$([char]1504)$([char]1497)$([char]1511)$([char]1493)$([char]1497)" }
    "btnUpdateMgr"           = @{ En = "Update Manager"; He = "$([char]1502)$([char]1504)$([char]1492)$([char]1500)$([char]32)$([char]1506)$([char]1491)$([char]1499)$([char]1493)$([char]1504)$([char]1497)$([char]1501)" }
    "btnSecurity"            = @{ En = "Security"; He = "$([char]1488)$([char]1489)$([char]1496)$([char]1495)$([char]1492)" }
    "btnUserMgmt"            = @{ En = "Users"; He = "$([char]1502)$([char]1513)$([char]1514)$([char]1502)$([char]1513)$([char]1497)$([char]1501)" }
    "btnMusic"               = @{ En = "Media Hub"; He = "$([char]1502)$([char]1491)$([char]1497)$([char]1492)" }
    "btnPower"               = @{ En = "Power"; He = "$([char]1504)$([char]1497)$([char]1492)$([char]1493)$([char]1500)$([char]32)$([char]1510)$([char]1512)$([char]1497)$([char]1499)$([char]1514)$([char]32)$([char]1495)$([char]1513)$([char]1502)$([char]1500)" }
    "btnBeast"               = @{ En = "System Health"; He = "$([char]1489)$([char]1512)$([char]1497)$([char]1488)$([char]1493)$([char]1514)$([char]32)$([char]1492)$([char]1502)$([char]1506)$([char]1512)$([char]1499)$([char]1514)" }
    "lblGen"                 = @{ En = "GENERAL"; He = "$([char]1499)$([char]1500)$([char]1500)$([char]1497)" }
    "lblSys"                 = @{ En = "SYSTEM"; He = "$([char]1502)$([char]1506)$([char]1512)$([char]1499)$([char]1514)" }
    "lblAdv"                 = @{ En = "ADVANCED"; He = "$([char]1502)$([char]1514)$([char]1511)$([char]1491)$([char]1501)" }
    "lblOverview"            = @{ En = "Overview"; He = "$([char]1505)$([char]1511)$([char]1497)$([char]1512)$([char]1514)$([char]32)$([char]1500)$([char]1493)$([char]1495)$([char]32)$([char]1492)$([char]1489)$([char]1511)$([char]1512)$([char]1492)" }
    "lblSysStatus"           = @{ En = "System Status"; He = "$([char]1505)$([char]1496)$([char]1496)$([char]1493)$([char]1505)$([char]32)$([char]1502)$([char]1506)$([char]1512)$([char]1499)$([char]1514)" }
    "lblClockTxt"            = @{ En = "Clock"; He = "$([char]32)$([char]1513)$([char]1506)$([char]1493)$([char]1503)" }
    "lblQuickActions"        = @{ En = "Quick Actions"; He = "$([char]1508)$([char]1506)$([char]1493)$([char]1500)$([char]1493)$([char]1514)$([char]32)$([char]1502)$([char]1492)$([char]1497)$([char]1512)$([char]1493)$([char]1514)" }
    "lblThemeTxt"            = @{ En = "Theme:"; He = "$([char]1506)$([char]1512)$([char]1499)$([char]1514)$([char]32)$([char]1504)$([char]1493)$([char]1513)$([char]1488)$([char]58)" }
    "lblRamTxt"              = @{ En = "RAM Usage"; He = "$([char]1513)$([char]1497)$([char]1502)$([char]1493)$([char]1513)$([char]32)$([char]1489)$([char]1512)$([char]1488)$([char]1501)" }
    "lblDiskTxt"             = @{ En = "Disk (C:)"; He = "$([char]1491)$([char]1497)$([char]1505)$([char]1511)$([char]32)$([char]67)$([char]58)" }
    
    # Headers
    "lblAIHeader"            = @{ En = "AI and Automation Hub"; He = "$([char]1502)$([char]1512)$([char]1499)$([char]1494)$([char]32)$([char]1489)$([char]1497)$([char]1504)$([char]1492)$([char]32)$([char]1502)$([char]1500)$([char]1488)$([char]1499)$([char]1493)$([char]1514)$([char]1497)$([char]1514)$([char]32)$([char]1493)$([char]1488)$([char]1493)$([char]1496)$([char]1493)$([char]1502)$([char]1510)$([char]1497)$([char]1492)" }
    "lblEssentials"          = @{ En = "Essentials"; He = "$([char]1495)$([char]1497)$([char]1493)$([char]1504)$([char]1497)$([char]1497)$([char]1501)" }
    "lblWinTools"            = @{ En = "Windows Tools"; He = "$([char]1499)$([char]1500)$([char]1497)$([char]32)$([char]87)$([char]105)$([char]110)$([char]100)$([char]111)$([char]119)$([char]115)" }
    "lblMusicHeader"         = @{ En = "Music Hub"; He = "$([char]1502)$([char]1512)$([char]1499)$([char]1494)$([char]32)$([char]1502)$([char]1493)$([char]1494)$([char]1497)$([char]1511)$([char]1492)" }
    "lblMaintHeader"         = @{ En = "Maintenance"; He = "$([char]1514)$([char]1495)$([char]1494)$([char]1493)$([char]1511)$([char]1492)" }
    "lblUpdateMgrHeader"     = @{ En = "Update Manager"; He = "$([char]1502)$([char]1504)$([char]1492)$([char]1500)$([char]32)$([char]1506)$([char]1491)$([char]1499)$([char]1493)$([char]1504)$([char]1497)$([char]1501)" }
    "lblPowerHeader"         = @{ En = "Power Menu"; He = "$([char]1514)$([char]1508)$([char]1512)$([char]1497)$([char]1496)$([char]32)$([char]1499)$([char]1497)$([char]1489)$([char]1493)$([char]1497)" }
    "lblUserHeader"          = @{ En = "User Management"; He = "$([char]1504)$([char]1497)$([char]1492)$([char]1493)$([char]1500)$([char]32)$([char]1502)$([char]1513)$([char]1514)$([char]1502)$([char]1513)$([char]1497)$([char]1501)" }
    "lblHwHeader"            = @{ En = "Hardware Tools"; He = "$([char]1499)$([char]1500)$([char]1497)$([char]32)$([char]1495)$([char]1493)$([char]1502)$([char]1512)$([char]1492)" }
    "lblSecHeader"           = @{ En = "Security"; He = "$([char]1488)$([char]1489)$([char]1496)$([char]1495)$([char]1492)" }
    "lblTweakHeader"         = @{ En = "UI Tweaks"; He = "$([char]1513)$([char]1497)$([char]1508)$([char]1493)$([char]1512)$([char]1497)$([char]32)$([char]1502)$([char]1502)$([char]1513)$([char]1511)" }
    
    # Quick Actions
    "btnQuickUpdateMgr"      = @{ En = "Update Manager"; He = "$([char]1502)$([char]1504)$([char]1492)$([char]1500)$([char]32)$([char]1506)$([char]1491)$([char]1499)$([char]1493)$([char]1504)$([char]1497)$([char]1501)" }

    # User Management
    "lblLocalUsers"          = @{ En = "Local Users"; He = "$([char]1502)$([char]1513)$([char]1514)$([char]1502)$([char]1513)$([char]1497)$([char]1501)$([char]32)$([char]1502)$([char]1511)$([char]1493)$([char]1502)$([char]1497)$([char]1497)$([char]1501)" }
    "lblUserActions"         = @{ En = "User Actions"; He = "$([char]1508)$([char]1506)$([char]1493)$([char]1500)$([char]1493)$([char]1514)$([char]32)$([char]1502)$([char]1513)$([char]1514)$([char]1502)$([char]1513)" }
    "lblAdvTools"            = @{ En = "Advanced Tools"; He = "$([char]1499)$([char]1500)$([char]1497)$([char]1501)$([char]32)$([char]1502)$([char]1514)$([char]1511)$([char]1491)$([char]1502)$([char]1497)$([char]1501)" }
    "btnRefreshUsers"        = @{ En = "Refresh List"; He = "$([char]1512)$([char]1506)$([char]1504)$([char]1503)$([char]32)$([char]1512)$([char]1513)$([char]1497)$([char]1502)$([char]1492)" }
    "btnCreateUser"          = @{ En = "Create New User"; He = "$([char]1510)$([char]1493)$([char]1512)$([char]32)$([char]1502)$([char]1513)$([char]1514)$([char]1502)$([char]1513)$([char]32)$([char]1495)$([char]1491)$([char]1513)" }
    "btnResetPass"           = @{ En = "Reset Password"; He = "$([char]1488)$([char]1497)$([char]1508)$([char]1493)$([char]1505)$([char]32)$([char]1505)$([char]1497)$([char]1505)$([char]1502)$([char]1492)" }
    "btnToggleActive"        = @{ En = "Enable/Disable"; He = "$([char]1492)$([char]1508)$([char]1506)$([char]1500)$([char]1492)$([char]47)$([char]1489)$([char]1497)$([char]1496)$([char]1493)$([char]1500)" }
    "btnToggleAdmin"         = @{ En = "Toggle Admin"; He = "$([char]1513)$([char]1504)$([char]1492)$([char]32)$([char]1492)$([char]1512)$([char]1513)$([char]1488)$([char]1493)$([char]1514)$([char]32)$([char]1502)$([char]1504)$([char]1492)$([char]1500)" }
    "btnDeleteUser"          = @{ En = "Delete User"; He = "$([char]1502)$([char]1495)$([char]1497)$([char]1511)$([char]1514)$([char]32)$([char]1502)$([char]1513)$([char]1514)$([char]1502)$([char]1513)" }

    # Music Tabs
    "tabIsr"                 = @{ En = "Israeli"; He = "$([char]1497)$([char]1513)$([char]1512)$([char]1488)$([char]1500)$([char]1497)" }
    "tabRock"                = @{ En = "Rock and Metal"; He = "$([char]1512)$([char]1493)$([char]1511)$([char]32)$([char]1493)$([char]1502)$([char]1496)$([char]1488)$([char]1500)" }
    "tabPop"                 = @{ En = "Pop"; He = "$([char]1508)$([char]1493)$([char]1508)" }
    "tabJazz"                = @{ En = "Jazz/Soul"; He = "$([char]1490)$([char]39)$([char]1488)$([char]1494)$([char]47)$([char]1505)$([char]1493)$([char]1500)" }
    "tabOst"                 = @{ En = "OST and Classic"; He = "$([char]1508)$([char]1505)$([char]1511)$([char]1493)$([char]1500)$([char]32)$([char]1493)$([char]1511)$([char]1500)$([char]1488)$([char]1505)$([char]1497)" }
    "tabElec"                = @{ En = "Electronic"; He = "$([char]1488)$([char]1500)$([char]1511)$([char]1496)$([char]1512)$([char]1493)$([char]1504)$([char]1497)" }
    "tabWorld"               = @{ En = "World/Urban"; He = "$([char]1506)$([char]1493)$([char]1500)$([char]1501)$([char]47)$([char]1488)$([char]1493)$([char]1512)$([char]1489)$([char]1504)$([char]1497)" }
    "tabArtists"             = @{ En = "Artists"; He = "$([char]1488)$([char]1502)$([char]1504)$([char]1497)$([char]1501)" }
    "tabMoods"               = @{ En = "Moods"; He = "$([char]1502)$([char]1510)$([char]1489)$([char]1497)$([char]32)$([char]1512)$([char]1493)$([char]1495)" }

    "btnQuickCTT"            = @{ En = "CTT WinUtil"; He = "$([char]1499)$([char]1500)$([char]1497)$([char]32)$([char]1506)$([char]1494)$([char]1512)$([char]32)$([char]67)$([char]84)$([char]84)" }
    "btnQuickCP"             = @{ En = "Control Panel"; He = "$([char]1500)$([char]1493)$([char]1495)$([char]32)$([char]1489)$([char]1511)$([char]1512)$([char]1492)" }
    "btnQuickUpdate"         = @{ En = "Win Update"; He = "$([char]1506)$([char]1491)$([char]1499)$([char]1493)$([char]1504)$([char]1497)$([char]32)$([char]1493)$([char]1493)$([char]1497)$([char]1504)$([char]1491)$([char]1493)$([char]1505)" }
    "btnQuickClean"          = @{ En = "Clean"; He = "$([char]1504)$([char]1497)$([char]1511)$([char]1493)$([char]1497)" }
    
    # New Quick Action Buttons
    "btnQuickSettings"       = @{ En = "Settings"; He = "$([char]1492)$([char]1490)$([char]1491)$([char]1512)$([char]1493)$([char]1514)" }
    "btnQuickDevicesClassic" = @{ En = "Devices (Old)"; He = "$([char]1492)$([char]1514)$([char]1511)$([char]1504)$([char]1497)$([char]1501)$([char]32)$([char]40)$([char]1497)$([char]1513)$([char]1503)$([char]41)" }
    "btnQuickDevicesModern"  = @{ En = "Devices (New)"; He = "$([char]1492)$([char]1514)$([char]1511)$([char]1504)$([char]1497)$([char]1501)$([char]32)$([char]40)$([char]1495)$([char]1491)$([char]1513)$([char]41)" }
    "btnQuickDevMgr"         = @{ En = "Device Manager"; He = "$([char]1502)$([char]1504)$([char]1492)$([char]1500)$([char]32)$([char]1492)$([char]1514)$([char]1511)$([char]1504)$([char]1497)$([char]1501)" }
    "btnQuickPrintMgmt"      = @{ En = "Print Mgmt"; He = "$([char]1504)$([char]1497)$([char]1492)$([char]1493)$([char]1500)$([char]32)$([char]1502)$([char]1491)$([char]1508)$([char]1505)$([char]1493)$([char]1514)" }

    # Sub Headers
    "btnExportHw"            = @{ En = "Export Report"; He = "$([char]1497)$([char]1510)$([char]1493)$([char]1488)$([char]32)$([char]1491)$([char]1493)$([char]34)$([char]1495)" }

    # Tweaks Translations
    "lblTweakTaskbar"        = @{ En = "Taskbar and Start Menu"; He = "$([char]1513)$([char]1493)$([char]1512)$([char]1514)$([char]32)$([char]1502)$([char]1513)$([char]1497)$([char]1502)$([char]1493)$([char]1514)$([char]32)$([char]1493)$([char]1514)$([char]1508)$([char]1512)$([char]1497)$([char]1496)$([char]32)$([char]1492)$([char]1514)$([char]1495)$([char]1500)$([char]1492)" }
    "lblTweakExplorer"       = @{ En = "File Explorer"; He = "$([char]1505)$([char]1497)$([char]1497)$([char]1512)$([char]32)$([char]1492)$([char]1511)$([char]1489)$([char]1510)$([char]1497)$([char]1501)" }
    "lblTweakSystem"         = @{ En = "System and Visuals"; He = "$([char]1502)$([char]1506)$([char]1512)$([char]1499)$([char]1514)$([char]32)$([char]1493)$([char]1493)$([char]1497)$([char]1494)$([char]1493)$([char]1488)$([char]1500)" }
    "btnApplyTaskbar"        = @{ En = "Toggle Center/Left Align"; He = "$([char]1513)$([char]1497)$([char]1504)$([char]1493)$([char]1497)$([char]32)$([char]1497)$([char]1497)$([char]1513)$([char]1493)$([char]1512)$([char]32)$([char]1502)$([char]1512)$([char]1499)$([char]1494)$([char]47)$([char]1513)$([char]1502)$([char]1488)$([char]1500)" }
    "btnSecondsClock"        = @{ En = "Toggle Seconds in Clock"; He = "$([char]1492)$([char]1510)$([char]1490)$([char]1514)$([char]32)$([char]1513)$([char]1504)$([char]1497)$([char]1493)$([char]1514)$([char]32)$([char]1489)$([char]1513)$([char]1506)$([char]1493)$([char]1503)" }
    "btnDisableBing"         = @{ En = "Disable Bing Search"; He = "$([char]1489)$([char]1497)$([char]1496)$([char]1493)$([char]1500)$([char]32)$([char]1495)$([char]1497)$([char]1508)$([char]1493)$([char]1513)$([char]32)$([char]66)$([char]105)$([char]110)$([char]103)" }
    "btnClassicContext"      = @{ En = "Classic Context Menu"; He = "$([char]1514)$([char]1508)$([char]1512)$([char]1496)$([char]32)$([char]1492)$([char]1511)$([char]1513)$([char]1512)$([char]32)$([char]1511)$([char]1500)$([char]1488)$([char]1505)$([char]1497)$([char]1514)" }
    "btnFileExt"             = @{ En = "Show/Hide File Ext"; He = "$([char]1492)$([char]1510)$([char]1490)$([char]1514)$([char]32)$([char]1505)$([char]1497)$([char]1493)$([char]1502)$([char]1493)$([char]1514)$([char]32)$([char]1511)$([char]1489)$([char]1510)$([char]1497)$([char]1501)" }
    "btnHiddenFiles"         = @{ En = "Show/Hide Hidden Files"; He = "$([char]1492)$([char]1510)$([char]1490)$([char]1514)$([char]32)$([char]1511)$([char]1489)$([char]1510)$([char]1497)$([char]1501)$([char]32)$([char]1495)$([char]1489)$([char]1493)$([char]1497)$([char]1497)$([char]1501)" }
    "btnCompactMode"         = @{ En = "Toggle Compact Mode"; He = "$([char]1502)$([char]1510)$([char]1489)$([char]32)$([char]1510)$([char]1508)$([char]1493)$([char]1507)$([char]32)$([char]47)$([char]32)$([char]1512)$([char]1490)$([char]1497)$([char]1500)" }
    "btnDarkMode"            = @{ En = "Toggle Dark/Light Mode"; He = "$([char]1502)$([char]1510)$([char]1489)$([char]32)$([char]1499)$([char]1492)$([char]1492)$([char]32)$([char]47)$([char]32)$([char]1489)$([char]1492)$([char]1497)$([char]1512)" }
    
    # System Health Center
    "lblBeastHeader"         = @{ En = "System Health Center"; He = "$([char]1502)$([char]1512)$([char]1499)$([char]1494)$([char]32)$([char]1489)$([char]1512)$([char]1497)$([char]1488)$([char]1493)$([char]1514)$([char]32)$([char]1492)$([char]1502)$([char]1506)$([char]1512)$([char]1499)$([char]1514)" }
    "lblBeastMaint"          = @{ En = "Maintenance and Repair"; He = "$([char]1514)$([char]1495)$([char]1494)$([char]1493)$([char]1511)$([char]1492)$([char]32)$([char]1493)$([char]1514)$([char]1497)$([char]1511)$([char]1493)$([char]1503)" }
    "lblBeastHard"           = @{ En = "Hardware & Performance"; He = "$([char]1495)$([char]1493)$([char]1502)$([char]1512)$([char]1492)$([char]32)$([char]1493)$([char]1489)$([char]1497)$([char]1510)$([char]1493)$([char]1506)$([char]1497)$([char]1501)" }
    "lblBeastNet"            = @{ En = "Network & Communication"; He = "$([char]1512)$([char]1513)$([char]1514)$([char]32)$([char]1493)$([char]1514)$([char]1511)$([char]1513)$([char]1493)$([char]1512)$([char]1514)" }

    # Category Bubbles Guide
    "lblBubAITitle"          = @{ En = "AI Bots"; He = "$([char]1489)$([char]1493)$([char]1496)$([char]1497)$([char]32)$([char]65)$([char]73)" }
    "lblBubAIDesc"           = @{ En = "Access ChatGPT, Gemini & smart tools"; He = "$([char]1490)$([char]1497)$([char]1513)$([char]1492)$([char]32)$([char]1500)$([char]45)$([char]67)$([char]104)$([char]97)$([char]116)$([char]71)$([char]80)$([char]84)$([char]44)$([char]32)$([char]71)$([char]101)$([char]109)$([char]105)$([char]110)$([char]105)$([char]32)$([char]1493)$([char]1499)$([char]1500)$([char]1497)$([char]1501)$([char]32)$([char]1495)$([char]1499)$([char]1502)$([char]1497)$([char]1501)" }
    "lblBubCTTTitle"         = @{ En = "CTT Tools"; He = "$([char]1499)$([char]1500)$([char]1497)$([char]32)$([char]67)$([char]84)$([char]84)" }
    "lblBubCTTDesc"          = @{ En = "System utilities & installation helpers"; He = "$([char]1499)$([char]1500)$([char]1497)$([char]32)$([char]1502)$([char]1506)$([char]1512)$([char]1499)$([char]1514)$([char]32)$([char]1493)$([char]1506)$([char]1494)$([char]1512)$([char]1497)$([char]32)$([char]1492)$([char]1514)$([char]1511)$([char]1504)$([char]1492)" }
    "lblBubTVTitle"          = @{ En = "Israel TV"; He = "$([char]1496)$([char]1500)$([char]1493)$([char]1497)$([char]1494)$([char]1497)$([char]1492)$([char]32)$([char]1497)$([char]1513)$([char]1512)$([char]1488)$([char]1500)$([char]1497)$([char]1514)" }
    "lblBubTVDesc"           = @{ En = "Watch live Israeli TV channels"; He = "$([char]1510)$([char]1508)$([char]1497)$([char]1497)$([char]1492)$([char]32)$([char]1497)$([char]1513)$([char]1497)$([char]1512)$([char]1492)$([char]32)$([char]1489)$([char]1506)$([char]1512)$([char]1493)$([char]1510)$([char]1497)$([char]32)$([char]1496)$([char]1500)$([char]1493)$([char]1497)$([char]1494)$([char]1497)$([char]1492)" }
    "lblBubUpdTitle"         = @{ En = "Updates"; He = "$([char]1506)$([char]1491)$([char]1499)$([char]1493)$([char]1504)$([char]1497)$([char]1501)" }
    "lblBubUpdDesc"          = @{ En = "Check updates, history & fixes"; He = "$([char]1489)$([char]1491)$([char]1497)$([char]1511)$([char]1514)$([char]32)$([char]1506)$([char]1491)$([char]1499)$([char]1493)$([char]1504)$([char]1497)$([char]1501)$([char]44)$([char]32)$([char]1492)$([char]1497)$([char]1505)$([char]1496)$([char]1493)$([char]1512)$([char]1497)$([char]1492)$([char]32)$([char]1493)$([char]1514)$([char]1497)$([char]1511)$([char]1493)$([char]1504)$([char]1497)$([char]1501)" }
    "lblBubHwTitle"          = @{ En = "Hardware"; He = "$([char]1495)$([char]1493)$([char]1502)$([char]1512)$([char]1492)" }
    "lblBubHwDesc"           = @{ En = "Full specs (CPU, RAM, GPU)"; He = "$([char]1502)$([char]1512)$([char]1496)$([char]1497)$([char]32)$([char]1495)$([char]1493)$([char]1502)$([char]1512)$([char]1492)$([char]32)$([char]1502)$([char]1500)$([char]1488)$([char]1497)$([char]1501)" }
    "lblBubWinTitle"         = @{ En = "Windows"; He = "$([char]1493)$([char]1493)$([char]1497)$([char]1504)$([char]1491)$([char]1493)$([char]1505)" }
    "lblBubWinDesc"          = @{ En = "Built-in tools (Control Panel, CMD)"; He = "$([char]1499)$([char]1500)$([char]1497)$([char]1501)$([char]32)$([char]1502)$([char]1493)$([char]1489)$([char]1504)$([char]1497)$([char]1501)$([char]32)$([char]1513)$([char]1500)$([char]32)$([char]1492)$([char]1502)$([char]1506)$([char]1512)$([char]1499)$([char]1514)" }
    "lblBubTwkTitle"         = @{ En = "Tweaks"; He = "$([char]1496)$([char]1493)$([char]1493)$([char]1497)$([char]1511)$([char]1497)$([char]1501)" }
    "lblBubTwkDesc"          = @{ En = "Boost performance & customize UI"; He = "$([char]1513)$([char]1497)$([char]1508)$([char]1493)$([char]1512)$([char]32)$([char]1489)$([char]1497)$([char]1510)$([char]1493)$([char]1506)$([char]1497)$([char]1501)$([char]32)$([char]1493)$([char]1492)$([char]1514)$([char]1488)$([char]1502)$([char]1492)$([char]32)$([char]1488)$([char]1497)$([char]1513)$([char]1497)$([char]1514)" }
    "lblBubClnTitle"         = @{ En = "Cleanup"; He = "$([char]1504)$([char]1497)$([char]1511)$([char]1493)$([char]1497)$([char]32)$([char]1502)$([char]1506)$([char]1512)$([char]1499)$([char]1514)" }
    "lblBubClnDesc"          = @{ En = "Free space, clear cache & junk"; He = "$([char]1508)$([char]1504)$([char]1492)$([char]32)$([char]1513)$([char]1496)$([char]1495)$([char]44)$([char]32)$([char]1504)$([char]1511)$([char]1492)$([char]32)$([char]1502)$([char]1496)$([char]1502)$([char]1493)$([char]1503)$([char]32)$([char]1493)$([char]1494)$([char]1489)$([char]1500)" }
    "lblBubSecTitle"         = @{ En = "Security"; He = "$([char]1488)$([char]1489)$([char]1496)$([char]1495)$([char]1492)" }
    "lblBubSecDesc"          = @{ En = "Antivirus, Firewall & Privacy"; He = "$([char]1488)$([char]1500)$([char]1496)$([char]1497)$([char]45)$([char]1493)$([char]1497)$([char]1512)$([char]1493)$([char]1505)$([char]44)$([char]32)$([char]1495)$([char]1493)$([char]1502)$([char]1514)$([char]32)$([char]1488)$([char]1513)$([char]32)$([char]1493)$([char]1508)$([char]1512)$([char]1496)$([char]1497)$([char]1493)$([char]1514)" }
    "lblBubMusTitle"         = @{ En = "Music"; He = "$([char]1502)$([char]1493)$([char]1494)$([char]1497)$([char]1511)$([char]1492)" }
    "lblBubMusDesc"          = @{ En = "Music player, playlists & radio"; He = "$([char]1504)$([char]1490)$([char]1503)$([char]32)$([char]1502)$([char]1493)$([char]1494)$([char]1497)$([char]1511)$([char]1492)$([char]44)$([char]32)$([char]1512)$([char]1513)$([char]1497)$([char]1502)$([char]1493)$([char]1514)$([char]32)$([char]1492)$([char]1513)$([char]1502)$([char]1506)$([char]1492)$([char]32)$([char]1493)$([char]1512)$([char]1491)$([char]1497)$([char]1493)" }
    "lblBubBstTitle"         = @{ En = "Beast Mode"; He = "$([char]1502)$([char]1510)$([char]1489)$([char]32)$([char]1495)$([char]1497)$([char]1492)" }
    "lblBubBstDesc"          = @{ En = "Advanced tools & full optimization"; He = "$([char]1499)$([char]1500)$([char]1497)$([char]1501)$([char]32)$([char]1502)$([char]1514)$([char]1511)$([char]1491)$([char]1502)$([char]1497)$([char]1501)$([char]32)$([char]1493)$([char]1488)$([char]1493)$([char]1508)$([char]1496)$([char]1497)$([char]1502)$([char]1493)$([char]1494)$([char]1510)$([char]1497)$([char]1492)$([char]32)$([char]1502)$([char]1500)$([char]1488)$([char]1492)" }
    "lblBeastSec"            = @{ En = "Security & System"; He = "$([char]1488)$([char]1489)$([char]1496)$([char]1495)$([char]1492)$([char]32)$([char]1493)$([char]1502)$([char]1506)$([char]1512)$([char]1499)$([char]1514)" }
    
    "btnBeastGlobalRepair"   = @{ En = "Full Repair (SFC/DISM)"; He = "$([char]1514)$([char]1497)$([char]1511)$([char]1493)$([char]1503)$([char]32)$([char]1502)$([char]1500)$([char]1488)$([char]32)$([char]40)$([char]83)$([char]70)$([char]67)$([char]47)$([char]68)$([char]73)$([char]83)$([char]77)$([char]41)" }
    "btnBeastCleanTemp"      = @{ En = "Clean Temp Files"; He = "$([char]1504)$([char]1511)$([char]1492)$([char]32)$([char]1511)$([char]1489)$([char]1510)$([char]1497)$([char]1501)$([char]32)$([char]1494)$([char]1502)$([char]1504)$([char]1497)$([char]1497)$([char]1501)" }
    "btnBeastEmptyRecycle"   = @{ En = "Empty Recycle Bin"; He = "$([char]1512)$([char]1493)$([char]1511)$([char]1503)$([char]32)$([char]1505)$([char]1500)$([char]32)$([char]1502)$([char]1497)$([char]1495)$([char]1493)$([char]1494)$([char]1493)$([char]1512)" }
    "btnBeastResetStore"     = @{ En = "Reset Windows Store"; He = "$([char]1488)$([char]1497)$([char]1508)$([char]1493)$([char]1505)$([char]32)$([char]1495)$([char]1504)$([char]1493)$([char]1514)$([char]32)$([char]87)$([char]105)$([char]110)$([char]100)$([char]111)$([char]119)$([char]115)" }
    "btnBeastIconCache"      = @{ En = "Reset Icon Cache"; He = "$([char]1488)$([char]1497)$([char]1508)$([char]1493)$([char]1505)$([char]32)$([char]1502)$([char]1496)$([char]1502)$([char]1493)$([char]1503)$([char]32)$([char]1505)$([char]1502)$([char]1500)$([char]1497)$([char]1501)" }
    "btnBeastWinUpdate"      = @{ En = "Clean Update Cache"; He = "$([char]1504)$([char]1511)$([char]1492)$([char]32)$([char]1502)$([char]1496)$([char]1502)$([char]1493)$([char]1503)$([char]32)$([char]1506)$([char]1491)$([char]1499)$([char]1493)$([char]1504)$([char]1497)$([char]1501)" }
    
    "btnBeastStress"         = @{ En = "Stress Test (WinSAT)"; He = "$([char]1489)$([char]1491)$([char]1497)$([char]1511)$([char]1514)$([char]32)$([char]1502)$([char]1488)$([char]1502)$([char]1509)$([char]32)$([char]40)$([char]87)$([char]105)$([char]110)$([char]83)$([char]65)$([char]84)$([char]41)" }
    "btnBeastRAM"            = @{ En = "Check RAM & Slots"; He = "$([char]1489)$([char]1491)$([char]1497)$([char]1511)$([char]1514)$([char]32)$([char]1494)$([char]1497)$([char]1499)$([char]1512)$([char]1493)$([char]1503)$([char]32)$([char]1493)$([char]1505)$([char]1500)$([char]1493)$([char]1496)$([char]1497)$([char]1501)" }
    "btnBeastSMART"          = @{ En = "Disk Health (SMART)"; He = "$([char]1489)$([char]1512)$([char]1497)$([char]1488)$([char]1493)$([char]1514)$([char]32)$([char]1492)$([char]1491)$([char]1497)$([char]1505)$([char]1511)$([char]32)$([char]40)$([char]83)$([char]77)$([char]65)$([char]82)$([char]84)$([char]41)" }
    "btnBeastCPU"            = @{ En = "CPU Details"; He = "$([char]1508)$([char]1512)$([char]1514)$([char]1497)$([char]32)$([char]1502)$([char]1506)$([char]1489)$([char]1491)" }
    "btnBeastBattery"        = @{ En = "Battery Report (HTML)"; He = "$([char]1491)$([char]1493)$([char]34)$([char]1495)$([char]32)$([char]1505)$([char]1493)$([char]1500)$([char]1500)$([char]1492)$([char]32)$([char]40)$([char]72)$([char]84)$([char]77)$([char]76)$([char]41)" }
    "btnBeastHighPerf"       = @{ En = "Max Performance"; He = "$([char]1489)$([char]1510)$([char]1493)$([char]1506)$([char]1497)$([char]1501)$([char]32)$([char]1502)$([char]1511)$([char]1505)$([char]1497)$([char]1502)$([char]1500)$([char]1497)$([char]1497)$([char]1501)" }
    
    "btnBeastNetReset"       = @{ En = "Reset Network & IP"; He = "$([char]1488)$([char]1497)$([char]1508)$([char]1493)$([char]1505)$([char]32)$([char]1512)$([char]1513)$([char]1514)$([char]32)$([char]1493)$([char]45)$([char]73)$([char]80)" }
    "btnBeastDNS"            = @{ En = "Flush DNS Cache"; He = "$([char]1504)$([char]1497)$([char]1511)$([char]1493)$([char]1497)$([char]32)$([char]1502)$([char]1496)$([char]1502)$([char]1493)$([char]1503)$([char]32)$([char]68)$([char]78)$([char]83)" }
    "btnBeastPorts"          = @{ En = "Scan Open Ports"; He = "$([char]1505)$([char]1512)$([char]1497)$([char]1511)$([char]1514)$([char]32)$([char]1508)$([char]1493)$([char]1512)$([char]1496)$([char]1497)$([char]1501)$([char]32)$([char]1508)$([char]1514)$([char]1493)$([char]1495)$([char]1497)$([char]1501)" }
    "btnBeastPublicIP"       = @{ En = "Show Public IP"; He = "$([char]1492)$([char]1510)$([char]1490)$([char]1514)$([char]32)$([char]73)$([char]80)$([char]32)$([char]1510)$([char]1497)$([char]1489)$([char]1493)$([char]1512)$([char]1497)" }
    "btnBeastWiFi"           = @{ En = "Wi-Fi Profiles List"; He = "$([char]1512)$([char]1513)$([char]1497)$([char]1502)$([char]1514)$([char]32)$([char]1508)$([char]1512)$([char]1493)$([char]1508)$([char]1497)$([char]1500)$([char]1497)$([char]32)$([char]87)$([char]105)$([char]45)$([char]70)$([char]105)" }
    "btnBeastPing"           = @{ En = "Ping Test (Google)"; He = "$([char]1489)$([char]1491)$([char]1497)$([char]1511)$([char]1514)$([char]32)$([char]1508)$([char]1497)$([char]1504)$([char]1490)$([char]32)$([char]40)$([char]71)$([char]111)$([char]111)$([char]103)$([char]108)$([char]101)$([char]41)" }
    
    "btnBeastProductKey"     = @{ En = "Extract Product Key"; He = "$([char]1495)$([char]1497)$([char]1500)$([char]1493)$([char]1509)$([char]32)$([char]1502)$([char]1508)$([char]1514)$([char]1495)$([char]32)$([char]1502)$([char]1493)$([char]1510)$([char]1512)" }
    "btnBeastRestorePoint"   = @{ En = "Create Restore Point"; He = "$([char]1497)$([char]1510)$([char]1497)$([char]1512)$([char]1514)$([char]32)$([char]1504)$([char]1511)$([char]1493)$([char]1491)$([char]1514)$([char]32)$([char]1513)$([char]1495)$([char]1493)$([char]1512)" }
    "btnBeastTopRAM"         = @{ En = "Top RAM Processes"; He = "$([char]1514)$([char]1492)$([char]1500)$([char]1497)$([char]1499)$([char]1497)$([char]1501)$([char]32)$([char]1494)$([char]1493)$([char]1500)$([char]1500)$([char]1497)$([char]32)$([char]1494)$([char]1497)$([char]1499)$([char]1512)$([char]1493)$([char]1503)" }
    "btnBeastStartup"        = @{ En = "Startup Programs"; He = "$([char]1514)$([char]1493)$([char]1499)$([char]1504)$([char]1493)$([char]1514)$([char]32)$([char]1513)$([char]1506)$([char]1493)$([char]1500)$([char]1493)$([char]1514)$([char]32)$([char]1489)$([char]1488)$([char]1514)$([char]1493)$([char]1500)" }
    "btnBeastUptime"         = @{ En = "System Uptime"; He = "$([char]1494)$([char]1502)$([char]1503)$([char]32)$([char]1508)$([char]1506)$([char]1497)$([char]1500)$([char]1493)$([char]1514)$([char]32)$([char]1492)$([char]1502)$([char]1506)$([char]1512)$([char]1499)$([char]1514)" }
    "btnBeastEventLog"       = @{ En = "Clear Event Logs"; He = "$([char]1504)$([char]1497)$([char]1511)$([char]1493)$([char]1497)$([char]32)$([char]1497)$([char]1493)$([char]1502)$([char]1504)$([char]1497)$([char]32)$([char]1488)$([char]1497)$([char]1512)$([char]1493)$([char]1506)$([char]1497)$([char]1501)" }
    
    "btnBeastTaskMgr"        = @{ En = "Task Manager"; He = "$([char]1502)$([char]1504)$([char]1492)$([char]1500)$([char]32)$([char]1492)$([char]1513)$([char]1497)$([char]1502)$([char]1493)$([char]1514)" }
    "btnBeastDevMgr"         = @{ En = "Device Manager"; He = "$([char]1502)$([char]1504)$([char]1492)$([char]1500)$([char]32)$([char]1492)$([char]1492)$([char]1514)$([char]1511)$([char]1504)$([char]1497)$([char]1501)" }
    "btnBeastDiskMgr"        = @{ En = "Disk Management"; He = "$([char]1504)$([char]1497)$([char]1492)$([char]1493)$([char]1500)$([char]32)$([char]1491)$([char]1497)$([char]1505)$([char]1511)$([char]1497)$([char]1501)" }
    "btnBeastRegEdit"        = @{ En = "Registry Editor"; He = "$([char]1506)$([char]1493)$([char]1512)$([char]1498)$([char]32)$([char]1492)$([char]1512)$([char]1497)$([char]1513)$([char]1493)$([char]1502)" }
    "btnBeastNetplwiz"       = @{ En = "User Management"; He = "$([char]1504)$([char]1497)$([char]1492)$([char]1493)$([char]1500)$([char]32)$([char]1502)$([char]1513)$([char]1514)$([char]1502)$([char]1513)$([char]1497)$([char]1501)" }
    "btnGameMode"            = @{ En = "Enable Game Mode"; He = "$([char]1492)$([char]1508)$([char]1506)$([char]1500)$([char]1514)$([char]32)$([char]1502)$([char]1510)$([char]1489)$([char]32)$([char]1502)$([char]1513)$([char]1492)$([char]1511)" }
    "btnMouseAccel"          = @{ En = "Disable Mouse Accel"; He = "$([char]1489)$([char]1497)$([char]1496)$([char]1493)$([char]1500)$([char]32)$([char]1492)$([char]1488)$([char]1510)$([char]1514)$([char]32)$([char]1506)$([char]1499)$([char]1489)$([char]1512)" }
    "btnIconSettings"        = @{ En = "Desktop Icon Settings"; He = "$([char]1492)$([char]1490)$([char]1491)$([char]1512)$([char]1493)$([char]1514)$([char]32)$([char]1505)$([char]1502)$([char]1500)$([char]1497)$([char]32)$([char]1513)$([char]1493)$([char]1500)$([char]1495)$([char]1503)$([char]32)$([char]1506)$([char]1489)$([char]1493)$([char]1491)$([char]1492)" }
    "lblBeastQuickTools"     = @{ En = "Quick Access Tools"; He = "$([char]1499)$([char]1500)$([char]1497)$([char]32)$([char]1490)$([char]1497)$([char]1513)$([char]1492)$([char]32)$([char]1502)$([char]1492)$([char]1497)$([char]1512)$([char]1492)" }
    "lblKbdSysProp" = @{ En = "System Properties"; He = "$([char]1502)$([char]1488)$([char]1508)$([char]1497)$([char]1497)$([char]1504)$([char]1497)$([char]32)$([char]1502)$([char]1506)$([char]1512)$([char]1499)$([char]1514)" }
    "lblKbdSnap" = @{ En = "Snap Window Left/Right"; He = "$([char]1492)$([char]1510)$([char]1502)$([char]1491)$([char]32)$([char]1495)$([char]1500)$([char]1493)$([char]1503)$([char]32)$([char]1497)$([char]1502)$([char]1497)$([char]1504)$([char]1492)$([char]47)$([char]1513)$([char]1502)$([char]1488)$([char]1500)$([char]1492)" }
    "lblKbdRun" = @{ En = "Open Run Dialog"; He = "$([char]1492)$([char]1508)$([char]1506)$([char]1500)$([char]32)$([char]40)$([char]82)$([char]117)$([char]110)$([char]41)" }
    "lblHdrTaskSys" = @{ En = " Task Manager & System"; He = "$([char]32)$([char]1502)$([char]1504)$([char]1492)$([char]1500)$([char]32)$([char]1502)$([char]1513)$([char]1497)$([char]1502)$([char]1493)$([char]1514)$([char]32)$([char]1493)$([char]1502)$([char]1506)$([char]1512)$([char]1499)$([char]1514)" }
    "lblKeyboardShortcutsTitle" = @{ En = " Keyboard Shortcuts"; He = "$([char]32)$([char]1511)$([char]1497)$([char]1510)$([char]1493)$([char]1512)$([char]1497)$([char]32)$([char]1502)$([char]1511)$([char]1500)$([char]1491)$([char]1514)" }
    "lblKbdLock" = @{ En = "Lock Computer"; He = "$([char]1504)$([char]1506)$([char]1497)$([char]1500)$([char]1514)$([char]32)$([char]1502)$([char]1495)$([char]1513)$([char]1489)" }
    "lblKbdPrtScn" = @{ En = "Screenshot to Clipboard"; He = "$([char]1510)$([char]1500)$([char]1501)$([char]32)$([char]1502)$([char]1505)$([char]1498)$([char]32)$([char]1500)$([char]1500)$([char]1493)$([char]1495)$([char]32)$([char]1492)$([char]1513)$([char]1502)$([char]1493)$([char]1512)$([char]1493)$([char]1514)" }
    "lblKbdMax" = @{ En = "Maximize Window"; He = "$([char]1492)$([char]1490)$([char]1491)$([char]1500)$([char]32)$([char]1495)$([char]1500)$([char]1493)$([char]1503)" }
    "lblKbdSnip" = @{ En = "Snipping Tool (Screenshot)"; He = "$([char]1499)$([char]1500)$([char]1497)$([char]32)$([char]1495)$([char]1497)$([char]1514)$([char]1493)$([char]1498)$([char]32)$([char]1502)$([char]1505)$([char]1498)" }
    "lblKbdSecScreen" = @{ En = "Security Options Screen"; He = "$([char]1502)$([char]1505)$([char]1498)$([char]32)$([char]1488)$([char]1489)$([char]1496)$([char]1495)$([char]1492)" }
    "lblKbdMin" = @{ En = "Minimize/Restore Window"; He = "$([char]1502)$([char]1494)$([char]1506)$([char]1512)$([char]47)$([char]1513)$([char]1495)$([char]1494)$([char]1512)$([char]32)$([char]1495)$([char]1500)$([char]1493)$([char]1503)" }
    "lblKbdEmoji" = @{ En = "Emoji Picker"; He = "$([char]1514)$([char]1508)$([char]1512)$([char]1497)$([char]1496)$([char]32)$([char]1505)$([char]1502)$([char]1497)$([char]1497)$([char]1500)$([char]1497)$([char]1501)$([char]32)$([char]40)$([char]1488)$([char]1497)$([char]1502)$([char]1493)$([char]1490)$([char]39)$([char]1497)$([char]41)" }
    "lblKbdSettings" = @{ En = "Open Settings"; He = "$([char]1492)$([char]1490)$([char]1491)$([char]1512)$([char]1493)$([char]1514)" }
    "lblKbdTaskMgr" = @{ En = "Open Task Manager"; He = "$([char]1502)$([char]1504)$([char]1492)$([char]1500)$([char]32)$([char]1492)$([char]1502)$([char]1513)$([char]1497)$([char]1502)$([char]1493)$([char]1514)" }
    "lblKbdExplorer" = @{ En = "Open File Explorer"; He = "$([char]1505)$([char]1497)$([char]1497)$([char]1512)$([char]32)$([char]1492)$([char]1511)$([char]1489)$([char]1510)$([char]1497)$([char]1501)" }
    "lblHdrWinMgmt" = @{ En = " Window Management"; He = "$([char]32)$([char]1504)$([char]1497)$([char]1492)$([char]1493)$([char]1500)$([char]32)$([char]1495)$([char]1500)$([char]1493)$([char]1504)$([char]1493)$([char]1514)" }
    "lblHdrClip" = @{ En = " Screenshot & Clipboard"; He = "$([char]32)$([char]1510)$([char]1497)$([char]1500)$([char]1493)$([char]1501)$([char]32)$([char]1502)$([char]1505)$([char]1498)$([char]32)$([char]1493)$([char]1500)$([char]1493)$([char]1495)$([char]32)$([char]1492)$([char]1506)$([char]1514)$([char]1511)$([char]1492)" }
    "lblKbdQuickLink" = @{ En = "Quick Link Menu"; He = "$([char]1514)$([char]1508)$([char]1512)$([char]1497)$([char]1496)$([char]32)$([char]1502)$([char]1513)$([char]1514)$([char]1502)$([char]1513)$([char]32)$([char]1502)$([char]1514)$([char]1511)$([char]1491)$([char]1501)" }
    "lblKbdClipHist" = @{ En = "Clipboard History"; He = "$([char]1492)$([char]1497)$([char]1505)$([char]1496)$([char]1493)$([char]1512)$([char]1497)$([char]1497)$([char]1514)$([char]32)$([char]1492)$([char]1506)$([char]1514)$([char]1511)$([char]1493)$([char]1514)" }
    "lblKbdSwitch" = @{ En = "Switch Between Windows"; He = "$([char]1506)$([char]1489)$([char]1493)$([char]1512)$([char]32)$([char]1489)$([char]1497)$([char]1503)$([char]32)$([char]1495)$([char]1500)$([char]1493)$([char]1504)$([char]1493)$([char]1514)" }
    "lblKbdClose" = @{ En = "Close Active Window"; He = "$([char]1505)$([char]1490)$([char]1493)$([char]1512)$([char]32)$([char]1495)$([char]1500)$([char]1493)$([char]1503)$([char]32)$([char]1508)$([char]1506)$([char]1497)$([char]1500)" }
    "lblHdrGeneralWin" = @{ En = " General Windows"; He = "$([char]32)$([char]1499)$([char]1500)$([char]1500)$([char]1497)$([char]32)$([char]45)$([char]32)$([char]1493)$([char]1493)$([char]1497)$([char]1504)$([char]1491)$([char]1493)$([char]1505)" }
    "lblKbdDesktop" = @{ En = "Show/Hide Desktop"; He = "$([char]1492)$([char]1510)$([char]1490)$([char]47)$([char]1492)$([char]1505)$([char]1514)$([char]1512)$([char]32)$([char]1513)$([char]1493)$([char]1500)$([char]1495)$([char]1503)$([char]32)$([char]1506)$([char]1489)$([char]1493)$([char]1491)$([char]1492)" }
    "lblKbdTaskView" = @{ En = "Task View (Virtual Desktops)"; He = "$([char]1514)$([char]1510)$([char]1493)$([char]1490)$([char]1514)$([char]32)$([char]1502)$([char]1513)$([char]1497)$([char]1502)$([char]1493)$([char]1514)$([char]32)$([char]40)$([char]1512)$([char]1497)$([char]1489)$([char]1493)$([char]1497)$([char]32)$([char]1513)$([char]1493)$([char]1500)$([char]1495)$([char]1504)$([char]1493)$([char]1514)$([char]41)" }

}

function Toggle-Language {
    $script:isHebrew = -not $script:isHebrew
    $global:isHebrew = $script:isHebrew
    $mode = $(if ($script:isHebrew) { "He" } else { "En" })
    $flow = $(if ($script:isHebrew) { [System.Windows.FlowDirection]::RightToLeft } else { [System.Windows.FlowDirection]::LeftToRight })
        # Fix: Keep background from flipping by only mirroring the content grid
    $mainGrid = Get-GuiElement "MainGrid"
    if ($mainGrid) { $mainGrid.FlowDirection = $flow }
    # Keep window LeftToRight for the Background ImageBrush
    $window.FlowDirection = [System.Windows.FlowDirection]::LeftToRight
    foreach ($key in $langData.Keys) {
        $el = Get-GuiElement $key
        if ($el) { 
            if ($el.GetType().Name -eq "TextBlock") { $el.Text = $langData[$key][$mode] }
            elseif ($el.GetType().Name -eq "Button") { $el.Content = $langData[$key][$mode] }
            elseif ($el.GetType().Name -eq "MenuItem") { $el.Header = $langData[$key][$mode] }
            elseif ($el.GetType().Name -eq "TabItem") { $el.Header = $langData[$key][$mode] }
        }
    }
    $sidebar = Get-GuiElement "SidebarBorder"
    if ($sidebar) {
        $sidebar.CornerRadius = if ($script:isHebrew) { New-Object System.Windows.CornerRadius(0,12,12,0) } else { New-Object System.Windows.CornerRadius(12,0,0,12) }
    }
}
(Get-GuiElement "btnLang").Add_Click({ Toggle-Language })

# --- SEARCH ENGINE ---
$txtSearch = Get-GuiElement "txtSearch"
$lblPlaceholder = Get-GuiElement "lblSearchPlaceholder"
$txtSearch.Add_TextChanged({
        if ($txtSearch.Text.Length -gt 0) { $lblPlaceholder.Visibility = "Hidden" } else { $lblPlaceholder.Visibility = "Visible" }
    })

function Invoke-SearchChoice {
    param($Term)
    [xml]$dialogXaml = @"
    <Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
            xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml" Title="Smart Search" Height="220" Width="450" WindowStartupLocation="CenterScreen" WindowStyle="None" AllowsTransparency="True" Background="Transparent" Topmost="True"><Border CornerRadius="15" BorderThickness="1" BorderBrush="#8A2BE2" Background="#1E1E1E"><Effect><DropShadowEffect BlurRadius="15" ShadowDepth="5" Opacity="0.5"/></Effect><StackPanel Margin="20"><TextBlock Text="Smart Search" Foreground="#8A2BE2" FontWeight="Bold" FontSize="18" Margin="0,0,0,10"/><TextBlock Foreground="White" FontSize="14" TextWrapping="Wrap" Margin="0,0,0,5">No internal feature found for '<Run Name="runSearchTerm" Foreground="#00E0FF" FontWeight="Bold" Text="..."/>'.</TextBlock><TextBlock Text="   .   ?" Foreground="#B0B0B0" FontSize="14" Margin="0,0,0,20" FlowDirection="RightToLeft"/><StackPanel Orientation="Horizontal" HorizontalAlignment="Center"><Button Name="btnPC" Content=" Computer" Width="130" Height="35" Margin="5" Background="#333333" Foreground="White" BorderThickness="0" Cursor="Hand"/><Button Name="btnWeb" Content=" Web" Width="130" Height="35" Margin="5" Background="#8A2BE2" Foreground="White" BorderThickness="0" Cursor="Hand"/><Button Name="btnCancel" Content=" Cancel" Width="100" Height="35" Margin="5" Background="#E81123" Foreground="White" BorderThickness="0" Cursor="Hand"/></StackPanel></StackPanel></Border></Window>
"@
    $reader = (New-Object System.Xml.XmlNodeReader $dialogXaml)
    $dialog = [Windows.Markup.XamlReader]::Load($reader)
    $runElem = $dialog.FindName("runSearchTerm"); if ($runElem) { $runElem.Text = $Term }
    $dialog.FindName("btnPC").Add_Click({ Start-Process "explorer.exe" -ArgumentList "search-ms:query=$Term"; $dialog.Close() })
    $dialog.FindName("btnWeb").Add_Click({ Start-Process "https://www.google.com/search?q=$([System.Net.WebUtility]::UrlEncode($Term))"; $dialog.Close() })
    $dialog.FindName("btnCancel").Add_Click({ $dialog.Close() })
    $dialog.ShowDialog() | Out-Null
}

function Perform-Search {
    $term = $txtSearch.Text; if ([string]::IsNullOrWhiteSpace($term)) { return }
    
    # Search mapping: keyword -> panel + button
    $searchMap = @{
        "CTT"           = @{ Panel = $pnlEssentials; Button = "btnEssentials" }
        "Essentials"    = @{ Panel = $pnlEssentials; Button = "btnEssentials" }
        "AI"            = @{ Panel = $pnlAIBots; Button = "btnAIBots" }
        "Automation"    = @{ Panel = $pnlAIBots; Button = "btnAIBots" }
        "ChatGPT"       = @{ Panel = $pnlAIBots; Button = "btnAIBots" }
        "Gemini"        = @{ Panel = $pnlAIBots; Button = "btnAIBots" }
        "Windows Tools" = @{ Panel = $pnlWindowsTools; Button = "btnWindowsTools" }
        "Tools"         = @{ Panel = $pnlWindowsTools; Button = "btnWindowsTools" }
        "Hardware"      = @{ Panel = $pnlSysInfoTools; Button = "btnSysInfoTools" }
        "Tweaks"        = @{ Panel = $pnlTweaks; Button = "btnTweaks" }
        "Cleanup"       = @{ Panel = $pnlMaintenance; Button = "btnMaintenance" }
        "Maintenance"   = @{ Panel = $pnlMaintenance; Button = "btnMaintenance" }
        "Security"      = @{ Panel = $pnlSecurity; Button = "btnSecurity" }
        "Users"         = @{ Panel = $pnlUserMgmt; Button = "btnUserMgmt" }
        "Music"         = @{ Panel = $pnlMusic; Button = "btnMusic" }
        "Media"         = @{ Panel = $pnlMusic; Button = "btnMusic" }
        "Power"         = @{ Panel = $pnlPower; Button = "btnPower" }
        "Shutdown"      = @{ Panel = $pnlPower; Button = "btnPower" }
        "Restart"       = @{ Panel = $pnlPower; Button = "btnPower" }
        "Update"        = @{ Panel = $pnlUpdateMgr; Button = "btnUpdateMgr" }
        "System Health" = @{ Panel = $pnlBeast; Button = "btnBeast" }
        "Health"        = @{ Panel = $pnlBeast; Button = "btnBeast" }
        "Keyboard"      = @{ Panel = $pnlKeyboardShortcuts; Button = "btnKeyboardShortcuts" }
        "Shortcuts"     = @{ Panel = $pnlKeyboardShortcuts; Button = "btnKeyboardShortcuts" }
        "Dashboard"     = @{ Panel = $pnlHome; Button = "btnHome" }
        "Home"          = @{ Panel = $pnlHome; Button = "btnHome" }
    }
    
    # Try to find matching panel
    $found = $false
    foreach ($key in $searchMap.Keys) {
        if ($key -match $term -or $term -match $key) {
            $panelInfo = $searchMap[$key]
            Switch-Panel $panelInfo.Panel
            $txtSearch.Text = ""
            $found = $true
            break
        }
    }
    
    # If no panel found, try old button search
    if (-not $found) {
        $searchableButtons = @("btnHome", "btnAIBots", "btnEssentials", "btnWindowsTools", "btnSysInfoTools", "btnTweaks", "btnMaintenance", "btnSecurity", "btnUserMgmt", "btnMusic", "btnPower", "btnQuickCTT", "btnQuickCP", "btnQuickUpdate", "btnQuickClean", "btnQuickDevices", "btnDiskMgmt", "btnTaskMgr", "btnDevMgmt", "btnRegEdit", "btnDiskCleanup", "btnNanoBanana")
        $foundButton = $null
        foreach ($btnName in $searchableButtons) {
            $originalBtn = Get-GuiElement $btnName
            if ($originalBtn) {
                $contentStr = $originalBtn.Content.ToString()
                if ($contentStr -match "$term" -or $btnName -match "$term") { $foundButton = $originalBtn; break }
            }
        }
        if ($foundButton) { $foundButton.RaiseEvent((New-Object System.Windows.RoutedEventArgs([System.Windows.Controls.Button]::ClickEvent))); $txtSearch.Text = "" } else { Invoke-SearchChoice $term }
    }
}
(Get-GuiElement "btnSearch").Add_Click({ Perform-Search })
$txtSearch.Add_KeyDown({ param($s, $e) if ($e.Key -eq 'Enter') { Perform-Search } })

# --- LOGIC IMPLEMENTATION ---
function Write-Log { param($Msg) Write-Host "[$(Get-Date -Format 'HH:mm')] $Msg" -ForegroundColor Cyan }
function Open-Url { param($U) Start-Process $U }

function Invoke-OnlineApp {
    param([string]$Url, [string]$FileName, [string]$ExeToRun, [bool]$IsZip = $false)
    $tempDir = "$env:TEMP\WinFlexApps"; if (-not (Test-Path $tempDir)) { New-Item -ItemType Directory -Path $tempDir -Force | Out-Null }
    $localFile = "$tempDir\$FileName"; [System.Windows.Forms.Cursor]::Current = [System.Windows.Forms.Cursors]::WaitCursor
    try {
        if (-not (Test-Path $localFile)) { Write-Host "Downloading $FileName..." -ForegroundColor Cyan; Start-BitsTransfer -Source $Url -Destination $localFile -DisplayName "Downloading $FileName" -ErrorAction Stop }
        $runPath = $localFile
        if ($IsZip) {
            $extractDir = "$tempDir\$($FileName)_extracted"; if (-not (Test-Path $extractDir)) { Expand-Archive -Path $localFile -DestinationPath $extractDir -Force }
            if ($ExeToRun) { $runPath = (Get-ChildItem -Path $extractDir -Filter $ExeToRun -Recurse | Select -First 1).FullName } else { Start-Process $extractDir; return }
        }
        Start-Process $runPath
    }
    catch { [System.Windows.Forms.MessageBox]::Show("Download failed via script. Opening browser.", "Error"); Start-Process $Url } finally { [System.Windows.Forms.Cursor]::Current = [System.Windows.Forms.Cursors]::Default }
}

Set-Click "btnRunCTT" { Start-Process powershell "iwr -useb https://christitus.com/win | iex" -Verb RunAs }
Set-Click "btnQuickCTT" { Start-Process powershell "iwr -useb https://christitus.com/win | iex" -Verb RunAs }
Set-Click "btnQuickCP" { Start-Process control }
Set-Click "btnQuickUpdate" { Start-Process ms-settings:windowsupdate }
Set-Click "btnQuickClean" { Start-Process cleanmgr }
Set-Click "btnQuickDevices" { $el = Get-GuiElement "btnQuickDevices"; if ($el -and $el.ContextMenu) { $el.ContextMenu.IsOpen = $true } }
Set-Click "menuDevModern"   { Start-Process ms-settings:connecteddevices }
Set-Click "menuDevClassic"  { Start-Process "explorer.exe" -ArgumentList "shell:::{A8A91A66-3A7D-4424-8D24-04E180695C7A}" }
Set-Click "menuDevMgr"      { Start-Process devmgmt.msc }

# NANO BANANA
# NANO BANANA DATA (English-first, Hebrew aliased for encoding safety)
$stylesEnglish = @("in crayon drawing style", "in rough pencil sketch style", "in 1930s rubber hose animation style", "in claymation style", "in 8-bit pixel art style", "in street graffiti style", "in Renaissance oil painting style", "in CCTV footage style", "in origami style", "in comic book style", "in cyberpunk neon style", "in vintage travel poster style", "in children's book illustration style", "in old school tattoo style", "in stained glass style", "in 4K studio photography style", "in architectural blueprint style", "in Japanese woodblock print style", "in surrealist Dali style", "in sock puppet style", "in underwater photography style", "in ice sculpture style", "in knitted amigurumi style", "in watercolor style", "in Pop Art style")
$stylesHebrew = $stylesEnglish
$scenariosEnglish = @("dinosaur tying shoelaces", "cat running board meeting", "marshmallow city", "tired robot drinking coffee", "yellow submarine in bathtub", "astronaut BBQ on moon", "elephant dancing ballet", "flying house with balloons", "penguin with sunglasses", "cute monster with flowers", "cyborg rabbit repairing clock", "galaxy in a jar", "samurai fighting giant crab", "train in clouds", "robot coffee shop", "turtle carrying city", "disco ball moon", "hamster in mech suit", "hologram chess", "flying car in Tokyo")
$scenariosHebrew = $scenariosEnglish

$cmbRatio = Get-GuiElement "cmbRatio"; $chk4K = Get-GuiElement "chk4K"; $chkReal = Get-GuiElement "chkReal"; $chkLight = Get-GuiElement "chkLight"
$cmbRatio.Items.Add("Square (1:1)") | Out-Null; $cmbRatio.Items.Add("Wide (16:9)") | Out-Null; $cmbRatio.Items.Add("Portrait (9:16)") | Out-Null; $cmbRatio.SelectedIndex = 0

function Get-ActiveModifiers {
    param($Lang)
    $mods = @()
    if ($cmbRatio.SelectedIndex -eq 1) { $mods += "16:9 aspect ratio" }
    if ($cmbRatio.SelectedIndex -eq 2) { $mods += "9:16 aspect ratio" }
    if ($chk4K.IsChecked) { $mods += "4k, high resolution" }
    if ($chkReal.IsChecked) { $mods += "photorealistic, hyper-detailed" }
    if ($chkLight.IsChecked) { $mods += "cinematic lighting" }
    if ($mods.Count -gt 0) { return ", " + ($mods -join ", ") }; return ""
}

function Send-To-Gemini {
    param($PromptText)
    if ([string]::IsNullOrWhiteSpace($PromptText)) { return }
    try { [System.Windows.Forms.Clipboard]::SetText($PromptText) } catch {}
    $msgResult = [System.Windows.Forms.MessageBox]::Show("Copied to Clipboard: $PromptText`n`nLaunch browser to generate?", "Nano Banana", [System.Windows.Forms.MessageBoxButton]::OKCancel)
    if ($msgResult -eq 'OK') { Start-Process "https://gemini.google.com/app?q=$([System.Web.HttpUtility]::UrlEncode($PromptText))" }
}

(Get-GuiElement "btnGenHebrew").Add_Click({ $scn = $scenariosHebrew | Get-Random; $sty = $stylesHebrew | Get-Random; $mods = Get-ActiveModifiers 'He'; Send-To-Gemini "Generate an image of $scn, $sty$mods." })
(Get-GuiElement "btnGenEnglish").Add_Click({ $scn = $scenariosEnglish | Get-Random; $sty = $stylesEnglish | Get-Random; $mods = Get-ActiveModifiers 'En'; Send-To-Gemini "Generate an image of $scn, $sty$mods." })
(Get-GuiElement "btnLaunchCustom").Add_Click({ Send-To-Gemini (Get-GuiElement "txtCustomInput").Text })
Set-Click "btnNanoBanana" { Switch-Panel $pnlNanoBanana }
Set-Click "btnBackToAI" { Switch-Panel $pnlAIBots }

function Update-StyleList {
    $cmbStyles = Get-GuiElement "cmbStyles"
    if (-not $cmbStyles) { return }
    $cmbStyles.Items.Clear()
    if ((Get-GuiElement "rbHebrew").IsChecked) { $stylesHebrew | ForEach-Object { [void]$cmbStyles.Items.Add($_) } }
    else { $stylesEnglish | ForEach-Object { [void]$cmbStyles.Items.Add($_) } }
    $cmbStyles.SelectedIndex = 0
}
(Get-GuiElement "rbHebrew").Add_Checked({ Update-StyleList }); (Get-GuiElement "rbEnglish").Add_Checked({ Update-StyleList }); Update-StyleList

(Get-GuiElement "btnSurpriseMe").Add_Click({
    if ((Get-Random -Min 0 -Max 2) -eq 0) {
        $scn = $scenariosHebrew | Get-Random; $sty = $stylesHebrew | Get-Random; $mods = Get-ActiveModifiers 'He'
        Send-To-Gemini "Generate an image of $scn, $sty$mods."
    } else {
        $scn = $scenariosEnglish | Get-Random; $sty = $stylesEnglish | Get-Random; $mods = Get-ActiveModifiers 'En'
        Send-To-Gemini "Generate an image of $scn, $sty$mods."
    }
})

(Get-GuiElement "btnSpinRoulette").Add_Click({
    $idx = (Get-GuiElement "cmbStyles").SelectedIndex; if ($idx -lt 0) { $idx = 0 }
    if ((Get-GuiElement "rbHebrew").IsChecked) {
        $sty = $stylesHebrew[$idx]; $scn = $scenariosHebrew | Get-Random; $mods = Get-ActiveModifiers 'He'
        Send-To-Gemini "Generate an image of $scn, $sty$mods."
    } else {
        $sty = $stylesEnglish[$idx]; $scn = $scenariosEnglish | Get-Random; $mods = Get-ActiveModifiers 'En'
        Send-To-Gemini "Generate an image of $scn, $sty$mods."
    }
})


# MUSIC ENGINE






