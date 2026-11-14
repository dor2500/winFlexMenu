# ==============================================================================
# WinFlexOS - Office Module (Sync with XAML Layout)
# ==============================================================================

# 1. Installation Handler
$btnInstallOffice = Get-GuiElement "btnInstallOffice"
if ($btnInstallOffice) {
    Set-Click "btnInstallOffice" {
        $cmbOfficeVersion = Get-GuiElement "cmbOfficeVersion"
        $cmbOfficeType = Get-GuiElement "cmbOfficeType"
        
        $versionStr = $cmbOfficeVersion.Text
        $typeStr = $cmbOfficeType.Text
        
        $xmlPrefix = ""
        switch -Wildcard ($versionStr) {
            "O365 Business*"      { $xmlPrefix = "O365_Business_64bit_Heb" }
            "O365 Enterprise*"    { $xmlPrefix = "O365_Enterprise_64bit_Heb" }
            "Office ProPlus 2019*" { $xmlPrefix = "Office_ProPlus_2019_64bit_Heb" }
            "Office ProPlus 2021*" { $xmlPrefix = "Office_ProPlus_2021_64bit_Heb" }
            "Office ProPlus 2024*" { $xmlPrefix = "Office_ProPlus_2024_64bit_Heb" }
            "Office Standard 2019*" { $xmlPrefix = "Office_Standard_2019_64bit_Heb" }
            "Office Standard 2021*" { $xmlPrefix = "Office_Standard_2021_64bit_Heb" }
            "Office Standard 2024*" { $xmlPrefix = "Office_Standard_2024_64bit_Heb" }
        }
        
        $xmlSuffix = ""
        if ($typeStr -match "Basic") { $xmlSuffix = "_Basic.xml" }
        elseif ($typeStr -match "Full") { $xmlSuffix = "_Full.xml" }
        
        $targetXml = "$xmlPrefix$xmlSuffix"
        $officeDir = "C:\MENU\Tools\OfficeSetup"
        if (!(Test-Path $officeDir)) { New-Item $officeDir -ItemType Directory -Force | Out-Null }
        $xmlPath = "$officeDir\$targetXml"
        $setupExe = "$officeDir\setup.exe"
        $repoRaw = "https://raw.githubusercontent.com/dor2500/winFlexMenu/main"

        if (!(Test-Path $xmlPath)) {
            $localRepoXml = Join-Path (Split-Path $PSScriptRoot -Parent) "OfficeSetup\OfficeSetup\$targetXml"
            if (Test-Path $localRepoXml) {
                Copy-Item $localRepoXml $xmlPath -Force
            } else {
                try {
                    Show-Toast "Downloading Office configuration ($targetXml)..." "info"
                    Invoke-WebRequest -Uri "$repoRaw/OfficeSetup/OfficeSetup/$targetXml" -OutFile $xmlPath -UseBasicParsing -TimeoutSec 15 -ErrorAction Stop
                } catch {
                    [System.Windows.Forms.MessageBox]::Show("XML file not found and download failed: $targetXml", "Error", "OK", "Error")
                    return
                }
            }
        }

        if (!(Test-Path $setupExe)) {
            $localSetup = Join-Path (Split-Path $PSScriptRoot -Parent) "OfficeSetup\Remove Office\setup.exe"
            if (Test-Path $localSetup) {
                Copy-Item $localSetup $setupExe -Force
            } else {
                try {
                    Show-Toast "Downloading Office Deployment Tool (setup.exe)..." "info"
                    Invoke-WebRequest -Uri "$repoRaw/OfficeSetup/Remove%20Office/setup.exe" -OutFile $setupExe -UseBasicParsing -TimeoutSec 30 -ErrorAction Stop
                } catch {
                    [System.Windows.Forms.MessageBox]::Show("Office setup.exe could not be downloaded: $_", "Error", "OK", "Error")
                    return
                }
            }
        }

        if (Test-Path $setupExe) {
            Show-Toast "Starting Office installation..." "success"
            Start-Process -FilePath $setupExe -ArgumentList "/configure `"$xmlPath`"" -Verb RunAs
        }
    }
}

# 2. Activation & Utilities
$btnRunMAS = Get-GuiElement "btnRunMAS"
if ($btnRunMAS) {
    Set-Click "btnRunMAS" {
        Start-Process -FilePath "powershell" -ArgumentList '-NoProfile -ExecutionPolicy Bypass -Command "irm https://get.activated.win | iex"' -Verb RunAs
    }
}

$btnRemoveOffice = Get-GuiElement "btnRemoveOffice"
if ($btnRemoveOffice) {
    Set-Click "btnRemoveOffice" {
        Start-Process "appwiz.cpl"
    }
}

$btnOfficeInfo = Get-GuiElement "btnOfficeInfo"
if ($btnOfficeInfo) {
    Set-Click "btnOfficeInfo" {
        $msg = "Office Installation Info:`n`n" +
               "Basic Installation Includes: Word, Excel, PowerPoint`n`n" +
               "Full Installation Includes: All Apps + Teams & Outlook"
        [System.Windows.Forms.MessageBox]::Show($msg, "Office Info", "OK", "Information")
    }
}
