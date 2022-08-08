#!/bin/bash
# Ubuntu初始化脚本
# Author:pinesss<https://gitee.com/pinesss>


#定义全局变量
datevar=$(date)



#全局函数
aptupdatefun(){
echo "检查更新"
echo "------>>开始更新源列表"
sudo apt-get update -y && apt-get install curl -y
echo "已更改源列表。所有更新和升级都完成了!"
}


# sys set 系统设置-----------------------############################################################################################### sys set 系统设置-#########################-----------------------
sysset(){

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
sleep 1
echo "开始备份原列表"
sudo cp /etc/apt/sources.list /etc/apt/sources.list.bak."$datevar"
sleep 1
echo "原source list已备份."
sleep 1
echo "检测你的系统版本为："
lsb_release -a
sleep 1
echo "选择你的Ubuntu版本（其他版本请手动换源）"
sleep 1
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
exit
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
sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak."$datevar"
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

supportcn(){
echo ""
sudo apt-get install zhcon -y
sudo adduser $(whoami) video

sleep 1
sudo zhcon -–utf8
echo ""
echo "Please enter 'zhcon -–utf8' "

}

sshkey(){
echo "输完3次回车"
read -p "请输入email: " email
ssh-keygen -t ed25519 -C "$email"
echo ""
echo "ssh公钥生成成功"
echo ""
echo ""
cat ~/.ssh/id_ed25519.pub



}

echo " "
echo "#########################################################################################"
echo "#                                                 #"
echo "#         自定义Ubuntu 初始化shell脚本    ufw     #"
echo "#                                                 #"
echo "#########################################################################################"
echo ""



echo "1：换源    2：同步时间      3：开启root远程登录      4：support Chinese 中文显示"
echo "------------------------------------------------------------------------------------"
echo ""
echo "5.生成ssh公钥           "
echo "------------------------------------------------------------------------------------"
echo "7: 返回主页"

echo "0:退出"
read -p "请输入命令数字: " number

case $number in
    0)  #退出#
    ;;
    1)  huanyuanfun
    ;;
    2)  timeok
    ;;
    3)  openroot
    ;;
    4)  supportcn
	;;
	5)  sshkey
	;;

    7)  ./init.sh
    ;;
    *)  echo '---------输入有误，脚本终止--------'

    ;;
esac

}



# network set 网络设置-----------------------########################################################################################### network set 网络设置##############################-----------------------
networkset(){

staticip(){
echo "确保原文件手工备份至别的目录，避免重复执行脚本无法找回"
read -n1 -r -p "请按任意键继续..."
echo "确保网卡名称ens33 还是其他"
ifconfig
read -p "请输入网卡名称（例：ens33 回车默认ens33）: " ens



if [[ "$ens" = "" ]]; then
ens="ens33"

fi
echo "网卡为" $ens
echo "开始备份原文件"




sudo cp /etc/netplan/00-installer-config.yaml /etc/netplan/00-installer-config.yaml.bak."$datevar"
echo "原00-installer-config.yaml已备份."

echo "开始配置静态ip"

ipaddresses="errorip"
read -p "请输入ip地址+网络号（x.x.x.x/x）: " ipaddresses

	until [[  "$ipaddresses"  ]]  ;do
			echo "$ipaddresses: 网络地址不能为空."
			read -p "请输入ip地址+网络号（x.x.x.x/x）: " ipaddresses

		done


echo "网络地址为：$ipaddresses"
echo "提示：x.x.x.x"
read -p "请输入网关: " gateway

until [[  "$gateway"   ]]; do
			echo "$gateway: 网关不能为空."
			read -p "请输入网关: " gateway
		done

	echo "网关为：$gateway"	
echo "提示：x.x.x.x  备用DNS已固定为114.114.114.114"
read -p "请输入主DNS: " nameservers
until [[  "$nameservers"   ]]; do
			echo "$nameservers: DNS不能为空."
			read -p "请输入主DNS: " nameservers
		done

echo "DNS地址为：$nameservers 114.114.114.114"


cat <<EOM >/etc/netplan/00-installer-config.yaml
# This is the network config written by 'subiquity'
network:
  version: 2
  ethernets:
     $ens:
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

dhcpip(){
echo "开始配置DHCP"
echo "确保网卡名称ens33 还是其他"
ifconfig
read -p "请输入网卡名称（例：ens33 回车默认ens33）: " ens



if [[ "$ens" = "" ]]; then
ens="ens33"
echo "网卡为" $ens

fi

cat <<EOM >/etc/netplan/00-installer-config.yaml
# This is the network config written by 'subiquity'
network:
  ethernets:
     $ens:
      dhcp4: true
  version: 2

EOM
echo "配置信息成功写入"
netplan apply
sleep 1
echo "DHCP已开启"
}

echo " "
echo "#########################################################################################"
echo "#                                                 #"
echo "#         自定义Ubuntu 初始化shell脚本   网络设置 #"
echo "#                                                 #"
echo "#########################################################################################"
echo ""



echo "1：配置静态ip    2：启用dhcp动态获取          3："
echo "------------------------------------------------------------------------------------"

echo "7: 返回主页"

echo "0:退出"
read -p "请输入命令数字: " number

case $number in
    0)  #退出#
    ;;
    1)  staticip
    ;;
    2)  dhcpip
    ;;

    
    7)  ./init.sh
    ;;
    *)  echo '---------输入有误，脚本终止--------'

    ;;
