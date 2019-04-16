# Instructions for running tuya-convert in open-wrt

## Configure network in admin interface

Set wlan to access point mode

Set up NAT to eth0

Set network to 10.42.42.x, with router on 10.42.42.1, serving DHCP addresses from 10.42.42.10 to .42

Set AP name to `vtrust-flash` and WPA2 password to `flashmeifyoucan`

## Set up dnsmasq to mask tuya domains

Edit `/etc/dnsmasq.conf` and append:

```
address=/tuya.com/10.42.42.1
address=/tuyaeu.com/10.42.42.1
address=/tuyaus.com/10.42.42.1
address=/tuyacn.com/10.42.42.1
```

TODO: Also set `no-resolv` and `server=1.1.1.1`?

TODO: Also configure firewall NAT and broadcast? This is what the script does:

```
# dnsmasq.conf

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

# Network

ifconfig $WLAN up 10.42.42.1 netmask 255.255.255.0

iptables --flush
iptables --table nat --flush
iptables --delete-chain
iptables --table nat --delete-chain
iptables --table nat --append POSTROUTING --out-interface $ETH -j MASQUERADE
iptables --append FORWARD --in-interface $WLAN -j ACCEPT

sysctl -w net.ipv4.ip_forward=1 > /dev/null 2>&1

ip route add 255.255.255.255 dev $WLAN
```

# Run registration server

Stop lighthttpd so we can take over port 80

```
$ /etc/init.d/lighttpd stop
```

Then start server in a Screen:

```
$ ./scripts/fake-registration-server.py
```


# Run mosquitto

Stop existing install if running

```
$ /etc/init.d/mosquitto stop
```

Run verbose server in a Screen:

```
$ mosquitto -v
```

# Run smartconfig

In another Screen:

```
$ ./scripts/smartconfig/main.py
``` 
