# Server Configuration and Customization

[TOC]

---

## Config Files

There are three config files in the community edition:

- [ccnet.conf](ccnet-conf.md): contains the LDAP settings
- [seafile.conf](seafile-conf.md): contains settings for seafile daemon and fileserver.
- [seahub_settings.py](seahub_settings_py.md): contains settings for Seahub


Since version 5.0.0, you can also modify most of the config items via web interface. The config items are saved in database table (seahub-db/constance_config). 
**They have a higher priority over the items in config files.**

![Seafile Config via Web](../images/seafile-server-config.png)
