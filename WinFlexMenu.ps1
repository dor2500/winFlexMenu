# ==============================================================================
# WinFlexOS V3.0 - Windows Management & Productivity Suite (Remote Loader)
# ==============================================================================
param([switch]$Restart, [switch]$Shutdown, [string]$Message)

# 1. Load Required Assemblies
Add-Type -AssemblyName PresentationFramework, PresentationCore, WindowsBase, System.Windows.Forms, System.Drawing

# 2. Define Module Config
$ModuleDir = "C:\MENU\Modules"
if (!(Test-Path $ModuleDir)) { New-Item $ModuleDir -ItemType Directory | Out-Null }

# Base URL for script modules
$RemoteBase = "https://raw.githubusercontent.com/dor2500/winFlexMenu/main/Scripts"
$RemoteFiles = @(
    @{ Name = "Helpers.ps1"; Url = "$RemoteBase/Helpers.ps1" },
    @{ Name = "Assets.ps1";  Url = "$RemoteBase/Assets.ps1" },
    @{ Name = "Layout.ps1";  Url = "$RemoteBase/Layout.ps1" },
    @{ Name = "CoreUI.ps1";  Url = "$RemoteBase/CoreUI.ps1" },
    @{ Name = "Menu_Cinema.ps1"; Url = "$RemoteBase/Menu_Cinema.ps1" },
    @{ Name = "Menu_Gaming.ps1"; Url = "$RemoteBase/Menu_Gaming.ps1" },
    @{ Name = "Menu_Music.ps1";  Url = "$RemoteBase/Menu_Music.ps1" },
    @{ Name = "Menu_System.ps1"; Url = "$RemoteBase/Menu_System.ps1" },
    @{ Name = "Menu_TV.ps1";     Url = "$RemoteBase/Menu_TV.ps1" }
)

# 3. Remote Loader Logic (Skipped - using local files in C:\MENU\Modules)
<#
Write-Host "Syncing Scripts..." -ForegroundColor Cyan
foreach ($file in $RemoteFiles) {
    $localPath = Join-Path $ModuleDir $file.Name
    try {
        Invoke-WebRequest -Uri $file.Url -OutFile $localPath -TimeoutSec 15 -ErrorAction Stop
        Write-Host "[OK] $($file.Name)" -ForegroundColor Green
    } catch {
        Write-Host "[OFFLINE] Using local $($file.Name)" -ForegroundColor Yellow
    }
}
#>

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
    if (Get-Command Toggle-Language -ErrorAction SilentlyContinue) { Toggle-Language; Toggle-Language } # Double toggle to ensure default English state with content
    if (Get-Command Refresh-Users -ErrorAction SilentlyContinue) { Refresh-Users }
    if (Get-Command Update-Greeting-Smart -ErrorAction SilentlyContinue) { Update-Greeting-Smart }
} catch {}

# 10. Hide Console & Show Application
if ($window) {
    try {
        $code = '[DllImport("user32.dll")] public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow); [DllImport("kernel32.dll")] public static extern IntPtr GetConsoleWindow();'
        $win32 = Add-Type -MemberDefinition $code -Name "Win32ShowWindow" -Namespace "Win32" -PassThru
        $win32::ShowWindow($win32::GetConsoleWindow(), 0) # 0 = SW_HIDE
    } catch {}
    $window.ShowDialog()
}
