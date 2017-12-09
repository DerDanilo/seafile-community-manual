# Seafile Server Community Manual

[TOC]

---

### About

**What is this guide for?**

We write this step-by-step guide to enable all users to setup Seafile on their own but without the struggle 
of having to read the more complex and sometimes confusing [original manual](https://manual.seafile.com/).

It is not our intension to replace the [original manual](https://manual.seafile.com/) !

**How does it work?**

This manual will guide you through each step of the setup. If you are new to Seafile we encourage
you to to the checks whereever we recommend them. This helps to pinpoint possible errors before you have to search for them.

This manual will show how to setup a Seafile Server using MariaDB, Memcached and Nginx as a local reverse proxy.
All operations will be peformed as root unless otherwise specified. So login as root or 'su' to root, if logged in as ordinary user:
```bash
su
```

### CE vs PRO Edition

**Seafile Server Community Edition**

This guide is mantained from community members only. Therefor this manual only covers **Seafile CE**.
If you want to deploy Seafile Server CE you are welcome to use our guide.

**Seafile Server Professional Edition**

If you want to deploy Seafile PRO, you are welcome to use our guide, but for support and official 
documentation please consult the [original manual](https://manual.seafile.com/deploy_pro/).

### Contribution

You are welcome to contribute to this manual. Please submit your code on [Github](https://github.com/DerDanilo/seafile-community-manual.git).

#### Languages / Translation
At a later point we might provide this manual in other languages if we find enough people to maintain the translation. The English version has priority.
Please contact us via [Seafile Forum](https://forum.seafile.com/) if you would like to contribute.
