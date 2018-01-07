# Add filters

What we need to do first here is to create the filters that we need, some of them are already created as default in Fail2Ban but some we need to create by our self.

Let us go to the filter.d folder before we begin.
```sh
cd /etc/fail2ban/filter.d/
```

First we are going to add a line in a filter.
```sh
sudo nano /etc/fail2ban/filter.d/nginx-http-auth.conf
```

And then we need to add this line, add it under the line that almost look the same.
```sh
^ \[error\] \d+#\d+: \*\d+ no user/password was provided for basic authentication, client: <HOST>, server: \S+, request: "\S+ \S+ HTTP/\d+\.\d+", host: "\S+"\s*$
```

Then we need to copy a filter from Apache2 to NGINX.
```sh
sudo cp apache-badbots.conf nginx-badbots.conf
```

Then we are going to create our first filter.
```sh
sudo nano /etc/fail2ban/filter.d/nginx-forbidden.conf
```

Then add this to the file
```sh
[Definition]

failregex = ^ \[error\] \d+#\d+: .* forbidden .*, client: <HOST>, .*$

ignoreregex =
```

Create
```sh
sudo nano /etc/fail2ban/filter.d/nginx-nohome.conf
```

Add
```sh
[Definition]

failregex = ^<HOST> -.*GET .*/~.*

ignoreregex =
```

Create
```sh
sudo nano /etc/fail2ban/filter.d/nginx-noproxy.conf
```

Add

```sh
[Definition]

failregex = ^<HOST> -.*GET http.*

ignoreregex =
```

Create
```sh
sudo nano /etc/fail2ban/filter.d/nginx-noscript.conf
```

Add

```sh
[Definition]

failregex = ^<HOST> -.*GET.*(\.php|\.asp|\.exe|\.pl|\.cgi|\.scgi)

ignoreregex =
```

Create
```sh
nano /etc/fail2ban/filter.d/seafile-auth.conf
```

Add

```sh
# Fail2Ban filter for seafile
#

[INCLUDES]

# Read common prefixes. If any customizations available -- read them from
# common.local
before = common.conf

[Definition]

_daemon = seaf-server

failregex = Login attempt limit reached.*, ip: <HOST>

ignoreregex =

# DEV Notes:
#
# pattern : 2015-10-20 15:20:32,402 [WARNING] seahub.auth.views:155 login Login attempt limit reached, username: <user>, ip: 1.2.3.4, attemps: 3
# 2015-10-20 17:04:32,235 [WARNING] seahub.auth.views:163 login Login attempt limit reached, ip: 1.2.3.4, attempts: 3
```


# Configuration

I’ll just past the configuration here that works with the filters that we have done and the best settings for the filter, if you want to se more information regarding the configuration file you can read someone of this two guides
How to secure your Ubuntu server: https://nohatech.se/how-to-secure-your-ubuntu-16-04-lts-server/
Setup Fail2Ban for NGINX: https://nohatech.se/setup-fail2ban-for-nginx/

If you want to activate so you can send mails from Fail2Ban you need to follow this guide first:
https://nohatech.se/install-ssmtp-send-mails-from-your-server/

And here is a notice regarding the Seafile filter, it’s a little different then the others, maxretry set to 1 is actually 3 failed login attempts that’s why I have it set to 2 in this guide.

Now we are going to create the configuration file.
```sh
sudo nano /etc/fail2ban/jail.local
```

Then add this to the file.
```sh
[DEFAULT]

# Also add your gateways IP numbere here.
ignoreip = 127.0.0.1/8
bantime = 259200
findtime = 3600
maxretry = 0
# Change this to your mail.
destemail = YOUREMAIL
sendername = Fail2Ban
action = %(action_mwl)s

[sshd]

enabled = true
port = 2324,22
filter = sshd
logpath = /var/log/auth.log
maxretry = 3

[sshd-ddos]

enabled = true
port = 2324,22
filter = sshd-ddos
logpath = /var/log/auth.log

[seafile]

enabled = true
port = https,http
filter = seafile-auth
logpath = /opt/nohatech/logs/*seahub.log
bantime = 3600
maxretry = 2

[nginx-http-auth]

enabled = true
port = https,http
filter = nginx-http-auth
logpath = /var/log/nginx/*error.log

[nginx-badbots]

enabled = true
port = https,http
filter = nginx-badbots
logpath = /var/log/nginx/*access.log

[nginx-nohome]

enabled = true
port = https,http
filter = nginx-nohome
logpath = /var/log/nginx/*access.log

[nginx-noproxy]

enabled = true
port = https,http
filter = nginx-noproxy
logpath = /var/log/nginx/*access.log

[nginx-noscript]

enabled = true
port = https,http
filter = nginx-noscript
logpath = /var/log/nginx/*access.log

[nginx-req-limit]

enabled = true
port = https,http
filter = nginx-limit-req
logpath = /var/log/nginx/*error.log

[nginx-forbidden]

enabled = true
port = https,http
filter = nginx-forbidden
logpath = /var/log/nginx/*error.log

[nginx-botsearch]

enabled = true
port = http,https
filter = nginx-botsearch
logpath = /var/log/nginx/*error.log
```

Now we need to restart Fail2Ban and then everything is up and running.  
```sh
systemctl restart fail2ban
```