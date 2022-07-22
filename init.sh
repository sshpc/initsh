#!/bin/bash
 
aptupdatefun(){

echo "------>>开始更新源列表"
sudo apt-get update -y && apt-get install curl -y
echo "已更改源列表。所有更新和升级都完成了!"
}

huanyuanfun(){


a1604(){
echo "开始写入阿里云源Ubuntu 1604版本."
cat <<EOM >/etc/apt/sources.list
deb http://mirrors.aliyun.com/ubuntu/ xenial main
deb-src http://mirrors.aliyun.com/ubuntu/ xenial main

deb http://mirrors.aliyun.com/ubuntu/ xenial-updates main
deb-src http://mirrors.aliyun.com/ubuntu/ xenial-updates main

deb http://mirrors.aliyun.com/ubuntu/ xenial universe
deb-src http://mirrors.aliyun.com/ubuntu/ xenial universe
deb http://mirrors.aliyun.com/ubuntu/ xenial-updates universe
deb-src http://mirrors.aliyun.com/ubuntu/ xenial-updates universe

deb http://mirrors.aliyun.com/ubuntu/ xenial-security main
deb-src http://mirrors.aliyun.com/ubuntu/ xenial-security main
deb http://mirrors.aliyun.com/ubuntu/ xenial-security universe
deb-src http://mirrors.aliyun.com/ubuntu/ xenial-security universe


EOM
echo "source list已经写入阿里云源."

sleep 1
aptupdatefun
}

a1804(){
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
aptupdatefun
}

a2004(){
echo "开始写入阿里云源Ubuntu 2004版本."
cat <<EOM >/etc/apt/sources.list
deb http://mirrors.aliyun.com/ubuntu/ focal main restricted universe multiverse
deb-src http://mirrors.aliyun.com/ubuntu/ focal main restricted universe multiverse

deb http://mirrors.aliyun.com/ubuntu/ focal-security main restricted universe multiverse
deb-src http://mirrors.aliyun.com/ubuntu/ focal-security main restricted universe multiverse

deb http://mirrors.aliyun.com/ubuntu/ focal-updates main restricted universe multiverse
deb-src http://mirrors.aliyun.com/ubuntu/ focal-updates main restricted universe multiverse

# deb http://mirrors.aliyun.com/ubuntu/ focal-proposed main restricted universe multiverse
# deb-src http://mirrors.aliyun.com/ubuntu/ focal-proposed main restricted universe multiverse

deb http://mirrors.aliyun.com/ubuntu/ focal-backports main restricted universe multiverse
deb-src http://mirrors.aliyun.com/ubuntu/ focal-backports main restricted universe multiverse

EOM
echo "source list已经写入阿里云源."

sleep 1
aptupdatefun
}

echo "开始备份原列表"
sudo cp /etc/apt/sources.list /etc/apt/sources.list.backup
echo "原source list已备份."

echo "检测你的系统版本为："
lsb_release -a
echo "选择你的Ubuntu版本（其他版本请手动换源）"
echo "1：Ubuntu 16.04    2：Ubuntu 18.04(bionic)    3：Ubuntu 20.04(focal)"
read -p "请输入命令数字: " sourcesnumber
case $sourcesnumber in
    1)  a1604
    ;;
    2)  a1804
    ;;
    3)  a2004
    ;;
  *)  echo '---------输入有误，脚本终止--------'

    ;;
esac

}


timeok(){
echo "同步前的时间: $(date -R)"
echo "-----》即将同步为上海时间"
read -n1 -r -p "请按任意键继续..."
sudo cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

sudo timedatectl set-timezone Asia/Shanghai

# 将当前的 UTC 时间写入硬件时钟 (硬件时间默认为UTC)
sudo timedatectl set-local-rtc 0
# 启用NTP时间同步：
sudo timedatectl set-ntp yes

# 手动校准-强制更新时间
# chronyc -a makestep
# 系统时钟同步硬件时钟

sudo hwclock -w
sudo systemctl restart rsyslog.service cron.service


echo "当前系统时间: $(date -R)"
}

openroot(){
echo "确保root远程权限未开"

read -n1 -p "Do you want to continue [Y/N]? " answer
case $answer in
Y | y) echo

echo "开始备份原文件sshd_config"
sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.backup
echo "原文件sshd_config已备份."
sleep 1
echo "port 22" >> /etc/ssh/sshd_config
echo "PermitRootLogin yes" >> /etc/ssh/sshd_config
echo "重启服务中"
service sshd restart

echo "ok";;
       
 N | n) echo 
       echo "OK, goodbye"
       exit;;
 esac   


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
ufwstatus
./init.sh

}
ufwdel(){
sudo ufw disable 
echo "ufw已关闭"
ufwstatus

}
ufwadd(){

  read -p "请输入端口号（0-65535）: " port
sudo ufw allow $port
echo "端口 $port 已放行"
ufwstatus

}
ufwstatus(){
ufw status
echo "提示：inactive 关闭状态 , active 开启状态"
./init.sh

}


ufwclose(){

  read -p "请输入端口号（0-65535）: " unport
sudo ufw  delete allow $unport
echo "端口 $unport 已关闭"
ufwstatus

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

diskinfo(){

echo "\n分区信息:"
  sudo df -Th
  sudo lsblk
  echo -e "\n 磁盘信息："
  sudo fdisk -l
  echo -e "\n PV物理卷查看："
  sudo pvscan
  echo -e "\n vgs虚拟卷查看："
  sudo vgs
  echo -e "\n lvscan逻辑卷扫描:"
  sudo lvscan
  echo -e "\n 分区扩展"
  echo "Ubuntu \n lvextend -L +74G /dev/ubuntu-vg/ubuntu-lv"
  echo "lsblk"
  echo -e "ubuntu general \n # resize2fs -p -F /dev/mapper/ubuntu--vg-ubuntu--lv"


}



#程序开始---------->>>>>>>>>>>>
echo " "
echo "###################################################"
echo "#                                                 #"
echo "#         自定义Ubuntu 初始化shell脚本            #"
echo "#                                                 #"
echo "###################################################"
echo ""

echo "1：升级 update apt源     2：更换aliyun源sources.list    3：同步系统时间"
echo "------------------------------------------------------------------------------------"
echo "4：配置静态ip            5：配置DHCP自动获取            6：install screen、git、nmap"
echo "------------------------------------------------------------------------------------"
echo "7：查看机器信息          8：磁盘信息查看                9：open root user login"
echo "------------------------------------------------------------------------------------"
echo "10：查看防火墙-ufw状态    11：添加-ufw允许端口          12：关闭-ufw端口"
echo "------------------------------------------------------------------------------------"
echo "13: 安装&开启防火墙-ufw   14: 关闭防火墙-ufw"
echo "------------------------------------------------------------------------------------"
echo "0:退出"
read -p "请输入命令数字: " number

case $number in
    0)  #退出#
    ;;
    1)  aptupdatefun
    ;;
    2)  huanyuanfun
    ;;
    3)  timeok
    ;;
    4)  staticip
    ;;
    5)  dhcpip
    ;;
    6)  installtools
    ;;
    7)  sysinfo
    ;;
    8)  diskinfo
    ;;
    9)  openroot
    ;;
    10)  ufwstatus
    ;;
    11)  ufwadd
    ;;
    12)  ufwclose
    ;;
    13)  ufwapt
    ;;
    14)  ufwdel
    ;;
    *)  echo '---------输入有误，脚本终止--------'

    ;;
esac





