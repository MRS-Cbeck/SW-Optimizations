Add-Type -AssemblyName PresentationFramework
$DSRegPath = "HKCU:\Software\Dassault Systemes" #Registry Path being updated
$desPath = "$env:USERPROFILE\Documents\SolidworksRegistryBackUp" #Path to user SolidWorks Registry
$d = $desPath + "\DSregistryBackup.reg" #backup folder path for Dassault
$s = $desPath + "\SWregistryBackup.reg" #Backup folder path for SolidWorks

#Warn users they are about to edit the Registry, give them a change to opt out.
$msgBoxInput = [System.Windows.MessageBox]::Show(
    "You are about to edit Registry Files, Make sure all windows are closed and your work is saved.`nDo you wish to continue?", 'FixSW3D', 'YesNo'
)

#Check computer user admin accounts with the Jong and Cbeck profiles

#If the message box comes back with Yes:
switch ($msgBoxInput) {
    'Yes' {
        
if(!(Test-Path -PathType Container $desPath)){
    New-Item -ItemType Directory -Path $desPath
}

reg export "HKCU\Software\Dassault Systemes" $d 
reg export "HKCU\Software\SolidWorks" $s 

try {
    Get-ItemProperty -Path $DSRegPath | Select-Object -ExpandProperty "SW_Login_Disable"
    Set-ItemProperty -Path $DSRegPath -Name "SW_Login_Disable" -Value $true
    Write-Host -NoNewline 'Script Complete. Press any key to Continue...'
    $null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
}
catch {
    New-ItemProperty -Path $DSRegPath -Name "SW_Login_Disable" -Value $true
    Write-Host -NoNewline 'Script Complete. Press any key to Continue...'
    $null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
}
    }
    'No' {
        Write-Host -NoNewline 'Script Terminated. Press any key to Continue...'
        $null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
    }
}
