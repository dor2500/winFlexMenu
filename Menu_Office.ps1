$btnInstallOffice = Get-GuiElement "btnInstallOffice"

if ($btnInstallOffice) {
    Set-Click "btnInstallOffice" {
        $cmbOfficeVersion = Get-GuiElement "cmbOfficeVersion"
        $cmbOfficeType = Get-GuiElement "cmbOfficeType"
        
        $versionStr = $cmbOfficeVersion.Text
        $typeStr = $cmbOfficeType.Text
        
        $xmlPrefix = ""
        switch -Wildcard ($versionStr) {
            "O365 Business*" { $xmlPrefix = "O365_Business_64bit_Heb" }
            "O365 Enterprise*" { $xmlPrefix = "O365_Enterprise_64bit_Heb" }
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
            [System.Windows.Forms.MessageBox]::Show("XML configuration file not found at: $xmlPath`nPlease check C:\MENU\Tools\OfficeSetup", "Error", "OK", "Error")
            return
        }
        
        $setupExe = "C:\MENU\Tools\OfficeSetup\setup.exe"
        if (!(Test-Path $setupExe)) {
            try {
                Invoke-WebRequest -Uri "https://download.microsoft.com/download/2/7/A/27AF1BE6-DD20-4CB4-B154-EBAB8A7D4A7E/officedeploymenttool_18129-20030.exe" -OutFile "C:\MENU\Tools\OfficeSetup\odt.exe"
                Start-Process -FilePath "C:\MENU\Tools\OfficeSetup\odt.exe" -ArgumentList "/extract:`"C:\MENU\Tools\OfficeSetup`" /quiet" -Wait
            } catch {
                [System.Windows.Forms.MessageBox]::Show("Failed to download Office Deployment Tool setup.exe.`nPlease ensure internet is connected or manually place setup.exe in the folder.", "Error", "OK", "Error")
                return
            }
        }
        
        if (Test-Path $setupExe) {
            Start-Process -FilePath $setupExe -ArgumentList "/configure `"$xmlPath`""
            [System.Windows.Forms.MessageBox]::Show("Office Installation has started in the background using Microsoft ODT.`nPlease wait for it to complete.", "Success", "OK", "Information")
        } else {
            [System.Windows.Forms.MessageBox]::Show("setup.exe could not be extracted.", "Error", "OK", "Error")
        }
    }
}


$btnRunMAS = Get-GuiElement "btnRunMAS"
if ($btnRunMAS) {
    Set-Click "btnRunMAS" {
        Start-Process -FilePath "powershell" -ArgumentList '-NoProfile -ExecutionPolicy Bypass -Command "irm https://get.activated.win | iex"' -Verb RunAs
    }
}

$btnRemoveOffice = Get-GuiElement "btnRemoveOffice"
if ($btnRemoveOffice) {
    Set-Click "btnRemoveOffice" {
        [System.Windows.Forms.MessageBox]::Show("Opening Programs and Features to remove Office...", "Remove Office", "OK", "Information")
        Start-Process "appwiz.cpl"
    }
}

$btnOfficeInfo = Get-GuiElement "btnOfficeInfo"
if ($btnOfficeInfo) {
    Set-Click "btnOfficeInfo" {
        $msg = "Office Installation Info:`n`n" +
               "Basic Installation Includes:`n" +
               "- Word, Excel, PowerPoint`n`n" +
               "Full Installation Includes:`n" +
               "- Word, Excel, PowerPoint, Outlook, OneNote, Access, Publisher, Teams (O365), Skype for Business"
        [System.Windows.Forms.MessageBox]::Show($msg, "Office Info", "OK", "Information")
    }
}
