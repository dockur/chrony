# syntax=docker/dockerfile:1

FROM alpine:edge

# Install chrony
RUN <<EOF
  set -eu

  apk update
  apk upgrade
  apk add --no-cache \
    chrony-nts \
    bash \
    tzdata

  # Create chrony user and group
  { getent group chrony >/dev/null || addgroup -S chrony; }
  { id -u chrony >/dev/null 2>&1 || adduser -S chrony -G chrony; }

  # Remove default Chrony config
  rm -f /etc/chrony/chrony.conf

  rm -rf /tmp/* /var/cache/apk/*
EOF

# Script to configure/startup Chrony
COPY --chmod=0755 entrypoint.sh /entrypoint.sh

# NTP port
EXPOSE 123/udp

# Default configuration
ENV NTP_DIRECTIVES="ratelimit,rtcsync"

# Mark volumes that need to be writable
VOLUME /etc/chrony /run/chrony /var/lib/chrony

# Let Docker know how to test container health
HEALTHCHECK CMD ["chronyc", "-n", "tracking"]

# Start chronyd in the foreground
ENTRYPOINT [ "/entrypoint.sh" ]
