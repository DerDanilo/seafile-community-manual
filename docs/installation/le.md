[TOC]

---

## Digital Certificate / Let's Encrypt
At this point your server should be reachable by your domain, but our self-signed certificate is not trusted.

We will get an X.509 certificate from [Let's Encrypt](https://letsencrypt.org/ "Let's Encrypt") for free, which will be accepted by almost every actual web browser.

Let's Encrypt uses the ACME protocol to ensure you control the domain. We need a client to get a certificate and to renew it before it expires.
### Install Certbot and configure the system
We will use [Certbot](https://certbot.eff.org/ "Certbot"), the standard ACME client from Let's Encrypt. Install it:
```sh
root@cloudserver:~# apt-get install certbot
```
Certbot provides several methods to obtain certificates, They are called plugins. We will use the plugin 'webroot', which will use an already running webserver to deliver some content to the Let's Encrypt CA (certification authority) to prove we are controlling the domain. The benefit of this plugin is no need for us to stop Nginx when renewing a certificate, a simple reload of Nginx' configuration is sufficient to deliver the new certificate. Debian comes with a nice feature to automate the renewing of certificates. Unfortunately it is buggy because it does not reload the changes in configuration into Nginx. The second point we don't like, it runs as root. That's enough to turn it off and write our own solution:
```sh
root@cloudserver:~# systemctl disable certbot.timer
```

Create a user to run certbot:
```sh
useradd -U -m certbot
```

`/etc/letsencrypt` will contain the Let's Encrypt certificate(s), `/var/log/letsencrypt` the log files for certbot and `var/www/letsencrypt` we will use for Certbot and Nginx to handle the domain validation. The first two are created by the installation, we only need to set the access rights (Nginx runs as www-data:www-data)
```sh
root@cloudserver:~# mkdir -p /var/www/letsencrypt/.well-known/acme-challenge
root@cloudserver:~# chown certbot:certbot /etc/letsencrypt /var/log/letsencrypt
root@cloudserver:~# chmod 750 /var/www/letsencrypt
root@cloudserver:~# chown -R certbot:www-data /var/www/letsencrypt
```

Now create a location block in `/etc/nginx/sites-available/seafile` in the http server (port 80) behind the `location /seafile` block to support the ACME domain validation:
```
...
    location /seafile {
      rewrite ^ https://$http_host$request_uri? permanent;    # force redirect http to https
    }

    location /.well-known/acme-challenge {
        alias /var/www/letsencrypt/.well-known/acme-challenge;
        location ~ /.well-known/acme-challenge/(.*) {
            add_header Content-Type application/jose+json;
        }
    }
}

server {
...
```

Restart Nginx:
```sh
root@cloudserver:~# systemctl restart nginx
```

### OCSP Stapling and Must-Staple
At this point we are ready to obtain our certificate. Before we'll do that, we have to make a decision. Generally, if a private key ist thought to have been compromised, the certificate should be revoked. Let's Encrypt will publish that revocation information through [OCSP](https://en.wikipedia.org/wiki/Online_Certificate_Status_Protocol "OCSP"), the Online Certificate Status Protocol. The basic idea is, a browser should check the revocation status via OCSP. The problem is, the OCSP servers are under heavy load and it is not guaranteed the web browser will get an answer within a reasonable time. So the web browsers ignore the OCSP answer if it takes too long, or don't contact the OSCP server at all.

An extension to the TLS protocol, called [OCSP stapling](https://en.wikipedia.org/wiki/OCSP_stapling "OCSP stapling"), solves this problem. If used, the web server (our Nginx) gets a ticket from the OSCP server and delivers it along with the certificate. So the web browser gets an assurance from the CA that the certificate is not revoked.

The problem with this is, the client does not know if the web server will send an OCSP response. If an attacker tries to abuse a stolen, revoked certificate he can just block the connection to the OCSP server an deliver the certificate without OCSP stapling. The web browser will just accept the connection.

The solution is [OCSP Must-Staple](https://casecurity.org/2014/06/18/ocsp-must-staple/ "OCSP Must-Staple"). We can have a flag set in the certificate, which tells the web browsers we will deliver an OCSP response for sure. If we don't do so, the browser shall hard-fail, which means it should't accept the connection.

The decision you have to make is wheather you want the OCSP Must-Staple indication in your certificate or not.

### Obtain the certificate
Remove the '--must-staple' from command line if you don't want the OCSP Must-Staple flag in your certificate. Replace the 'home.seafile.com' to your domain name. Obtain the certificate as user 'certbot'. Answer the questions.
```sh
root@cloudserver:~# su -l certbot
$ certbot certonly --webroot -w /var/www/letsencrypt -d home.seafile.com
$ exit
```

If it tells you 'Congratulations! Your certificate and chain have been saved at ...' everything worked and you have obtained your certificate. If not, the error message should point you into the right direction.

### Configure Nginx to use the certificate
Edit `/etc/nginx/sites-available/seafile` to point to your Let's Encrypt certificate. We'll leave the old self-signed certificate in the configuration, but comment it out:
```
...
    ssl_protocols TLSv1.2;
#    ssl_certificate /etc/ssl/private/cacert.pem;
#    ssl_certificate_key /etc/ssl/private/privkey.pem;
    ssl_certificate /etc/letsencrypt/live/home.seafile.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/home.seafile.com/privkey.pem;
    ssl_dhparam /etc/ssl/private/dhparam2048.pem;
...
```

If you want OCSP Stapling (or need it because your certificate requires it), edit the configuration again to enable OCSP Stapling. 'resolver' is any DNS resolver, reachable by your server. You may use that one in your router or whatever you like:
```
...
    ssl_certificate /etc/letsencrypt/live/home.seafile.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/home.seafile.com/privkey.pem;
    ssl_stapling on;
    ssl_stapling_verify on;
    resolver 192.168.1.1;
    ssl_dhparam /etc/ssl/private/dhparam2048.pem;
...
```

Restart Nginx:
```sh
root@cloudserver:~# systemctl restart nginx
```

If you requested OCSP Must-Staple in your certificate, and you test it with your web browser `http://home.seafile.com/seafile`, it might fail. This is because OSCP Stapling in Nginx is broken. Nginx sends out the first TLS connection without stapling even it's enabled. If your test didn't give you an error, the OCSP handling of your browser is also broken. If you load your web site a second time, it will work because Nginx then already has obtained the OCSP response and delivers it.

### Workaround for the broken OCSP Stapling in Nginx
The handling of OCSP Stapling of Nginx is at least bad, and in case of Must-Staple, almost unusable.

If you are using OSCP Stapling, create the script `/usr/local/sbin/OCSPResponse` with the following contents. if you like, you may set the SERVER variable to your domain:
```
#!/bin/bash
# OCSPResponse
# Get OSCP respone for certificate
VERSION="20170723"

# you might set your domain name
SERVER=""

# try to get SERVER from configuration if not set
[ "$SERVER" = "" ] && SERVER="$(ls /etc/letsencrypt/live/)"

# Location of the certificate
CHAIN="/etc/letsencrypt/live/$SERVER/chain.pem"
CERT="/etc/letsencrypt/live/$SERVER/cert.pem"

# Location where to store a valid OCSP response
OCSPRESPONSE=/etc/nginx/OCSP/$SERVER/ocsp.response

# some temporary locations
TMPREPLY=/tmp/ocsp.reply
TMPRESPONSE=/etc/nginx/OCSP/ocsp.response

# Create the required paths
mkdir -p ${OCSPRESPONSE%/*}

# Get the OCSP server url out of the certificate
OCSPURL="$(openssl x509 -noout -ocsp_uri -in $CERT)"

# get the OCSP response and save it
openssl ocsp -no_nonce -respout $TMPRESPONSE -issuer $CHAIN -verify_other $CHAIN -cert $CERT -url $OCSPURL >$TMPREPLY 2>/dev/null

# Check the reply for being valid (drop response, if request failed)
if [ "$(grep ': good' $TMPREPLY)" != "" ]; then
  # move response to its final location
  mv $TMPRESPONSE $OCSPRESPONSE
  # reload nginx
  systemctl reload nginx
fi

# Remofe temporary stuff
rm -f $TMPREPLY $TMPRESPONSE
```

Make the script executable, run it and verify the result:
```sh
root@cloudserver:~# chmod 750 /usr/local/sbin/OCSPResponse
root@cloudserver:~# OCSPResponse
root@cloudserver:~# ls -l /etc/nginx/OCSP/home.seafile.com/ocsp.response 
-rw-r--r-- 1 root root 527 Jul 23 13:02 /etc/nginx/OCSP/home.seafile.com/ocsp.response
```

Edit `/etc/nginx/sites-available/seafile` to use the response file:
```
...
   ssl_stapling on;
   ssl_stapling_file /etc/nginx/OCSP/home.seafile.com/ocsp.response;
#   ssl_stapling_verify on;
#   resolver 192.168.1.1;
    ssl_dhparam /etc/ssl/private/dhparam2048.pem;
...
```

Restart Nginx and verify it's working with your web browser.

Create a cronjob to get a new OCSP reponse once a day. Change the time to a different value to prevent a daily DDOS if millions of Seafile Servers update their OCSP response at the same time at seven minutes past five :-)

```sh
root@cloudserver:~# crontab -u root -e
# Edit this file to introduce tasks to be run by cron.
...
# m h  dom mon dow   command
0 3 * * * /usr/local/sbin/BackupSeafileData
7 5 * * * /usr/local/sbin/OCSPResponse
```

### Certificate renewal
Because we disabled Debian's certificate renewal, we have to create our own. Create a file `/usr/local/sbin/CertbotRenew` with the following contents:
```
#!/bin/bash
# CertbotRenew
# Renew Let's Encrypt certificate
VERSION="20170723"

# Renew certificate as user certbot
su certbot -c "certbot renew"
 
# Get a new OCSP response if configured
if [ -x /usr/local/sbin/OCSPResponse ]; then
    /usr/local/sbin/OCSPResponse # will reload nginx
else
  systemctl reload nginx
fi
```

Make it executable and create a cronjob to execute it once a week. Be nice to Let's Encrypt and change day and time:
```sh
root@cloudserver:~# chmod 754 /usr/local/sbin/CertbotRenew 
root@cloudserver:~# crontab -u root -e
# Edit this file to introduce tasks to be run by cron.
...
# m h  dom mon dow   command
0 3 * * * /usr/local/sbin/BackupSeafileData
7 5 * * * /usr/local/sbin/OCSPResponse
9 7 * * 3 /usr/local/sbin/CertbotRenew
```

Backup your Installation.