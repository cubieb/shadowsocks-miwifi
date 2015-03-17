#!/bin/sh

clear
echo "#############################################################"
echo "# Install Shadowsocks for Miwifi(r1d)"
echo "#############################################################"
echo "# You need shadowsocks configuration like below"
echo ""
echo "# { "
echo "#   "server":"10.10.10.10","
echo "#   "server_port":443,"
echo "#   "local_port":1080,"
echo "#   "password":"abcdefg","
echo "#   "timeout":60,"
echo "#   "method":"rc4-md5""
echo "# } "
echo ""

# Make sure only root can run our script
if [[ $EUID -ne 0 ]]; then
   echo "Error:This script must be run as root!" 1>&2
   exit 1
fi
cd /userdisk/data/
rm -f shadowsocks-miwifi.tar.gz
wget http://www.bobcafer.tk/shadowsocks-miwifi.tar.gz
tar zxf shadowsocks-miwifi.tar.gz

# install shadowsocks ss-redir to /usr/bin
mount / -o rw,remount
cp -f ./shadowsocks-miwifi/ss-redir  /usr/bin/ss-redir
chmod +x /usr/bin/ss-redir
sync
mount / -o ro,remount

# Config shadowsocks init script
cp ./shadowsocks-miwifi/shadowsocks /etc/init.d/shadowsocks
chmod +x /etc/init.d/shadowsocks

#config setting and save settings.
mkdir -p /etc/shadowsocks
echo "#############################################################"
echo "#"
echo "# Please input your shadowsocks configuration"
echo "#"
echo "#############################################################"
echo ""
echo "input server_address(ipaddress is suggested):"
read serverip
echo "input server_port(443 is suggested):"
read serverport
echo "input local_port(1082 is suggested):"
read localport
echo "input password:"
read shadowsockspwd
echo "input method(encrypt method: table, rc4, rc4-md5,
                                     aes-128-cfb, aes-192-cfb, aes-256-cfb,
                                     bf-cfb, camellia-128-cfb, camellia-192-cfb,
                                     camellia-256-cfb, cast5-cfb, des-cfb,
                                     idea-cfb, rc2-cfb and seed-cfb):"
read method

# Config shadowsocks
cat > /etc/shadowsocks/config.json<<-EOF
{
    "server":"${serverip}",
    "server_port":${serverport},
    "local_port":${localport},
    "password":"${shadowsockspwd}",
    "timeout":60,
    "method":"${method}"
}
EOF

#config dnsmasq
mkdir -p /etc/dnsmasq.d
cp -f ./shadowsocks-miwifi/fgserver.conf /etc/dnsmasq.d/fgserver.conf
cp -f ./shadowsocks-miwifi/fgset.conf /etc/dnsmasq.d/fgset.conf

#config firewall
cp -f /etc/firewall.user /etc/firewall.user.back
echo "ipset -N setmefree iphash -! " >> /etc/firewall.user
echo "iptables -t nat -A PREROUTING -p tcp -m set --match-set setmefree dst -j REDIRECT --to-port ${localport}" >> /etc/firewall.user

#restart all service
/etc/init.d/dnsmasq restart
/etc/init.d/firewall restart
/etc/init.d/shadowsocks start
/etc/init.d/shadowsocks enable
#install successfully
rm -rf /userdisk/data/shadowsocks-miwifi
echo ""
echo "Congratulations, shadowsocks-miwifi installed complete !"
echo ""
exit 0
