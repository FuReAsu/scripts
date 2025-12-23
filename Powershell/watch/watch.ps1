#watch utility 
param (
    [int]$i = 1
)


if ($args.Count -eq 0) {
    Write-Host "'watch' - tool to print output of commands every specified interval.`n Usage: watch <command> -i <interval>"
    exit
}

$Command = $args -join " "
while ($true) {
    Clear-Host
    Write-Host "Every $i Seconds:$Command`n================================================================"
    Invoke-Expression $Command
    Start-Sleep -Seconds $i
}