esac

}




# ufw & safe 安全配置-----------------------################################################################################## ufw & safe 安全配置###############################-----------------------
ufwfun(){


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
  until [[ -z "$port" || "$port" =~ ^[0-9]+$ && "$port" -le 65535 ]]; do
		echo "$port: 无效端口."
		read -p "请输入端口号（0-65535）: " port
	done
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
  until [[ -z "$unport" || "$unport" =~ ^[0-9]+$ && "$unport" -le 65535 ]]; do
		echo "$unport: 无效端口."
		read -p "请输入端口号（0-65535）: " unport
	done
sudo ufw  delete allow $unport
echo "端口 $unport 已关闭"
ufwstatus

}

fail2ban(){

echo "检查并安装fail2ban"
apt install fail2ban -y
echo "fail2ban 已安装"
echo "开始配置fail2ban"



read -n1 -r -p "请按任意键继续..."

read -p "请输入尝试次数（直接回车默认4次）: " retry
read -p "请输入拦截后禁止访问的时间（直接回车默认604800s）: " timeban


if [[ "$retry" = "" ]]; then
retry=4
fi

if [[ "$timeban" = "" ]]; then
timeban=604800
fi

cat <<EOM >/etc/fail2ban/jail.d/sshd.local

[ssh-iptables]
enabled  = true
filter   = sshd
action   = iptables[name=SSH, port=ssh, protocol=tcp]
logpath  = /var/log/auth.log
maxretry = $retry
bantime  = $timeban

EOM

 sudo service fail2ban start 
echo "服务已开启"
echo ""
echo "----服务状态----"
 sudo fail2ban-client status sshd 


}

echo " "
echo "#########################################################################################"
echo "#                                                 #"
echo "#         自定义Ubuntu 初始化shell脚本    ufw     #"
echo "#                                                 #"
echo "#########################################################################################"
echo ""



echo "1：查看防火墙-ufw状态    2：添加-ufw允许端口          3：关闭-ufw端口"
echo "------------------------------------------------------------------------------------"
echo "4: 安装&开启防火墙-ufw   5: 关闭防火墙-ufw            6：配置 fail2ban"
echo "------------------------------------------------------------------------------------"
echo "7: 返回主页"

echo "0:退出"
read -p "请输入命令数字: " number

case $number in
    0)  #退出#
    ;;
    1)  ufwstatus
    ;;
    2)  ufwadd
    ;;
    3)  ufwclose
    ;;
    4)  ufwapt
    ;;
    5)  ufwdel
    ;;
    6)  fail2ban
    ;;
    7)  ./init.sh
    ;;
    *)  echo '---------输入有误，脚本终止--------'

    ;;
esac

}

# 系统信息-----------------------########################################################################################################### 系统信息-#####################-----------------------
linuxinfo(){


sysinfo(){

echo "-----------系统版本------------"
lsb_release -a
echo ""
echo "---------当前登录用户-------登录时间-----"
who am i
echo ""
echo "-------------系统运行时间----当前登录用户数------系统负载----"

uptime
echo ""


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
netinfo()
{
echo ""
echo "---------局域网IP信息-------------"
	ifconfig -a
	sleep 1
echo "---------公网ip信息-----------------"
curl cip.cc
echo ""
	sleep 1
echo "---------路由表信息-----------------"
route -n
echo ""

}

netfast(){
	echo ""
	echo "检查安装测速工具"
apt install speedtest-cli -y
echo "开始测速"
speedtest-cli
echo "测速完成"

echo ""
}




echo " "
echo "#########################################################################################"
echo "#                                                 #"
echo "#         自定义Ubuntu 初始化shell脚本   系统信息 #"
echo "#                                                 #"
echo "#########################################################################################"
echo ""



echo "1：版本信息    2：磁盘信息     3：网络信息    4.网络测速（外网） "
echo "------------------------------------------------------------------------------------"

echo "7: 返回主页"

echo "0:退出"
read -p "请输入命令数字: " number

case $number in
    0)  #退出#
    ;;
    1)  sysinfo
    ;;
    2)  diskinfo
    ;;
    3) netinfo
    ;;
 4) netfast
    ;;
  
    7)  ./init.sh
    ;;
    *)  echo '---------输入有误，脚本终止--------'

    ;;
