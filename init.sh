#!/bin/bash
 
aptupdatefun(){

echo "------>>开始更新源列表"
sudo apt-get update -y && apt-get install curl -y
echo "已更改源列表。所有更新和升级都完成了!"
}

huanyuanfun(){
echo "开始备份原列表"
sudo cp /etc/apt/sources.list /etc/apt/sources.list.backup
echo "原source list已备份."
echo "开始写入阿里云源Ubuntu 1804版本."
cat <<EOM >/etc/apt/sources.list
deb http://mirrors.aliyun.com/ubuntu/ bionic main restricted universe multiverse
deb-src http://mirrors.aliyun.com/ubuntu/ bionic main restricted universe multiverse

deb http://mirrors.aliyun.com/ubuntu/ bionic-security main restricted universe multiverse
deb-src http://mirrors.aliyun.com/ubuntu/ bionic-security main restricted universe multiverse

deb http://mirrors.aliyun.com/ubuntu/ bionic-updates main restricted universe multiverse
deb-src http://mirrors.aliyun.com/ubuntu/ bionic-updates main restricted universe multiverse

# deb http://mirrors.aliyun.com/ubuntu/ bionic-proposed main restricted universe multiverse
# deb-src http://mirrors.aliyun.com/ubuntu/ bionic-proposed main restricted universe multiverse

deb http://mirrors.aliyun.com/ubuntu/ bionic-backports main restricted universe multiverse
deb-src http://mirrors.aliyun.com/ubuntu/ bionic-backports main restricted universe multiverse

EOM
echo "source list已经写入阿里云源."

sleep 1
echo "开始更新源列表"
sudo apt-get update -y && apt-get install curl -y
echo "已更改源列表。所有更新和升级都完成了!"
}

staticip(){
echo "确保原文件手工备份至别的目录，避免重复执行脚本无法找回"
read -n1 -r -p "请按任意键继续..."


echo "开始备份原文件"
sudo cp /etc/netplan/00-installer-config.yaml /etc/netplan/00-installer-config.yaml.backup
echo "原source list已备份."

echo "开始配置静态ip"
echo "提示：x.x.x.x/x"
read -p "请输入网络地址: " ipaddresses
echo "提示：x.x.x.x"
read -p "请输入网关: " gateway
echo "提示：x.x.x.x  备用DNS默认114.114.114.114"
read -p "请输入主DNS: " nameservers


cat <<EOM >/etc/netplan/00-installer-config.yaml
# This is the network config written by 'subiquity'
network:
  version: 2
  ethernets:
     ens33:
         dhcp4: no
         addresses: [$ipaddresses]
         gateway4: $gateway
         nameservers:
             addresses: [$nameservers,114.114.114.114]

EOM
echo "配置信息成功写入,成功切换ip 、ssh已断开，请使用设置的ip重新登录"
netplan apply
sleep 1
echo "配置已应用"
}
ufwapt(){
apt install ufw -y
echo "ufw 已安装"
echo "请输入y以开启ufw"
ufw enable 
echo "ufw已开启"
sudo ufw allow 22
echo "已配置允许 22 端口"
sudo ufw default deny
echo "已配置关闭所有外部对本机的访问"


}
ufwdel(){
sudo ufw disable 
echo "ufw已关闭"
}
ufwadd(){

  read -p "请输入端口号（0-65535）: " port
sudo ufw allow $port
echo "端口 $port 已放行"

}
ufwstatus(){
ufw status
echo "提示：inactive 关闭状态 , active 开启状态"


}


ufwclose(){

  read -p "请输入端口号（0-65535）: " unport
sudo ufw  delete allow $unport
echo "端口 $unport 已关闭"

}

sysinfo(){
echo "####系统版本############"
lsb_release -a

echo "####当前登录用户############"
who am i
echo "####系统运行时间############"
uptime

}
installtools(){

apt install screen -y
echo "screen 已安装"
apt install git -y
echo "git 已安装"
apt install nmap -y
echo "nmap 已安装"
}


dhcpip(){
echo "开始配置DHCP"


cat <<EOM >/etc/netplan/00-installer-config.yaml
# This is the network config written by 'subiquity'
network:
  ethernets:
    ens33:
      dhcp4: true
  version: 2

EOM
echo "配置信息成功写入"
netplan apply
sleep 1
echo "DHCP已开启"
}

#程序开始
echo " "
echo "###################################################"
echo "#                                                 #"
echo "#         自定义Ubuntu 初始化shell脚本            #"
echo "#                                                 #"
echo "###################################################"
echo ""

echo "1：just update apt源    2：更换aliyun源sources.list    3："
echo "4：配置静态ip                5：配置DHCP自动获取           6：install screen、git、nmap"
echo "7：查看机器信息             8：安装&开启防火墙ufw       9：添加ufw允许端口"
echo "10：查看防火墙ufw状态  11：关闭防火墙ufw               12：关闭ufw允许端口"

read -p "请输入: " number

case $number in
    1)  aptupdatefun
    ;;
    2)  huanyuanfun
    ;;
    3)  
    ;;
    4)  staticip
    ;;
    5)  dhcpip
    ;;
    6)  installtools
    ;;
    7)  sysinfo
    ;;
    8)  ufwapt
    ;;
    9)  ufwadd
    ;;
    10)  ufwstatus
    ;;
    11)  ufwdel
    ;;
    12)  ufwclose
    ;;
    13)  
    ;;
    14)  
    ;;
    *)  echo '---------输入有误--------!!!!!!!!  #报废#'

    ;;
esac





