# ==============================================================================
# WinFlexOS V3.0 - Windows Management & Productivity Suite (Hybrid Loader)
# ==============================================================================
param([switch]$Restart, [switch]$Shutdown, [string]$Message)

# Progress bars make Invoke-WebRequest / Invoke-RestMethod up to 10x slower in Windows PowerShell 5.1
$ProgressPreference = 'SilentlyContinue'
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# 0. Define Module Config & fire the (async) GitHub check immediately,
#    so the network round-trip overlaps with assembly loading + splash screen.
$ModuleDir    = "C:\MENU\Modules"
$OfficeDir    = "C:\MENU\Tools\OfficeSetup"
$manifestFile = "C:\MENU\sync_manifest.txt"
$repoApi      = "https://api.github.com/repos/dor2500/winFlexMenu/git/trees/main?recursive=1"
$repoRaw      = "https://raw.githubusercontent.com/dor2500/winFlexMenu/main"
if (!(Test-Path $ModuleDir)) { New-Item $ModuleDir -ItemType Directory -Force | Out-Null }
if (!(Test-Path $OfficeDir)) { New-Item $OfficeDir -ItemType Directory -Force | Out-Null }

$treeTask = $null
try {
    $wcApi = New-Object Net.WebClient
    $wcApi.Headers['User-Agent'] = 'WinFlexMenu'
    $treeTask = $wcApi.DownloadStringTaskAsync($repoApi)
} catch {}

# 0.5 Hide Console ASAP (Reflection.Emit P/Invoke: ~10ms instead of a ~100-400ms Add-Type C# compile)
try {
    $asmName = New-Object System.Reflection.AssemblyName('WfxNative')
    $asmBld  = [AppDomain]::CurrentDomain.DefineDynamicAssembly($asmName, [Reflection.Emit.AssemblyBuilderAccess]::Run)
    $typeBld = $asmBld.DefineDynamicModule('WfxNative').DefineType('Native', 'Public,Class')
    $null = $typeBld.DefinePInvokeMethod('GetConsoleWindow', 'kernel32.dll', 'Public,Static,PinvokeImpl', 'Standard', [IntPtr], [Type[]]@(), 'Winapi', 'Auto')
    $null = $typeBld.DefinePInvokeMethod('ShowWindow', 'user32.dll', 'Public,Static,PinvokeImpl', 'Standard', [bool], [Type[]]@([IntPtr], [int]), 'Winapi', 'Auto')
    $native = $typeBld.CreateType()
    $null = $native::ShowWindow($native::GetConsoleWindow(), 0)
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
            <TextBlock Text="Syncing System Modules..." FontSize="12" Foreground="#8AB4F8" HorizontalAlignment="Center" Margin="0,5,0,0"/>
        </StackPanel>
    </Border>
</Window>
"@
    $global:splashScreen = [Windows.Markup.XamlReader]::Parse($splashXaml)
    $global:splashScreen.Show()
    $global:splashScreen.Dispatcher.Invoke([Action]{}, [System.Windows.Threading.DispatcherPriority]::Render)
} catch {}

# 2. DELTA SYNC: only files whose git blob SHA changed are downloaded, all in parallel.
#    - Warm start & nothing changed  -> a single (already in-flight) API call, zero downloads.
#    - Offline / API rate-limited    -> falls straight through to the local copies.
$hasLocal = (Test-Path "$ModuleDir\Layout.ps1") -and (Test-Path "$ModuleDir\CoreUI.ps1") -and (Test-Path "$ModuleDir\Helpers.ps1")
$apiWaitMs = if ($hasLocal) { 2500 } else { 20000 }   # first run has nothing local, so we must wait

try {
    if ($treeTask -and $treeTask.Wait($apiWaitMs)) {
        $remoteFiles = @((ConvertFrom-Json $treeTask.Result).tree | Where-Object {
            $_.type -eq 'blob' -and $_.path -like 'Scripts/*.ps1' -and $_.path -ne 'Scripts/Assets.ps1'
        })

        $known = @{}
        if (Test-Path $manifestFile) {
            foreach ($line in [IO.File]::ReadAllLines($manifestFile)) {
                $kv = $line.Split('|'); if ($kv.Count -eq 2) { $known[$kv[0]] = $kv[1] }
            }
        }

        $pending = @()
        foreach ($rf in $remoteFiles) {
            $name = [IO.Path]::GetFileName($rf.path)
            $dest = Join-Path $ModuleDir $name
            if ($known[$name] -eq $rf.sha -and (Test-Path $dest)) { continue }
            $wc = New-Object Net.WebClient
            $wc.Headers['User-Agent'] = 'WinFlexMenu'
            # ?v=<blob sha> makes every file version a unique URL -> never served stale by the raw CDN cache
            $pending += [pscustomobject]@{
                Name = $name; Dest = $dest; Tmp = "$dest.download"; Sha = $rf.sha
                Task = $wc.DownloadFileTaskAsync("$repoRaw/$($rf.path)?v=$($rf.sha)", "$dest.download")
            }
        }

        if ($pending.Count -gt 0) {
            try { [void][Threading.Tasks.Task]::WaitAll([Threading.Tasks.Task[]]@($pending | ForEach-Object { $_.Task }), 30000) } catch {}
            foreach ($p in $pending) {
                # Only swap in files that fully downloaded (a half-written module would break the whole UI)
                if ($p.Task.Status -eq 'RanToCompletion' -and (Test-Path $p.Tmp) -and (Get-Item $p.Tmp).Length -gt 0) {
                    Move-Item $p.Tmp $p.Dest -Force
                    $known[$p.Name] = $p.Sha
                } else {
                    Remove-Item $p.Tmp -Force -ErrorAction SilentlyContinue
                }
            }
            [IO.File]::WriteAllLines($manifestFile, [string[]]@($known.GetEnumerator() | ForEach-Object { "$($_.Key)|$($_.Value)" }))
        }

        # Legacy cleanup: the 7MB base64 Assets module was replaced by on-demand background files
        Remove-Item "$ModuleDir\Assets.ps1" -Force -ErrorAction SilentlyContinue
    }
} catch {
    # No internet / API failure: proceed with the local files immediately
}

# 3. Load Core Definitions (From Local Disk)
if (Test-Path "$ModuleDir\Helpers.ps1") { . "$ModuleDir\Helpers.ps1" }
if (Test-Path "$ModuleDir\Layout.ps1") { . "$ModuleDir\Layout.ps1" }

# 4. Parse UI Layout
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

# 5. Load Core Logic
if (Test-Path "$ModuleDir\CoreUI.ps1") { . "$ModuleDir\CoreUI.ps1" }

# 6. Load Menu Modules
Get-ChildItem -Path $ModuleDir -Filter "Menu_*.ps1" | ForEach-Object { . $_.FullName }

# 7. Post-Load Startup Logic
#    (user list is loaded lazily when the Users panel is opened - see btnUserMgmt)
try {
    if (Get-Command Toggle-Language -ErrorAction SilentlyContinue) { Toggle-Language; Toggle-Language }
} catch {}

# 8. Show Application
if ($global:splashScreen) { try { $global:splashScreen.Close() } catch {} }
if ($window) {
    $window.ShowDialog()
}