esac


}


# install tools 软件安装-----------------------###################################################################################### install tools 软件安装############################################-----------------------
installtools(){

installuseful(){

apt install net-tools -y
echo "net-tools 已安装"
apt install screen -y
echo "screen 已安装"
apt install git -y
echo "git 已安装"
apt install nmap -y
echo "nmap 已安装"
apt install iperf -y
echo "iperf已安装"
apt install zip -y
echo "zip 已安装"

}


installphp(){

aptupdatefun

	echo "开始安装php"
apt install php-dev  -y

apt install php-curl  -y
apt install php-zip -y
apt install php -y
	echo "开始安装composer"
	apt install composer -y

}


removephp(){
	echo ""
	
echo "开始卸载php"
apt remove php -y
 apt-get --purge remove php -y

 apt-get --purge remove php-* -y
 apt-get autoremove php -y
echo ""

echo "删除所有包含php的文件"
rm -rf /etc/php
rm -rf /etc/init.d/php
find  /etc  -name  *php* -print0 | xargs -0 rm -rf 

echo "清除dept列表"
apt purge `dpkg -l | grep php| awk '{print $2}' |tr "\n" " "`

echo ""
echo "卸载完成"

echo ""

}


installapache(){

aptupdatefun

	echo "开始安装apache"
apt install apache2 -y
	

}

removenginx(){
	echo ""
	echo "服务关闭"
service nginx stop
echo "开始卸载nginx"
apt remove nginx -y
 apt-get --purge remove nginx -y
 apt-get --purge remove nginx-common -y
 apt-get --purge remove nginx-core -y
echo ""

echo "删除所有包含nginx的文件"

find  /  -name  nginx* -print0 | xargs -0 rm -rf 
echo ""
echo "卸载完成"

echo ""

}

removeapache(){
	echo ""
	echo "服务关闭"
service apache2 stop
echo "开始卸载apache"
apt remove apache2 -y
 apt-get --purge remove apache2 -y
 apt-get --purge remove apache2-common -y
 apt-get --purge remove apache2-utils -y
 apt-get autoremove apache2
echo ""

echo "删除所有包含apache的文件"
rm -rf /etc/apache2
rm -rf /etc/init.d/apache2
find  /  -name  apache2* -print0 | xargs -0 rm -rf 
echo ""
echo "卸载完成"

echo ""

}



echo " "
echo "#########################################################################################"
echo "#                                                 #"
echo "#         自定义Ubuntu 初始化shell脚本    安装    #"
echo "#                                                 #"
echo "#########################################################################################"
echo ""



echo "1：安装常用必备    2：安装PHP及依赖      3.安装 Apache    4.               "
echo "------------------------------------------------------------------------------------"
echo "5：卸载nginx    6： 卸载Apache     7. 卸载php    8.              "
echo "------------------------------------------------------------------------------------"

echo "9: 返回主页"

echo "0:退出"
read -p "请输入命令数字: " number

case $number in
    0)  #退出#
    ;;
    1)  installuseful
    ;;
    2)  installphp
    ;;
    3)  installapache
    ;;
    4)  
    ;;
    5)  removenginx
    ;;
    6)  removeapache
    ;;
    7)  removephp
	;;
	8)  
    ;;
    9)  ./init.sh
    ;;
    *)  echo '---------输入有误，脚本终止--------'

    ;;
esac

}




# main 程序开始---------->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>># main 程序开始->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
echo " "
echo "#########################################################################################"
echo "#                                                 #"
echo "#         自定义Ubuntu 初始化shell脚本    主页    #"
echo "#                                                 #"
echo "#########################################################################################"
echo ""

echo "1：update apt （升级源）     2：software（软件安装&卸载）    3：ufw & safe （安全配置）"
echo "------------------------------------------------------------------------------------"
echo "4：sys set （系统设置）       5：net set （网络设置）       6：linux info （系统信息）"
echo "------------------------------------------------------------------------------------"
echo "0: exit 退出"
read -p "Please enter the command number 请输入命令数字: " number

case $number in
    0)  #退出#
    ;;
    1)  aptupdatefun
    ;;
    2)  installtools
    ;;
    3)  ufwfun
    ;;
    4)  sysset
    ;;
    5)  networkset
    ;;
    6)  linuxinfo
    ;;
    *)  echo '---------输入有误，脚本终止--------'

    ;;
esac





