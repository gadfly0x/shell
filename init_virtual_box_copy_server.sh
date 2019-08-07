#!/bin/bash
#VirtualBox copy CentOS6.6 host init
#
#rename hostname
old_hostname=`awk -F '=' '/HOSTNAME/{print $2}' /etc/sysconfig/network`
read -p "input new hostname:" new_hostname
if [[ ! -n "$new_hostname"  ]]; then
    echo "hostname can not be empty"
    exit
else
    sed -i "s/${old_hostname}/${new_hostname}/g" /etc/sysconfig/network
fi

#change mac address
old_mac=`awk '/eth0/{match($0,"ATTR{address}==");print substr($0,RSTART+16,17)}' /etc/udev/rules.d/70-persistent-net.rules`
new_mac=`awk '/eth1/{match($0,"ATTR{address}==");print substr($0,RSTART+16,17)}' /etc/udev/rules.d/70-persistent-net.rules`
sed -i "s/${old_mac}/${new_mac}/g" /etc/udev/rules.d/70-persistent-net.rules

old_mac=$(echo $old_mac | tr '[a-z]' '[A-Z]')
new_mac=$(echo $new_mac | tr '[a-z]' '[A-Z]')
sed -i "s/${old_mac}/${new_mac}/g" /etc/sysconfig/network-scripts/ifcfg-eth0

#delete eth1
linenum=`wc -l /etc/udev/rules.d/70-persistent-net.rules | awk '{print $1}'`
linenum_last3=`expr $linenum - 2`
sed -i "${linenum_last3},${linenum}d" /etc/udev/rules.d/70-persistent-net.rules

#reboot
reboot