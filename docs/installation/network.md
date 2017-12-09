[TOC]

---

# Tasks
* Configure static IP(s)
* Install diagnostic tools
* Verify network config


# Server IP already assigned
If you have a *root server* or *vServer* or for whatever reason you got a static IPv4 address for your server, just use that address and your are done with this chapter. 

---

# Configure static IP(s)

## Debian / Ubuntu / Rasphian

### Static IPv4 address
After installing the operating system it often gets its IPv4 adress via DHCP. To avoid trouble in the future this address should be static in most cases.
```sh
root@cloudserver:~# ip route
default via 192.168.1.1 dev ens3 
192.168.1.0/24 dev ens3 proto kernel scope link src 192.168.1.22 
```

The `default` line tells us `192.168.1.1` is the default gateway, `ens3` is the network device in our case. We need to remember that.
```sh
root@cloudserver:~# ip addr
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host 
       valid_lft forever preferred_lft forever
2: ens3: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default qlen 1000
    link/ether 52:54:00:ae:a4:12 brd ff:ff:ff:ff:ff:ff
    inet 192.168.1.22/24 brd 192.168.1.255 scope global ens3
       valid_lft forever preferred_lft forever
    inet6 fe80::5054:ff:feae:a412/64 scope link 
       valid_lft forever preferred_lft forever
```

