#!/bin/bash
# Ubuntu初始化&工具脚本
# Author:SSHPC <https://github.com/sshpc>
export LANG=en_US.UTF-8
#定义全局变量：

datevar=$(date)
#版本
version='23.3.8'
#菜单名称(默认主页)
menuname='主页'

#全局函数~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#分割线
next() {
    printf "%-70s\n" "-" | sed 's/\s/-/g'
}

waitinput(){
read -n1 -r -p "按任意键继续..."
}


#apt更新
aptupdatefun() {
    echo "检查更新"
    echo "------>>开始更新源列表"
    sudo apt-get update -y && apt-get install curl -y
    echo "已更改源列表。所有更新和升级都完成了!"
}

#菜单头部
menutop() {
    echo ""
    echo "~~~~~~~~~~~~~~ Ubuntu tools 脚本工具 ~~~~~~~~~~~~ 版本:v $version"
    echo ""
    echo "当前菜单: $menuname "
    echo ""
    next
}

#二级菜单底部
menubottom() {
    next
    echo "0: 退出    99: 返回主页"
    echo ""
    
    read -p "请输入命令数字: " number
}

inputerror() {
    echo '>---------输入有误,脚本终止--------<'
}

io_test() {
    (LANG=C dd if=/dev/zero of=benchtest_$$ bs=512k count=$1 conv=fdatasync && rm -f benchtest_$$) 2>&1 | awk -F, '{io=$NF} END { print io}' | sed 's/^[ \t]*//;s/[ \t]*$//'
}

#终端字体颜色定义
_red() {
    printf '\033[0;31;31m%b\033[0m' "$1"
}

_green() {
    printf '\033[0;31;32m%b\033[0m' "$1"
}

_yellow() {
    printf '\033[0;31;33m%b\033[0m' "$1"
}

_blue() {
    printf '\033[0;31;36m%b\033[0m' "$1"
}



installbase() {
    apt-get update -y && apt-get install curl -y
    apt install net-tools -y
    echo "net-tools 已安装"
    apt install vim -y
    apt install openssh-server -y
    echo "vim 和 ssh 已安装"
}

