FROM ubuntu:20.04

RUN apt-get -y update && apt-get install -y dnsmasq wget unzip

RUN \
mkdir /tmp/syslinux && \
cd /tmp/syslinux && \
wget https://mirrors.edge.kernel.org/pub/linux/utils/boot/syslinux/syslinux-6.03.zip && \
unzip syslinux-6.03.zip

RUN \
mkdir /tmp/uefi && \
cd /tmp/uefi && \
apt-get download shim.signed && \
dpkg -x *shim* shim && \
apt-get download grub-efi-amd64-signed && \
dpkg -x *grub* grub

RUN \
mkdir /tftp && \
mkdir /tftp/bios && \
mkdir /tftp/boot && \
mkdir /tftp/grub

RUN \
cp /tmp/syslinux/bios/com32/elflink/ldlinux/ldlinux.c32 /tftp/bios && \
cp /tmp/syslinux/bios/com32/libutil/libutil.c32 /tftp/bios && \
cp /tmp/syslinux/bios/com32/menu/menu.c32 /tftp/bios && \
cp /tmp/syslinux/bios/com32/menu/vesamenu.c32 /tftp/bios && \
cp /tmp/syslinux/bios/core/pxelinux.0 /tftp/bios && \
cp /tmp/syslinux/bios/core/lpxelinux.0 /tftp/bios

RUN \
cp /tmp/uefi/grub/usr/lib/grub/x86_64-efi-signed/grubnetx64.efi.signed /tftp/grubx64.efi && \
cp /tmp/uefi/shim/usr/lib/shim/shimx64.efi.signed /tftp/grub/bootx64.efi

COPY ./tftp/boot/grub/grub.cfg /tftp/grub/
COPY ./tftp/boot/grub/font.pf2 /tftp/grub/

COPY ./tftp/casper/vmlinuz /tftp/boot/casper/vmlinuz
COPY ./tftp/casper/initrd /tftp/boot/casper/initrd

COPY ./etc/dnsmasq.conf /etc/dnsmasq.conf

RUN \
ln -s /tftp/boot /tftp/bios/boot && \
ln -s /tftp/grub /tftp/boot/grub && \
ln -s /tftp/boot/casper /tftp/casper

RUN mkdir /tftp/bios/pxelinux.cfg

COPY ./tftp/bios/pxelinux.cfg/default /tftp/bios/pxelinux.cfg/default

# Start dnsmasq. It picks up default configuration from /etc/dnsmasq.conf and
# /etc/default/dnsmasq plus any command line switch
ENTRYPOINT ["dnsmasq", "--no-daemon"]
CMD ["--dhcp-range=192.168.56.2,proxy"]