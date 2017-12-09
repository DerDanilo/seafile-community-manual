[TOC]

---

# What is memcached?
Please check the [Wikipedia page](https://en.wikipedia.org/wiki/Memcached).

# Tasks
* Install Memcached
* Enable Memcached autostart
* Configure Seahub to use memcached

---
# Install memcached
**Debian**

```sh
root@cloudserver:~# apt-get update && apt-get install memcached
```

**Ubuntu**

```sh
root@cloudserver:~# apt-get update && apt-get install memcached
```


**CentOS**

```sh
root@cloudserver:~# yum install memcached
```


# Enable Memcached autostart

**Debian/Ubuntu/Raspbian/CentOS**
```sh
root@cloudserver:~# systemctl enable memcached
```

---

# Configure Seahub

Append the following lines to `/opt/Seafile/Server/conf/seahub_settings.py` to enable memcached.

```
...
CACHES = {
    'default': {
        'BACKEND': 'django.core.cache.backends.memcached.MemcachedCache',
        'LOCATION': '127.0.0.1:11211',
    }
}
...
```

**Restart seahub service**  
`systemctl restart seahub`