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

If(Get-ItemProperty -Path HKLM:\Software\Intune -Name "PRD-Set-FOD"){
Write-Host "Installed"
}