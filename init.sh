#!/bin/bash
export LANG=en_US.UTF-8
#全局变量
glovar() {
    version='0.2.1'
    datevar=$(date +%y%m%d%H%M%S)
    #菜单名称(默认主页)
    menuname='主页'
    #父级函数名
    parentfun=''
}
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
#分割线
next() {
    printf "%-50s\n" "-" | sed 's/\s/-/g'
}
#字符跳动
jumpfun() {
    my_string=$1
    # 循环输出每个字符
    for ((i = 0; i < ${#my_string}; i++)); do
        printf '\033[0;31;36m%b\033[0m' "${my_string:$i:1}"
        sleep 0.1
    done
    echo
}
#网卡获取
getnetcard() {
    # 获取系统中可用的网卡名称
    interfaces=$(ifconfig -a | sed -nE 's/^([^[:space:]]+).*$/\1/p')

    # 输出供用户选择的网卡名称列表
    PS3="请选择网卡名称： "
    select interface in $interfaces; do
        if [[ -n "$interface" ]]; then
            break
        fi
    done
    # 去掉网卡名称后面的冒号，并输出用户选择的网卡名称
    interface=$(echo "$interface" | sed 's/://')
    echo $interface
}
#按任意键继续
waitinput() {
    echo
    read -n1 -r -p "按任意键继续...(退出 Ctrl+C)"
}
#继续执行函数
nextrun() {
    #unset number
    waitinput
    #${parentfun}
    main

}
#菜单头部
menutop() {
    which init.sh >/dev/null 2>&1
    if [ $? == 0 ]; then
        clear
    fi
    _green '# Ubuntu初始化&工具脚本'
    _green '# Author:SSHPC <https://github.com/sshpc>'
    echo
    _blue ">~~~~~~~~~~~~~~ Ubuntu tools 脚本工具 ~~~~~~~~~~~~<  版本:v$version"
    echo
    _yellow "当前菜单: $menuname "
    echo
}
#菜单渲染
menu() {
    menutop
    options=("$@")
    num_options=${#options[@]}
    # 渲染菜单
    for ((i = 0; i < num_options; i += 4)); do
        printf "$((i / 2 + 1)): ${options[i]}           "
        if [[ "${options[i + 2]}" != "" ]]; then printf "$((i / 2 + 2)): ${options[i + 2]}"; fi
        echo
        echo
    done
    echo
    printf '\033[0;31;36m%b\033[0m' "q: 退出  "
    if [[ "$number" != "" ]]; then printf '\033[0;31;36m%b\033[0m' "  0: 返回主页"; fi
    echo
    echo
    # 获取用户输入
    read -ep "请输入命令号: " number
    if [[ $number -ge 1 && $number -le $((num_options / 2)) ]]; then
        #找到函数名索引
        action_index=$((2 * (number - 1) + 1))
        #函数名赋值
        parentfun=${options[action_index]}
        #函数执行
        ${options[action_index]}
    elif [[ $number == 0 ]]; then
        main
    elif [[ $number == 'q' ]]; then
        exit
    else
        _yellow '>~~~~~~~~~~~~~~~输入有误~~~~~~~~~~~~~~~~~<'
    fi

}
#软件
software() {

    #更新所有已安装的软件包
    aptupdatefun() {
        jumpfun "更新所有已安装的软件包"
        apt-get update -y && apt-get install curl -y
        echo "更新完成"
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
            "wget"
            "curl"
            "net-tools"
            "vim"
            "openssh-server"
            "screen"
            "git"
            "zip"
            "htop"
        )
        for package in "${packages[@]}"; do
            package_name="${package%:*}"
            install_package "$package_name" &
        done
        wait
        echo "所有包都已安装完成"
    }
    #安装xray八合一
    installbaheyi() {
        wget -P /root -N --no-check-certificate "https://raw.githubusercontent.com/mack-a/v2ray-agent/master/install.sh" && chmod 700 /root/install.sh && /root/install.sh
        vasma
    }

    #安装xui
    installxui() {
        bash <(curl -Ls https://raw.githubusercontent.com/vaxilu/x-ui/master/install.sh)
    }
    #安装openvpn
    installopenvpn() {
        _blue '即将下载sh脚本到当前目录,安装后记得修改/etc/openvpn/client-template.txt 文件路由规则'
        waitinput
        curl -O https://raw.githubusercontent.com/angristan/openvpn-install/master/openvpn-install.sh && chmod +x openvpn-install.sh && ./openvpn-install.sh
    }

    removefun() {
        #专项卸载
        removephp() {
            masterremove php
        }
        removenginx() {
            apt-get --purge remove nginx-common -y
            apt-get --purge remove nginx-core -y
            masterremove nginx
        }
        removeapache() {
            apt-get --purge remove apache2-common -y
            apt-get --purge remove apache2-utils -y
            masterremove apache2
        }
        removedocker() {
            docker kill $(docker ps -a -q)
            docker rm $(docker ps -a -q)
            docker rmi $(docker images -q)
            apt-get autoremove docker docker-ce docker-engine docker.io containerd runc
            apt-get autoremove docker-ce-*
            rm -rf /etc/systemd/system/docker.service.d
            rm -rf /var/lib/docker
            rm -rf /etc/docker
            rm -rf /run/docker
            rm -rf /var/lib/dockershim
            umount /var/lib/docker/devicemapper
            masterremove docker
        }
        removev2() {
            masterremove v2ray
        }
        removemysql() {
            apt-get remove mysql-common -y
            apt-get remove dbconfig-mysql -y
            apt-get remove mysql-client -y
            apt-get remove mysql-client-5.7 -y
            apt-get remove mysql-client-core-5.7 -y
            apt-get remove apparmor -y
            apt-get autoremove mysql* --purge -y
            masterremove mysql-server
        }
        #彻底卸载
        masterremove() {
            if [ $# -eq 0 ]; then
                resoftname=$1
            else
                read -ep "请输入要卸载的软件名: " resoftname
            fi
            _red "注意：将会删除关于 $resoftname 所有内容"
            waitinput
            _red "开始卸载 $resoftname"
            echo "关闭服务.."
            service $resoftname stop
            systemctl stop $resoftname
            apt remove $resoftname -y
            apt-get --purge remove $resoftname -y
            apt-get --purge remove $resoftname-* -y
            echo "清除dept列表"
            apt purge $(dpkg -l | grep $resoftname | awk '{print $2}' | tr "\n" " ")
            echo "删除 $resoftname 的启动脚本"
            update-rc.d -f $resoftname remove
            echo "删除所有包含 $resoftname 的文件"
            rm -rf /etc/$resoftname
            rm -rf /etc/init.d/$resoftname
            find /etc -name *$resoftname* -print0 | xargs -0 rm -rf
            rm -rf /usr/bin/$resoftname
            rm -rf /var/log/$resoftname
            rm -rf /lib/systemd/system/$resoftname.service
            rm -rf /var/lib/$resoftname
            rm -rf /run/$resoftname
            next
            echo
            _blue "卸载完成"
        }
        menuname='主页/软件/卸载'
        options=("手动输入" masterremove "卸载nginx" removenginx "卸载Apache" removeapache "卸载php" removephp "卸载docker" removedocker "卸载v2ray" removev2 "卸载mysql" removemysql)
        menu "${options[@]}"
    }
    menuname='主页/软件'
    options=("软件更新" aptupdatefun "软件卸载" removefun "安装常用包" installcomso "安装八合一" installbaheyi "安装xui" installxui "安装openvpn" installopenvpn )
    menu "${options[@]}"
}
#网络
networktools() {

    #ufw防火墙
    ufwfun() {
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
            read -ep "请输入端口号 (0-65535): " port
            until [[ -z "$port" || "$port" =~ ^[0-9]+$ && "$port" -le 65535 ]]; do
                echo "$port: 无效端口."
                read -ep "请输入端口号 (0-65535): " port
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
            read -ep "请输入端口号 (0-65535): " unport
            until [[ -z "$unport" || "$unport" =~ ^[0-9]+$ && "$unport" -le 65535 ]]; do
                echo "$unport: 无效端口."
                read -ep "请输入端口号 (0-65535): " unport
            done
            ufw delete allow $unport
            echo "端口 $unport 已关闭"
            ufwstatus
        }
        ufwdisablefun() {
            ufw disable
            echo "ufw已关闭"
            ufwstatus
        }

        menuname='主页/网络/ufw'
        options=("开启ufw" ufwinstall "关闭ufw" ufwdisablefun "ufw状态" ufwstatus "添加端口" ufwadd "关闭端口" ufwclose)
        menu "${options[@]}"

    }

    fail2banfun() {
        installfail2ban() {
            echo "检查并安装fail2ban"
            apt install fail2ban -y
            echo "fail2ban 已安装"
            echo "开始配置fail2ban"
            waitinput
            read -ep "请输入尝试次数 (直接回车默认4次): " retry
            read -ep "请输入拦截后禁止访问的时间 (直接回车默认604800s): " timeban
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
        fail2banstatusfun() {
            fail2ban-client status sshd
        }

        menuname='主页/网络/fail2ban'
        options=("安装配置" installfail2ban "查看状态" fail2banstatusfun)
        menu "${options[@]}"

    }

    staticip() {
        echo "开始备份原文件"
        cp /etc/netplan/00-installer-config.yaml /etc/netplan/00-installer-config.yaml.bak."$datevar"
        #获取网卡名称
        ens=${getnetcard}
        until [[ -z "$ipaddresses"  ]]; do
            read -ep "请输入ip地址+网络号 (x.x.x.x/x): " ipaddresses
        done
        until [[ -z "$gateway" ]]; do
            read -ep "请输入网关(x.x.x.x): " gateway
        done
        until [[ -z "$nameservers" ]]; do
            read -ep "请输入DNS(x.x.x.x): " nameservers
        done
        _red "请仔细检查配置是否正确!"
        echo "网卡为" $ens
        echo "网络地址为:$ipaddresses"
        echo "网关为:$gateway"
        echo "DNS地址为:$nameservers "
        waitinput

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
        echo "配置信息成功写入,成功切换ip 、若ssh断开,请使用设置的ip:$ipaddresses 重新登录"
        netplan apply
        echo "ok"
    }
    dhcpip() {
        echo "开始配置DHCP"
        #获取网卡名称
        ens=${getnetcard}
        _red "请仔细检查配置是否正确!"
        echo "网卡为" $ens
        waitinput
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
        echo "ok"
    }
    netinfo() {
        echo
        jumpfun "本机IP"
        ifconfig -a | grep "inet "
        jumpfun "公网IP"
        curl cip.cc
        jumpfun "路由表"
        route -n
        jumpfun "监听端口"
        netstat -tunlp
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
    iperftest() {

        which iperf3 >/dev/null 2>&1
        if [ $? == 1 ]; then
            echo "iperf3 未安装,正在安装..."
            apt install iperf3 -y
        fi

        iperf3client() {

            until [[ "$serversip" ]]; do
                read -ep "请输入服务器ip: " serversip
            done

            iperf3 -u -c $serversip -b 2000M -t 40
        }

        echo "请选择运行模式  1.服务端  2.客户端"
        until [[ $PROTOCOL_CHOICE =~ ^[1-2]$ ]]; do
            read -rp "Protocol [1-2]: " PROTOCOL_CHOICE
        done
        case $PROTOCOL_CHOICE in
        1)
            _blue '端口默认为 5201'
            iperf3 -s
            ;;
        2)
            iperf3client
            ;;
        esac
    }

    nmapfun() {

        which nmap >/dev/null 2>&1
        if [ $? == 1 ]; then
            echo "nmap 未安装,正在安装..."
            apt install nmap -y
        fi

        nmapdetection() {
            echo '本地网络：'
            ip addr show | grep "inet " | grep -v "127.0.0.1"
            echo

            until [[ -z "$ips" ]]; do
                read -ep "请输入网段x.x.x.x/x: " ips
            done

            nmap -sP $ips
        }
        nmapportcat() {

            until [[ -z "$ip" ]]; do
                read -ep "请输入ip: " ip
            done

            nmap $ip
        }

        echo "1.主机探测  2.端口扫描"
        until [[ $PROTOCOL_CHOICE =~ ^[1-2]$ ]]; do
            read -rp "Protocol [1-2]: " PROTOCOL_CHOICE
        done
        case $PROTOCOL_CHOICE in
        1)
            _blue '扫描网段中有哪些主机在线，本质上是Ping扫描'
            nmapdetection
            ;;
        2)
            _blue '默认扫描1-65535 扫描「指定端口」nmap ip -p 1-2000'
            nmapportcat
            ;;
        esac
    }

    vnstatfun() {
        apt-get install vnstat
        #获取网卡名称
        ens=${getnetcard}
        vnstat -l -i $ens
    }

    #各IP地址连接数
    ipcount() {
        echo
        echo '   数量 ip'
        netstat -na | grep ESTABLISHED | awk '{print$5}' | awk -F : '{print$1}' | sort | uniq -c | sort -r
        echo
    }
    #ssh爆破记录
    sshbaopo() {
        lastb | grep root | awk '{print $3}' | sort | uniq
    }
    #SpeedCLI 测速
    netfast2() {
        curl -fsSL git.io/speedtest-cli.sh | sudo bash
        speedtest
    }
    #三网测速
    sanwang() {
        bash <(curl -Lso- https://down.wangchao.info/sh/superspeed.sh)
    }

    menuname='主页/网络'
    options=("网络信息" netinfo "IP连接数" ipcount "ssh爆破记录" sshbaopo "实时网速" vnstatfun "测速1" netfast "测速2" netfast2 "三网测速" sanwang "iperf3" iperftest "配置本机ip" staticip "启用dhcp" dhcpip "nmap扫描" nmapfun "ufw" ufwfun "fail2ban" fail2banfun)

    menu "${options[@]}"
}

#系统
sysset() {

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
        read -ep "请输入命令数字: " sourcesnumber
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
            _yellow '>~~~~~~~~~~~~~~~输入有误~~~~~~~~~~~~~~~~~<'
            exit
            ;;
        esac
    }
    #同步时间
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
        waitinput
        echo "开始备份原文件sshd_config"
        cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak."$datevar"
        echo "原文件sshd_config已备份."
        echo "port 22" >>/etc/ssh/sshd_config
        echo "PermitRootLogin yes" >>/etc/ssh/sshd_config
        echo "PasswordAuthentication yes" >>/etc/ssh/sshd_config
        echo "重启服务中"
        service sshd restart
        echo "ok"

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
        read -ep "请输入email: " email
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
        read -ep "请粘贴至命令行回车: " sshpub
        echo -e $sshpub >>/root/.ssh/authorized_keys
        echo
        echo "ssh公钥写入成功"
        echo
    }
    #系统信息
    sysinfo() {
        echo
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
        _blue "系统版本:         $version $codename"
        echo "内核版本:         $kernel"
        echo "系统类型:         $platform"
        _green "CPU型号:         $cpumodel"
        echo "CPU核数:          $cpu"
        echo "CPU缓存:          $ccache"
        if [ -n "$cpu_aes" ]; then
        _blue "AES指令集:        yes"
        fi
        echo "机器型号:         $machinemodel"
        echo "系统时间:         $date"
        echo "本机IP地址:       $address"
        _blue "拥塞控制:         $tcpalgorithm"
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
    systemcheck() {
        echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>安全审计<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<"
        echo "正常情况下登录到本机30天内的所有用户的历史记录:"
        last | head -n 30
        echo "系统中关键文件修改时间:"
        ls -ltr /bin/ls /bin/login /etc/passwd /bin/ps /etc/shadow | awk '{print ">>>文件名："$9"  ""最后修改时间："$6" "$7" "$8}'
        echo
        _blue '开机启动的服务'
        systemctl list-unit-files | grep enabled
        _blue '/etc/rc.local 和开机启动脚本'
        cat /etc/rc.local
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
        echo "当前建立的连接:"
        netstat -n | awk '/^tcp/ {++S[$NF]} END {for(a in S) print a, S[a]}'

        more /etc/login.defs | grep -E "PASS_MAX_DAYS" | grep -v "#" | awk -F' ' '{if($2!=90){print ">>>密码过期天数是"$2"天,请管理员改成90天------warning"}}'
        next
        grep -i "^auth.*required.*pam_tally2.so.*$" /etc/pam.d/sshd >/dev/null
        if [ $? == 0 ]; then
            echo ">>>登入失败处理:已开启"
        else
            echo ">>>登入失败处理:未开启----------warning"
        fi
        echo
        echo "系统中存在以下非系统默认用户:"
        more /etc/passwd | awk -F ":" '{if($3>500){print ">>>/etc/passwd里面的"$1 "的UID为"$3",该账户非系统默认账户,请管理员确认是否为可疑账户--------warning"}}'
        next
        echo "系统特权用户:"
        awk -F: '$3==0 {print $1}' /etc/passwd
        next
        echo "系统中空口令账户:"
        awk -F: '($2=="!!") {print $1"该账户为空口令账户,请管理员确认是否为新增账户,如果为新建账户,请配置密码-------warning"}' /etc/shadow
        echo
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
    #磁盘测速
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
    #查看本机authorized_keys
    catkeys() {
        cat /root/.ssh/authorized_keys
        nextrun
    }
    #计划任务crontab
    crontabfun() {
        crontab -e
        service cron reload

    }
    #配置开机运行脚本 rc.local
    rclocalfun() {
        _blue '添加类似  nohup ... >> xxx.log 2>&1 &  最后行加 exit 0 '
        waitinput
        vim /etc/rc.local
    }

    menuname='主页/系统'
    options=("系统信息" sysinfo "磁盘信息"  diskinfo "写入ssh公钥" sshsetpub "仅密钥root" sshpubonly  "换阿里源" huanyuanfun "同步时间" synchronization_time "tty中文" supportcn "root登录" openroot  "生成密钥对" sshgetpub  "查看已存在ssh公钥" catkeys  "计划任务" crontabfun "配置rc.local" rclocalfun "系统检查" systemcheck "cpu压测" cputest "磁盘测速" iotestspeed )

    menu "${options[@]}"

}
#docker
dockerfun() {

    dockerrund() {
        echo
        docker images
        echo
        read -ep "请输入镜像包名或id REPOSITORY: " dcimage
        read -ep "请输入容器端口: " conport
        read -ep "请输入宿主机端口: " muport
        read -ep "请输入执行参数: " param
        docker run -d -p $muport:$conport $dcimage $param
        echo "$dcimage 已在后台运行中"
    }
    dockerrunit() {
        echo
        docker images
        echo
        read -ep "请输入镜像包名或id REPOSITORY: " dcimage
        read -ep "请输入容器端口: " conport
        read -ep "请输入宿主机端口: " muport
        read -ep "请输入执行参数(默认/bin/bash): " -i '/bin/bash' param
        docker run -it -p $muport:$conport $dcimage $param
        echo "$dcimage 后台运行中"
    }
    dockerexec() {
        echo
        docker ps
        echo
        read -ep "请输入容器名或id: " containerd
        read -ep "请输入执行参数(默认/bin/bash): " -i '/bin/bash' param
        docker exec -it $containerd $param
    }
    dockerimagesfun() {
        docker images
        nextrun
    }
    dockerpsfun() {
        echo 'runing'
        docker ps
        echo '所有'
        docker ps -a
        nextrun
    }
    opencon() {
        echo
        docker ps -a
        echo
        read -ep "请输入容器名或id: " containerd
        docker start $containerd
        echo
        echo "正在运行的容器 "
        docker ps
    }
    stopcon() {
        echo
        docker ps
        echo
        read -ep "请输入容器名或id: " containerd
        docker stop $containerd
        echo "正在运行的容器 "
        docker ps
    }
    rmcon() {
        echo
        docker ps -a
        echo
        read -ep "请输入容器名或id: " containerd
        docker rm -f $containerd
        echo "所有容器 "
        docker ps -a
    }
    menuname='主页/docker'
    options=("查看docker镜像" dockerimagesfun "查看容器" dockerpsfun "后台运行一个容器" dockerrund "运行一个终端交互容器" dockerrunit "进入交互式容器" dockerexec "开启一个容器" opencon "停止一个容器" stopcon "删除一个容器" rmcon)

    menu "${options[@]}"
}
#其他工具
ordertools() {
    #统计目录文件行数
    countfileslines() {
        echo
        _yellow '目前仅支持单一文件后缀搜索!'
        read -ep "请输入绝对路径 ./(默认当前目录) /.../..  : " abpath
        if [[ "$abpath" = "" ]]; then
            abpath='./'
        fi
        read -ep "请输入要搜索的文件后缀: sh(默认) php  html ...  : " suffix
        if [[ "$suffix" = "" ]]; then
            suffix='sh'
        fi
        # 使用 find 命令递归地查找指定目录下的所有文件,并执行计算行数的命令
        total=$(find $abpath -type f -name "*.$suffix" -exec wc -l {} \; | awk '{total += $1} END{print total}')
        # 输出总行数
        echo "$abpath 目录下的 后缀为 $suffix 文件的总行数是: $total"
    }
    #安装git便捷提交
    igitcommiteasy() {
        if which git >/dev/null; then
            _blue "Git is already installed"
            touch /bin/sgit
            chmod +x /bin/sgit
            echo 'git add . && git commit -m "`date +%y%m%d%H%M%S`" && git push' >/bin/sgit
            _blue '安装完成'
            echo
            echo '现在使用sgit命令 完成git add commit +时间字符串 push 提交  其他git命令不支持 请使用原生命令'
            echo
        else
            echo "Git没有安装"
            exit
        fi
    }
    menuname='主页/其他工具'
    options=("统计目录文件行数" countfileslines "安装git便捷提交" igitcommiteasy)
    menu "${options[@]}"
}
#全局变量初始化
glovar
#清屏
clear
#检查脚本是否已安装(/bin/init.sh存在?)
which init.sh >/dev/null 2>&1
if [ $? == 1 ]; then
    menuname='开箱页面'
    selfinstall
fi
#主页
main() {
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
        _blue "welcome!"
        jumpfun "海内存知己,天涯若比邻"
        echo
        read -n1 -r -p "开始安装脚本 (按任意键继续) ..."
        _yellow '检查系统环境..'
        if which s >/dev/null; then
            _red '系统已存在s程序,停止安装,请检查!'
            exit
        else
            _yellow '检查源文件..'
            if [ -e "$(pwd)/init.sh" ]; then
                jumpfun '开始安装脚本'
                cp -f "$(pwd)/init.sh" /bin/init.sh
                ln -s /bin/init.sh /bin/s
                jumpfun "很快就好"
                _blue '安装完成'
                menuname='主页'
                echo
                _blue "你可以在任意位置使用命令 's' 运行"
                echo
                waitinput
            else
                echo "当前目录没有发现原始脚本请检查"
                exit
            fi
        fi
    }
    #卸载脚本
    removeself() {
        _blue '开始卸载脚本'
        rm -rf /bin/init.sh
        rm -rf /bin/s
        rm -rf /bin/sgit
        _blue '卸载完成'
    }
    #脚本升级
    updateself() {
        removeself
        jumpfun '下载github最新版'
        wget -N http://raw.githubusercontent.com/sshpc/initsh/main/init.sh && chmod +x init.sh && ./init.sh
    }
    menuname='主页'
    options=("软件管理" software "网络管理" networktools "系统管理" sysset "其他工具" ordertools "脚本升级" updateself "脚本卸载" removeself)
    menu "${options[@]}"
}
main
