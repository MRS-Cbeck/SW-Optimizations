Add-Type -AssemblyName PresentationFramework

# Ensure script is running as Administrator
$currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
$principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
	Write-Host "Please run this script as an Administrator" -ForegroundColor Red
	exit
}

# Define registry and backup paths
$DSRegPath = "HKCU:\Software\Dassault Systemes"
$SWRegPath = "HKCU:\Software\SolidWorks"
$desPath = "$env:USERPROFILE\Documents\SolidworksRegistryBackUp"
$d = "$desPath\DSregistryBackup.reg"
$s = "$desPath\SWregistryBackup.reg"

# Warn the user before proceeding
$msgBoxInput = [System.Windows.MessageBox]::Show(
	"You are about to edit Registry Files. Ensure all windows are closed and work is saved. `nDo you wish to continue?",
	'FixSW3D', 'YesNo'
)


switch ($msgBoxInput) {
	'Yes' {
		# Ensure backup Directory exists
		if (!(Test-Path -PathType Container $desPath)) {
			New-Item -ItemType Directory -Path $desPath -Force | Out-Null
		}
		
		# Backup registry
		if (Test-Path $DSRegPath) { reg export "HKCU\Software\Dassault Systemes" $d }
		if (Test-Path $SWRegPath) { reg export "HKCU\Software\SolidWorks" $s }
		
		# Modify the registry safely
		try {
			if (Get-ItemProperty -Path $DSRegPath -Name "SW_Login_Disable" -ErrorAction Stop) {
				Set-ItemProperty -Path $DSRegPath -Name "SW_Login_Disable" -Value $true
			}
		}
		catch {
			Write-Host "Creating missing registry key. . ."
			New-ItemProperty -Path $DSRegPath -Name "SW_Login_Disable" -Value $true -Force
		}
		
		Write-Host 'Script Complete. Closing in 3 seconds . . .' -ForegroundColor Green
		Start-Sleep -Seconds 3
	}
	
	'No' {
		Write-Host 'Script Terminated. Exiting in 3 seconds . . .' -ForegroundColor Yellow
		Start-Sleep -Seconds 3
	}
}
