FROM alpine:3.20

ARG BUILD_DATE

# first, a bit about this container
LABEL org.opencontainers.image.created="${BUILD_DATE}" \
      org.opencontainers.image.authors="Simon Rupf <simon@rupf.net>" \
      org.opencontainers.image.documentation=https://github.com/simonrupf/docker-chronyd

# default configuration
ENV NTP_DIRECTIVES="ratelimit\nrtcsync"

# install chrony
RUN apk add --no-cache chrony tzdata && \
    rm /etc/chrony/chrony.conf

# script to configure/startup chrony (ntp)
COPY assets/startup.sh /bin/startup

# ntp port
EXPOSE 123/udp

# marking volumes that need to be writable
VOLUME /etc/chrony /run/chrony /var/lib/chrony

# let docker know how to test container health
HEALTHCHECK CMD chronyc -n tracking || exit 1

# start chronyd in the foreground
ENTRYPOINT [ "/bin/startup" ]
