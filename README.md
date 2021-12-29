# Docker-PXE

PXE container for installing Ubuntu 20.04 on a server

https://hub.docker.com/r/jeroenvandermeulen/pxe

## Example

`docker run -it --rm --net=host --cap-add NET_ADMIN jeroenvandermeulen/pxe --dhcp-range=192.168.2.100,192.168.2.199,255.255.255.0 --dhcp-option=option:router,192.168.2.254`