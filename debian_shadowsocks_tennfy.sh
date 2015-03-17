#! /bin/bash
#===============================================================================================
#   System Required:  Debian or Ubuntu (32bit/64bit)
#   Description:  Install Shadowsocks(libev) for Debian or Ubuntu
#   Author: tennfy <admin@tennfy.com>
#   Intro:  http://www.tennfy.com
#===============================================================================================

clear
echo "#############################################################"
echo "# Install Shadowsocks(libev) for Debian or Ubuntu (32bit/64bit)"
echo "# Intro: http://www.tennfy.com"
echo "#"
echo "# Author: tennfy <admin@tennfy.com>"
echo "#"
echo "#############################################################"
echo ""

############################### install function##################################
function install_shadowsocks_tennfy(){
# Make sure only root can run our script
if [[ $EUID -ne 0 ]]; then
   echo "Error:This script must be run as root!" 1>&2
   exit 1
fi

cd $HOME

# install
apt-get update
apt-get install -y --force-yes build-essential autoconf libtool libssl-dev git curl

#download source code
git clone https://github.com/madeye/shadowsocks-libev.git

#compile install
cd shadowsocks-libev
./configure --prefix=/usr
make && make install
mkdir -p /etc/shadowsocks-libev
cp ./debian/shadowsocks-libev.init /etc/init.d/shadowsocks-libev
cp ./debian/shadowsocks-libev.default /etc/default/shadowsocks-libev
chmod +x /etc/init.d/shadowsocks-libev

# Get IP address(Default No.1)
IP=`curl -s checkip.dyndns.com | cut -d' ' -f 6  | cut -d'<' -f 1`
if [ -z $IP ]; then
   IP=`curl -s ifconfig.me/ip`
fi

#config setting
echo "#############################################################"
echo "#"
echo "# Please input your shadowsocks server_port and password"
echo "#"
echo "#############################################################"
echo ""
echo "input server_port(443 is suggested):"
read serverport
echo "input password:"
read shadowsockspwd

# Config shadowsocks
cat > /etc/shadowsocks-libev/config.json<<-EOF
{
    "server":"${IP}",
    "server_port":${serverport},
    "local_port":1080,
    "password":"${shadowsockspwd}",
    "timeout":60,
    "method":"rc4-md5"
}
EOF

#restart
/etc/init.d/shadowsocks-libev restart

#start with boot
update-rc.d shadowsocks-libev defaults

#install successfully
    echo ""
    echo "Congratulations, shadowsocks-libev install completed!"
    echo -e "Your Server IP: ${IP}"
    echo -e "Your Server Port: ${serverport}"
    echo -e "Your Password: ${shadowsockspwd}"
    echo -e "Your Local Port: 1080"
    echo -e "Your Encryption Method:rc4-md5"
}
############################### uninstall function##################################
function uninstall_shadowsocks_tennfy(){
#change the dir to shadowsocks-libev
cd $HOME
cd shadowsocks-libev

#stop shadowsocks-libev process
/etc/init.d/shadowsocks-libev stop

#uninstall shadowsocks-libev
make uninstall
make clean
cd ..
rm -rf shadowsocks-libev

# delete config file
rm -rf /etc/shadowsocks-libev

# delete shadowsocks-libev init file
rm -f /etc/init.d/shadowsocks-libev
rm -f /etc/default/shadowsocks-libev

#delete start with boot
update-rc.d -f shadowsocks-libev remove

echo "Shadowsocks-libev uninstall success!"

}

############################### update function##################################
function update_shadowsocks_tennfy(){
     uninstall_shadowsocks_tennfy
     install_shadowsocks_tennfy
	 echo "Shadowsocks-libev update success!"
}
# Initialization
action=$1
[  -z $1 ] && action=install
case "$action" in
install)
    install_shadowsocks_tennfy
    ;;
uninstall)
    uninstall_shadowsocks_tennfy
    ;;
update)
    update_shadowsocks_tennfy
    ;;	
*)
    echo "Arguments error! [${action} ]"
    echo "Usage: `basename $0` {install|uninstall|update}"
    ;;
esac