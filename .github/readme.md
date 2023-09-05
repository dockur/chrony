<h1 align="center">chronyd<br />
<div align="center">
<img src="https://raw.githubusercontent.com/dockur/chrony/master/.github/logo.jpg" title="Logo" style="max-width:100%;" width="128" />
</div>
<div align="center">
  
[![Build]][build_url]
[![Version]][tag_url]
[![Size]][tag_url]
[![Pulls]][hub_url]

</div></h1>

Docker image of [chrony](https://chrony.tuxfamily.org/) on [Alpine Linux](https://alpinelinux.org/).

[chrony](https://chrony.tuxfamily.org) is a versatile implementation of the Network Time Protocol (NTP). It can synchronise the system clock with NTP servers, reference clocks (e.g. GPS receiver), and manual input using wristwatch and keyboard. It can also operate as an NTPv4 (RFC 5905) server and peer to provide a time service to other computers in the network.

## How to use

### With Docker Compose

```yaml
version: "3"
services:
  ntp:
    image: dockurr/chrony:latest
    container_name: ntp
    ports:
      - 123:123/udp
    environment:
      - NTP_SERVERS=time.cloudflare.com
```

### With the Docker CLI

Pull and run -- it's this simple.

```
# pull from docker hub
$> docker pull dockurr/chrony

# run ntp
$> docker run --name=ntp            \
              --restart=always      \
              --detach              \
              --publish=123:123/udp \
              dockurr/chrony

# OR run ntp with higher security
$> docker run --name=ntp                           \
              --restart=always                     \
              --detach                             \
              --publish=123:123/udp                \
              --read-only                          \
              --tmpfs=/etc/chrony:rw,mode=1750     \
              --tmpfs=/run/chrony:rw,mode=1750     \
              --tmpfs=/var/lib/chrony:rw,mode=1750 \
              dockurr/chrony
```

## Configure NTP Servers

By default, this container uses the [NTP pool's time servers](https://www.ntppool.org/en/). If you'd
like to use one or more different NTP server(s), you can pass this container an `NTP_SERVERS`
environment variable. This can be done by updating the [vars](vars), [docker-compose.yml](docker-compose.yml)
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

If you're interested in a public list of stratum 1 servers, you can have a look at the following list.
Do make sure to verify the ntp server is active as this list does appaer to have some no longer active
servers.

 * https://www.advtimesync.com/docs/manual/stratum1.html


## Logging

By default, this project logs informational messages to stdout, which can be helpful when running the
ntp service. If you'd like to change the level of log verbosity, pass the `LOG_LEVEL` environment
variable to the container, specifying the level (`#`) when you first start it. This option matches
the chrony `-L` option, which support the following levels can to specified: 0 (informational), 1
(warning), 2 (non-fatal error), and 3 (fatal error).

Feel free to check out the project documentation for more information at:

 * https://chrony.tuxfamily.org/doc/4.1/chronyd.html


## Testing your NTP Container

From any machine that has `ntpdate` you can query your new NTP container with the follow
command:

```
$> ntpdate -q <DOCKER_HOST_IP>
```


Here is a sample output from my environment:

```
$> ntpdate -q 10.13.13.9
server 10.13.1.109, stratum 4, offset 0.000642, delay 0.02805
14 Mar 19:21:29 ntpdate[26834]: adjust time server 10.13.13.109 offset 0.000642 sec
```


If you see a message, like the following, it's likely the clock is not yet synchronized.
You should see this go away if you wait a bit longer and query again.
```
$> ntpdate -q 10.13.13.9
server 10.13.13.9, stratum 16, offset 0.005689, delay 0.02837
11 Dec 09:47:53 ntpdate[26030]: no server suitable for synchronization found
```

To see details on the ntp status of your container, you can check with the command below
on your docker host:
```
$> docker exec ntp chronyc tracking
Reference ID    : D8EF2300 (time1.google.com)
Stratum         : 2
Ref time (UTC)  : Sun Mar 15 04:33:30 2020
System time     : 0.000054161 seconds slow of NTP time
Last offset     : -0.000015060 seconds
RMS offset      : 0.000206534 seconds
Frequency       : 5.626 ppm fast
Residual freq   : -0.001 ppm
Skew            : 0.118 ppm
Root delay      : 0.022015510 seconds
Root dispersion : 0.001476757 seconds
Update interval : 1025.2 seconds
Leap status     : Normal
```


Here is how you can see a peer list to verify the state of each ntp source configured:
```
$> docker exec ntp chronyc sources
210 Number of sources = 2
MS Name/IP address         Stratum Poll Reach LastRx Last sample
===============================================================================
^+ time.cloudflare.com           3  10   377   404   -623us[ -623us] +/-   24ms
^* time1.google.com              1  10   377  1023   +259us[ +244us] +/-   11ms
```


Finally, if you'd like to see statistics about the collected measurements of each ntp
source configured:
```
$> docker exec ntp chronyc sourcestats
210 Number of sources = 2
Name/IP Address            NP  NR  Span  Frequency  Freq Skew  Offset  Std Dev
==============================================================================
time.cloudflare.com        35  18  139m     +0.014      0.141   -662us   530us
time1.google.com           33  13  128m     -0.007      0.138   +318us   460us
```


Are you seeing messages like these and wondering what is going on?
```
$ docker logs -f ntps
[...]
2021-05-25T18:41:40Z System clock wrong by -2.535004 seconds
2021-05-25T18:41:40Z Could not step system clock
2021-05-25T18:42:47Z System clock wrong by -2.541034 seconds
2021-05-25T18:42:47Z Could not step system clock
```

Good question! Since `chronyd` is running with the `-x` flag, it will not try to control
the system (container host) clock. This of course is necessary because the process does not
have priviledge (for good reason) to modify the clock on the system.

Like any host on your network, simply use your preferred ntp client to pull the time from
the running ntp container on your container host.

[build_url]: https://github.com/dockur/chrony/
[hub_url]: https://hub.docker.com/r/dockurr/chrony/
[tag_url]: https://hub.docker.com/r/dockurr/chrony/tags

[Build]: https://github.com/dockur/chrony/actions/workflows/build.yml/badge.svg
[Size]: https://img.shields.io/docker/image-size/dockurr/chrony/latest?color=066da5&label=size
[Pulls]: https://img.shields.io/docker/pulls/dockurr/chrony.svg?style=flat&label=pulls&logo=docker
[Version]: https://img.shields.io/docker/v/dockurr/chrony/latest?arch=amd64&sort=semver&color=066da5
