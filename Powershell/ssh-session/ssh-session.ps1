#utility to save and ssh sessions
param (
	[switch]$a,
	[switch]$rm,
	[switch]$l,
	[switch]$h
)

$vars_file="$scripts\ssh-session\vars.ps1"

if (-not $a -and -not $rm -and -not $l -and -not $h) {
	Write-Host "usage: ssh-session [-a | -rm | -l | -h]"
	Exit
}

if ($a) {
	#get arguments and define variables
	$ssh_server=$args[0]
	$ssh_name=$args[1]
	if ($ssh_server -eq $null -or $ssh_name -eq $null) {
		Write-Host "Not Enough Arguments"
		Exit
	}

	#check if the entries already exists
	$keyExists = Select-String -Path $vars_file -Pattern "$([regex]::Escape($ssh_name))"
	$valueExists = Select-String -Path $vars_file -Pattern "$([regex]::Escape($ssh_server))"
	if ($keyExists -or $valueExists){
		Write-Host "The SSH Session $ssh_name already exists"
		Exit
	} else {
		Write-Host "Adding public key to remote server"
		Invoke-Expression "type $env:USERPROFILE\.ssh\id_ed25519.pub | ssh $ssh_server `"cat >> ~/.ssh/authorized_keys`""
		Add-Content -Path $vars_file -Value "`$$ssh_name=`"$ssh_server`""	
		Write-Host "Added the variable $ssh_name to the vars file"
		Write-Host "SSH Session added successfully. Please reload powershell to use the variable."
		Exit
	}
}

if ($rm) {
	$ssh_name=$args[0]
	$ssh_server=""
	$keyExists = Select-String -Path $vars_file -Pattern "$([regex]::Escape($ssh_name))"
	
	if ($keyExists) {
		$fileContent = Get-Content $vars_file
		foreach ($line in $fileContent) {
			if ($line -match "^\s*\`$$([regex]::Escape($ssh_name))\s*=\s*`"([^`"]+)`"") {
				$ssh_server=$matches[1]
			}
		} 
		Write-Host "Removing the public key from remote server $ssh_server"
		$comment = (Get-Content "$env:USERPROFILE\.ssh\id_ed25519.pub") -split ' ' | Select-Object -Last 1
		ssh $ssh_server "sed -i.bak -e '/$comment/d' ~/.ssh/authorized_keys" 
		Write-Host "Removing the variable from the vars file"
		(Get-Content $vars_file) | Where-Object { $_ -notmatch "^\s*\`$$([regex]::Escape($ssh_name))\s*=" } | Set-Content $vars_file
	} else {
		Write-Host "SSH Session $ssh_name is not saved yet"
	}
}

if ($l) {
	$keys = (Get-Content $vars_file) -match '^\s*\$\w+\s*=' | ForEach-Object { ($_ -split '=', 2)[0] -replace '^\$' }	
	$count = 0
	foreach ($key in $keys) {
		$count ++
		Write-Host "$count : $key"
	}
	Exit

}

if ($h) {
	Write-Host "Utility to save and delete ssh sessions"
	Write-Host "Add ed25519 public key to remote server and add the ssh connection string as variable"
	Write-Host "usage`t-> ssh-session -a <ssh_string> <connection_name>"
	Write-Host "`t-> ssh-session -l"
	Write-Host "`t-> ssh-session -rm <connection_name>"
	Write-Host "-a`t| add`n-l`t| list`n-rm`t| remove`n-h`t|help (print this)"
	Exit
}
