# ==============================================================================
# WinFlexOS V3.0 - Windows Management & Productivity Suite (Remote Loader)
# ==============================================================================
param([switch]$Restart, [switch]$Shutdown, [string]$Message)
# 0. Hide Console ASAP
try {
    $code = '[DllImport("user32.dll")] public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow); [DllImport("kernel32.dll")] public static extern IntPtr GetConsoleWindow();'
    $win32 = Add-Type -MemberDefinition $code -Name "Win32ShowWindow_$(Get-Random)" -Namespace "Win32" -PassThru
    $win32::ShowWindow($win32::GetConsoleWindow(), 0) | Out-Null
} catch {}

# 1. Load Required Assemblies
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
            <TextBlock Text="Loading System Modules..." FontSize="12" Foreground="#8AB4F8" HorizontalAlignment="Center" Margin="0,5,0,0"/>
        </StackPanel>
    </Border>
</Window>
"@
    $global:splashScreen = [Windows.Markup.XamlReader]::Parse($splashXaml)
    $global:splashScreen.Show()
    $global:splashScreen.Dispatcher.Invoke([Action]{}, [System.Windows.Threading.DispatcherPriority]::Render)
} catch {}

# 2. Define Module Config
$ModuleDir = "C:\MENU\Modules"
if (!(Test-Path $ModuleDir)) { New-Item $ModuleDir -ItemType Directory | Out-Null }



# --- DYNAMIC GITHUB UPDATE LOGIC ---
$githubBase = "https://raw.githubusercontent.com/dor2500/winFlexMenu/refs/heads/main/Scripts"
$ModuleDir = "C:\MENU\Modules"
if (-not (Test-Path $moduleDir)) { New-Item -Path $moduleDir -ItemType Directory -Force }

$filesToDownload = @(
    "Assets.ps1", "CoreUI.ps1", "Helpers.ps1", "Layout.ps1", 
    "Menu_Cinema.ps1", "Menu_Gaming.ps1", "Menu_Music.ps1", 
    "Menu_Office.ps1", "Menu_System.ps1", "Menu_TV.ps1"
)

Write-Host "Checking for updates from GitHub..." -ForegroundColor Cyan
foreach ($file in $filesToDownload) {
    try {
        $url = "$githubBase/$file"
        $dest = Join-Path $moduleDir $file
        Invoke-WebRequest -Uri $url -OutFile $dest -TimeoutSec 15 -ErrorAction SilentlyContinue
    } catch {}
}

$githubBase = "https://raw.githubusercontent.com/dor2500/winFlexMenu/main/winFlexMenu/winFlexMenu"
$ModuleDir = "C:\MENU\Modules"
if (-not (Test-Path $moduleDir)) { New-Item -Path $moduleDir -ItemType Directory -Force }

function Update-FromGitHub {
    param([string]$fileName, [string]$subFolder = "Scripts")
    try {
        $url = "$githubBase/$subFolder/$fileName"
        $dest = "$moduleDir/$fileName"
        # Simple download - you can add hash checking later for speed
        Invoke-WebRequest -Uri $url -OutFile $dest -TimeoutSec 5 -ErrorAction SilentlyContinue
    } catch {}
}

# Update core modules on startup (Quietly)
$modulesToUpdate = @("Menu_System.ps1", "Menu_Office.ps1", "Layout.ps1", "Menu_Gaming.ps1", "CoreUI.ps1", "Helpers.ps1")
foreach ($m in $modulesToUpdate) {
    Update-FromGitHub -fileName $m
}

# The system will strictly load modules from the local $ModuleDir.

# 4. Load Core Definitions (Local Cached Versions)
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
        throw "XAML layout not found."
    }
} catch {
    Write-Host "CRITICAL ERROR LOADING XAML:`n$_" -ForegroundColor Red
    Read-Host "Press Enter to exit..."
    exit
}

# 7. Load Core Logic
if (Test-Path "$ModuleDir\CoreUI.ps1") { . "$ModuleDir\CoreUI.ps1" }

# 8. Load Menu Modules
Get-ChildItem -Path $ModuleDir -Filter "Menu_*.ps1" | ForEach-Object { . $_.FullName }

# 9. Post-Load Startup Logic
try {
    if (Get-Command Toggle-Language -ErrorAction SilentlyContinue) { Toggle-Language }
    if (Get-Command Refresh-Users -ErrorAction SilentlyContinue) { Refresh-Users }
} catch {}

# 10. Show Application
if ($global:splashScreen) { try { $global:splashScreen.Close() } catch {} }
if ($window) {
    $window.ShowDialog()
}
