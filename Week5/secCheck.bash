#!/bin/bash

# Script to perform local security checks

function checks() {

	if [[ $2 != $3 ]]
	then

		echo -e "\e[1;31mThe $1 policy is not compliant. The current policy should be: $2, the current value is $3"
		echo -e "\e[1;33mREMEDIATION:"
		echo -e "$4\e[0m"
		echo ""

	else

		echo -e "\e[1;32mThe $1 policy is compliant. The current policy is: $3\e[0m"
		echo ""

	fi

}
# Check the password max days between changes
pmax=$(egrep -i '^PASS_MAX_DAYS' /etc/login.defs | awk ' { print $2 } ')
checks "Password Max Days" "365" "${pmax}" "Set the PASS_MAX_DAYS parameter to 365 in /etc/login/.defs"

# Check the pass min days between changes
pmin=$(egrep -i '^PASS_MIN_DAYS' /etc/login.defs | awk ' { print $2 } ')
checks "Password Min Days" "14" "${pmin}" "Set the PASS_MIN_DAYS parameter to 14 in /etc/login.defs"

# Check the pass warn age
pwarn=$(egrep -i '^PASS_WARN_AGE' /etc/login.defs | awk ' { print $2 } ')
checks "Password Warn Age" "7" "${pwarn}" "Set the PASS_WARN_AGE parameter to 7 in /etc/login.defs"

# Check the SSH UsePam configuration
chkSSHPAM=$(egrep -i "^UsePAM" /etc/ssh/sshd_config | awk ' { print $2 }' )
checks "SSH UsePAM" "yes" "${chkSSHPAM}" "Set the UsePAM parameter to yes in /etc/ssh/sshd_config"

# Check permissions on users home directory
echo ""
for eachDir in $(ls -l /home | egrep '^d' | awk ' { print $3 } ')
do

	chDir=$(ls -ld /home/${eachDir} | awk ' { print $1 } ')
	checks "Home directory ${eachDir}" "drwx------" "${chDir}" "Run the following command: sudo chmod 700 /home/${eachDir}"

done

# Check permissions in /etc/cron*
for eachDir in $(ls -l /etc | grep "cron" | tail -5 | awk ' { print $9 } ' )
do

	chDir=$(ls -ld /etc/${eachDir} | awk ' { print $1 } ')
	checks "directory /etc/${eachDir}" "drwx------" "${chDir}" "Run the following command: sudo chmod 700 /etc/${eachDir}"

done

# Check if permissions in /etc/passwd
chkEtcPasswd=$(ls -ld /etc/passwd | awk ' { print $1 } ' )
checks "permissions of directory /etc/passwd" "-rw-r--r--" "${chkEtcPasswd}" "Run the following command: sudo chmod 644 /etc/passwd"
chkEtcPasswdOwn=$(ls -ld /etc/passwd | awk ' { print $3 } ' )
checks "owner of directory /etc/passwd" "root" "${chkEtcPasswdOwn}" "Run the following command: sudo chown root:root /etc/passwd"

# Check if permissions in /etc/shadow
chkEtcShadow=$(ls -ld /etc/shadow | awk ' { print $1 } ' )
checks "directory /etc/shadow" "-rw-r-----" "${chkEtcShadow}" "Run the following command: sudo chmod 640 /etc/shadow"
chkEtcShadowOwn=$(ls -ld /etc/shadow | awk ' { print $3 } ' )
checks "owner of directory /etc/shadow" "root" "${chkEtcShadowOwn}" "Run the following command: sudo chown root:shadow /etc/shadow"

# Check if permissions in /etc/group
chkEtcGroup=$(ls -ld /etc/group | awk ' { print $1 } ' )
checks "directory /etc/group" "-rw-r--r--" "${chkEtcGroup}" "Run the following command: sudo chmod 644 /etc/group"
chkEtcGroupOwn=$(ls -ld /etc/group | awk ' { print $3 } ' )
checks "owner of directory /etc/group" "root" "${chkEtcGroupOwn}" "Run the following command: sudo chown root:root /etc/group"

# Check if permissions in /etc/gshadow
chkEtcGshadow=$(ls -ld /etc/gshadow | awk ' { print $1 } ' )
checks "directory /etc/gshadow" "-rw-r-----" "${chkEtcGshadow}" "Run the following command: sudo chmod 640 /etc/gshadow"
chkEtcGshadowOwn=$(ls -ld /etc/gshadow | awk ' { print $3 } ' )
checks "owner of directory /etc/gshadow" "root" "${chkEtcGshadowOwn}" "Run the following command: sudo chown root:shadow /etc/gshadow"

