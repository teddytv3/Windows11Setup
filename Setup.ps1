if (-NOT ([Security.Principle.WindowsPrinciple][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principle.WindowsBuiltInRole] "Administrator")) {
    $arguments = "& '" + $MyInvocation.MyCommand.definition + "'"
    Start-Process powershell -Verb runAs -ArgumentList $arguments
}

#List of apps to remove. Add/Remove as needed
$UWPApps = @(
    "Microsoft.Microsoft3DViewer"
    "Microsoft.BingWeather"
    "Microsoft.BingNews"
    "Microsoft.MicrosoftOfficeHub"
    "Microsoft.Office.Desktop"
    "Microsoft.MicrosoftStickyNotes"
    "Microsoft.MixedReality.Portal"
    "Microsoft.Office.OneNote"
    "Microsoft.People"
    "Microsoft.ScreenSketch"
    "Microsoft.Wallet"
    "Microsoft.SkypeApp"
    "microsoft.windowscommunicationsapps"
    "Microsoft.WindowsFeedbackHub"
    "Microsoft.WindowsMaps"
    "Microsoft.WindowsSoundRecorder"
    "Microsoft.YourPhone"
    "Microsoft.PowerAutomateDesktop"
    "Clipchamp.Clipchamp"
    "Microsoft.Getstarted"
    "Microsoft.Todos"
    "MicrosoftTeams"
)

Write-Host "Removing Pre-Installed Software"
#Iterate through the list of apps and removes them
foreach ($UWPApp in $UWPApps) {
    Get-AppxPackage -Name $UWPApp -AllUsers | Remove-AppxPackage
    Get-AppXProvisionedPackage -Online | Where-Object DisplayName -eq $UWPApp | Remove-AppxProvisionedPackage -Online
}

#Removes pre-installed versions of office
$AllLanguages =  "en-us", "es-es", "fr-fr"
$ClickToRunPath = "C:\Program Files\Common Files\Microsoft Shared\ClickToRun\OfficeClickToRun.exe" 
foreach($Language in $AllLanguages){
    Start-Process $ClickToRunPath -ArgumentList "scenario=install scenariosubtype=ARP sourcetype=None productstoremove=O365HomePremRetail.16_$($Language)_x-none culture=$($Language) DisplayLevel=False" -Wait
    Start-Sleep -Seconds 5
}


#This section is taken from the following git repo: https://github.com/Ccmexec/PowerShell/blob/master/Customize%20TaskBar%20and%20Start%20Windows%2011/CustomizeTaskbar%20v1.1.ps1
#I have removed the options I do not need/want for myself and kept what I need/want for my own personal use 

[string]$RegValueName = "CustomizeTaskbar"
[string]$FullRegKeyName = "HKLM:\SOFTWARE\ccmexec\" 

# Create registry value if it doesn't exist
If (!(Test-Path $FullRegKeyName)) {
    New-Item -Path $FullRegKeyName -type Directory -force 
}

New-itemproperty $FullRegKeyName -Name $RegValueName -Value "1" -Type STRING -Force

REG LOAD HKLM\Default C:\Users\Default\NTUSER.DAT

# Removes Task View from the Taskbar
Write-Host "Attempting to run: $PSItem"
$reg = New-ItemProperty "HKLM:\Default\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ShowTaskViewButton" -Value "0" -PropertyType Dword -Force
try { $reg.Handle.Close() } catch {}

# Removes Widgets from the Taskbar
Write-Host "Attempting to run: $PSItem"
$reg = New-ItemProperty "HKLM:\Default\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarDa" -Value "0" -PropertyType Dword -Force
try { $reg.Handle.Close() } catch {}

# Removes Chat from the Taskbar
Write-Host "Attempting to run: $PSItem"
$reg = New-ItemProperty "HKLM:\Default\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarMn" -Value "0" -PropertyType Dword -Force
try { $reg.Handle.Close() } catch {}

# Default StartMenu alignment 0=Left
Write-Host "Attempting to run: $PSItem"
$reg = New-ItemProperty "HKLM:\Default\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarAl" -Value "0" -PropertyType Dword -Force
try { $reg.Handle.Close() } catch {}    

[GC]::Collect()
REG UNLOAD HKLM\Default