The interresting part is the inet line in our network device (`ens3`). It tells us `192.168.1.22` is the current IPv4 address, `/24` is the network 
mask in CIDR notation, which is `255.255.255.0` as subnet mask (see [https://en.wikipedia.org/wiki/Classless_Inter-Domain_Routing](https://en.wikipedia.org/wiki/Classless_Inter-Domain_Routing)) 
and `192.168.1.255` is the broadcast address.

We need to pick an unused IPv4 address, which is not within the dhcp range. Mostly the dhcp server is in the router. 
You will find the description there. `x.x.x.1` ist the gateway in this case as we have seen. Dhcp range starts normaly at 
`x.x.x.20` or above. `x.x.x.2` is normally free, but you should be sure about that to prevent annoying network problems. 
I choose `192.168.1.2` as static IPv4 address.

```sh
root@cloudserver:~# cat /etc/resolv.conf
domain fritz.box
search fritz.box
nameserver 192.168.1.1
root@cloudserver:~# hostname -f
cloudserver.local
```

We take the dns-server (= nameserver)  from here. In this case the dhcp server put this computer in the domain `fritz.box` while I put it into the domain `local`. 
Pros and cons what to take are not scope of this how-to. I will leave it as it is for now.

Now it is better to have a backup of the configuration. We can put it in our home directory:
```sh
root@cloudserver:~# cp /etc/network/interfaces ~/
```

This is the actual network configuration:
```sh
root@cloudserver:~# cat /etc/network/interfaces
# This file describes the network interfaces available on your system
# and how to activate them. For more information, see interfaces(5).

source /etc/network/interfaces.d/*

# The loopback network interface
auto lo
iface lo inet loopback

# The primary network interface
allow-hotplug ens3
iface ens3 inet dhcp
# This is an autoconfigured IPv6 interface
iface ens3 inet6 auto
```

Change the network configuration to your actual values
```
...

# The primary network interface
allow-hotplug ens3
iface ens3 inet static
  address 192.168.1.2
  netmask 255.255.255.0
  gateway 192.168.1.1
  dns-domain local
  dns-nameservers 192.168.1.1
# This is an autoconfigured IPv6 interface
iface ens3 inet6 auto
...
```

Reboot and good luck. Test your network configuration to assure it's working as desired. `ip addr` should show your static IPv4 address, `ip route`
 still the gateway and so on. If something does not work, you have a file named "interfaces" in the home directory of user root, that is your backup.
 You can copy it back to `/etc/network/interfaces` and start all over.

### Static IPv6 address
If you don't want to use or cannot use [IPv6](https://en.wikipedia.org/wiki/IPv6 "IPv6") you may skip this step and anything related to IPv6 in the following chapters.

```sh
root@cloudserver:~# ip -6 addr
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 state UNKNOWN qlen 1
    inet6 ::1/128 scope host 
       valid_lft forever preferred_lft forever
2: ens3: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 state UP qlen 1000
    inet6 2003:a:452:e300:5054:ff:feae:a412/64 scope global mngtmpaddr dynamic 
       valid_lft 7197sec preferred_lft 3597sec
    inet6 fe80::5054:ff:feae:a412/64 scope link 
       valid_lft forever preferred_lft forever
```

If you find an inet6 address with scope `global` and not `deprecated` and not `temporary`, it's an IPv6 address you may use to access your server.

Add the IPv6 block to your network configuration
```
...
# This is an IPv6 interface
iface ens3 inet6 static
  address xxxx
  netmask xxxx
  gateway xxxx
  dns-domain local
  dns-nameservers xxxxx
...
```

---

## CentOS

### Static IPv4 address
*To be written...*

### Static IPv6 address
*To be written...*

---

## IPv6 only
Having a root server or a vServer without any IPv4 at all is not really within the scope of this manual. Probably the best way is to get a domain 
now and point it to your IPv6 address.

---

# Install diagnostic tools

* `curl` is a tool to transfer data from or to a server. We will use it to diagnose the web server.
* `nmap` is a network exploration tool. We will use it as a port scanner to diagnose running services.

**Debian / Ubuntu / Rasphian**
```bash
root@cloudserver:~# apt-get install curl nmap
```

**CentOS**
```bash
root@cloudserver:~# yum install curl nmap
```

---

## Verify network config

### IPv4
*To be written...*

---

### IPv6
If your server has a global IPv6 address, you can test it with a web browser on a computer in local LAN having IPv6 enabled as well: `http://[2003:a:452:e300:5054:ff:feae:a412]`. This works because the Nginx 'default' server (which we have still enabled) comes with IPv6 enabled.

You can test it with curl as well:
```sh
root@cloudserver:~# curl -I http://[2003:a:452:e300:5054:ff:feae:a412]
HTTP/1.1 200 OK
Server: nginx/1.10.3
Date: Wed, 19 Jul 2017 07:31:05 GMT
Content-Type: text/html
Content-Length: 612
Last-Modified: Mon, 17 Jul 2017 13:41:49 GMT
Connection: keep-alive
ETag: "596cbe9d-264"
Accept-Ranges: bytes
```

Or test it using nmap:
```sh
root@cloudserver:~# nmap -6 2003:a:452:e300:5054:ff:feae:a412

Starting Nmap 7.40 ( https://nmap.org ) at 2017-07-19 09:33 CEST
Nmap scan report for 2003:a:452:e300:5054:ff:feae:a412
Host is up (0.000015s latency).
Not shown: 998 closed ports
PORT   STATE SERVICE
22/tcp open  ssh
80/tcp open  http
```

Note that port 80 is open because of the default server, port 443 is not (for now)!

```

Test it using nmap:
```sh
root@cloudserver:~# nmap -6 fe80::5054:ff:feae:a412

Starting Nmap 7.40 ( https://nmap.org ) at 2017-07-19 10:13 CEST
Nmap scan report for fe80::5054:ff:feae:a412
Host is up (0.000015s latency).
Not shown: 997 closed ports
PORT    STATE SERVICE
22/tcp  open  ssh
80/tcp  open  http
443/tcp open  https
```

Open a web browser: `https://[2003:a:452:e300:5054:ff:feae:a412]/seafile`. Mind the 'https:' as there is no redirection for now. If you see the Log In page, it works. Do not log in for the moment because in Seafile Server we set our IPv4 address as SERVICE_URL and FILE_SERVER_ROOT. It will mix up things sooner or later if you log in. Just be satisfied with the knowledge it could work if we would continue. But in that case we would break IPv4.

---

# Literature
* [Debian Reference Manual: The network interface with the static IP](https://www.debian.org/doc/manuals/debian-reference/ch05.en.html#_the_network_interface_with_the_static_ip)
* [CentOS Reference Manual: Interface Configuration Files](https://www.centos.org/docs/5/html/Deployment_Guide-en-US/s1-networkscripts-interfaces.html)
