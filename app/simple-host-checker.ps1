#!/usr/bin/pwsh
function SendEmail {
    param (
        [string]$from,
        [string]$to,
        [string]$server,
        [int]$port,
        [ValidateSet('true','false')]
        [string]$ssl,
        [string]$user,
        [string]$pass,
        [string]$body,
        [string]$subject   
    )

    if ($server) {
        # Build the credential object
        $passSecureString = ConvertTo-SecureString $pass -AsPlainText -Force
        $credential = New-Object System.Management.Automation.PSCredential ($user, $passSecureString)

        # Send email
        try {
            if($ssl -eq 'true') {
                Send-MailMessage -From $from -To $to -Subject $subject -Body $body -SmtpServer $server -Port $port -Credential $credential -UseSsl -ErrorAction Stop
            }
            else {
                Send-MailMessage -From $from -To $to -Subject $subject -Body $body -SmtpServer $server -Port $port -Credential $credential -ErrorAction Stop
            }
        }
        catch {
            throw $_
        }
    }
}

function SendTeams {
    param (
        [string]$webhook,
        [string]$body,
        [string]$subject
    )

    if ($webhook) {
        $jsonBody = @"
        {
            "themeColor": "555555",
            "title": "$subject",
            "text": "$body"
        }
"@
        try {
            Invoke-RestMethod -Method post -ContentType 'Application/Json' -Body $jsonBody -Uri $webhook -ErrorAction Stop
        }
        catch {
            throw $_
        }
    }    
}

# Get the env variables
$monitorIp = $env:SHC_MONITOR_IP
$monitorDisplayName = $env:SHC_MONITOR_DISPLAYNAME
$interval = $env:SHC_SECONDS_INTERVAL

$emailFrom = $env:SHC_EMAIL_FROM
$emailTo = $env:SHC_EMAIL_TO
$emailSmtpServer = $env:SHC_SMTP_SERVER
$emailPort = $env:SHC_SMTP_PORT
$emailUseSsl = $env:SHC_SMTP_SSL
$emailUser = $env:SHC_SMTP_USER
$emailPass = $env:SHC_SMTP_PASS

$teamsWebhook = $env:SHC_TEAMS_WEBHOOK

# Set lastResult to 0 as we assume that when the script starts the monitored IP should be UP
$lastResult = 0

if (!$monitorDisplayName) { $monitorDisplayName = $monitorIp}

if ($monitorIp -and $interval){
    while ($true) {
        if (Test-Connection $monitorIp -Count 3 -Quiet) {
            if ($lastResult -eq 1) {
                SendEmail -from $emailFrom -to $emailTo -server $emailSmtpServer -port $emailPort -ssl $emailUseSsl -user $emailUser -pass $emailPass -body "The host $($monitorDisplayName) is up" -subject "$($monitorDisplayName) UP!"
                SendTeams -webhook $teamsWebhook -body "The host $($monitorDisplayName) is up" -subject "$($monitorDisplayName) UP!"
                $lastResult = 0
            }
        }
        else {
            if ($lastResult -eq 0) {
                SendEmail -from $emailFrom -to $emailTo -server $emailSmtpServer -port $emailPort -ssl $emailUseSsl -user $emailUser -pass $emailPass -body "The host $($monitorDisplayName) is down" -subject "$($monitorDisplayName) DOWN!"
                SendTeams -webhook $teamsWebhook -body "The host $($monitorDisplayName) is down" -subject "$($monitorDisplayName) DOWN!"
                $lastResult = 1
            }
        }
        Start-Sleep -Seconds $interval
    }
}
else {
    throw "Error reading environmental variables"
}