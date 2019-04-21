# Instructions for running tuya-convert in open-wrt

## Configure network in admin interface

Set wlan to router mode

Set network to 10.42.42.x, with router on 10.42.42.1, serving DHCP addresses from 10.42.42.10 to .42

Set AP name to `vtrust-flash` and WPA2 password to `flashmeifyoucan`

Set ip broadcast:

```
$ ip route add 255.255.255.255 dev br-lan
```

## Set up dnsmasq to mask tuya domains

Edit `/etc/dnsmasq.conf` and append:

```
address=/tuya.com/10.42.42.1
address=/tuyaeu.com/10.42.42.1
address=/tuyaus.com/10.42.42.1
address=/tuyacn.com/10.42.42.1
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

# Put device into pairing mode

Hold button until light flashes quickly

# Run smartconfig

In another Screen:

```
$ ./scripts/smartconfig/main.py
``` 

# Interact via curl

Device should appear e.g. on 10.42.42.42. Ping it to confirm.

Fetch backup:

```
$ curl -JO http://10.42.42.42/backup
```

Get device info:

```
$ curl http://10.42.42.42
```

Undo:

```
$ curl http://10.42.42.42/undo
```

Set conversation software in user2:

```
$ curl http://10.42.42.42/flash2"
```

Flash:

```
$ curl curl http://10.42.42.42/flash3
```
