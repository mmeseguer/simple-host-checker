# Simple host checker

Checks availability of a host using ICMP and sends notifications on status changes.

The following are the available notification types at this point in time:
- Email (SMTP with and without SSL)
- Microsoft Teams (using a webhook)

## Basic usage

This app is **meant to run from Docker** (you can always just download the script from ./app and execute it from plain PowerShell). All the configuration is done from environmental variables, so the cleanest way to run it is creating a .env file with the configuration:

```
SHC_MONITOR_IP=8.8.8.8
SHC_MONITOR_DISPLAYNAME=Google DNS
SHC_SECONDS_INTERVAL=60
SHC_EMAIL_FROM=alerts@mydomain.com
SHC_EMAIL_TO=me@mydomain.com
SHC_SMTP_SERVER=mysmtpserver.com
SHC_SMTP_PORT=587
SHC_SMTP_SSL=true
SHC_SMTP_USER=mysmtpuser
SHC_SMTP_PASS=mysmtppass
SHC_TEAMS_WEBHOOK=https://myteamswebhookurl.com/
```

*Credentials should be handled in a secure way like using a secrets manager, we are using an .env file for demonstration*

Once we have our configuration done we can run our container:
```
docker run -d --env-file .env mmeseguer/simple-host-checker
```

## Configuration reference

| Variable                      | Description                                                                                       | Mandatory         |
|---                            |---                                                                                                |---                |
| SHC_MONITOR_IP                | IP or hostname of the host to be monitored                                                        | Yes               |
| SHC_MONITOR_DISPLAYNAME       | Display name of the monitored host in the notifications. If empty defaults to SHC_MONITOR_IP      | No                |
| SHC_SECONDS_INTERVAL          | Interval in seconds between checks                                                                | Yes               |
| SHC_EMAIL_FROM                | Source email address of the notifications                                                         | No                |
| SHC_EMAIL_TO                  | Destination email address of the notifications                                                    | No                |
| SHC_SMTP_SERVER               | SMTP server to send email notifications                                                           | No                |
| SHC_SMTP_PORT                 | Port of the SMTP server                                                                           | No                |
| SHC_SMTP_SSL                  | Use or not SSL in the SMTP connection. Valid values: true or false                                | No                |
| SHC_SMTP_USER                 | User used in the SMTP connection                                                                  | No                |
| SHC_SMTP_PASS                 | Password used in the SMTP connection                                                              | No                |
| SHC_TEAMS_WEBHOOK             | URL of a Microsoft Teams webhook                                                                  | No                |

*When using email notifications, all of the SHC_EMAIL and SHC_SMTP env variables are required in order to be able to send the notifications*