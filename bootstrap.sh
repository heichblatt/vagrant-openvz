#!/usr/bin/env bash

set -e

INSTALL=${INSTALL:-yum install -y}

log() {
	echo -e "\033[34m[bootstrapper] $* \033[0m"
}

if [ "$EUID" -ne 0 ] ; then 
	log Escalating privileges..
	sudo "$0"
	exit 0
fi

log Installing OpenVZ.

wget -P /etc/yum.repos.d/ http://ftp.openvz.org/openvz.repo
rpm --import http://ftp.openvz.org/RPM-GPG-Key-OpenVZ
yum install -y vzkernel
yum install -y vzctl vzquota ploop
touch /etc/vz/vzstats-disable  # https://openvz.org/Vzstats#How_to_opt-out

echo << EOF > /etc/sysctl.conf
net.ipv4.ip_forward = 1
net.ipv6.conf.default.forwarding = 1
net.ipv6.conf.all.forwarding = 1
net.ipv4.conf.default.proxy_arp = 0
net.ipv4.conf.all.rp_filter = 1
kernel.sysrq = 1
net.ipv4.conf.default.send_redirects = 1
net.ipv4.conf.all.send_redirects = 0
EOF

echo "options nf_conntrack ip_conntrack_disable_ve0=0" > /etc/modprobe.d/openvz.conf
echo "SELINUX=disabled" > /etc/sysconfig/selinux


echo << EOF >> /etc/rc.local
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
iptables -t nat -A POSTROUTING -s 192.168.134.0/24  -o eth0 -j SNAT --to $(hostname -i|awk '{print $NF}')
EOF

log Downloading templates.

for tmpl in centos-7-x86_64 centos-6-x86_64 debian-7.0-x86_64 fedora-20-x86_64 ; do
  wget -P /vz/template/cache/ http://download.openvz.org/template/precreated/"$tmpl".tar.gz
done

log Rebooting to switch to OpenVZ kernel.

reboot
