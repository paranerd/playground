#! /bin/bash

# Allow responses to established connections
sudo iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
# SSH
sudo iptables -A INPUT -p tcp --dport 22 -j ACCEPT
# HTTP
sudo iptables -A INPUT -p tcp --dport 80 -j ACCEPT
# VNC
sudo iptables -A INPUT -p tcp --dport 5900 -j ACCEPT
# SAMBA
# sudo iptables -A INPUT -p udp -m udp --dport 137 -j ACCEPT
# sudo iptables -A INPUT -p udp -m udp --dport 138 -j ACCEPT
# sudo iptables -A INPUT -p tcp -m tcp --dport 139 -j ACCEPT
# sudo iptables -A INPUT -p tcp -m tcp --dport 445 -j ACCEPT
# DNS (for apt-get)
sudo iptables -A INPUT -p udp --sport 53 -j ACCEPT
# JDownloader
# sudo iptables -A INPUT -p tcp --sport 10101 -j ACCEPT
# Plex
sudo iptables -A INPUT -p tcp --dport 32400 -j ACCEPT
# Drop everything else
sudo iptables -A INPUT -j DROP
# Standard rule (persistent even after flushing)
sudo iptables -P INPUT ACCEPT
