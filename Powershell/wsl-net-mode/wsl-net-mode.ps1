param(
	[Parameter(Mandatory=$true)]
	[string]$Mode
)

$cfg_path = "$env:USERPROFILE\.wslconfig"

if (!(Test-Path $cfg_path)) {
	@"
[wsl2]
networkingMode = $Mode
"@ | Set-Content $cfg_path
		Write-Host "$cfg_path initialized with networkingMode = $Mode"
		exit
}

$cfg_content = Get-Content $cfg_path -Raw

if ($cfg_content -notmatch '\[wsl2\]') {
	$cfg_content = $cfg_content.Trim() + "`r`n[wsl2]`r`nnetworkingMode = $Mode`r`n"
	Set-Content = $cfg_path $cfg_content
	Write-Host "Added [wsl2] and networkingMode = $Mode to $cfg_path"
	exit
}

$cfg_content = $cfg_content.Trim() -replace '(?ms)(\[wsl2\][^\[]*?)\s*networkingMode\s*=.*?(\r?\n)', '$1$2'

$cfg_content = $cfg_content.Trim() -replace '(\[wsl2\]\s*)', "`$1`r`nnetworkingMode = $Mode`r`n"

Set-Content $cfg_path $cfg_content

Write-Host "Updated networkingMode to $Mode inside $cfg_path file"

$confirm = Read-Host -Prompt "Shutting down wsl to enable the new networkingMode Confirm? [y/N]"


if ($confirm.ToLower() -eq "y") {
	wsl --shutdown
	Write-Host "wsl shutdown successfully..."
	exit
}
else {
	Write-Host "Not shutting down wsl and exiting..."
	exit
}

