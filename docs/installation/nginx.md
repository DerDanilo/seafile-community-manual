[TOC]

---

# What is the Nginx web server?
Nginx is a web server, which we will use as a reverse proxy. In this mode incoming requests can distributed to several services, 
in our case to the seafile and seahub services. Furthermore Nginx can secure the connection to the browsers or clients providing 
encryption through TLS protocol a.s.o.

Please check the [Wikipedia page](https://en.wikipedia.org/wiki/nginx) for further information.

# Tasks
* Install Nginx
* Enable Nginx autostart
* Configure Nginx

---

## Install Nginx
```sh
root@cloudserver:~# apt-get install nginx
```

Verify it is running. Open a web browser: `http://192.168.1.2`. It should show the default page "Welcome to nginx!".

### Principles of nginx configuration
Read the [Beginner’s Guide](https://nginx.org/en/docs/beginners_guide.html "Beginner’s Guide"), which gives an idia of the block structure used in the configuration. 
You can have several server blocks, each defining a different port or server name. The server blocks itself may contain any number of location blocks, which define 
the action needed to handle the request at that specific location. An action can be a forwarding to another server or to a service. This is reverse proxying, which 
we will use for seafile and seahub daemons. Another action is simply delivering a static object. We will use this for delivering icons, avatars, JavaScript and the like.
### Configuring the server for using Nginx
One of the downsides of our configuration is not having configured our DNS properly. We gave our server a name, but it is not reachable via network using that name. 
So we are not able to access it like `http://cloudserver`.

Nginx comes with a default configuration, defining a server listening on port 80 (default for http) named '\_', which is a catch-all that is taken if no other 
name/port combination matches. We don't want to switch that off, so we need an acceptable server name because we do not want to use a different port. 
We will use our IP address for now as the name of our virtual Nginx server.

### Create a basic Nginx configuration for Seafile Server
Create a file `/etc/nginx/sites-available/seafile` with the following contents (adjust the IP adress in 'server_name'):
```
server {
    listen       80;
    server_name  192.168.1.2;
    server_tokens off;

    location /seafile {
        proxy_pass         http://127.0.0.1:8000;
        proxy_set_header   Host $host;
        proxy_set_header   X-Real-IP $remote_addr;
        proxy_set_header   X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header   X-Forwarded-Host $server_name;
        proxy_set_header   X-Forwarded-Proto https;
        proxy_http_version 1.1;
        proxy_connect_timeout  36000s;
        proxy_read_timeout  36000s;
        proxy_send_timeout  36000s;
        send_timeout  36000s;

        # used for view/edit office file via Office Online Server
        client_max_body_size 0;

        access_log      /var/log/nginx/seahub.access.log;
        error_log       /var/log/nginx/seahub.error.log;
    }

    location /seafhttp {
        rewrite ^/seafhttp(.*)$ $1 break;
        proxy_pass http://127.0.0.1:8082;
        client_max_body_size 0;
        proxy_connect_timeout  36000s;
        proxy_read_timeout  36000s;
        proxy_send_timeout  36000s;
        send_timeout  36000s;
        proxy_request_buffering off;
        proxy_http_version 1.1;
    }

    location /seafmedia {
        rewrite ^/seafmedia(.*)$ /media$1 break;
        root /opt/Seafile/Server/seafile-server-latest/seahub;
    }

    location /seafdav {
        proxy_pass         http://127.0.0.1:8080;
        proxy_set_header   Host $host;
        proxy_set_header   X-Real-IP $remote_addr;
        proxy_set_header   X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header   X-Forwarded-Host $server_name;
        proxy_set_header   X-Forwarded-Proto https;
        proxy_http_version 1.1;
        proxy_connect_timeout  36000s;
        proxy_read_timeout  36000s;
        proxy_send_timeout  36000s;
        send_timeout  36000s;

        # This option is only available for Nginx >= 1.8.0. See more details below.
        client_max_body_size 0;
        proxy_request_buffering off;

        access_log      /var/log/nginx/seafdav.access.log;
        error_log       /var/log/nginx/seafdav.error.log;
    }
}
```
The most interesting parts of this configuration are:
```
listen 80;               The port Nginx listens to
server_name 192.168.1.2; The 'name' of the virtual server
server_tokens off;       Nginx does not reveal its version number to make life more difficult for attackers
location /seafile        proxy for seahub (!)
location /seafhttp       proxy for seafile (!)
location /seafmedia      static content of Seafile Server
location /seafdav        a goodie for you, we don't use it for now
access_log and error_log Nginx log files
```

Stop Nginx:
```sh
root@cloudserver:~# systemctl stop nginx
```

Enable the seafile configuration in Nginx:
```sh
root@cloudserver:~# ln -s /etc/nginx/sites-available/seafile /etc/nginx/sites-enabled/seafile
```

### Adjusting Seafile Server for use with Nginx
Stop Seafile Server:
```sh
root@cloudserver:~# systemctl stop seahub
root@cloudserver:~# systemctl stop seafile
```

Adjust 'SERVICE_URL' in `/opt/Seafile/Server/conf/ccnet.conf` (mind the IP address):
```
SERVICE_URL = http://192.168.1.2/seafile
```

Add some lines in `/opt/Seafile/Server/conf/seahub_settings.py` between `SECRET_KEY` and `DATABASES` (mind the IP address):
```
SECRET_KEY = ...

FILE_SERVER_ROOT = 'http://192.168.1.2/seafhttp'

SERVE_STATIC = False
MEDIA_URL = '/seafmedia/'
SITE_ROOT = '/seafile/'
LOGIN_URL = '/seafile/accounts/login/'
COMPRESS_URL = MEDIA_URL
STATIC_URL = MEDIA_URL + 'assets/'

DATABASES = ...
```

Adjust `ExecStart` in `/etc/systemd/system/seahub.service` to tell seahub it is used in conjunction with Nginx:
```
ExecStart=/opt/seafile/seafile-server-latest/seahub.sh start-fastcgi
```

At least a little security enhancement. We will bind seafile service to localhost only which makes it reachable through Nginx only. Add a line 
in `/opt/seafile/conf/seafile.conf` between `[fileserver]` and `port = 8082` like:
```
[fileserver]
host = 127.0.0.1
port = 8082
...
```

Reload systemd configuration and start the whole thing:
```sh
root@cloudserver:~# systemctl daemon-reload
root@cloudserver:~# systemctl start seafile
root@cloudserver:~# systemctl start seahub
root@cloudserver:~# systemctl start nginx
```

If there are no errors reported, you can test it with your web browser: `http://192.168.1.2/seafile`.

If everything looks fine, it is time for a backup of the installation!


### Troubleshooting
If you get an error when starting a service it is a good hint in which parts of the configuration the problem has its cause. 
We modified ccnet.conf which affects seafile and seahub. seafile.conf affects seafile. seahub.service and seahub_settings.py affect seahub. 
The Nginx configuration affects only Nginx!

Check the ports. They need to be open for localhost.
- 22: openssh (only open if installed)
- 80: nginx
- 3306: mysql (or mariadb)
- 8000: seahub
- 8082: seafile

With the exeption of port `22` the only port open from LAN should be port `80`.
```sh
root@cloudserver:~# nmap localhost

Starting Nmap 7.40 ( https://nmap.org ) at 2017-07-18 11:23 CEST
Nmap scan report for localhost (127.0.0.1)
Host is up (0.0000090s latency).
Other addresses for localhost (not scanned): ::1
Not shown: 995 closed ports
PORT     STATE SERVICE
22/tcp   open  ssh
80/tcp   open  http
3306/tcp open  mysql
8000/tcp open  http-alt
8082/tcp open  blackice-alerts

Nmap done: 1 IP address (1 host up) scanned in 1.64 seconds
root@cloudserver:~# nmap 192.168.1.2

Starting Nmap 7.40 ( https://nmap.org ) at 2017-07-18 11:27 CEST
Nmap scan report for 192.168.1.2
Host is up (0.000010s latency).
Not shown: 998 closed ports
PORT   STATE SERVICE
22/tcp open  ssh
80/tcp open  http

Nmap done: 1 IP address (1 host up) scanned in 1.64 seconds
```

If all ports are open as required, you may do some more tests:

### Testing Nginx configuration
You can test the Nginx configuration for syntax errors:
```sh
root@cloudserver:~# nginx -t -c /etc/nginx/nginx.conf
nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
nginx: configuration file /etc/nginx/nginx.conf test is successful
```

Nginx default server:
```sh
root@cloudserver:~# curl -I http://192.168.1.2
HTTP/1.1 200 OK
Server: nginx
Date: Tue, 18 Jul 2017 10:19:27 GMT
Content-Type: text/html
Content-Length: 612
Last-Modified: Tue, 31 Jan 2017 15:01:11 GMT
Connection: keep-alive
ETag: "5890a6b7-264"
Accept-Ranges: bytes
```

Nginx seafile file delivery:
```sh
root@cloudserver:~# curl -I http://192.168.1.2/seafmedia/img/seafile-logo.png
HTTP/1.1 200 OK
Server: nginx
Date: Tue, 18 Jul 2017 09:48:47 GMT
Content-Type: image/png
Content-Length: 12612
Last-Modified: Tue, 13 Jun 2017 05:49:44 GMT
Connection: keep-alive
ETag: "593f7cf8-3144"
Accept-Ranges: bytes
```

If you get 'HTTP/1.1 404 Not Found', did you adjust the IP address in `/etc/nginx/sites-available/seafile`? Have you set the link in `/etc/nginx/sites-enabled/` to enable it? 
'Server: nginx/1.10.3' is an indication, that the 'default server' is taken, not the 'seafile server'. And yes, we should turn that off, but at this point it's helpful. 
'Server: nginx': Paths in `location /seafmedia` in `/etc/nginx/sites-available/seafile` and the Seafile Server installation do not match. Is the file present:
```sh
root@cloudserver:~# ls -l /opt/seafile/seafile-server-latest/seahub/media/img/seafile-logo.png
-rw-rw-r-- 1 seafserver seafserver 12612 Jun 13 07:49 /opt/seafile/seafile-server-latest/seahub/media/img/seafile-logo.png
```

'HTTP/1.1 403 Forbidden': Check the filesystem access rights 
for `/opt/seafile/seafile-server-latest/seahub/media/img/seafile-logo.png`. Each directory in the whole path must have set read and execute bit for others (drwxr-x**r**-**x**), 
the file itself must be world readable (-rwxr-x**r**--).

Avatar Icon damaged: check filesystem rights for `/srv/seafile/seahub-data/avatars/default.png`. The whole path must be world readable.

Nginx and seahub daemon:
```sh
root@cloudserver:~# curl -I http://192.168.1.2/seafile/
HTTP/1.1 302 FOUND
Server: nginx
Date: Tue, 18 Jul 2017 11:00:27 GMT
Content-Type: text/html; charset=utf-8
Connection: keep-alive
Vary: Accept-Language, Cookie
Location: http://192.168.1.2/seafile/accounts/login/?next=/seafile/
Content-Language: en
```

If you dont get the 'HTTP/1.1 302 FOUND', there is a problem between seahub daemon and Nginx. Activated `start-fastcgi` in `seahub.service`?

Still problems? Look into the log-files in `/var/log/nginx/`, `/opt/seafile/logs/` and `/var/log/messages`.

If you got it working, back up the installation.

---

## Access from Internet

Depending on your internet connection your server might be accessible from internet via IPv4, IPv6, both or not at all.
### root server or vServer
You are done, skip to next chapter.
### IPv6 Behind NAT router in local LAN
Set up port forwarding in your router:
- port 80/TCP to IP 192.168.1.2 port 80
- port 443/TCP to IP 192.168.1.2 port 443

Get your public IPv4 address:
```sh
root@cloudserver:~# wget -qO- http://ipecho.net/plain; echo
62.224.170.64
```

Do a test from outside your LAN (smartphone with a mobile connection will be sufficiant) using a web browser: `http://62.224.170.64/seafile`. If you can see 
your Seafile Server, do not log in, it will break things! If it does not work, you are probably behind a Carrier-grade NAT, Dual Stack Lite or whatever prevents 
a connection from internet to your server. Sorry, but no IPv4 access to your Seafile Server.

### IPv6 behind router in local LAN
Enable IPv6 access from internet to your server for port 80 and port 443 in your router.

Do a test from outside your LAN using a web browser:  `https://[2003:a:452:e300:5054:ff:feae:a412]/seafile`. A smartphone using a mobile connection will do, 
if it provides IPv6 internet access. Be sure to have IPv6 internet access. You can test it using a service like `http://test-ipv6.com/`.

If you can reach your Seafile Server, don't log in! If you cannot see your Seafile Server it is probably behind a firewall of your internet service provider. 
Sorry, but no IPv6 access to your Seafile Server.

---

## (sub)Domain Name
A Domain Name is essential to use a trusted X.509 certificate. If you want the web browsers to accept your certificate, you need a domain name.
### Static or dynamic IP / prefix?
If you don't know, if you have a static IP, you probably have a dynamic IP. That means your public IP changes from time to time. It may change after 
each login of your router to your internet service provider, daily, after some months or whenever. For IPv4 you normally get one IP for your router, 
which can forward requests to your LAN. For IPv6 you get a whole network, from which IPv6 addresses are distributed to the devices in your network. 
The common part of these addresses is called prefix.

### Static IP / prefix
You can either register a domain like 'seafile.com' (that one is already assigned to sombody else, choose another one) and point it to your IPv4 and / or 
IPv6 address or create a subdomain in it like 'home.seafile.com' and do the same with the subdomain. Or you can ignore that it's static and do the same as 
it was a dynamic IP.

### Dynamic IP / prefix
If you have a dynamic IP, you need a [DDNS](https://en.wikipedia.org/wiki/Dynamic_DNS "DDNS") provider.

You can register a domain and do what your provider recommends to update the IP address. If you choose one for free, you will get a name like 'subdomainspecialforyou.bigddnsprovider.tld'. 
There is nothing wrong with it, but if you want to register an X.509 certificate for it, make sure it will be possible with the certificate authority of your choice. Let's Encrypt for 
example has [Rate Limits](https://letsencrypt.org/docs/rate-limits/ "Rate Limits") which prevent users of 'bigddnsprovider.tld' to register too many certificates within a time interval.
A hosting provider may request a higher rate limit for Let's Encrypt, but if your favorite provider didn't do that, you will run into problems getting or renewing a certificate. 
Check that before you choose a DDNS provider and want to use Let's Encrypt. This is no problem if you register your own domain.

### Dynamic IPv4
Because all devices in LAN share the public IPv4 address, each of the devices may do the update of the DDNS name. Let the router it, if is able to. 
That's normally the most stable solution. Your server should be the next choice.

### Dynamic IPv6
Because each device gets its own IPv6 address, it is up to your server to do the update.

### Implement DDNS update, configure DNS
If it's static DNS, configure it to point to your IP address(es). DDNS users should test the update mechanism to make sure, it allways points to your 
current IP address(es). Switch your router off and on and whatever you can think of to ensure, it's working.

### Configure Seafile Server for your domain
If you don't have a public IPv4 address, don't configure an IPv4 address for your domain! If you don't have a public IPv6 address, don't configure an 
IPv6 address for your domain! You may configure your public IPv4 address and your global IPv6 address of your server, if you can reach your server with both protocols.

Configure `/etc/nginx/sites-available/seafile` to be web server for your domain. IPv6 users may also enable port 80 for IPv6. Adjust the server name to your needs:
```
server {
    listen       80;
    listen       [::]:80;
    server_name  home.seafile.com;
    server_tokens off;
...

server {
    listen       443 ssl http2;
    listen       [::]:443 ssl http2;
    server_name  home.seafile.com;
    server_tokens off;
...
```

Configure `/opt/Seafile/Server/conf/ccnet.conf` for your domain:
```
...
SERVICE_URL = https://home.seafile.com/seafile
...
```

Configure `/opt/Seafile/Server/conf/seahub_settings.py` for your domain:
```
...
FILE_SERVER_ROOT = 'https://home.seafile.com/seafhttp'
...
```

Restart services:
```sh
root@cloudserver:~# systemctl stop seahub
root@cloudserver:~# systemctl restart seafile
root@cloudserver:~# systemctl start seahub
root@cloudserver:~# systemctl restart nginx
```

Test it with your web browser: `http://home.seafile.com/seafile`. If it does not work, try from outside your LAN. If that works, but from inside your LAN it does not, 
it's probably a problem with [hairpinning](https://en.wikipedia.org/wiki/Hairpinning "hairpinning") (also known as NAT loopback). In most cases, the router simply does 
not support it. You could try [split DNS](https://en.wikipedia.org/wiki/Split-horizon_DNS "split DNS"), but that's evil and I didn't tell you. Better try a different router.

---

### Troubleshooting
If you can log into your Seafile Server but uploading or viewing files failes, check your `SERVICE_URL` and `FILE_SERVER_ROOT` in seafile settings again.

Do not forget your backups!

---

## Seafile Server with Nginx HTTPS

**INFO**  
If you want a validated certificate from Let's Encrypt, you may set LE up later.  
Please do **not skip** the following steps as they are important for the setup to be complete.


First of all, switch off gzip compression if using https. It's a security risk:
```sh
root@cloudserver:~# sed -i 's/\tgzip/\t# gzip/' /etc/nginx/nginx.conf
```

For TLS (HTTPS) we need a [digital certificate](https://en.wikipedia.org/wiki/Public_key_certificate "digital certificate"), which proves the ownership of 
a [public key](https://en.wikipedia.org/wiki/Public_key "public key"). That means, we need to create a pair of keys (public and private part), and then 
sign them by ourselves. We can use this self-signed certificate for TLS, but it will not be accepted by the browsers. Must browsers allow to enter an exeption 
for our server so we can live with it for the moment.

Modern cryptography offers [forward secrecy](https://en.wikipedia.org/wiki/Forward_secrecy "forward secrecy"), a protection against future compromises, 
which requires [Diffie–Hellman key exchange](https://en.wikipedia.org/wiki/Diffie%E2%80%93Hellman_key_exchange "Diffie–Hellman key exchange"). We need to 
generate the parameters for it. The Certificate Signing Request will ask you some things required for the certificate. Just fill in what you think it's right. 
It will be visible in the certificate.

```sh
root@cloudserver:~# cd /etc/ssl/private
root@cloudserver:/etc/ssl/private# openssl genrsa -out privkey.pem 2048
root@cloudserver:/etc/ssl/private# openssl req -new -x509 -key privkey.pem -out cacert.pem -days 3650
root@cloudserver:/etc/ssl/private# openssl dhparam -outform PEM -out dhparam2048.pem 2048
root@cloudserver:/etc/ssl/private# cd
```

Verify the result:
```sh
root@cloudserver:~# ls -l /etc/ssl/private
total 12
-rw-r--r-- 1 root root 1379 Jul 18 15:46 cacert.pem
-rw-r--r-- 1 root root  424 Jul 18 15:51 dhparam2048.pem
-rw------- 1 root root 1679 Jul 18 15:44 privkey.pem
```

Modify `/etc/nginx/sites-available/seafile` to be:
```
server {
    listen       80;
    server_name  192.168.1.2;
    server_tokens off;

    location /seafile {
      rewrite ^ https://$http_host$request_uri? permanent;    # force redirect http to https
    }
}

server {
    listen       443 ssl http2;
    server_name  _;
    server_tokens off;

    ssl_protocols TLSv1.2;
    ssl_certificate /etc/ssl/private/cacert.pem;
    ssl_certificate_key /etc/ssl/private/privkey.pem;
    ssl_dhparam /etc/ssl/private/dhparam2048.pem;
    ssl_ecdh_curve secp384r1;
    ssl_ciphers EECDH+AESGCM:EDH+AESGCM:EECDH:EDH:!MD5:!RC4:!LOW:!MEDIUM:!CAMELLIA:!ECDSA:!DES:!DSS:!3DES:!NULL;
    ssl_prefer_server_ciphers on;
    ssl_session_timeout 10m;

    location /seafile {
...
        fastcgi_param   HTTPS               on;
        fastcgi_param   HTTP_SCHEME         https;
...
    location /seafdav {
...
        fastcgi_param   HTTPS               on;
...
```

The most interesting parts are:
```
rewrite ^ https://$http_host$request_uri? permanent; # Redirect http to https
listen  443 ssl http2;    listen to port 443, enable TLS and accept HTTP/2
ssl_protocols TLSv1.2;    accept TLS 1.2 only
```

Restart Nginx
```sh
root@cloudserver:~# systemctl restart nginx
```

If there are no errors reported, you can test it with your web browser: `http://192.168.1.2/seafile`. If everything works, your browser should redirect to https and tell you something like 'Your connection is not secure'. You should be able to add an exception to access your Seafile Server.

If everything looks fine you could back up the installation.

### Troubleshooting
We mainly modified the Nginx configuration, so there is a big chance for the problem to be in there.

Check the ports are open:
```sh
root@cloudserver:~# nmap 192.168.1.2

Starting Nmap 7.40 ( https://nmap.org ) at 2017-07-18 16:28 CEST
Nmap scan report for 192.168.1.2
Host is up (0.000010s latency).
Not shown: 997 closed ports
PORT    STATE SERVICE
22/tcp  open  ssh
80/tcp  open  http
443/tcp open  https
```

Check the http part, it should be a redirection (Moved Permanently) to https:
```sh
root@cloudserver:~# curl -I http://192.168.1.2/seafile/
HTTP/1.1 301 Moved Permanently
Server: nginx
Date: Tue, 18 Jul 2017 14:48:43 GMT
Content-Type: text/html
Content-Length: 178
Connection: keep-alive
Location: https://192.168.1.2/seafile/
```

Check the https part (option '-k' for curl disables verification of the certificate):
```sh
root@cloudserver:~# curl -I -k https://192.168.1.2/seafile/
HTTP/2 302 
server: nginx
date: Tue, 18 Jul 2017 14:52:16 GMT
content-type: text/html; charset=utf-8
location: https://192.168.1.2/seafile/accounts/login/?next=/seafile/
vary: Accept-Language, Cookie
content-language: en
```

If you got it working, back up the installation.