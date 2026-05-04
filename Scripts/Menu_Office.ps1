# ==============================================================================
# WinFlexOS - Office Module (Refined Version)
# ==============================================================================

# 1. Initialize Dropdowns with Sorted Values
$cmbOfficeVersion = Get-GuiElement "cmbOfficeVersion"
if ($cmbOfficeVersion) {
    $versions = @(
        "O365 Business (64-bit Heb)",
        "O365 Enterprise (64-bit Heb)",
        "Office ProPlus 2019 (64-bit Heb)",
        "Office ProPlus 2021 (64-bit Heb)",
        "Office ProPlus 2024 (64-bit Heb)",
        "Office Standard 2019 (64-bit Heb)",
        "Office Standard 2021 (64-bit Heb)",
        "Office Standard 2024 (64-bit Heb)"
    )
    $cmbOfficeVersion.ItemsSource = $versions
    $cmbOfficeVersion.SelectedIndex = 4 # Default to 2024
}

$cmbOfficeType = Get-GuiElement "cmbOfficeType"
if ($cmbOfficeType) {
    $types = @("Basic Installation", "Full Installation")
    $cmbOfficeType.ItemsSource = $types
    $cmbOfficeType.SelectedIndex = 0
}

# 2. Installation Handler
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
        $xmlPath = "C:\MENU\Tools\OfficeSetup\$targetXml"
        
        # DEBUG: Let user know what we are looking for
        Write-Host "Looking for: $xmlPath" -ForegroundColor Cyan
        
        if (!(Test-Path $xmlPath)) {
            $msg = "XML file not found: $targetXml`n`nLooking in: C:\MENU\Tools\OfficeSetup`n`nPlease ensure the file was downloaded correctly."
            [System.Windows.Forms.MessageBox]::Show($msg, "File Not Found", "OK", "Error")
            return
        }
        
        $setupExe = "C:\MENU\Tools\OfficeSetup\setup.exe"
        if (!(Test-Path $setupExe)) {
            try {
                Write-Host "Downloading ODT..." -ForegroundColor Yellow
                Invoke-WebRequest -Uri "https://download.microsoft.com/download/2/7/A/27AF1BE6-DD20-4CB4-B154-EBAB8A7D4A7E/officedeploymenttool_18129-20030.exe" -OutFile "C:\MENU\Tools\OfficeSetup\odt.exe"
                Start-Process -FilePath "C:\MENU\Tools\OfficeSetup\odt.exe" -ArgumentList "/extract:`"C:\MENU\Tools\OfficeSetup`" /quiet" -Wait
            } catch {
                [System.Windows.Forms.MessageBox]::Show("Failed to download Office Deployment Tool.", "Error", "OK", "Error")
                return
            }
        }
        
        if (Test-Path $setupExe) {
            Start-Process -FilePath $setupExe -ArgumentList "/configure `"$xmlPath`""
            [System.Windows.Forms.MessageBox]::Show("Office Installation has started. Please wait.", "Success", "OK", "Information")
        }
    }
}

# 3. Activation & Utilities
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
