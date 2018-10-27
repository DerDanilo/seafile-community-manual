# Nginx config

[TOC]

---

This is a full nginx config file with all services (includign SeaDAV) enabled on default ports.

`/etc/nginx/conf.d/seafile.conf`
```
server {
    listen        80;
    server_name   _;
    server_tokens off;

    location /seafile {
      rewrite ^ https://$http_host$request_uri? permanent;    # force redirect http to https
    }
}

server {
    listen        443 ssl http2;
    server_name   _;
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
        root /opt/seafile/seafile-server-latest/seahub;
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

        # This option is only available for Nginx >= 1.8.0.
        client_max_body_size 0;
        proxy_request_buffering off;

        access_log      /var/log/nginx/seafdav.access.log;
        error_log       /var/log/nginx/seafdav.error.log;
    }
}
```

The most interesting parts of this configuration are:
```
listen 80;               	The port Nginx listens to
server_name _; 	            The 'name' of the virtual server
server_tokens off;       	Nginx does not reveal its version number to make life more difficult for attackers
location /seafile        	proxy for seahub (!)
location /seafhttp       	proxy for seafile (!)
location /seafmedia      	static content of Seafile Server
location /seafdav        	proxy for seadav
access_log and error_log 	Nginx log files
```