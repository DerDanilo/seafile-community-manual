[TOC]

---

## Firewall configuration via UFW

This guide shows you how to install and enable the firewall via `ufw`.


# Install Fail2ban

```shell
root@cloudserver:~# apt-get update && apt-get install ufw
```

# Configure firewall

It is important that you configure the firewall rules before you enable it.
Otherwise you might lock yourself out.

## Configure allow rules

```shell
root@cloudserver:~# ufw allow http
root@cloudserver:~# ufw allow https
root@cloudserver:~# ufw allow ssh
root@cloudserver:~# ufw enable

```

## Activate firewall

```shell
root@cloudserver:~# ufw enable

```