[TOC]

---

In the wiki below, we assume your seafile installation folder is `/opt/haiwen`.

## SeafDAV Configuration

The configuration file is `/opt/haiwen/conf/seafdav.conf`. If it is not created already, you can just create the file.

```
[WEBDAV]

# Default is false. Change it to true to enable SeafDAV server.
enabled = true
port = 8080

# Change the value of fastcgi to true if fastcgi is to be used
fastcgi = false

# If you deploy seafdav behind nginx, you need to modify "share_name".
share_name = /
```

Every time the configuration is modified, you need to restart seafile server and nginx to make it take effect.

```
systemctl restart seafile
systemctl restart nginx
```

Your WebDAV client would visit the Seafile WebDAV server at `https://cloud.example.com/seafdav`

```
[WEBDAV]
enabled = true
port = 8080
fastcgi = false
share_name = /seafdav
```

In the above config, the value of '''share_name''' is changed to '''/seafdav''', which is the address suffix you assign to seafdav server.

Add the following lines to your nginx seafile config file.

```
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
```

By default Nginx will buffer large request body in temp file. After the body is completely received, Nginx will send the body to the upstream server (seafdav in our case). 
But it seems when file size is very large, the buffering mechanism dosen't work well. It may stop proxying the body in the middle. So if you want to support file upload 
larger for 4GB, we suggest you install Nginx version >= 1.8.0 and add `proxy_request_buffering off` to Nginx configuration.

## Notes on Clients

Please first note that, there are some known performance limitation when you map a Seafile webdav server as a local file system (or network drive).
* Uploading large number of files at once is usually much slower than the syncing client. That's because each file needs to be committed separately.
* The access to the webdav server may be slow sometimes. That's because the local file system driver sends a lot of unnecessary requests to get the files' attributes.

So WebDAV is more suitable for infrequent file access. If you want better performance, please use the sync client instead.

### Windows

The client recommendation for WebDAV depends on your Windows version:
- For Windows XP: Only non-encryped HTTP connection is supported by the Windows Explorer. So for security, the only viable option is to use third-party clients, such as Cyberduck or Bitkinex.
- For Vista and later versions: Windows Explorer supports HTTPS connection. But it requires a valid certificate on the server. It's generally recommended to use Windows Explorer to map a webdav server as network dirve. If you use a self-signed certificate, you have to add the certificate's CA into Windows' system CA store.

### Linux

On Linux you have more choices. You can use file manager such as Nautilus to connect to webdav server. Or you can use davfs2 from the command line.

To use davfs2

```
sudo apt-get install davfs2
sudo mount -t davfs -o uid=<username> https://example.com/seafdav /media/seafdav/
```

The -o option sets the owner of the mounted directory to <username> so that it's writable for non-root users.

It's recommended to disable LOCK operation for davfs2. You have to edit /etc/davfs2/davfs2.conf

```
 use_locks       0
```

### Mac OS X

Finder's support for WebDAV is also not very stable and slow. So it is recommended to use a webdav client software such as Cyberduck.

## Frequently Asked Questions

**Clients can't connect to seafdav server**

By default, seafdav is disabled. Check whether you have `enabled = true` in `seafdav.conf`.
If not, modify it and restart seafile server.


**The client gets "Error: 404 Not Found"**

If you deploy SeafDAV behind Nginx, make sure to change the value of `share_name` as the sample configuration above. Restart your seafile server and try again.

**Windows Explorer reports "file size exceeds the limit allowed and cannot be saved"**

This happens when you map webdav as a network drive, and tries to copy a file larger than about 50MB from the network drive to a local folder.

This is because Windows Explorer has a limit of the file size downloaded from webdav server. To make this size large, change the registry entry on the client machine. There is a registry key named `FileSizeLimitInBytes` under `HKEY_LOCAL_MACHINE -> SYSTEM -> CurrentControlSet -> Services -> WebClient -> Parameters`.
