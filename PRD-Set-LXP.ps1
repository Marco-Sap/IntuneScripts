<#
.SYNOPSIS
   
.DESCRIPTION
   
.AUTHOR
   Marco Sap 
.VERSION
   1.0.0
.EXAMPLE
   
.DISCLAIMER
   This script code is provided as is with no guarantee or waranty
   concerning the usability or impact on systems and may be used,
   distributed, and modified in any way provided the parties agree
   and acknowledge that Microsoft or Microsoft Partners have neither
   accountabilty or responsibility for results produced by use of
   this script.

   Microsoft will not provide any support through any means.
#>

# If we are running as a 32-bit process on a 64-bit system, re-launch as a 64-bit process
if (Test-Path "$($env:WINDIR)\SysNative\WindowsPowerShell\v1.0\powershell.exe")
{
    & "$($env:WINDIR)\SysNative\WindowsPowerShell\v1.0\powershell.exe" -ExecutionPolicy bypass -NoProfile -File "$PSCommandPath"
    Exit $lastexitcode
}

# Create a log file under c:\programdata\intunelogs
if (-not (Test-Path "$($env:ProgramData)\IntuneLogs"))
{
    Mkdir "$($env:ProgramData)\IntuneLogs"
}

# Main logic
$needReboot = $false
$Channel = "PRD"
$Name = "Set-LXP"
$Version = "1.0.0"
$LogFile = $Channel + "-" + $Name + "-" + $Version + ".log"

# Start logging
Start-Transcript "$($env:ProgramData)\IntuneLogs\$LogFile"

#region Set LXP

# Check Current Nation
$Nation = Get-ItemPropertyValue -Path "HKCU:\Control Panel\International\Geo" -Name Nation
$Keyboard = (Get-WinUserLanguageList)[0].InputMethodTips

# Make sure all added LXPs are registerd for the Current User
$appxLxpPath = (Get-AppxPackage | Where-Object Name -Like *LanguageExperiencePacknl-NL).InstallLocation
Add-AppxPackage -Register -Path "$appxLxpPath\AppxManifest.xml" -DisableDevelopmentMode

$appxLxpPath = (Get-AppxPackage | Where-Object Name -Like *LanguageExperiencePackde-DE).InstallLocation
Add-AppxPackage -Register -Path "$appxLxpPath\AppxManifest.xml" -DisableDevelopmentMode

$appxLxpPath = (Get-AppxPackage | Where-Object Name -Like *LanguageExperiencePackfr-FR).InstallLocation
Add-AppxPackage -Register -Path "$appxLxpPath\AppxManifest.xml" -DisableDevelopmentMode

$appxLxpPath = (Get-AppxPackage | Where-Object Name -Like *LanguageExperiencePackes-ES).InstallLocation
Add-AppxPackage -Register -Path "$appxLxpPath\AppxManifest.xml" -DisableDevelopmentMode

# Create New Language List with all languages (bug #24513 tracking id) , first in order is Store language, changed US to US-int keyboard as default
$langlist = Get-WinUserLanguageList
$langlist.Clear()
$langlist.Add("en-US")
$Langlist[0].InputMethodTips.Clear()
#$Langlist[0].InputMethodTips.Add('0409:00020409')
$Langlist[0].InputMethodTips.Add("'$Keyboard'")
$langlist.Add("nl-NL")
$langlist.Add("nl-BE")
$langlist.Add("de-DE")
$langlist.Add("fr-FR")
$langlist.Add("es-ES")
Set-WinUserLanguageList $langlist -Force

# Nation list https://docs.microsoft.com/en-us/windows/win32/intl/table-of-geographical-locations
If ($Nation -eq "21"){Set-Culture -CultureInfo nl-BE}
Elseif ($Nation -eq "176"){Set-Culture -CultureInfo nl-NL}
Elseif ($Nation -eq "94"){Set-Culture -CultureInfo de-DE}
Elseif ($Nation -eq "84"){Set-Culture -CultureInfo fr-FR}
Elseif ($Nation -eq "217"){Set-Culture -CultureInfo es-ES}
Else {Set-Culture -CultureInfo en-US}

#endregion

#region Set Registry for detection
$RegistryPathD = "HKCU:\SOFTWARE\Intune"
$NameD = $Channel + "-" + $Name
$valueD = "1"

IF(!(Test-Path $RegistryPathD))
  {
    New-Item -Path $RegistryPathD -Force
    New-ItemProperty -Path $RegistryPathD -Name $NameD -Value $valueD -PropertyType DWORD -Force}
 ELSE {
    New-ItemProperty -Path $RegistryPathD -Name $NameD -Value $valueD -PropertyType DWORD -Force}
#endregion

# Stop logging
Stop-Transcript

# Specify return code
if ($needReboot)
{
    Exit 3010
}
else
{
    Exit 0
}