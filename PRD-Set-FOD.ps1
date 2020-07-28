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

# Create a log file for Intune tracking
if (-not (Test-Path "$($env:ProgramData)\IntuneLogs"))
{
    Mkdir "$($env:ProgramData)\IntuneLogs"
}

# Main logic
$needReboot = $false
$Channel = "PRD"
$Name = "Set-FOD"
$Version = "1.0.0"
$LogFile = $Channel + "-" + $Name + "-" + $Version + ".log"

# Start logging
Start-Transcript "$($env:ProgramData)\IntuneLogs\$LogFile"

#region Set FOD

# Build dynamic array for FODs
$Features = New-Object System.Collections.ArrayList

# Add Basic Features on Demand
$languages = 'nl-NL', 'de-DE', 'fr-FR', 'es-ES'

foreach ($language in $languages) {
   $Features.Add("Basic~~~$language~0.0.1.0")
   $Features.Add("Language.Handwriting~~~$language~0.0.1.0")
   $Features.Add("Language.OCR~~~$language~0.0.1.0")
   $Features.Add("Language.TextToSpeech~~~$language~0.0.1.0")
 }

# Add Speech for Languages that support it
$Speechs = 'de-DE', 'fr-FR', 'es-ES'

foreach ($Speech in $Speechs) {
   $Features.Add("Language.Speech~~~$Speech~0.0.1.0")
 }

 # Add FOD's based on dynamic array
 foreach ($Feature in $Features) {
   DISM /Online /Add-Capability /CapabilityName:$Feature
 }

#endregion

#region Set Registry for detection
$RegistryPathD = "HKLM:\SOFTWARE\Intune"
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