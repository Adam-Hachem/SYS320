#!/bin/bash

#Storyline: Script to create a wireguard server

#Create a private key
p="$(wg genkey)"

#Create a public key
pub="$(echo ${p} | wg pubkey)"

#Set the addresesses
address="10.254.132.0/24,172.16.28.0/24"

#Set Server IP addresses
ServerAddress="10.254.132.1/24,172.16.28.1/24"

#Set the listen port
lport="4282"

#Create the format for the client configuration options
peerInfo="# ${address} 184.171.153.48:4282 ${pub} 8.8.8.8,1.1.1.1 1280 120 0.0.0.0/0"

echo "${peerInfo}
[Interface]
Address = ${ServerAddress}
#PostUp = /etc/wireguard/wg-up.bash
#PostDown = /etc/wireeguard/wg-down.bash
ListenPort = ${lport}
PrivateKey = ${p}
" > wg0.conf
