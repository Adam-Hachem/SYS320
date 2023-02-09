#!/bin/bash

# Storyline: Menu for admin, VPN, and Security functions

function invalid_opt() {

	echo ""
	echo "Invalid option"
	echo ""
	sleep 2

}

function menu() {

	# clears the screen
	clear

	echo "[1] Admin Menu"
	echo "[2] Security Menu"
	echo "[3] Exit"
	read -p "Please enter a choice above: " choice

	case "$choice" in 

		1) admin_menu
		;;

		2) security_menu
		;;

		3) exit 0
		;;

		*)

			invalid_opt
			# Call the main menu
			menu

		;;
	esac


}

function security_menu() {

	clear

	echo "[N]etwork Sockets"
	echo "[C]heck users with UID of 0"
	echo "[L]ast 10 logged in users"
	echo "[S]igned in users"
	echo "[5] Exit"
	read -p "Please enter a choice above: " choice

	case "$choice" in

		N|n) netstat -an --inet | less
		;;
		C|c) cat /etc/passwd | grep ":x:0:" | less
		;;
		L|l) last -a | head -n 10 | awk '{ print $1 }' | less
		;;
		S|s) users | less
		;;
		5) exit 0
		;;

		*)
			invalid_opt
		;;

	esac
security_menu
}

function admin_menu() {

	clear

	echo "[L]ist Running Processes"
	echo "[N]etwork Sockets"
	echo "[V]PN Menu"
	echo "[4] Exit"
	read -p "Please enter a choice above: " choice


	case "$choice" in

		L|l) ps -ef | less
		;;
		N|n) netstat -an --inet | less
		;;
		V|v) vpn_menu
		;;
		4) exit 0
		;;

		*)
			invalid_opt
		;;

	esac

admin_menu
}

function vpn_menu() {

	clear

	echo "[A]dd a user"
	echo "[D]elete a user"
	echo "[B]ack to admin menu"
	echo "[M]ain menu"
	echo "[E]xit"
	read -p "Please select an option: " choice

	case "$choice" in

		A|a)

			bash peer.bash
			tail -6 wg0.conf | less

		;;
		D|d)
			# Create a prompt for the user
			# Call the manage-user.bash and pass the proper switches and argument
			# to delete the user.
			read -p "Name the user to be deleted: " del_choice
			manage-users -d -u ${del_choice}
		;;
		B|b) admin_menu
		;;
		M|m) menu
		;;
		E|e) exit 0
		;;
		*)
			invalid_opt

		;;

	esac
vpn_menu
}

# Call the main function
menu