installuseful() {

    aptupdatefun
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

installphp() {

    aptupdatefun

    echo "开始安装php"
    apt install php-dev php-curl php-zip -y

}

removephp() {
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
    find /etc -name *php* -print0 | xargs -0 rm -rf

    echo "清除dept列表"
    apt purge $(dpkg -l | grep php | awk '{print $2}' | tr "\n" " ")

    echo ""
    echo "卸载完成"

    echo ""

}

removenginx() {
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

    find / -name nginx* -print0 | xargs -0 rm -rf
    echo ""
    echo "卸载完成"

    echo ""

}

removeapache() {
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
    find / -name apache2* -print0 | xargs -0 rm -rf
    echo ""
    echo "卸载完成"

    echo ""

}

removedocker() {

    docker kill $(docker ps -a -q)
    docker rm $(docker ps -a -q)
    docker rmi $(docker images -q)
    systemctl stop docker
    service docker stop

    sudo apt-get autoremove docker docker-ce docker-engine docker.io containerd runc
    dpkg -l | grep docker
    sudo apt-get autoremove docker-ce-*
    sudo rm -rf /etc/systemd/system/docker.service.d
    sudo rm -rf /var/lib/docker
    rm -rf /etc/docker
    rm -rf /run/docker
    rm -rf /var/lib/dockershim
    umount /var/lib/docker/devicemapper

    echo ""
    echo "卸载完成"

    echo ""

}

removev2() {

    systemctl stop v2ray

    systemctl disable v2ray

    service v2ray stop

    update-rc.d -f v2ray remove

    rm -rf /etc/v2ray/*

    rm -rf /usr/bin/v2ray/*

    rm -rf /var/log/v2ray/*

    rm -rf /lib/systemd/system/v2ray.service

    rm -rf /etc/init.d/v2ray

}

removemysql() {

    echo ""
    echo "服务关闭"
    service mysql-server stop
    echo "开始卸载mysql"

    sudo apt-get autoremove --purge mysql-server -y
    sudo apt-get remove mysql-common -y

    sudo apt-get remove dbconfig-mysql -y
    sudo apt-get remove mysql-client -y
    sudo apt-get remove mysql-client-5.7 -y
    sudo apt-get remove mysql-client-core-5.7 -y

    sudo apt-get remove apparmor -y
    sudo apt-get autoremove mysql* --purge -y
    dpkg -l | grep ^rc | awk '{print $2}' | sudo xargs dpkg -P

    sudo rm /var/lib/mysql/ -R
    sudo rm /etc/mysql/ -R

    echo ""
    echo "卸载完成"

    echo ""

}

cfpinstall() {

    echo "确保cfp的仓库在root目录已克隆"

    read -n1 -p "Do you want to continue [Y/N]? " answer
    case $answer in
    Y | y)
        echo "开始请手动克隆仓库"
        installphp
        echo "php 检查完成"
        nohup php vpscfptools/server.php start >vpscfptools/logs/server.log 2>&1 &
        echo "server 尝试开始"
        sleep 2
        cfpstatus
        ;;

    N | n)
        echo
        echo "OK, goodbye"
        exit
        ;;
    esac

}

ufwinstall() {
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

}

ufwdel() {
    sudo ufw disable
    echo "ufw已关闭"
    ufwstatus
}

ufwadd() {

    read -p "请输入端口号 (0-65535): " port
    until [[ -z "$port" || "$port" =~ ^[0-9]+$ && "$port" -le 65535 ]]; do
        echo "$port: 无效端口."
        read -p "请输入端口号 (0-65535): " port
    done
    sudo ufw allow $port
    echo "端口 $port 已放行"
    ufwstatus

}
ufwstatus() {
    ufw status
    echo "提示:inactive 关闭状态 , active 开启状态"

}

ufwclose() {

    read -p "请输入端口号 (0-65535): " unport
    until [[ -z "$unport" || "$unport" =~ ^[0-9]+$ && "$unport" -le 65535 ]]; do
        echo "$unport: 无效端口."
        read -p "请输入端口号 (0-65535): " unport
    done
    sudo ufw delete allow $unport
    echo "端口 $unport 已关闭"
    ufwstatus

}

installfail2ban() {

    echo "检查并安装fail2ban"
    apt install fail2ban -y
    echo "fail2ban 已安装"
    echo "开始配置fail2ban"

    waitinput

    read -p "请输入尝试次数 (直接回车默认4次): " retry
    read -p "请输入拦截后禁止访问的时间 (直接回车默认604800s): " timeban

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

huanyuanfun() {

    a1804() {
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

    a2004() {
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

    a2204() {
        echo "开始写入阿里云源Ubuntu 2204版本."
        cat <<EOM >/etc/apt/sources.list
deb http://mirrors.aliyun.com/ubuntu/ jammy main restricted universe multiverse
deb-src http://mirrors.aliyun.com/ubuntu/ jammy main restricted universe multiverse
deb http://mirrors.aliyun.com/ubuntu/ jammy-security main restricted universe multiverse
deb-src http://mirrors.aliyun.com/ubuntu/ jammy-security main restricted universe multiverse
deb http://mirrors.aliyun.com/ubuntu/ jammy-updates main restricted universe multiverse
deb-src http://mirrors.aliyun.com/ubuntu/ jammy-updates main restricted universe multiverse
deb http://mirrors.aliyun.com/ubuntu/ jammy-proposed main restricted universe multiverse
deb-src http://mirrors.aliyun.com/ubuntu/ jammy-proposed main restricted universe multiverse
deb http://mirrors.aliyun.com/ubuntu/ jammy-backports main restricted universe multiverse
deb-src http://mirrors.aliyun.com/ubuntu/ jammy-backports main restricted universe multiverse

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
    echo "检测你的系统版本为:"
    lsb_release -a
    sleep 1
    echo "选择你的Ubuntu版本(其他版本请手动换源)"
    sleep 1
    echo "1:Ubuntu 16.04    2:Ubuntu 18.04(bionic)    3:Ubuntu 20.04(focal)  4:Ubuntu 22.04(jammy)"
    read -p "请输入命令数字: " sourcesnumber
    case $sourcesnumber in
    1)
        a1804
        ;;
    2)
        a2004
        ;;
    3)
        a2204
        ;;

    *)
        inputerror
        exit
        ;;
    esac

}

synchronization_time() {
    echo "同步前的时间: $(date -R)"
    echo "-----》即将同步为上海时间"
    waitinput
    sudo cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

    sudo timedatectl set-timezone Asia/Shanghai

    # 将当前的 UTC 时间写入硬件时钟 (硬件时间默认为UTC)
    sudo timedatectl set-local-rtc 0
    # 启用NTP时间同步:
    sudo timedatectl set-ntp yes

    # 手动校准-强制更新时间
    # chronyc -a makestep
    # 系统时钟同步硬件时钟

    sudo hwclock -w
    sudo systemctl restart rsyslog.service cron.service

    echo "当前系统时间: $(date -R)"
}

openroot() {
    echo "确保root远程权限未开"

    read -n1 -p "Do you want to continue [Y/N]? " answer
    case $answer in
    Y | y)
        echo

        echo "开始备份原文件sshd_config"
        sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak."$datevar"
        echo "原文件sshd_config已备份."
        sleep 1
        echo "port 22" >>/etc/ssh/sshd_config
        echo "PermitRootLogin yes" >>/etc/ssh/sshd_config
        echo "PasswordAuthentication yes" >>/etc/ssh/sshd_config
        echo "重启服务中"
        service sshd restart

        echo "ok"
        ;;

    N | n)
        echo
        echo "OK, goodbye"
        exit
        ;;
    esac

}

sshpubonly() {

    echo "开始备份原文件sshd_config"
    sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak."$datevar"
    echo "原文件sshd_config已备份."
    sleep 1
    echo "port 22" >>/etc/ssh/sshd_config
    echo "PermitRootLogin yes" >>/etc/ssh/sshd_config
    echo "PasswordAuthentication no" >>/etc/ssh/sshd_config
    echo "重启服务中"
    service sshd restart

    echo "ok"
}

supportcn() {
    echo ""
    sudo apt-get install zhcon -y
    sudo adduser $(whoami) video

    sleep 1
    sudo zhcon --utf8
    echo ""
    echo "Please enter 'zhcon --utf8' "

}

sshgetpub() {
    echo "输完3次回车"
    read -p "请输入email: " email
    ssh-keygen -t ed25519 -C "$email"
    echo ""
    echo "ssh秘钥钥生成成功"
    echo ""
    echo "公钥："
    cat ~/.ssh/id_ed25519.pub
}

sshsetpub() {
    echo "请填入ssh公钥"
    read -p "请粘贴至命令行回车: " sshpub
    echo -e $sshpub >>/root/.ssh/authorized_keys
    echo ""
    echo "ssh公钥写入成功"
    echo ""
}

sysinfo() {

    echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>系统基本信息<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<"
    hostname=$(uname -n)
    system=$(cat /etc/os-release | grep "^NAME" | awk -F\" '{print $2}')
    version=$(lsb_release -s -d)
    codename=$(lsb_release -s -c)

    ccache=$(awk -F: '/cache size/ {cache=$2} END {print cache}' /proc/cpuinfo | sed 's/^[ \t]*//;s/[ \t]*$//')
    cpu_aes=$(grep -i 'aes' /proc/cpuinfo)

    kernel=$(uname -r)
    platform=$(uname -p)
    address=$(ip addr | grep inet | grep -v "inet6" | grep -v "127.0.0.1" | awk '{ print $2; }' | tr '\n' '\t')
    cpumodel=$(cat /proc/cpuinfo | grep name | cut -f2 -d: | uniq)
    cpu=$(cat /proc/cpuinfo | grep 'processor' | sort | uniq | wc -l)
    machinemodel=$(dmidecode | grep "Product Name" | sed 's/^[ \t]*//g' | tr '\n' '\t')
    date=$(date)
    tcpalgorithm=$(sysctl net.ipv4.tcp_congestion_control | awk -F ' ' '{print $3}')

    echo "主机名:           $hostname"
    echo "系统名称:         $system"
    echo "系统版本:         $version $codename"

    echo "内核版本:         $kernel"
    echo "系统类型:         $platform"

    echo "CPU型号:          $cpumodel"
    echo "CPU核数:          $cpu"
    echo "CPU缓存:          $ccache"

    if [ -n "$cpu_aes" ]; then
        echo "AES加密指令集支持: yes"
    fi

    echo "机器型号:         $machinemodel"
    echo "系统时间:         $date"
    echo "本机IP地址:       $address"
    echo "tcp拥塞控制算法:   $tcpalgorithm"

    echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>资源使用情况<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<"
    summemory=$(free -h | grep "Mem:" | awk '{print $2}')
    freememory=$(free -h | grep "Mem:" | awk '{print $4}')
    usagememory=$(free -h | grep "Mem:" | awk '{print $3}')
    uptime=$(uptime | awk '{print $2" "$3" "$4" "$5}' | sed 's/,$//g')
    loadavg=$(uptime | awk '{print $9" "$10" "$11" "$12" "$13}')

    echo "总内存大小:           $summemory"
    echo "已使用内存大小:       $usagememory"
    echo "可使用内存大小:       $freememory"
    echo "系统运行时间:         $uptime"
    echo "系统负载:            $loadavg"

    echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>安全审计<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<"
    echo "正常情况下登录到本机30天内的所有用户的历史记录:"
    last | head -n 30

    echo "系统中关键文件修改时间:"
    ls -ltr /bin/ls /bin/login /etc/passwd /bin/ps /etc/shadow | awk '{print ">>>文件名："$9"  ""最后修改时间："$6" "$7" "$8}'
    echo ""
    
    echo "是否进行磁盘测速？"
    waitinput
    echo "正在进行磁盘测速..."
    
    freespace=$(df -m . | awk 'NR==2 {print $4}')
    if [ -z "${freespace}" ]; then
        freespace=$(df -m . | awk 'NR==3 {print $3}')
    fi
    if [ ${freespace} -gt 1024 ]; then

        io1=$(io_test 2048)
        echo " I/O Speed(1st run) : $(_yellow "$io1")"
        io2=$(io_test 2048)
        echo " I/O Speed(2nd run) : $(_yellow "$io2")"
        io3=$(io_test 2048)
        echo " I/O Speed(3rd run) : $(_yellow "$io3")"
        ioraw1=$(echo $io1 | awk 'NR==1 {print $1}')
        [ "$(echo $io1 | awk 'NR==1 {print $2}')" == "GB/s" ] && ioraw1=$(awk 'BEGIN{print '$ioraw1' * 1024}')
        ioraw2=$(echo $io2 | awk 'NR==1 {print $1}')
        [ "$(echo $io2 | awk 'NR==1 {print $2}')" == "GB/s" ] && ioraw2=$(awk 'BEGIN{print '$ioraw2' * 1024}')
        ioraw3=$(echo $io3 | awk 'NR==1 {print $1}')
        [ "$(echo $io3 | awk 'NR==1 {print $2}')" == "GB/s" ] && ioraw3=$(awk 'BEGIN{print '$ioraw3' * 1024}')
        ioall=$(awk 'BEGIN{print '$ioraw1' + '$ioraw2' + '$ioraw3'}')
        ioavg=$(awk 'BEGIN{printf "%.1f", '$ioall' / 3}')
        echo " I/O Speed(average) : $(_yellow "$ioavg MB/s")"
    else
        echo " $(_red "Not enough space for I/O Speed test!")"
    fi



}

diskinfo() {

    echo "\n分区信息:"
    sudo df -Th
    sudo lsblk
    echo -e "\n 磁盘信息:"
    sudo fdisk -l
    echo -e "\n PV物理卷查看:"
    sudo pvscan
    echo -e "\n vgs虚拟卷查看:"
    sudo vgs
    echo -e "\n lvscan逻辑卷扫描:"
    sudo lvscan
    echo -e "\n 分区扩展"
    echo "Ubuntu \n lvextend -L +74G /dev/ubuntu-vg/ubuntu-lv"
    echo "lsblk"
    echo -e "ubuntu general \n # resize2fs -p -F /dev/mapper/ubuntu--vg-ubuntu--lv"

    echo "文件系统信息:"
    more /etc/fstab | grep -v "^#" | grep -v "^$"
    echo " "

}



staticip() {
    echo "确保原文件手工备份"
    waitinput
    echo "确保网卡名称ens33 还是其他"
    ifconfig
    read -p "请输入网卡名称 (例:ens33 回车默认ens33): " ens

    if [[ "$ens" = "" ]]; then
        ens="ens33"

    fi
    echo "网卡为" $ens
    echo "开始备份原文件"

    sudo cp /etc/netplan/00-installer-config.yaml /etc/netplan/00-installer-config.yaml.bak."$datevar"
    echo "原00-installer-config.yaml已备份."

    echo "开始配置静态ip"

    ipaddresses="errorip"
    read -p "请输入ip地址+网络号 (x.x.x.x/x): " ipaddresses

    until [[ "$ipaddresses" ]]; do
        echo "$ipaddresses: 网络地址不能为空."
        read -p "请输入ip地址+网络号 (x.x.x.x/x): " ipaddresses

    done

    echo "网络地址为:$ipaddresses"
    echo "提示:x.x.x.x"
    read -p "请输入网关: " gateway

    until [[ "$gateway" ]]; do
        echo "$gateway: 网关不能为空."
        read -p "请输入网关: " gateway
    done

    echo "网关为:$gateway"
    echo "提示:x.x.x.x  备用DNS已固定为114.114.114.114"
    read -p "请输入主DNS: " nameservers
    until [[ "$nameservers" ]]; do
        echo "$nameservers: DNS不能为空."
        read -p "请输入主DNS: " nameservers
    done

    echo "DNS地址为:$nameservers 114.114.114.114"

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
    echo "配置信息成功写入,成功切换ip 、ssh已断开,请使用设置的ip重新登录"
    netplan apply
    sleep 1
    echo "配置已应用"
}

dhcpip() {
    echo "开始配置DHCP"
    echo "确保网卡名称ens33 还是其他"
    ifconfig
    read -p "请输入网卡名称 (例:ens33 回车默认ens33): " ens

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

netinfo() {
    echo ""
    echo "---------本地IP信息-------------"
    ifconfig -a

    echo "---------公网ip信息-----------------"
    curl cip.cc
    echo ""
}

netfast() {
    echo ""
    echo "检查安装测速工具"
    apt install speedtest-cli -y
    echo "开始测速"
    speedtest-cli
    echo "测速完成"

    echo ""
}

dockerrund() {
    echo " "
    docker images
    echo ""
    read -p "请输入镜像包名或idREPOSITORY: " dcimage

    read -p "请输入容器端口: " conport
    read -p "请输入宿主机端口: " muport

    read -p "请输入执行参数: " param

    docker run -d -p $muport:$conport $dcimage $param

    echo "$dcimage 已在后台运行中"

}

dockerrunit() {
    echo " "
    docker images
    echo ""
    read -p "请输入镜像包名或idREPOSITORY: " dcimage

    read -p "请输入容器端口: " conport
    read -p "请输入宿主机端口: " muport

    read -p "请输入执行参数(默认/bin/bash): " param

    if [[ "$param" = "" ]]; then
        param="/bin/bash"

    fi

    docker run -it -p $muport:$conport $dcimage $param

    echo "$dcimage 后台运行中"

}

dockerexec() {

    echo " "
    docker ps
    echo ""

    read -p "请输入容器名或id: " containerd
    read -p "请输入执行参数(默认/bin/bash): " param

    if [[ "$param" = "" ]]; then
        param="/bin/bash"

    fi

    docker exec -it $containerd $param

}

opencon() {
    echo " "
    docker ps -a
    echo ""

    read -p "请输入容器名或id: " containerd
    docker start $containerd

    echo ""
    echo "正在运行的容器 "

    docker ps
}
stopcon() {
    echo " "
    docker ps
    echo ""

    read -p "请输入容器名或id: " containerd
    docker stop $containerd

    echo "正在运行的容器 "

    docker ps

}

rmcon() {
    echo " "
    docker ps -a
    echo ""

    read -p "请输入容器名或id: " containerd
    docker rm -f $containerd

    echo "所有容器 "

    docker ps -a
}

#二级菜单
software() {
    menutop

    echo "<安装>"

    echo "1:update apt  (升级源)    2: 安装核心软件     3.安装常用软件    4. 安装x-ui              "
    next
    echo ""
    echo "<卸载>"

    echo "5:卸载nginx    6: 卸载Apache     7. 卸载php    8. 卸载docker    9:卸载v2ray         "
    next
    echo "10:卸载mysql             "
    next
    echo ""
    echo "<cfp>"

    echo "30:一键配置cfp  31. 查看cfp-server状态 "
    next
    echo "32:安装PHP及依赖    33: 开启cfpserver  34. 停止cfpserver   "

    menubottom

    case $number in
    0) #退出#
        ;;
    1)
        aptupdatefun
        ./init.sh 1

        ;;
    2)
        installbase
        ./init.sh 1

        ;;
    3)
        installuseful
        ./init.sh 1
        ;;

    4)
        bash <(curl -Ls https://raw.githubusercontent.com/vaxilu/x-ui/master/install.sh)

        ;;
    5)
        removenginx

        ;;
    6)
        removeapache
        ;;
    7)
        removephp
        ;;
    8)
        removedocker
        ;;
    9)
        removev2
        ;;

    10)
        removemysql
        ;;
    30)
        cfpinstall
        ./init.sh 1
        ;;

    31)
        php /root/vpscfptools/server.php status
        ./init.sh 1

        ;;
    32)
        installphp
        ;;
    33)
        nohup php vpscfptools/server.php start >vpscfptools/logs/server.log 2>&1 &
        ./init.sh 1
        ;;
    34)
        php /root/vpscfptools/server.php stop
        ./init.sh 1
        ;;

    99)
        ./init.sh
        ;;
    *)
        inputerror

        ;;
    esac

}