# Check if permissions in /etc/passwd-
chkEtcPasswdDash=$(ls -ld /etc/passwd- | awk ' { print $1 } ' )
checks "directory /etc/passwd-" "-rw-r--r--" "${chkEtcPasswdDash}" "Run the following command: sudo chmod 644 /etc/passwd-"
chkEtcPasswdDashOwn=$(ls -ld /etc/passwd- | awk ' { print $3 } ' )
checks "owner of directory /etc/passwd-" "root" "${chkEtcPasswdDashOwn}" "Run the following command: sudo chown root:root /etc/passwd-"

# Check if permissions in /etc/shadow-
chkEtcShadowDash=$(ls -ld /etc/shadow- | awk ' { print $1 } ' )
checks "directory /etc/shadow-" "-rw-r-----" "${chkEtcShadowDash}" "Run the following command: sudo chmod 640 /etc/shadow-"
chkEtcShadowDashOwn=$(ls -ld /etc/shadow- | awk ' { print $3 } ' )
checks "owner of directory /etc/shadow-" "root" "${chkEtcShadowDashOwn}" "Run the following command: sudo chown root:shadow /etc/shadow-"

# Check if permissions in /etc/group-
chkEtcGroupDash=$(ls -ld /etc/group- | awk ' { print $1 } ' )
checks "directory /etc/group-" "-rw-r--r--" "${chkEtcGroupDash}" "Run the following command: sudo chmod 644 /etc/group-"
chkEtcGroupDashOwn=$(ls -ld /etc/group- | awk ' { print $3 } ' )
checks "owner of directory /etc/group-" "root" "${chkEtcGroupDashOwn}" "Run the following command: sudo chown root:root /etc/group-"

# Check if permissions in /etc/gshadow-
chkEtcGshadowDash=$(ls -ld /etc/gshadow- | awk ' { print $1 } ' )
checks "directory /etc/gshadow-" "-rw-r-----" "${chkEtcGshadowDash}" "Run the following command: sudo chmod 640 /etc/gshadow-"
chkEtcGshadowDashOwn=$(ls -ld /etc/gshadow- | awk ' { print $3 } ' )
checks "owner of directory /etc/gshadow-" "root" "${chkEtcGshadowDashOwn}" "Run the following command: sudo chown root:root /etc/gshadow-"

# Check if legacy entries exist in /etc/passwd
chkLegPasswd=$(grep '^\+:' /etc/passwd)
checks "check for legacy entries in directory /etc/passwd" "None" "${chkLegPasswd}None" "Remove any legacy '+' entries from /etc/passwd if they exist."

# Check if legacy entries exist in /etc/shadow
chkLegShadow=$(grep '^\+:' /etc/shadow)
checks "check for legacy entries in directory /etc/shadow" "None" "${chkLegShadow}None" "Remove any legacy '+' entries from /etc/shadow if they exist."

# Check if legacy entries exist in /etc/group
chkLegGroup=$(grep '^\+:' /etc/group)
checks "check for legacy entries in directory /etc/group" "None" "${chkLegGroup}None" "Remove any legacy '+' entries from /etc/group if they exist."

# Check if root is the only UID 0 account
chkUIDs=$(cat /etc/passwd | awk -F: '($3 == 0) { print $1 }')
checks "check for accounts with UID of 0" "root" "${chkUIDs}" "Remove any users other than root with UID 0 or assign them a new UID if appropriate."

# Check if IP forwarding is disabled
chkIPFwd=$(sysctl net.ipv4.ip_forward | awk ' { print $3 } ')
checks "IP forwarding" "0" "${chkIPFwd}" "Set the following parameter in /etc/sysctl.conf or a /etc/sysctl.d/* file: net.ipv4.ip_forward = 0"

# Check if ICMP Redirects are disabled
chkICMPRedir=$(sysctl net.ipv4.conf.all.send_redirects | awk ' { print $3 } ')
checks "ICMP Redirects" "0" "${chkICMPRedir}" "Set the following parameter in /etc/sysctl.conf or a /etc/sysctl.d/* file: net.ipv4.conf.all.send_redirects = 0"
