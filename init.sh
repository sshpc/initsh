#!/bin/bash
export LANG=en_US.UTF-8
#字体颜色定义
_red() {
    printf '\033[0;31;31m%b\033[0m' "$1"
    echo
}
_green() {
    printf '\033[0;31;32m%b\033[0m' "$1"
    echo
}
_yellow() {
    printf '\033[0;31;33m%b\033[0m' "$1"
    echo
}
_blue() {
    printf '\033[0;31;36m%b\033[0m' "$1"
    echo
}
#介绍
sinfo() {
    _green '# Ubuntu初始化&工具脚本'
    _green '# Author:SSHPC <https://github.com/sshpc>'
}
#时间变量：
datevar=$(date)
#版本
version='23.7.1'
#菜单名称(默认主页)
menuname='主页'
#分割线
next() {
    printf "%-50s\n" "-" | sed 's/\s/-/g'
}
#等待
waitinput() {
    echo
    read -n1 -r -p "按任意键继续...(退出 Ctrl+C)"
}
#菜单头部
menutop() {
    which init.sh > /dev/null 2>&1
    if [ $? == 0 ]; then
        clear
    fi
    sinfo
    echo
    _blue ">~~~~~~~~~~~~~~ Ubuntu tools 脚本工具 ~~~~~~~~~~~~<  版本:v$version"
    echo
    _yellow "当前菜单: $menuname "
    echo
}
#二级菜单底部
menubottom() {
    echo
    next
    echo
    _blue "0: 退出    99: 返回主页"
    echo
    read -p "请输入命令数字: " number
}
#输入有误
inputerror() {
    echo
    _yellow '>~~~~~~~~~~~~~~~输入有误,脚本终止~~~~~~~~~~~~~~~~~<'
    echo
    exit
}
#安装脚本
selfinstall() {
    menutop
    echo
    _blue '  ________       '
    _blue ' |\   ____\      '
    _blue ' \ \  \___|_     '
    _blue '  \ \_____  \    '
    _blue '   \|____|\  \   '
    _blue '     ____\_\  \  '
    _blue '    |\_________\ '
    _blue '    \|_________| '
    echo
    echo
    _blue "welcome !"
    echo
    echo
    read -n1 -r -p "脚本安装 (按任意键继续) ..."
    _yellow '检查系统环境..'
    which s
    if [ $? == 1 ]; then
        _blue '开始安装脚本'
        cp -f "$(pwd)/init.sh" /bin/init.sh
        ln -s /bin/init.sh /bin/s
        _blue '安装完成'
        menuname='主页'
        echo
        _blue "你可以在任意位置使用命令 's' 运行"
        echo
        waitinput
    else
        _red '系统已存在s程序,停止安装,请检查!'
        exit
    fi
}
selfuninstall() {
    _blue '开始卸载脚本'
    rm -rf /bin/init.sh
    rm -rf /bin/s
    _blue '卸载完成'
}
#脚本升级
updateself(){
    selfuninstall
    _blue '拉取最新版'
    wget -N http://raw.githubusercontent.com/sshpc/initsh/main/init.sh && chmod +x init.sh && ./init.sh
}
#更新所有已安装的软件包
aptupdatefun() {
    echo "更新所有已安装的软件包"
    apt-get update -y && apt-get install curl -y
    echo "更新完成"
}
#开始卸载
uninstallstart() {
    echo
    _red "开始卸载 $1"
    echo "服务关闭"
    service $1 stop
    systemctl stop $1
    echo
}
#结束卸载
uninstallend() {
    next
    echo
    echo "卸载完成"
    echo
}
#安装常用包
installcomso() {
    echo "开始异步安装.."
    install_package() {
        package_name=$1
        echo "开始安装 $package_name"
        apt install $package_name -y
        echo "$package_name 安装完成"
    }
    packages=(
        "curl"
        "net-tools"
        "vim"
        "openssh-server"
        "screen"
        "git"
        "nmap"
        "iperf"
        "zip"
    )
    for package in "${packages[@]}"; do
        package_name="${package%:*}"
        install_package "$package_name" &
    done
    wait
    echo "所有包都已安装完成"
}
removephp() {
    uninstallstart php
    apt remove php -y
    apt-get --purge remove php -y
    apt-get --purge remove php-* -y
    apt-get autoremove php -y
    echo
    echo "删除所有包含php的文件"
    rm -rf /etc/php
    rm -rf /etc/init.d/php
    find /etc -name *php* -print0 | xargs -0 rm -rf
    echo "清除dept列表"
    apt purge $(dpkg -l | grep php | awk '{print $2}' | tr "\n" " ")
    uninstallend
}
removenginx() {
    uninstallstart nginx
    apt remove nginx -y
    apt-get --purge remove nginx -y
    apt-get --purge remove nginx-common -y
    apt-get --purge remove nginx-core -y
    echo
    echo "删除所有包含nginx的文件"
    find / -name nginx* -print0 | xargs -0 rm -rf
    uninstallend
}
removeapache() {
    uninstallstart apache2
    apt remove apache2 -y
    apt-get --purge remove apache2 -y
    apt-get --purge remove apache2-common -y
    apt-get --purge remove apache2-utils -y
    apt-get autoremove apache2
    echo
    echo "删除所有包含apache的文件"
    rm -rf /etc/apache2
    rm -rf /etc/init.d/apache2
    find / -name apache2* -print0 | xargs -0 rm -rf
    uninstallend
}
removedocker() {
    docker kill $(docker ps -a -q)
    docker rm $(docker ps -a -q)
    docker rmi $(docker images -q)
    uninstallstart docker
    apt-get autoremove docker docker-ce docker-engine docker.io containerd runc
    dpkg -l | grep docker
    apt-get autoremove docker-ce-*
    rm -rf /etc/systemd/system/docker.service.d
    rm -rf /var/lib/docker
    rm -rf /etc/docker
    rm -rf /run/docker
    rm -rf /var/lib/dockershim
    umount /var/lib/docker/devicemapper
    uninstallend
}
removev2() {
    uninstallstart v2ray
    update-rc.d -f v2ray remove
    rm -rf /etc/v2ray/*
    rm -rf /usr/bin/v2ray/*
    rm -rf /var/log/v2ray/*
    rm -rf /lib/systemd/system/v2ray.service
    rm -rf /etc/init.d/v2ray
    uninstallend
}
removemysql() {
    uninstallstart mysql-server
    apt-get autoremove --purge mysql-server -y
    apt-get remove mysql-common -y
    apt-get remove dbconfig-mysql -y
    apt-get remove mysql-client -y
    apt-get remove mysql-client-5.7 -y
    apt-get remove mysql-client-core-5.7 -y
    apt-get remove apparmor -y
    apt-get autoremove mysql* --purge -y
    dpkg -l | grep ^rc | awk '{print $2}' | xargs dpkg -P
    rm /var/lib/mysql/ -R
    rm /etc/mysql/ -R
    uninstallend
}
ufwinstall() {
    apt install ufw -y
    echo "ufw 已安装"
    echo "请输入y以开启ufw"
    ufw enable
    echo "ufw已开启"
    ufw allow 22
    echo "已配置允许 22 端口"
    ufw default deny
    echo "已配置关闭所有外部对本机的访问"
    ufwstatus
}
ufwadd() {
    read -p "请输入端口号 (0-65535): " port
    until [[ -z "$port" || "$port" =~ ^[0-9]+$ && "$port" -le 65535 ]]; do
        echo "$port: 无效端口."
        read -p "请输入端口号 (0-65535): " port
    done
    ufw allow $port
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
    ufw delete allow $unport
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
    rm /etc/fail2ban/jail.d/sshd.local
    echo "[ssh-iptables]" >>/etc/fail2ban/jail.d/sshd.local
    echo "enabled  = true" >>/etc/fail2ban/jail.d/sshd.local
    echo "filter   = sshd" >>/etc/fail2ban/jail.d/sshd.local
    echo "action   = iptables[name=SSH, port=ssh, protocol=tcp]" >>/etc/fail2ban/jail.d/sshd.local
    echo "logpath  = /var/log/auth.log" >>/etc/fail2ban/jail.d/sshd.local
    echo "maxretry = $retry" >>/etc/fail2ban/jail.d/sshd.local
    echo "bantime  = $timeban" >>/etc/fail2ban/jail.d/sshd.local
    service fail2ban start
    echo "服务已开启"
    echo
    echo "----服务状态----"
    fail2ban-client status sshd
}
huanyuanfun() {
    a1804() {
        echo "deb http://mirrors.aliyun.com/ubuntu/ bionic main restricted universe multiverse" >>/etc/apt/sources.list
        echo "deb-src http://mirrors.aliyun.com/ubuntu/ bionic main restricted universe multiverse" >>/etc/apt/sources.list
        echo "deb http://mirrors.aliyun.com/ubuntu/ bionic-security main restricted universe multiverse" >>/etc/apt/sources.list
        echo "deb-src http://mirrors.aliyun.com/ubuntu/ bionic-security main restricted universe multiverse" >>/etc/apt/sources.list
        echo "deb http://mirrors.aliyun.com/ubuntu/ bionic-updates main restricted universe multiverse" >>/etc/apt/sources.list
        echo "deb-src http://mirrors.aliyun.com/ubuntu/ bionic-updates main restricted universe multiverse" >>/etc/apt/sources.list
        echo "deb http://mirrors.aliyun.com/ubuntu/ bionic-backports main restricted universe multiverse" >>/etc/apt/sources.list
        echo "deb-src http://mirrors.aliyun.com/ubuntu/ bionic-backports main restricted universe multiverse" >>/etc/apt/sources.list
    }
    a2004() {
        echo "deb http://mirrors.aliyun.com/ubuntu/ focal main restricted universe multiverse" >>/etc/apt/sources.list
        echo "deb-src http://mirrors.aliyun.com/ubuntu/ focal main restricted universe multiverse" >>/etc/apt/sources.list
        echo "deb http://mirrors.aliyun.com/ubuntu/ focal-security main restricted universe multiverse" >>/etc/apt/sources.list
        echo "deb-src http://mirrors.aliyun.com/ubuntu/ focal-security main restricted universe multiverse" >>/etc/apt/sources.list
        echo "deb http://mirrors.aliyun.com/ubuntu/ focal-updates main restricted universe multiverse" >>/etc/apt/sources.list
        echo "deb-src http://mirrors.aliyun.com/ubuntu/ focal-updates main restricted universe multiverse" >>/etc/apt/sources.list
        echo "deb http://mirrors.aliyun.com/ubuntu/ focal-backports main restricted universe multiverse" >>/etc/apt/sources.list
        echo "deb-src http://mirrors.aliyun.com/ubuntu/ focal-backports main restricted universe multiverse" >>/etc/apt/sources.list
    }
    a2204() {
        echo "deb http://mirrors.aliyun.com/ubuntu/ jammy main restricted universe multiverse" >>/etc/apt/sources.list
        echo "deb-src http://mirrors.aliyun.com/ubuntu/ jammy main restricted universe multiverse" >>/etc/apt/sources.list
        echo "deb http://mirrors.aliyun.com/ubuntu/ jammy-security main restricted universe multiverse" >>/etc/apt/sources.list
        echo "deb-src http://mirrors.aliyun.com/ubuntu/ jammy-security main restricted universe multiverse" >>/etc/apt/sources.list
        echo "deb http://mirrors.aliyun.com/ubuntu/ jammy-updates main restricted universe multiverse" >>/etc/apt/sources.list
        echo "deb-src http://mirrors.aliyun.com/ubuntu/ jammy-updates main restricted universe multiverse" >>/etc/apt/sources.list
        echo "deb http://mirrors.aliyun.com/ubuntu/ jammy-proposed main restricted universe multiverse" >>/etc/apt/sources.list
        echo "deb-src http://mirrors.aliyun.com/ubuntu/ jammy-proposed main restricted universe multiverse" >>/etc/apt/sources.list
        echo "deb http://mirrors.aliyun.com/ubuntu/ jammy-backports main restricted universe multiverse" >>/etc/apt/sources.list
        echo "deb-src http://mirrors.aliyun.com/ubuntu/ jammy-backports main restricted universe multiverse" >>/etc/apt/sources.list
    }
    menutop
    echo "检测你的系统版本为:"
    lsb_release -a
    echo "选择你的Ubuntu版本(其他版本请手动换源)"
    echo "1:Ubuntu 18.04(bionic)    2:Ubuntu 20.04(focal)  3:Ubuntu 22.04(jammy)"
    read -p "请输入命令数字: " sourcesnumber
    echo "开始备份原列表"
    cp /etc/apt/sources.list /etc/apt/sources.list.bak."$datevar"
    echo "原source list已全量备份至 /etc/apt/sources.list.bak.$datevar"
    rm /etc/apt/sources.list
    echo "开始写入阿里源$sourcesnumber"
    case $sourcesnumber in
    1)
        a1804
        echo "source list已经写入阿里云源."
        ;;
    2)
        a2004
        echo "source list已经写入阿里云源."
        ;;
    3)
        a2204
        echo "source list已经写入阿里云源."
        ;;
    *)
        inputerror
        exit
        ;;
    esac
}
synchronization_time() {
    echo "同步前的时间: $(date -R)"
    echo "同步为上海时间?"
    waitinput
    cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
    timedatectl set-timezone Asia/Shanghai
    timedatectl set-local-rtc 0
    timedatectl set-ntp yes
    hwclock -w
    systemctl restart rsyslog.service cron.service
    echo "当前系统时间: $(date -R)"
}
openroot() {
    echo "确保root远程权限未开"
    read -n1 -p "Do you want to continue [Y/N]? " answer
    case $answer in
    Y | y)
        echo
        echo "开始备份原文件sshd_config"
        cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak."$datevar"
        echo "原文件sshd_config已备份."
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
    cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak."$datevar"
    echo "原文件sshd_config已备份."
    echo "port 22" >>/etc/ssh/sshd_config
    echo "PermitRootLogin yes" >>/etc/ssh/sshd_config
    echo "PasswordAuthentication no" >>/etc/ssh/sshd_config
    echo "重启服务中"
    service sshd restart
    echo "ok"
}
#tty中文支持
supportcn() {
    echo
    apt-get install zhcon -y
    adduser $(whoami) video
    zhcon --utf8
    echo
    echo "Please enter 'zhcon --utf8' "
}
#生成ssh密钥对
sshgetpub() {
    echo "输完3次回车"
    read -p "请输入email: " email
    ssh-keygen -t ed25519 -C "$email"
    echo
    echo "ssh秘钥钥生成成功"
    echo
    echo "公钥："
    cat ~/.ssh/id_ed25519.pub
}
#写入其他ssh公钥
sshsetpub() {
    echo "请填入ssh公钥"
    read -p "请粘贴至命令行回车: " sshpub
    echo -e $sshpub >>/root/.ssh/authorized_keys
    echo
    echo "ssh公钥写入成功"
    echo
}
#系统信息
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
    echo
}
diskinfo() {
    echo "\n分区信息:"
    df -Th
    lsblk
    echo -e "\n 磁盘信息:"
    fdisk -l
    echo -e "\n PV物理卷查看:"
    pvscan
    echo -e "\n vgs虚拟卷查看:"
    vgs
    echo -e "\n lvscan逻辑卷扫描:"
    lvscan
    echo -e "\n 分区扩展"
    echo "Ubuntu \n lvextend -L +74G /dev/ubuntu-vg/ubuntu-lv"
    echo "lsblk"
    echo -e "ubuntu general \n # resize2fs -p -F /dev/mapper/ubuntu--vg-ubuntu--lv"
    echo "文件系统信息:"
    more /etc/fstab | grep -v "^#" | grep -v "^$"
    echo
}
#
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
    cp /etc/netplan/00-installer-config.yaml /etc/netplan/00-installer-config.yaml.bak."$datevar"
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
    echo "提示:x.x.x.x"
    read -p "请输入主DNS: " nameservers
    until [[ "$nameservers" ]]; do
        echo "$nameservers: DNS不能为空."
        read -p "请输入主DNS: " nameservers
    done
    echo "DNS地址为:$nameservers "
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
             addresses: [$nameservers]
EOM
    echo "配置信息成功写入,成功切换ip 、ssh已断开,请使用设置的ip:$ipaddresses 重新登录"
    netplan apply
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
    echo "DHCP已开启"
}
netinfo() {
    echo
    echo "---------本地IP信息-------------"
    ifconfig -a
    echo "---------公网ip信息-----------------"
    curl cip.cc
    echo
}
netfast() {
    echo
    echo "检查安装测速工具"
    apt install speedtest-cli -y
    echo "开始测速"
    speedtest-cli
    echo "测速完成"
    echo
}
dockerrund() {
    echo
    docker images
    echo
    read -p "请输入镜像包名或idREPOSITORY: " dcimage
    read -p "请输入容器端口: " conport
    read -p "请输入宿主机端口: " muport
    read -p "请输入执行参数: " param
    docker run -d -p $muport:$conport $dcimage $param
    echo "$dcimage 已在后台运行中"
}
dockerrunit() {
    echo
    docker images
    echo
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
    echo
    docker ps
    echo
    read -p "请输入容器名或id: " containerd
    read -p "请输入执行参数(默认/bin/bash): " param
    if [[ "$param" = "" ]]; then
        param="/bin/bash"
    fi
    docker exec -it $containerd $param
}
opencon() {
    echo
    docker ps -a
    echo
    read -p "请输入容器名或id: " containerd
    docker start $containerd
    echo
    echo "正在运行的容器 "
    docker ps
}
stopcon() {
    echo
    docker ps
    echo
    read -p "请输入容器名或id: " containerd
    docker stop $containerd
    echo "正在运行的容器 "
    docker ps
}
rmcon() {
    echo
    docker ps -a
    echo
    read -p "请输入容器名或id: " containerd
    docker rm -f $containerd
    echo "所有容器 "
    docker ps -a
}
systemcheck() {
    echo "僵尸进程:"
    ps -ef | grep zombie | grep -v grep
    if [ $? == 1 ]; then
        echo ">>>无僵尸进程"
    else
        echo ">>>有僵尸进程------warning"
    fi
    next
    echo "耗CPU最多的进程:"
    ps auxf | sort -nr -k 3 | head -5
    next
    echo "耗内存最多的进程:"
    ps auxf | sort -nr -k 4 | head -5
    next
    echo "环境变量:"
    env
    next
    echo "监听端口:"
    netstat -tunlp
    next
    echo "当前建立的连接:"
    netstat -n | awk '/^tcp/ {++S[$NF]} END {for(a in S) print a, S[a]}'
    next
    echo "开机启动的服务:"
    systemctl list-unit-files | grep enabled
    echo
    echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>系统用户情况<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<"
    echo "活动用户:"
    w | tail -n +2
    next
    echo "系统所有用户:"
    cut -d: -f1,2,3,4 /etc/passwd
    next
    echo "系统所有组:"
    cut -d: -f1,2,3 /etc/group
    echo
    echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>身份鉴别安全<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<"
    more /etc/login.defs | grep -E "PASS_MAX_DAYS" | grep -v "#" | awk -F' ' '{if($2!=90){print ">>>密码过期天数是"$2"天,请管理员改成90天------warning"}}'
    next
    grep -i "^auth.*required.*pam_tally2.so.*$" /etc/pam.d/sshd >/dev/null
    if [ $? == 0 ]; then
        echo ">>>登入失败处理:已开启"
    else
        echo ">>>登入失败处理:未开启,请加固登入失败锁定功能----------warning"
    fi
    echo
    echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>访问控制安全<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<"
    echo "系统中存在以下非系统默认用户:"
    more /etc/passwd | awk -F ":" '{if($3>500){print ">>>/etc/passwd里面的"$1 "的UID为"$3",该账户非系统默认账户,请管理员确认是否为可疑账户--------warning"}}'
    next
    echo "系统特权用户:"
    awk -F: '$3==0 {print $1}' /etc/passwd
    next
    echo "系统中空口令账户:"
    awk -F: '($2=="!!") {print $1"该账户为空口令账户,请管理员确认是否为新增账户,如果为新建账户,请配置密码-------warning"}' /etc/shadow
    echo
    echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>安全审计<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<"
    echo "正常情况下登录到本机30天内的所有用户的历史记录:"
    last | head -n 30
    next
    echo "查看syslog日志审计服务是否开启:"
    if service rsyslog status | egrep " active \(running"; then
        echo ">>>经分析,syslog服务已开启"
    else
        echo ">>>经分析,syslog服务未开启,建议通过service rsyslog start开启日志审计功能---------warning"
    fi
    next
    echo "查看syslog日志是否开启外发:"
    if more /etc/rsyslog.conf | egrep "@...\.|@..\.|@.\.|\*.\* @...\.|\*\.\* @..\.|\*\.\* @.\."; then
        echo ">>>经分析,客户端syslog日志已开启外发--------warning"
    else
        echo ">>>经分析,客户端syslog日志未开启外发---------ok"
    fi
    next
    echo "审计的要素和审计日志:"
    more /etc/rsyslog.conf | grep -v "^[$|#]" | grep -v "^$"
    next
    echo "系统中关键文件修改时间:"
    ls -ltr /bin/ls /bin/login /etc/passwd /bin/ps /etc/shadow | awk '{print ">>>文件名："$9"  ""最后修改时间："$6" "$7" "$8}'
    next
    echo "检查重要日志文件是否存在:"
    log_secure=/var/log/secure
    log_messages=/var/log/messages
    log_cron=/var/log/cron
    log_boot=/var/log/boot.log
    log_dmesg=/var/log/dmesg
    if [ -e "$log_secure" ]; then
        echo ">>>/var/log/secure日志文件存在"
    else
        echo ">>>/var/log/secure日志文件不存在------warning"
    fi
    if [ -e "$log_messages" ]; then
        echo ">>>/var/log/messages日志文件存在"
    else
        echo ">>>/var/log/messages日志文件不存在------warning"
    fi
    if [ -e "$log_cron" ]; then
        echo ">>>/var/log/cron日志文件存在"
    else
        echo ">>>/var/log/cron日志文件不存在--------warning"
    fi
    if [ -e "$log_boot" ]; then
        echo ">>>/var/log/boot.log日志文件存在"
    else
        echo ">>>/var/log/boot.log日志文件不存在--------warning"
    fi
    if [ -e "$log_dmesg" ]; then
        echo ">>>/var/log/dmesg日志文件存在"
    else
        echo ">>>/var/log/dmesg日志文件不存在--------warning"
    fi
    echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>入侵防范安全<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<"
    echo "系统入侵行为:"
    more /var/log/secure | grep refused
    if [ $? == 0 ]; then
        echo "有入侵行为,请分析处理--------warning"
    else
        echo ">>>无入侵行为"
    fi
    next
    echo "用户错误登入列表:"
    lastb | head >/dev/null
    if [ $? == 1 ]; then
        echo ">>>无用户错误登入列表"
    else
        echo ">>>用户错误登入--------warning"
        lastb | head
    fi
    next
    echo "ssh暴力登入信息:"
    more /var/log/secure | grep "Failed" >/dev/null
    if [ $? == 1 ]; then
        echo ">>>无ssh暴力登入信息"
    else
        more /var/log/secure | awk '/Failed/{print $(NF-3)}' | sort | uniq -c | awk '{print ">>>登入失败的IP和尝试次数: "$2"="$1"次---------warning";}'
    fi
    echo
    echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>资源控制安全<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<"
    echo "查看是否开启了ssh服务:"
    if service sshd status | grep -E "listening on|active \(running\)"; then
        echo ">>>SSH服务已开启"
    else
        echo ">>>SSH服务未开启--------warning"
    fi
    next
    echo "查看是否开启了Telnet-Server服务:"
    if more /etc/xinetd.d/telnetd 2>&1 | grep -E "disable=no"; then
        echo ">>>Telnet-Server服务已开启"
    else
        echo ">>>Telnet-Server服务未开启--------ok"
    fi
    next
    ps axu | grep iptables | grep -v grep || ps axu | grep firewalld | grep -v grep
    if [ $? == 0 ]; then
        echo ">>>防火墙已启用--------ok"
        iptables -nvL --line-numbers
    else
        echo ">>>防火墙未启用--------warning"
    fi
    next
    echo "查看系统SSH远程访问设置策略(host.deny拒绝列表):"
    if more /etc/hosts.deny | grep -E "sshd"; then
        echo ">>>远程访问策略已设置--------warning"
    else
        echo ">>>远程访问策略未设置--------ok"
    fi
    next
    echo "查看系统SSH远程访问设置策略(hosts.allow允许列表):"
    if more /etc/hosts.allow | grep -E "sshd"; then
        echo ">>>远程访问策略已设置--------warning"
    else
        echo ">>>远程访问策略未设置--------ok"
    fi
}
cputest() {
    echo "检查安装stress"
    apt install stress -y
    echo "默认单核60s测速 手动测试命令: stress -c 2 -t 100  #2代表核数 测试时间100s"
    waitinput
    stress -c 1 -t 60
}
iotestspeed() {
    #io测试
    io_test() {
        (LANG=C dd if=/dev/zero of=benchtest_$$ bs=512k count=$1 conv=fdatasync && rm -f benchtest_$$) 2>&1 | awk -F, '{io=$NF} END { print io}' | sed 's/^[ \t]*//;s/[ \t]*$//'
    }
    _blue "正在进行磁盘测速..."
    echo
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
countfileslines() {
    echo
    _yellow '目前仅支持单一文件后缀搜索!'
    read -p "请输入绝对路径 ./(默认当前目录) /.../..  : " abpath
    if [[ "$abpath" = "" ]]; then
        abpath='./'
    fi
    read -p "请输入要搜索的文件后缀: sh(默认) php  html ...  : " suffix
    if [[ "$suffix" = "" ]]; then
        suffix='sh'
    fi
    # 使用 find 命令递归地查找指定目录下的所有文件,并执行计算行数的命令
    total=$(find $abpath -type f -name "*.$suffix" -exec wc -l {} \; | awk '{total += $1} END{print total}')
    # 输出总行数
    echo "$abpath 目录下的 后缀为 $suffix 文件的总行数是: $total"
}
#二级菜单
#软件
software() {
    menutop
    echo
    echo "1:更新源            2:安装常用软件   "
    echo
    echo "3:安装xray八合一    4:安装x-ui  "
    echo
    _red "5:卸载nginx        6:卸载Apache    "
    echo
    _red "7:卸载php          8:卸载docker "
    echo
    _red "9:卸载v2ray        10:卸载mysql  "
    echo
    menubottom
    case $number in
    0)
        exit
        ;;
    1)
        aptupdatefun
        waitinput
        s 1
        ;;
    2)
        installcomso
        waitinput
        s 1
        ;;
    3)
        wget -P /root -N --no-check-certificate "https://raw.githubusercontent.com/mack-a/v2ray-agent/master/install.sh" && chmod 700 /root/install.sh && /root/install.sh
        vasma
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
    99)
        s
        ;;
    *)
        inputerror
        ;;
    esac
}
#网络
networktools() {
    menutop
    echo
    echo "1:配置本机网卡静态ip    2:启用dhcp动态获取"
    echo
    echo "3:网络信息             4.网络测速 (外网speednet)  "
    echo
    echo "5:路由表               6:查看监听端口     "
    echo
    echo "7:SpeedCLI 外网测速 "
    echo
    echo "11:开启ufw             12:关闭ufw   "
    echo
    echo "14:ufw状态             15: 添加ufw端口  "
    echo
    echo "16:关闭ufw端口         17:配置fail2ban "
    echo
    echo "18:fail2ban状态       19:ssh爆破记录  "
    echo
    echo "20:各IP地址连接数       "
    menubottom
    case $number in
    0)
        exit
        ;;
    1)
        staticip
        ;;
    2)
        dhcpip
        ;;
    3)
        netinfo
        waitinput
        s 2
        ;;
    4)
        netfast
        ;;
    5)
        route -n
        waitinput
        s 2
        ;;
    6)
        netstat -tunlp
        waitinput
        s 2
        ;;
    7)
        curl -fsSL git.io/speedtest-cli.sh | sudo bash
        speedtest
        waitinput
        s 2
        ;;
    11)
        ufwinstall
        ;;
    12)
        ufw disable
        echo "ufw已关闭"
        ufwstatus
        ;;
    14)
        ufwstatus
        ;;
    15)
        ufwadd
        ;;
    16)
        ufwclose
        ;;
    17)
        installfail2ban
        ;;
    18)
        fail2ban-client status sshd
        ;;
    19)
        lastb | grep root | awk '{print $3}' | sort | uniq
        ;;
    20)
        echo
        echo '   数量 ip'
        netstat -na | grep ESTABLISHED | awk '{print$5}' | awk -F : '{print$1}' | sort | uniq -c | sort -r
        echo
        waitinput
        s 2
        ;;
    99)
        s
        ;;
    *)
        inputerror
        ;;
    esac
}

