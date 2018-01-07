# Seafile Community Manual

[TOC]

---
## Status

This guide is "work in progress". We released it already, as it contains enough information to proceed with the setup of Seafile.
We will update the manual whenever we find time to do so. Please keep in mind that it is very time consuming to write such manual.
So far we spend ~ 90h on the manual.

## About

**What is this guide for?**

We write this step-by-step guide to enable all users to setup Seafile on their own but without the struggle 
of having to read the more complex and sometimes confusing [original manual](https://manual.seafile.com/).

It is not our intension to replace the [original manual](https://manual.seafile.com/) !

**How does it work?**

This manual will guide you through each step of the setup. If you are new to Seafile we encourage
you to do the recommend checks whenever we suggest them. This helps to pinpoint possible errors before you have to search for them.

This manual will show how to setup a Seafile Server using MariaDBas database server, Memcached to speed up the webinterface response and Nginx as local reverse proxy.
All operations will be peformed as root unless otherwise specified. So login as root or 'su' to root, if logged in as ordinary user:
```bash
su
# or
su root
# or - if 'sudo' is installed
sudo -i
```

## CE vs PRO Edition

**Seafile Server Community Edition**

This guide is mantained from community members only. Therefor this manual only covers Seafile Server CE.
If you want to deploy Seafile Server CE you are welcome to use our guide.

**Seafile Server Professional Edition**

If you want to deploy Seafile PRO, you are welcome to use our guide. Be aware that this guide does only cover the setup for CE version.
For support and official documentation please consult the [original manual](https://manual.seafile.com/deploy_pro/).

## Wrong or missing information
You can contact us via the forum, but it takes usually longer to get the changes into the manual this way.
It is faster if you submit the suggested changes via Github.

## Contribution

You are welcome to contribute to this manual. Please submit your code on [Github](https://github.com/DerDanilo/seafile-community-manual.git).

### Languages / Translation
At a later point we might provide this manual in other languages if we find at least two persons to maintain each translation. Currently this is not the case.
The English version has priority as the focus is to have a working manual and not many languages.

Please contact us via [Seafile Forum](https://forum.seafile.com/) if you would like to contribute.
