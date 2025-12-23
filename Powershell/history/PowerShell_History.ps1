param (
	[switch]$l,
	[switch]$h,
	[int]$n
)

$history_path="$env:APPDATA\Microsoft\Windows\PowerShell\PSReadLine"
$i = 0
if ($h) {
	Write-Host "powershell history utility"
	Write-Host "-l -> list all the history files"
	Write-Host "-h -> help; show this output"
	Write-Host "-n -> specify which file number to read (integer)"
	Exit
}

if ($l) {
	Write-Host "==================="
	Get-ChildItem -Path $history_path -Name
	Write-Host "==================="
	Exit
}

if ($n) {
	Get-Content "$history_path\$n.archive.txt" | ForEach-Object { $i++;"${i}: $_"}
	Exit
}

Get-Content "$history_path\ConsoleHost_history.txt" | ForEach-Object { $i++;"${i}: $_"}
if ( $i -gt 1000 ) {
	$number = (ls $history_path).Count
	Invoke-Expression "mv $history_path\ConsoleHost_history.txt $history_path\$number.archive.txt"
}

