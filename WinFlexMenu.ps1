# ==============================================================================
# WinFlexOS V3.0 - Windows Management & Productivity Suite (Hybrid Loader)
# ==============================================================================
param([switch]$Restart, [switch]$Shutdown, [string]$Message)

# 0. Hide Console ASAP
try {
    $code = '[DllImport("user32.dll")] public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow); [DllImport("kernel32.dll")] public static extern IntPtr GetConsoleWindow();'
    $win32 = Add-Type -MemberDefinition $code -Name "Win32ShowWindow_$(Get-Random)" -Namespace "Win32" -PassThru
    $win32::ShowWindow($win32::GetConsoleWindow(), 0) | Out-Null
} catch {}

# 1. Load Required Assemblies
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Add-Type -AssemblyName PresentationFramework, PresentationCore, WindowsBase, System.Windows.Forms, System.Drawing

# 1.5. Show Minimal Splash Screen
try {
    $splashXaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        WindowStyle="None" AllowsTransparency="True" Background="Transparent"
        WindowStartupLocation="CenterScreen" Width="300" Height="120" Topmost="True" ShowInTaskbar="False">
    <Border Background="#1E1E1E" CornerRadius="12" BorderBrush="#00BFFF" BorderThickness="1">
        <Border.Effect>
            <DropShadowEffect BlurRadius="20" ShadowDepth="0" Color="Black" Opacity="0.5"/>
        </Border.Effect>
        <StackPanel VerticalAlignment="Center" HorizontalAlignment="Center">
            <TextBlock Text="WinFlexOS" FontSize="26" FontWeight="Bold" Foreground="#FFFFFF" HorizontalAlignment="Center"/>
            <TextBlock Text="Syncing System Modules..." FontSize="12" Foreground="#8AB4F8" HorizontalAlignment="Center" Margin="0,5,0,0"/>
        </StackPanel>
    </Border>
</Window>
"@
    $global:splashScreen = [Windows.Markup.XamlReader]::Parse($splashXaml)
    $global:splashScreen.Show()
    $global:splashScreen.Dispatcher.Invoke([Action]{}, [System.Windows.Threading.DispatcherPriority]::Render)
} catch {}

# 2. Define Module Config & Hybrid Sync Logic
$ModuleDir = "C:\MENU\Modules"
$OfficeDir = "C:\MENU\Tools\OfficeSetup"
if (!(Test-Path $ModuleDir)) { New-Item $ModuleDir -ItemType Directory -Force | Out-Null }
if (!(Test-Path $OfficeDir)) { New-Item $OfficeDir -ItemType Directory -Force | Out-Null }




# --- ULTRA FAST SYNC (One-Check Logic) ---
$moduleDir = "C:\MENU\Modules"
$lastSyncFile = "C:\MENU\last_sync.txt"
$githubApi = "https://api.github.com/repos/dor2500/winFlexMenu/branches/main"

try {
    # 1. Get latest commit SHA from GitHub API (Very fast)
    $apiRes = Invoke-RestMethod -Uri $githubApi -TimeoutSec 2 -ErrorAction Stop
    $latestSha = $apiRes.commit.sha
    $localSha = ""
    if (Test-Path $lastSyncFile) { $localSha = Get-Content $lastSyncFile }

    # 2. If SHA matches, skip everything and open instantly
    if ($latestSha -ne $localSha) {
        Write-Host "New update detected! Syncing..." -ForegroundColor Cyan
        $githubBase = "https://raw.githubusercontent.com/dor2500/winFlexMenu/main/Scripts"
        $files = @("Assets.ps1", "CoreUI.ps1", "Helpers.ps1", "Layout.ps1", "Menu_Cinema.ps1", "Menu_Gaming.ps1", "Menu_Music.ps1", "Menu_Office.ps1", "Menu_System.ps1", "Menu_TV.ps1")
        
        foreach ($f in $files) {
            Invoke-WebRequest -Uri "$githubBase/$f" -OutFile "$moduleDir/$f" -TimeoutSec 10 -ErrorAction SilentlyContinue
        }
        # Save new SHA after successful sync
        $latestSha | Set-Content $lastSyncFile
    }
} catch {
    # If API fails or no internet, just proceed to open local files immediately
}




# 4. Load Core Definitions (From Local Disk)
if (Test-Path "$ModuleDir\Helpers.ps1") { . "$ModuleDir\Helpers.ps1" }
if (Test-Path "$ModuleDir\Assets.ps1") { . "$ModuleDir\Assets.ps1" }
if (Test-Path "$ModuleDir\Layout.ps1") { . "$ModuleDir\Layout.ps1" }

# 5. Initialize Assets Data
if (Get-Command Initialize-GamingAssets -ErrorAction SilentlyContinue) {
    Initialize-GamingAssets
}

# 6. Parse UI Layout
try {
    if ($xaml) {
        $window = [Windows.Markup.XamlReader]::Parse($xaml)
    } else {
        throw "XAML layout not found. Please check internet connection or local C:\MENU\Modules folder."
    }
} catch {
    if ($global:splashScreen) { $global:splashScreen.Close() }
    [System.Windows.MessageBox]::Show("CRITICAL ERROR LOADING XAML:`n$_", "WinFlexOS Error", "OK", "Error")
    exit
}

# 7. Load Core Logic
if (Test-Path "$ModuleDir\CoreUI.ps1") { . "$ModuleDir\CoreUI.ps1" }

# 8. Load Menu Modules
Get-ChildItem -Path $ModuleDir -Filter "Menu_*.ps1" | ForEach-Object { . $_.FullName }

# 9. Post-Load Startup Logic
try {
    if (Get-Command Toggle-Language -ErrorAction SilentlyContinue) { Toggle-Language; Toggle-Language }
    if (Get-Command Refresh-Users -ErrorAction SilentlyContinue) { Refresh-Users }
} catch {}

# 10. Show Application
if ($global:splashScreen) { try { $global:splashScreen.Close() } catch {} }
if ($window) {
    $window.ShowDialog()
}
