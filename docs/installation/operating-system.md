[TOC]

---
# General information

This manual covers setup on the following operating systems:

* Debian 9 Stretch (latest)
* Ubuntu 16.04 LTS (latest)

Still in progress and may not be complete:

* CentOS 7 (latest)
* Raspbian (Raspberry Pi)
* Docker

---

## Operating Systems
### Debian
You can use Debian 9 *Stretch* 64-bit as operating system.  
The *64-bit PC Network installer* will be sufficiant. It can be obtained from [www.debian.org](https://www.debian.org/distrib/). 

### Ubuntu LTS
You can use Ubuntu 16.04 LTS *Xenial* 64-bit as operating system.  
The *64-bit PC Network installer* will be sufficiant. It can be obtained from [www.ubuntu.com](https://www.ubuntu.com/download/alternative-downloads). 

### CentOS
You can use CentOS 7 64-bit as operating system.  
The *64-bit PC Network installer* will be sufficiant. It can be obtained from [www.centos.org](https://www.centos.org/download/). 

### Raspbian (Raspberry Pi)
You can use  Debian 9 *Raspbian* as operating system.   
We recommend to use the *Minimal image*. It can be obtained from [www.raspberrypi.org](https://www.raspberrypi.org/downloads/raspbian/).

### Docker (Linux & Windows)
You may also use the [offical docker image](https://hub.docker.com/r/seafileltd/seafile/) of Seafile server.
There are also some 3rd Party Seafile Docker images that might work better.

*The manual does not yet cover this topic.*

### ARM64 Platforms
If you want to use Seafile on a ARM64 Platform, [this guide](https://forum.seafile.com/t/compilation-arm64-done/6170) will help you. You can download 
the packed version 6.3.0 (**deprecated!**) [here](https://cdn.iklive.eu/tcb13/2018/seafile-server_6.3.0_arm64.tar.gz), it should definately work with Debian and Ubuntu.

---

## Storage
### Local Storage

* In this manual we will put the Seafile Server and configuration files in `/opt` and seafile_data in `/srv`
* `/srv` will contain all data in Seafile server and needs to be at least that data size plus some spare for deleted files (file versions)
* If you devide your disk(s) into several partitions or want to use several disks, 10 GiB will be enough for `/` (root)
* If you have 2+ GiB of memory, choose 2 GiB for swap, otherwise 1 GiB will be sufficiant

### NFS/iSCSI Storage
You can map NFS storage to `/srv` or setup a iSCSI target to `/srv`.

### Block Storage
For now the **CE Version** of Seafile Server **does not support** any **block storage**. Adding block storage to the CE version was [requested in the forum](https://forum.seafile.com/t/add-s3-custom-base-bucket-option-make-available-to-ce/) though.
