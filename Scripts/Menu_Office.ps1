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
        $xmlPath = "C:\MENU\Tools\OfficeSetup\$targetXml"
        
        if (!(Test-Path $xmlPath)) {
            $msg = "XML file not found: $targetXml`n`nLooking in: C:\MENU\Tools\OfficeSetup"
            [System.Windows.Forms.MessageBox]::Show($msg, "Error", "OK", "Error")
            return
        }
        
        $setupExe = "C:\MENU\Tools\OfficeSetup\setup.exe"
        if (Test-Path $setupExe) {
            Start-Process -FilePath $setupExe -ArgumentList "/configure `"$xmlPath`""
            [System.Windows.Forms.MessageBox]::Show("Office Installation has started.", "Success", "OK", "Information")
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
