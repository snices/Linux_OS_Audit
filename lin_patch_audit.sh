#!/bin/bash
#A script to ssh into multiple linux hosts and determine their OS version and available patches.

function show_usage(){
	printf "$0 inputfile username password outputfile\n"
	printf "This script requires the use of an input file containing the list of hosts to be checked.\n"
	printf "It also requires the username and password to ssh into these hosts.\n"
	printf "Optionally you can include an output file to capture the output.\n"

return 0
}

ssh_cmd="$(cat <<EOF
	uname -srv
	if [ -x "$(command -v apt)" ]; then apt list --upgradable
	elif [ -x "$(command -v yum)" ]; then  yum check-update
	elif [ -x "$(command -v dnf)" ];     then dnf check-update
	elif [ -x "$(command -v zypper)" ];  then zypper list-updates
	else echo "Failed to discover available package manager."
	fi
EOF
)"

if [[ -e "$1" && -n "$2" && -n "$3" ]];then
	infile="$1"
	username="$2"
	password="$3"
elif [[ ! -e "$1" ]];then
	echo "Please enter a valid input file."
else
	echo "Missing required parameters"
	show_usage
fi

if [ -n "$4" ];then
	outfile="$4"
fi

touch $outfile

while read host; do

	if [[ -n "$outfile"]];then
		sshpass -p $password ssh -o StrictHostKeyChecking=no $username@$host "$ssh_cmd">>$outfile
	else
		sshpass -p $password ssh -o StrictHostKeyChecking=no $username@$host "$ssh_cmd"
done < $infile

#EOF
