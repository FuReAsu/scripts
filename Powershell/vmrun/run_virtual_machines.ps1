#script to run virtual machines by name using vmrun
param (
	[switch]$n,
	[switch]$h,
	[switch]$l,
	[switch]$e
)


$VMDIR="D:\Virtual Machines"
$vmrun="C:\Program Files (x86)\VMware\VMware Workstation\vmrun.exe"

if ($args.Count -gt 0 -and -not $n -and -not $h -and -not $l -and -not $e) {
    	Start-Process -FilePath $vmrun $args -NoNewWindow -Wait
    	Exit
}

if ($args.Count -eq 0 -and -not $n -and -not $h -and -not $l -and -not $e) {
	Start-Process -FilePath $vmrun -NoNewWindow -Wait
}

if ($h) {
	Write-Host "vmrun | run with names instead of vmx paths`n"
	Write-Host "-n -> enter the names of virtual machines"
	Write-Host "-l -> print the list of virtual machines"
	Write-Host "-e -> go to the virtual machines directory"
	Write-Host "-h -> print this page`n"
	Write-Host "example usage:	vmrun -n vm1,vm2,vm3 start"
	Write-Host "		vmrun -n vm1 stop"
	Write-Host "		vmrun -n vm2 checkToolsState"
	Write-Host "		vmrun -n vm3 getGuestIPaddress"
	Exit
}

if ($n) {
	$vmname_list=$args[0]
	$args = $args[1..($args.Length - 1)]
	if ($args -eq $vmname_list) {
		Write-Host "Please, provide commands to run!"
		Exit
	}

	Write-Host "Running -> vmrun $args"
	
	foreach ($vmname in $vmname_list) {
		$vmxFile = Get-ChildItem -Path $VMDIR/$vmname -Recurse -Filter "*.vmx" | Where-Object { $_.FullName -match $vmname } | Select-Object -First 1
		
		if ($vmxFile) {
			$vmxPath = $vmxFile.FullName
			Write-Host "$vmname" -NoNewLine -ForegroundColor green
			Write-Host " at $vmxPath"
			Start-Process $vmrun -ArgumentList "$args `"$vmxPath`" nogui"-NoNewWindow -Wait
		} else {
			Write-Host "VM not Found at $vmxPath"
		}
	}
	Exit
}

if ($l) {
	$VMList = Get-ChildItem -Path $VMDIR -Name
	$count = 0
	foreach ($VM in $VMList) {
		$count ++
		Write-Host "$count : $VM"
	}
}

if ($e) {
	Write-Host "Opening Explorer in the VM Directory"
	explorer $VMDIR
}




