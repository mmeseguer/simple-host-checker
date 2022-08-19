FROM mcr.microsoft.com/powershell:lts-alpine-3.14
WORKDIR /app

# Install supervisord
RUN apk update && apk add --no-cache supervisor
COPY supervisord.conf /etc/supervisord.conf

# Copy script
COPY ../app/simple-host-checker.ps1 .
RUN chmod a+x simple-host-checker.ps1

# Start the script
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf"]