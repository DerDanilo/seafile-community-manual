[TOC]

---

## Types of Email Sending

There are currently five types of emails sent in Seafile:

- User reset his/her password
- System admin add new member
- System admin reset user password
- User send file/folder share link and upload link

The first four types of email are sent immediately. The last type is sent by a background task running periodically.

## Options of Email Sending

Please add the following lines to `seahub_settings.py` to enable email sending.

```python
EMAIL_USE_TLS = False
EMAIL_HOST = 'smtp.example.com'        # smpt server
EMAIL_HOST_USER = 'username@example.com'    # username and domain
EMAIL_HOST_PASSWORD = 'password'    # password
EMAIL_PORT = 25
DEFAULT_FROM_EMAIL = EMAIL_HOST_USER
SERVER_EMAIL = EMAIL_HOST_USER
```

If you are using **Gmail as SMTP server**, use following lines:

```python
EMAIL_USE_TLS = True
EMAIL_HOST = 'smtp.gmail.com'
EMAIL_HOST_USER = 'username@gmail.com'
EMAIL_HOST_PASSWORD = 'password'
EMAIL_PORT = 587
DEFAULT_FROM_EMAIL = EMAIL_HOST_USER
SERVER_EMAIL = EMAIL_HOST_USER
```

If you are using **Postfix as local, outgoing SMTP server**, use following lines:

```python
EMAIL_USE_TLS = False
EMAIL_HOST = 'localhost'
EMAIL_HOST_USER = ''
EMAIL_HOST_PASSWORD = ''
EMAIL_PORT = '25'
DEFAULT_FROM_EMAIL = noreply@${HOSTNAME}
SERVER_EMAIL = DEFAULT_FROM_EMAIL
```

**Notes**

* If your email service still does not work, you can checkout the log file `logs/seahub.log` to see what may cause the problem. 
For a complete email notification list, please refer to [email notification list](customize_email_notifications.md).
* If you want to use the email service without authentication leaf `EMAIL_HOST_USER` and `EMAIL_HOST_PASSWORD` **blank** (`''`). 
(But notice that the emails then will be sent without a `From:` address.)
* About using SSL connection (using port 465)

*Port 587 is being used to establish a TLS connection and port 465 is being used to establish an SSL connection. Starting from Django 1.8, 
it supports both. Until version 5.1 Seafile only supported Django 1.5, which only supports TLS connections. If your email server only 
supports SSL connections and you are using a Seafile Server version below 5.1, you can find a workaround here: [django-smtp-ssl](https://github.com/bancek/django-smtp-ssl).*

## Change the `sender` and `reply to` of email

You can change the sender and reply to field of email by add the following settings to `seahub_settings.py`. This only affects email sending for file share link.

```python
# Replace default from email with user's email or not, defaults to `False`
REPLACE_FROM_EMAIL = True

# Set reply-to header to user's email or not, defaults to `False`. For details,
# please refer to http://www.w3.org/Protocols/rfc822/
ADD_REPLY_TO_HEADER = True
```