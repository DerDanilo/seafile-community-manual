[TOC]

---

# No fixed IP or Domain?

If you have no fixed IP and/or no Domain you can simply skip this step of the setup.  
Please check the [config description](../config/seafile/sending-email) for sending e-mails via another
mailserver or e.g. gmail.

---

# What is Postfix?
We install Postfix as outgoing smtp mail server.
If you want further information please check the [Wikipedia page](https://en.wikipedia.org/wiki/MariaDB).

# Tasks
* Install Postfix
* Enable Postfix autostart
* Configure Postfix
* Set DNS SPF record (allow server to send e-mail for your domain)
* Configure Seafile to use Postfix



---

# Install Postifx

**Debian/Ubuntu**

```sh
debconf-set-selections << EOF
postfix postfix/root_address    string
postfix postfix/rfc1035_violation       boolean false
postfix postfix/mydomain_warning        boolean
postfix postfix/mynetworks      string  127.0.0.0/8 [::ffff:127.0.0.0]/104 [::1]/128
postfix postfix/mailname        string  $(hostname -f)
postfix postfix/tlsmgr_upgrade_warning  boolean
postfix postfix/recipient_delim string  +
postfix postfix/main_mailer_type        select  Internet Site
postfix postfix/destinations    string  $(hostname -f), localhost.$(hostname -d)
postfix postfix/retry_upgrade_warning   boolean
# Install postfix despite an unsupported kernel?
postfix postfix/kernel_version_warning  boolean
postfix postfix/not_configured  error
postfix postfix/sqlite_warning  boolean
postfix postfix/mailbox_limit   string  0
postfix postfix/relayhost       string
postfix postfix/procmail        boolean false
postfix postfix/bad_recipient_delimiter error
postfix postfix/protocols       select  all
postfix postfix/chattr  boolean false
EOF

apt-get install postfix -y
dpkg-reconfigure postfix
```

**CentOS**

```sh
# Config for Postfix not yet written

yum install postfix
systemctl enable postfix
```

# Enable Postfix autostart

**Debian/Ubuntu/CentOS**
```sh
systemctl enable postfix
```

# Set DNS SPF record

Your server can directly send e-mails but it's public IP needs to be added to the used domains
SPF record. Otherwise e-mails will be marked as spam and nerver reach the recipient.

As a courtesy, we've come up with a generic SPF record that should work for you.  
Be sure to replace xxx.xxx.xxx.xxx with your server's IP address.

Set the DNS record type to 'TXT' and enter your SPF record.

```text
v=spf1 a mx ip4:xxx.xxx.xxx.xxx -all
```

## Configure Seafile to send E-Mail via Postfix

Please check the [config description](../config/seafile/sending-email) for sending e-mails.