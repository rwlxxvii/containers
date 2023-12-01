#!/bin/bash

INTERFACE=wlo1

dnf update -y; dnf install firewalld -y

firewall-cmd --permanent --new-policy metasploit 
firewall-cmd --permanent --policy metasploit --set-target DROP
firewall-cmd --permanent --policy metasploit --add-ingress-zone public
firewall-cmd --permanent --policy metasploit --add-egress-zone internal
firewall-cmd --permanent --policy metasploit --add-port=80/tcp
firewall-cmd --permanent --policy metasploit --add-port=443/tcp
firewall-cmd --permanent --policy metasploit --add-port=445/tcp
firewall-cmd --permanent --policy metasploit --add-port=4444/tcp
firewall-cmd --permanent --policy metasploit --add-port=8080/tcp
firewall-cmd --permanent --policy metasploit --add-port=8081/tcp
firewall-cmd --permanent --zone=public --change-interface=${INTERFACE}
firewall-cmd --permanent --zone=internal --change-interface=${INTERFACE}
firewall-cmd --reload