networktools() {
    menutop
    echo "<--物理机专用-->"
    echo "1:配置静态ip    2:启用dhcp动态获取 "
    echo "<--物理机专用-->"
    next
    echo "3:网络信息      4.网络测速 (外网speednet)   "
    next
    echo "5:路由表        6:查看监听端口     "
    menubottom

    case $number in
    0) #退出#
        ;;
    1)
        staticip
        ;;
    2)
        dhcpip
        ;;
    3)
        netinfo
        ./init.sh 2
        ;;
    4)
        netfast
        ;;

    5)
        route -n
        ./init.sh 2
        ;;

    6)
        netstat -tunlp
        ./init.sh 2
        ;;

    99)
        ./init.sh
        ;;
    *)
        inputerror

        ;;
    esac

}

ufwsafe() {
    menutop
    echo "1:开启防火墙-ufw          2:关闭防火墙-ufw           "
    next
    echo "4:查看防火墙-ufw状态      5: 添加-ufw允许端口      6:关闭-ufw端口     "
    next
    echo "7:检查并安装配置fail2ban  8: fail2ban状态         9:查看是否有ssh爆破记录     "
    next
    echo "10:查出每个IP地址连接数       "
    menubottom
    case $number in
    0) #退出#
        ;;
    1)
        ufwinstall
        ./init.sh 3

        ;;
    2)
        ufwdel
        ./init.sh 3
        ;;

    4)
        ufwstatus
        ./init.sh 3
        ;;
    5)
        ufwadd
        ./init.sh 3
        ;;
    6)
        ufwclose
        ./init.sh 3
        ;;
    7)
        installfail2ban
        ./init.sh 3
        ;;
    8)
        sudo fail2ban-client status sshd
        ./init.sh 3
        ;;
    9)
        sudo lastb | grep root | awk '{print $3}' | sort | uniq
        ./init.sh 3
        ;;
    10)
        netstat -na | grep ESTABLISHED | awk '{print$5}' | awk -F : '{print$1}' | sort | uniq -c | sort -r
        ./init.sh 3
        ;;
    99)
        ./init.sh
        ;;
    *)
        inputerror

        ;;
    esac

}

