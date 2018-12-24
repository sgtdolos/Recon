#!/bin/bash

if [ "$1" != "" ]; then
	echo "Running Recon on $1"
else
	echo "Usage ./recon.sh <Target IP> <hostname>"
	exit 1
fi

if [ "$2" != "" ]; then
	echo "Saving files to directory: $2"
else 
	echo "Usage ./recon.sh <Target IP> <hostname>"
	exit 1
fi

mkdir $2

echo "Beginning Initial Scan"
nmap -sC -sV -oA ./$2/init $1 >/dev/null
echo "Initial Scan Complete!"

echo "Beginning full port scan, this may take a while..."
nmap -sV -p- -oA ./$2/full $1 -T4 >/dev/null
echo "Full Scan Complete!"

cat ./$2/full.nmap | grep open | cut -d'/' -f1 > ./$2/portlist

echo "Beginning Gobuster"
gobuster -u http://$1/ -w /usr/share/seclists/Discovery/Web-Content/common.txt -s '200,204,301,302,307,403,500' -e -o ./$2/gobuster >/dev/null
echo "Gobuster Complete!"

echo "Beginning Nikto Scan"
nikto -host $1 --output ./$2/nikto.txt >/dev/null
echo "Nikto Scan Complete!"

echo "Beginning Dirb"
dirb http://$1 -o ./$2/dirb >/dev/null
echo "Dirb Complete!"

echo "Beginning enum4linux"
enum4linux -a $1 > ./$2/enum4linux
echo "enum4linux Complete!"

echo "Beginning Unicorn Scan"
#uniscan -u $1 -qweds > ./$2/uniscan
echo "Unicorn Scan Complete!"

echo "------------------------------Recon Complete----------------------------------------"
