#!/bin/bash

# Source config
. ../config.txt

# TODO: Do we need this?
# ifconfig $WLAN up

echo "Writing dnsmasq config file..."
echo "Creating new /tmp/dnsmasq-tuya.conf..."
cat <<- EOF >/tmp/dnsmasq-tuya.conf
	# disables dnsmasq reading any other files like /etc/resolv.conf for nameservers
	no-resolv
	# Interface to bind to
	interface=$WLAN
	#Specify starting_range,end_range,lease_time
	dhcp-range=10.42.42.10,10.42.42.40,12h
	# dns addresses to send to the clients
	server=9.9.9.9
	server=1.1.1.1
	address=/tuya.com/10.42.42.1
	address=/tuyaeu.com/10.42.42.1
	address=/tuyaus.com/10.42.42.1
	address=/tuyacn.com/10.42.42.1
EOF

# TODO: We probably don't need this since the router does its own thing
# echo "Writing hostapd config file..."
# cat <<- EOF >/etc/hostapd/hostapd.conf
#	interface=$WLAN
#	driver=nl80211
#	ssid=$AP
#	hw_mode=g
#	channel=1
#	macaddr_acl=0
#	auth_algs=1
#	ignore_broadcast_ssid=0
#	wpa=2
#	wpa_passphrase=$PASS
#	wpa_key_mgmt=WPA-PSK
#	wpa_pairwise=TKIP
#	rsn_pairwise=CCMP
# EOF

echo "Configuring AP interface..."
ifconfig $WLAN up 10.42.42.1 netmask 255.255.255.0

echo "Applying iptables rules..."
iptables --flush
iptables --table nat --flush
iptables --delete-chain
iptables --table nat --delete-chain
iptables --table nat --append POSTROUTING --out-interface $ETH -j MASQUERADE
iptables --append FORWARD --in-interface $WLAN -j ACCEPT

echo "Starting DNSMASQ server..."
pkill dnsmasq
dnsmasq --conf-file=/tmp/dnsmasq-tuya.conf

# TODO: Do we need this or will the router handle?
# sysctl -w net.ipv4.ip_forward=1 > /dev/null 2>&1

ip route add 255.255.255.255 dev $WLAN

# echo "Starting AP on $WLAN in screen terminal..."
# hostapd /etc/hostapd/hostapd.conf

read -p "Waiting ... Press Enter to clean up"

pkill dnsmasq

ip route del 255.255.255.255

iptables --flush
iptables --flush -t nat
iptables --delete-chain
iptables --table nat --delete-chain
