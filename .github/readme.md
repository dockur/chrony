<h1 align="center">chronyd<br />
<div align="center">
<a href="https://github.com/dockur/chrony"><img src="https://raw.githubusercontent.com/dockur/chrony/master/.github/logo.jpg" title="Logo" style="max-width:100%;" width="128" /></a>
</div>
<div align="center">
  
[![Build]][build_url]
[![Version]][tag_url]
[![Size]][tag_url]
[![Package]][pkg_url]
[![Pulls]][hub_url]

</div></h1>

Docker container of [chrony](https://chrony-project.org/), a versatile implementation of the Network Time Protocol (NTP).

## Features ✨

  - Synchronise the system clock with NTP servers, reference clocks (e.g. GPS receiver), and manual input using wristwatch and keyboard.
  - Operate as an NTPv4 (RFC 5905) server and peer to provide a time service to other computers in the network.

## Usage  🐳

Via Docker Compose:

```yaml
services:
  ntp:
    image: dockurr/chrony
    container_name: ntp
    environment:
      NTP_SERVERS: "pool.ntp.org"
    ports:
      - 123:123/udp
```

Via Docker CLI:

```bash
docker run -it --rm -p 123:123/udp dockurr/chrony
```

## Configuration ⚙️

By default, this container uses the [NTP pool's time servers](https://www.ntppool.org/en/). If you'd
like to use one or more different NTP server(s), you can pass this container an `NTP_SERVERS`
environment variable. This can be done by updating the [compose.yml](https://github.com/dockur/chrony/blob/master/compose.yml)
files or manually passing `--env=NTP_SERVERS="..."` to `docker run`.

Below are some examples of how to configure common NTP Servers.

Do note, to configure more than one server, you must use a comma delimited list WITHOUT spaces.

```
# (default) NTP pool
NTP_SERVERS="0.pool.ntp.org,1.pool.ntp.org,2.pool.ntp.org,3.pool.ntp.org"

# cloudflare
NTP_SERVERS="time.cloudflare.com"

# google
NTP_SERVERS="time1.google.com,time2.google.com,time3.google.com,time4.google.com"

# alibaba
NTP_SERVERS="ntp1.aliyun.com,ntp2.aliyun.com,ntp3.aliyun.com,ntp4.aliyun.com"

# local (offline)
NTP_SERVERS="127.127.1.1"
```

## Setting your timezone ⏲️

By default the UTC timezone is used, however if you'd like to adjust your NTP server to be running in your
local timezone, all you need to do is provide a `TZ` environment variable following the standard TZ data format.
As an example, using `docker-compose.yaml`, that would look like this if you were located in Vancouver, Canada:

```yaml
  ...
  environment:
    TZ: "America/Vancouver"
    ...
```

## Enable Network Time Security 🛡️

If **all** the `NTP_SERVERS` you have configured support NTS (Network Time Security) you can pass the `ENABLE_NTS=true`
option to the container to enable it. As an example, using `docker-compose.yaml`, that would look like this:

```yaml
  ...
  environment:
    ENABLE_NTS: "true"
    NTP_SERVERS: "time.cloudflare.com"
    ...
```

If any of the `NTP_SERVERS` you have configured does not support NTS, you will see a message like the
following during startup:

> NTS-KE session with 164.67.62.194:4460 (tick.ucla.edu) timed out

## Enable control of system clock 🖥️

This option enables the control of the system clock.

By default, chronyd will not try to make any adjustments of the clock. It will assume the clock is free running
and still track its offset and frequency relative to the estimated true time. This allows chronyd to run without
the capability to adjust or set the system clock in order to operate as an NTP server.

Enabling the control requires granting SYS_TIME capability and a container run-time allowing that access:

```yaml
  ...
  cap_add:
    - SYS_TIME
  environment:
    ENABLE_SYSCLK: "true"
    ...
```

 ## Logging 📒

By default, this project logs informational messages to stdout, which can be helpful when running the
ntp service. If you'd like to change the level of log verbosity, pass the `LOG_LEVEL` environment
variable to the container, specifying the level (`#`) when you first start it. This option matches
the chrony `-L` option, which support the following levels can to specified: 0 (informational), 1
(warning), 2 (non-fatal error), and 3 (fatal error).

Feel free to check out the project documentation for more information at:

 * https://chrony-project.org/documentation.html

## Stars 🌟
[![Stars](https://starchart.cc/dockur/chrony.svg?variant=adaptive)](https://starchart.cc/dockur/chrony)

[build_url]: https://github.com/dockur/chrony/
[hub_url]: https://hub.docker.com/r/dockurr/chrony/
[tag_url]: https://hub.docker.com/r/dockurr/chrony/tags
[pkg_url]: https://github.com/dockur/chrony/pkgs/container/chrony

[Build]: https://github.com/dockur/chrony/actions/workflows/build.yml/badge.svg
[Size]: https://img.shields.io/docker/image-size/dockurr/chrony/latest?color=066da5&label=size
[Pulls]: https://img.shields.io/docker/pulls/dockurr/chrony.svg?style=flat&label=pulls&logo=docker
[Version]: https://img.shields.io/docker/v/dockurr/chrony/latest?arch=amd64&sort=semver&color=066da5
[Package]: https://img.shields.io/badge/dynamic/json?url=https%3A%2F%2Fipitio.github.io%2Fbackage%2Fdockur%2Fchrony%2Fchrony.json&query=%24.downloads&logo=github&style=flat&color=066da5&label=pulls
