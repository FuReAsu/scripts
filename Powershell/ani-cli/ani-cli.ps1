#ani-cli wrapper for powershell

if ($args.Count -eq 0){
	Invoke-Expression "bash -c 'ani-cli --help'"
	exit
}

Invoke-Expression "bash -c 'ani-cli $args'"