sysset() {

    menutop
    echo "1:换源    2:同步时间      3:support Chinese 中文显示"
    next
    echo "4:密码秘钥root登录         5. 秘钥root登录   "
    next
    echo "6.生成ssh公钥             7.写入ssh公钥    "
    next
    echo "8.查看本机authorized_keys                  "
    next
    echo "9:系统信息                10:磁盘信息     "
    next
    echo "11:计划任务crontab        12:开机启动的服务"
    menubottom

    case $number in
    0) #退出#
        ;;
    1)
        huanyuanfun
        ;;
    2)
        synchronization_time
        ;;
    3)
        supportcn

        ;;
    4)
        openroot
        ;;
    5)
        sshpubonly
        ;;
    6)
        sshgetpub

        ;;
    7)

        sshsetpub

        ./init.sh 4
        ;;
    8)

        cat /root/.ssh/authorized_keys
        ./init.sh 4
        ;;

    9)
        sysinfo
        

        ;;
    10)
        diskinfo
        ./init.sh 4
        ;;
    11)
        crontab -e
        service cron reload
        ./init.sh 4
        ;;

    12)
        systemctl list-unit-files | grep enabled
        ;;
    99)
        ./init.sh
        ;;
    *)
        inputerror

        ;;
    esac

}

dockermain() {
    menutop

    echo "1:安装docker            2:查看docker镜像     "
    next
    echo "3:查看正在运行的容器     4: 查看所有的容器"
    next
    echo "5:后台运行一个容器       6:运行一个终端交互容器       8: 进入交互式容器"
    next
    echo "9:开启一个容器           10:停止一个容器             11:删除一个容器         "
    
    menubottom

    case $number in
    0) #退出#
        ;;
    1)
        apt install docker -y
        ;;
    2)

        docker images

        ./init.sh 5
        ;;
    3)
        docker ps
        ./init.sh 5
        ;;
    4)
        docker ps -a
        ./init.sh 5
        ;;
    5)
        dockerrund
        ./init.sh 5
        ;;
    6)
        dockerrunit
        ./init.sh 5
        ;;
    7) ;;

    8)
        dockerexec
        ;;
    9)
        opencon
        ./init.sh 5
        ;;
    10)
        stopcon
        ./init.sh 5
        ;;
    11)
        rmcon
        ./init.sh 5
        ;;
    12) ;;

    99)
        ./init.sh
        ;;
    *)
        inputerror

        ;;
    esac

}

#主菜单 main 主程序开始
number="$1"

if [[ "$number" = "" ]]; then

    menutop

    echo "1:软件      2:网络     3:ufw防火墙&安全"
    next
    echo "4:系统      5:docker"
    next
    echo "66:脚本升级 "
    next
    echo "0: exit 退出"
    echo ""

    read -p "Please enter the command number 请输入命令数字: " number
fi

case $number in
0) #退出#
    ;;
1)
    menuname='主页/软件'
    software
    ;;
2)
    menuname='主页/网络'
    networktools
    ;;
3)
    menuname='主页/防火墙安全'
    ufwsafe
    ;;
4)
    menuname='主页/系统'
    sysset
    ;;
5)
    menuname='主页/docker'
    dockermain
    ;;

66)
    wget -N http://raw.githubusercontent.com/sshpc/initsh/main/init.sh && chmod +x init.sh && sudo ./init.sh
    ;;
*)
    inputerror

    ;;
esac
