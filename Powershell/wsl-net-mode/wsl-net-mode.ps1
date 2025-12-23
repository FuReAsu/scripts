param(
    [Parameter(Mandatory=$true)]
    [string]$Mode
)

$cfg_path = "$env:USERPROFILE\.wslconfig"

if ($Mode -ieq "help") {
    Write-Host "Example Usage`nwsl-net-mode [Mirrored|Nat|None|current]"
    exit
}

if ($Mode -ieq "current") {
    if (Test-Path $cfg_path) {
        $current = ((Get-Content $cfg_path | Select-String '^\s*networkingMode\s*=').Line -split '=', 2)[1].Trim()
        if ($current) {
            Write-Host "Current networking mode is $current"
        } else {
            Write-Host "No networking mode set yet!"
        }
    } else {
        Write-Host "No .wslconfig file found!"
    }
    exit
}

if ($Mode -notmatch '^(Mirrored|Nat|None)$') {
    Write-Host "Invalid networking mode $Mode"
    Write-Host "Please use [Mirrored|Nat|None]"
    exit
}

if (!(Test-Path $cfg_path)) {
@"
[wsl2]
networkingMode = $Mode
"@ | Set-Content $cfg_path

    Write-Host "$cfg_path initialized with networkingMode = $Mode"
    exit
}

$cfg_content = Get-Content $cfg_path -Raw

if ($cfg_content -match "(?i)\bnetworkingMode\s*=\s*$Mode\b") {
    Write-Host "The networking mode is already set to $Mode"
    exit
}

if ($cfg_content -notmatch '(?im)^\s*\[wsl2\]\s*$') {
    $cfg_content += "`r`n[wsl2]`r`nnetworkingMode = $Mode`r`n"
    Set-Content $cfg_path $cfg_content
    Write-Host "Added [wsl2] and networkingMode = $Mode to $cfg_path"
    exit
}

$cfg_content = $cfg_content -replace '(?im)^\s*networkingMode\s*=.*$', ''

$cfg_content = $cfg_content.Trim() -replace '(?im)(^\s*\[wsl2\]\s*$)', "`$1`r`nnetworkingMode = $Mode"

Set-Content $cfg_path $cfg_content

Write-Host "Updated networkingMode to $Mode inside $cfg_path"

$confirm = Read-Host "Shutting down WSL to enable the new networkingMode. Confirm? [y/N]"

if ($confirm -match '^[yY]$') {
    wsl --shutdown
    Write-Host "WSL shut down successfully..."
}
else {
    Write-Host "Not shutting down WSL."
}
