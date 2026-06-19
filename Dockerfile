# syntax=docker/dockerfile:1

FROM alpine:edge

# default configuration
ENV NTP_DIRECTIVES="ratelimit\nrtcsync"

# install chrony
RUN set -eu && \
    apk update && \
    apk upgrade && \
    apk add --no-cache \
      chrony-nts \
      bash \
      tzdata && \
    { getent group chrony >/dev/null || addgroup -S chrony; } && \
    { id -u chrony >/dev/null 2>&1 || adduser -S chrony -G chrony; } && \
    rm -f /etc/chrony/chrony.conf && \
    rm -rf /tmp/* /var/cache/apk/*

# script to configure/startup chrony (ntp)
COPY --chmod=0755 entrypoint.sh /entrypoint.sh

# ntp port
EXPOSE 123/udp

# marking volumes that need to be writable
VOLUME /etc/chrony /run/chrony /var/lib/chrony

# let docker know how to test container health
HEALTHCHECK CMD chronyc -n tracking || exit 1

# start chronyd in the foreground
ENTRYPOINT [ "/entrypoint.sh" ]
