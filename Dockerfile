FROM alpine:edge

# default configuration
ENV NTP_DIRECTIVES="ratelimit\nrtcsync"

# install chrony
RUN apk add --no-cache chrony && \
    rm /etc/chrony/chrony.conf

# script to configure/startup chrony (ntp)
COPY assets/startup.sh /bin/startup

# ntp port
EXPOSE 123/udp

# marking volumes that need to be writable
VOLUME /etc/chrony /run/chrony /var/lib/chrony

# Container version
ARG VERSION_ARG="0.0"
ENV VERSION=$VERSION_ARG

LABEL org.opencontainers.image.title="Chrony"
LABEL org.opencontainers.image.description="Chronyd NTP server"

# let docker know how to test container health
HEALTHCHECK CMD chronyc tracking || exit 1

# start chronyd in the foreground
ENTRYPOINT [ "/bin/startup" ]
