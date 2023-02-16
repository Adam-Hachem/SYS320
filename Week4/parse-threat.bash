#!/bin/bash

# Storyline: Extract IPs from emergingthreats.net and create a firewall ruleset

# alert ip [2.59.200.0/22,5.134.128.0/19,5.180.4.0/22,5.183.60.0/22,5.188.10.0/23,24.137.16.0/20,24.170.208.0/20,24.233.0.0/19,24.236.0.0/19,27.126.160.0/20,27.146.0.0/16,31.14.65.0/24,36.0.8.0/21,36.37.48.0/20,36.116.0.0/16,36.119.0.0/16,37.156.64.0/23,37.156.173.0/24,41.72.0.0/18,42.0.32.0/19] any -> $HOME_NET any (msg:"ET DROP Spamhaus DROP Listed Traffic Inbound group 1"; reference:url,www.spamhaus.org/drop/drop.lasso; threshold: type limit, track by_src, seconds 3600, count 1; classtype:misc-attack; flowbits:set,ET.Evil; flowbits:set,ET.DROPIP; sid:2400000; rev:3530; metadata:affected_product Any, attack_target Any, deployment Perimeter, tag Dshield, signature_severity Minor, created_at 2010_12_30, updated_at 2023_02_15;)


# Regex to extract the networks
# 2.         59.          200.         0/       22

# grabs the IP list from the internet and formats it nicely in a file
function listmaker() {

	# get the bad ip file from the internet and put them into a file in the /tmp directory.
	wget https://rules.emergingthreats.net/blockrules/emerging-drop.suricata.rules -O /tmp/emerging-drop.suricata.rules

	# get only the IPs from the bad ip file that just downloaded and turn the result into the badIPs.txt file.
	egrep -o '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.0/[0-9]{1,2}' /tmp/emerging-drop.suricata.rules | sort -u | tee badIPs.txt
	echo "Malicious IPs list created"

}

# check to see if the badIPs file exists. if it does, ask whether or not the user wants to download again.
if [[ -f badIPs.txt ]]
then
	read -p "The list of malicious IPs already exists. Download again? [y][n]: " answer
	case "$answer" in
		y|Y)
			echo "Rebuilding list of malicious IPs..."
			listmaker
		;;
		n|N)
			echo "Proceeding with original file."
		;;
		*)
			echo "Invalid response. Answer Y or N."
			exit 1
		;;
	esac
else
	echo "Downloading list of malicious IPs"
	listmaker
fi

# Menu for selecting output format
while getopts 'icwmu' OPTION ; do

	case "$OPTION" in
		i) iptables=${OPTION}
		;;
		c) cisco=${OPTION}
		;;
		w) windows=${OPTION}
		;;
		m) mac=${OPTION}
		;;
		u) ciscourl=${OPTION}
		;;
		*)
			echo "Invalid response."
			exit 1
		;;

	esac
done

# If the user selected IPTables option, create a correctly formatted IPTables file
if [[ ${iptables} ]]
then
	for eachIP in $(cat badIPs.txt)
	do
		echo "iptables -a input -s ${eachIP} -j drop" | tee -a  badIPs.iptables
	done
	clear
	echo 'IPTables format firewall file created: badips.iptables'
fi

# If the user selected Cisco option, create a correctly formatted cisco file
if [[ ${cisco} ]]
then
	# Make a new list without the subnet mask. Cisco firewalls do not accept the subnet mask
	egrep -o '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.0' badIPs.txt | tee badIPs.onlyip
	for eachIP in $(cat badIPs.onlyip)
	do
		echo "deny ip host ${eachIP} any" | tee -a badIPs.cisco
	done
	rm badIPs.onlyip
	clear
	echo 'Cisco firewall file created: badips.cisco'
fi

# If the user selected Windows option, create a correctly formatted netsh file
if [[ ${windows} ]]
then
	egrep -o '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.0' badIPs.txt | tee badIPs.onlyip
	for eachIP in $(cat badIPs.onlyip)
	do
		echo "netsh advfirewall firewall add rule name=\"BLOCK IP ADDRESS - ${eachIP}\" dir=in action=block remoteip=${eachIP}" | tee -a badIPs.netsh
	done
	rm badIPs.onlyip
	clear
	echo 'Windows firewall file created: badIPs.netsh'
fi

# If the user selected Mac option, create a correctly formatted pf.conf file
if [[ ${mac} ]]
then
	echo '
	scrub-anchor "com.apple/*"
	nat-anchor "com.apple/*"
	rdr-anchor "com.apple/*"
	dummynet-anchor "com.apple/*"
	anchor "com.apple/*"
	load anchor "com.apple" from "/etc/pf.anchors/com.apple"

	' | tee pf.conf

	for eachip in $(cat badIPs.txt)
	do
		echo "block in from ${eachip} to any" | tee -a pf.conf
	done
	clear
	echo 'Mac firewall file created: pf.conf'
fi

# If the user selected Cisco URL option, create a correctly formatted ciscothreats.txt
if [[ ${ciscourl} ]]
then
	wget https://raw.githubusercontent.com/botherder/targetedthreats/master/targetedthreats.csv -O /tmp/targetedthreats.csv
	awk '/domain/ {print}' /tmp/targetedthreats.csv | awk -F \" '{print $4}' | sort -u > threats.txt
	echo 'class-map match-any BAD_URLS' | tee ciscothreats.txt
	for eachip in $(cat threats.txt)
	do
		echo "match protocol http host \"${eachip}\"" | tee -a ciscothreats.txt
	done
	rm threats.txt
	clear
	echo 'Cisco URL Filter file created: ciscothreats.txt'
fi