#系统
sysset() {
    menutop
    echo
    echo "1:换阿里源                 2:同步时间             3:命令行中文支持"
    echo
    echo "4:密码和密钥root登录       5. 仅密钥root登录(推荐)   "
    echo
    echo "6.生成ssh密钥对            7.写入ssh公钥(常用)    "
    echo
    echo "8.查看本机authorized_keys     "
    echo
    echo
    echo "9:系统信息                10:磁盘信息     "
    echo
    echo "11:计划任务crontab        12:开机启动的服务"
    echo
    echo "13:系统检查               14:cpu压力测试  "
    echo
    echo "15:磁盘测速              "
    menubottom
    case $number in
    0)
        exit
        ;;
    1)
        menuname='主页/系统/换阿里源'
        huanyuanfun
        aptupdatefun
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
        s 3
        waitinput
        ;;
    8)
        cat /root/.ssh/authorized_keys
        waitinput
        s 3
        ;;
    9)
        sysinfo
        ;;
    10)
        diskinfo
        waitinput
        s 3
        ;;
    11)
        crontab -e
        service cron reload
        waitinput
        s 3
        ;;
    12)
        systemctl list-unit-files | grep enabled
        ;;
    13)
        systemcheck
        ;;
    14)
        cputest
        ;;
    15)
        iotestspeed
        ;;
    99)
        s
        ;;
    *)
        inputerror
        ;;
    esac
}
#docker
dockermain() {
    menutop
    echo
    echo "1:安装docker            2:查看docker镜像     "
    echo
    echo "3:查看正在运行的容器     4: 查看所有的容器"
    echo
    echo "5:后台运行一个容器       6:运行一个终端交互容器 "
    echo
    echo "8: 进入交互式容器       9:开启一个容器    "
    echo
    echo "10:停止一个容器         11:删除一个容器"
    menubottom
    case $number in
    0)
        exit
        ;;
    1)
        apt install docker -y
        ;;
    2)
        docker images
        ;;
    3)
        docker ps
        ;;
    4)
        docker ps -a
        ;;
    5)
        dockerrund
        ;;
    6)
        dockerrunit
        ;;
    8)
        dockerexec
        ;;
    9)
        opencon
        ;;
    10)
        stopcon
        ;;
    11)
        rmcon
        ;;
    99)
        s
        ;;
    *)
        inputerror
        ;;
    esac
    waitinput
    s 3
}
#其他工具
ordertools() {
    menutop
    echo
    echo "1:统计目录文件行数"
    menubottom
    case $number in
    0)
        exit
        ;;
    1)
        countfileslines
        ;;
    99)
        s
        ;;
    *)
        inputerror
        ;;
    esac
    waitinput
    s 6
}
clear
#检查脚本是否已安装(/bin/init.sh存在?)
which init.sh > /dev/null 2>&1
if [ $? == 1 ]; then
    menuname='开箱页面'
    selfinstall
fi

#主菜单 main 主程序开始
number="$1"
if [[ "$number" = "" ]]; then
    
    menutop
    
    echo "1:软件         2:网络        3:系统 "
    echo
    echo "4:docker       5:其他工具"
    echo
    echo "666:脚本升级   777:脚本卸载"
    echo
    echo "0: 退出"
    echo 
    read -p "请输入命令数字: " number
fi
case $number in
0)
    exit
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
    menuname='主页/系统'
    sysset
    ;;
4)
    menuname='主页/docker'
    dockermain
    ;;
5)
    menuname='主页/其他工具'
    ordertools
    ;;
666)
    updateself
    
    ;;
777)
    menuname='脚本卸载'
    selfuninstall
    ;;
*)
    inputerror
    ;;
esac
