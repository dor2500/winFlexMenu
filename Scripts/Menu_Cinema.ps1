
# --- CINEMA MODE HANDLERS ---
function Toggle-TV-CinemaMode {
    try {
        $window = [System.Windows.Application]::Current.MainWindow
        if (-not $window) { $window = $global:Window }
        
        $title = Get-GuiElement "lblTVTitle"
        $listCol = Get-GuiElement "colTVSidebar"
        $spacerCol = Get-GuiElement "colTVSpacer"
        $exitBtn = Get-GuiElement "btnExitCinema"
        $sidebar = Get-GuiElement "sidebar" # Main dashboard sidebar
        
        if (-not $global:IsCinemaMode) {
            # ENTER CINEMA MODE
            if ($title) { $title.Visibility = "Collapsed" }
            if ($listCol) { $listCol.Width = New-Object System.Windows.GridLength(0) }
            if ($spacerCol) { $spacerCol.Width = New-Object System.Windows.GridLength(0) }
            if ($exitBtn) { $exitBtn.Visibility = "Visible" }
            if ($sidebar) { $sidebar.Visibility = "Collapsed" }
            $global:IsCinemaMode = $true
        } else {
            # EXIT CINEMA MODE
            if ($title) { $title.Visibility = "Visible" }
            if ($listCol) { $listCol.Width = New-Object System.Windows.GridLength(220) }
            if ($spacerCol) { $spacerCol.Width = New-Object System.Windows.GridLength(10) }
            if ($exitBtn) { $exitBtn.Visibility = "Collapsed" }
            if ($sidebar) { $sidebar.Visibility = "Visible" }
            $global:IsCinemaMode = $false
        }
    } catch {}
}

(Get-GuiElement "btnCinemaMode").Add_Click({ Toggle-TV-CinemaMode })
(Get-GuiElement "btnExitCinema").Add_Click({ Toggle-TV-CinemaMode })

