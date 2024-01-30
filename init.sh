#!/bin/bash
export LANG=en_US.UTF-8
#初始化函数
initself() {
    selfversion='24.01'
    datevar=$(date +%y%m%d%H%M%S)
    #菜单名称(默认首页)
    menuname='首页'
    #父级函数名
    parentfun=''
    ipaddresses=''
    gateway=''
    nameservers=''
    port=''
    unport=''
    ips=''

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

    #按任意键继续
    waitinput() {
        echo
        read -n1 -r -p "按任意键继续...(退出 Ctrl+C)"
    }
    #继续执行函数
    nextrun() {
        waitinput
        #环境变量调用上一次的次菜单
        ${FUNCNAME[3]}
    }

    #字符跳动 (参数：字符串 间隔时间s，默认为0.1秒)
    jumpfun() {
        my_string=$1
        delay=${2:-0.1}
        # 循环输出每个字符
        for ((i = 0; i < ${#my_string}; i++)); do
            printf '\033[0;31;36m%b\033[0m' "${my_string:$i:1}"
            sleep "$delay"
        done
        echo
    }

    #安装脚本
    selfinstall() {
        menutop
        secho() {
            echo
            _green '   ________       '
            _green '  |\   ____\      '
            _green '  \ \  \___|_     '
            _green '   \ \_____  \    '
            _green '    \|____|\  \   '
            _green '      ____\_\  \  '
            _green '     |\_________\ '
            _green '     \|_________| '
            echo
        }
        jumpfun "welcome" 0.06
        echo
        _yellow '检查系统环境'
        echo
        if which s >/dev/null; then

            _red '检测到已存在s程序，位置：/bin/s 请检查!'
            exit
        else

            menuname='首页'
            if [ -e "$(pwd)/init.sh" ]; then
                jumpfun '开始安装脚本 ' 0.04
                echo
                jumpfun '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>' 0.02

                cp -f "$(pwd)/init.sh" /bin/init.sh
                ln -s /bin/init.sh /bin/s
                mkdir /etc/s

                secho
                echo
                echo '文件释放位置： /bin/init.sh  /bin/s /etc/s'

                echo
                echo "提示：再次执行任意位置键入 's' "
                echo
                _blue '成功安装'
                echo 's脚本安装 ' $datevar >>/etc/s/s.log

                echo
                waitinput
                clear
            else
                _yellow "没有此脚本文件，跳过安装，仅运行"
                waitinput
                clear
            fi
        fi
    }
    #卸载脚本
    removeself() {
        rm -rf /bin/init.sh
        rm -rf /bin/s
        echo '删除/bin/init.sh  /bin/s'
        echo 's脚本卸载 ' $datevar >>/etc/s/s.log
        read -ep "是否删除/etc/s 日志目录 y or n (回车默认n): " yorn
        if [[ "$yorn" = "y" ]]; then
            rm -rf /etc/s
        fi
        echo
        _blue '卸载完成'
    }
    #脚本升级
    updateself() {

        _blue '下载github最新版'
        wget -N http://raw.githubusercontent.com/sshpc/initsh/main/init.sh
        # 检查上一条命令的退出状态码
        if [ $? -eq 0 ]; then
            _blue '卸载旧版...'
            removeself
            chmod +x ./init.sh && ./init.sh

        else
            _red "下载失败,请重试"
        fi

    }
    #菜单头部
    menutop() {
        clear
        _green '# Ubuntu初始化&工具脚本'
        _green '# Author:SSHPC <https://github.com/sshpc>'
        echo
        _blue ">~~~~~~~~~~~~~~ Ubuntu tools 脚本工具 ~~~~~~~~~~~~<  v: $selfversion"
        echo
        _yellow "当前菜单: $menuname "
        echo
    }
    #菜单渲染
    menu() {
        menutop
        options=("$@")
        num_options=${#options[@]}
        # 计算数组中的字符最大长度
        max_len=0
        for ((i = 0; i < num_options; i++)); do
            # 获取当前字符串的长度
            str_len=${#options[i]}

            # 更新最大长度
            if ((str_len > max_len)); then
                max_len=$str_len
            fi
        done
        # 渲染菜单
        for ((i = 0; i < num_options; i += 4)); do
            printf "%s%*s  " "$((i / 2 + 1)): ${options[i]}" $((max_len - ${#options[i]})) ""
            if [[ "${options[i + 2]}" != "" ]]; then printf "$((i / 2 + 2)): ${options[i + 2]}"; fi
            echo
            echo
        done
        echo
        printf '\033[0;31;36m%b\033[0m' "q: 退出  "
        if [[ "$number" != "" ]]; then printf '\033[0;31;36m%b\033[0m' "b: 返回  0: 首页"; fi
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
        elif [[ $number == 'b' ]]; then
            ${FUNCNAME[3]}
        elif [[ $number == 'q' ]]; then
            echo
            exit
        else
            _yellow '>~~~~~~~~~~~~~~~输入有误~~~~~~~~~~~~~~~~~<'
        fi

    }

    #获取网卡
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

    clear
}

#软件
software() {

    #更新所有已安装的软件包
    aptupdatefun() {
        jumpfun "更新所有软件包" 0.02
        dpkg --configure -a
        if [[ -n $(pgrep -f "apt") ]]; then
            pgrep -f apt | xargs kill -9
        fi
        apt-get update -y && apt-get install curl -y
        jumpfun "更新完成" 0.02
    }
    #修复更新
    configureaptfun() {

        sudo killall apt apt-get
        sudo rm /var/cache/apt/archives/lock
        sudo rm /var/lib/dpkg/lock*
        sudo rm /var/lib/apt/lists/lock
        sudo dpkg --configure -a
        sudo apt update
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
                read -ep "请输入要卸载的软件名: " resoftname
            else
                resoftname=$1
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
        menuname='首页/软件/卸载'
        options=("手动输入" masterremove "卸载nginx" removenginx "卸载Apache" removeapache "卸载php" removephp "卸载docker" removedocker "卸载v2ray" removev2 "卸载mysql" removemysql)
        menu "${options[@]}"
    }

    installbtop() {
        apt install snap -y
        apt install snapd -y
        snap install btop
        btop
    }

    menuname='首页/软件'
    options=("aptupdate软件更新" aptupdatefun "修复更新" configureaptfun "软件卸载" removefun "安装常用包" installcomso "安装btop" installbtop "安装八合一" installbaheyi "安装xui" installxui "安装openvpn" installopenvpn)
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
            until [[ -n "$port" || "$port" =~ ^[0-9]+$ && "$port" -le 65535 ]]; do
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
            until [[ -n "$unport" || "$unport" =~ ^[0-9]+$ && "$unport" -le 65535 ]]; do
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

        menuname='首页/网络/ufw'
        options=("开启ufw" ufwinstall "关闭ufw" ufwdisablefun "ufw状态" ufwstatus "添加端口" ufwadd "关闭端口" ufwclose)
        menu "${options[@]}"

    }

    fail2banfun() {
        fail2banstatusfun() {
            fail2ban-client status sshd
        }

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
            fail2banstatusfun
        }
        

        menuname='首页/网络/fail2ban'
        options=("安装配置sshd" installfail2ban "查看状态" fail2banstatusfun)
        menu "${options[@]}"

    }
    #网络信息
    netinfo() {
        echo
        jumpfun "--本机IP--" 0.04
        ifconfig -a | grep "inet "

        jumpfun "--路由表--" 0.04
        route -n
        jumpfun "--监听端口--" 0.04
        netstat -tunlp
        jumpfun "--公网IP--" 0.04
        curl cip.cc
        echo
        jumpfun "--IP连接数--" 0.04
        echo '   数量 ip'
        netstat -na | grep ESTABLISHED | awk '{print$5}' | awk -F : '{print$1}' | sort | uniq -c | sort -r
        echo
        jumpfun "--ssh失败记录--" 0.04
        lastb | grep root | awk '{print $3}' | sort | uniq
        echo
    }
    #iperf3打流
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
            _blue '默认udp  手动执行'
            next
            _yellow "iperf3 -u -c $serversip -b 2000M -t 40"
            next
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
    #nmap扫描
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

            until [[ -n "$ips" ]]; do
                read -ep "请输入网段x.x.x.x/x: " ips
            done

            nmap -sP $ips
        }
        nmapportcat() {

            read -ep "请输入ip: " ip
            read -ep "请输入端口(1-65535): " port
            nmap "$ip" -p "$port"
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
    #实时网速
    vnstatfun() {
        apt-get install vnstat
        #获取网卡名称
        vnstat -l -i $(getnetcard)
    }
    #外网测速
    publicnettest() {

        netfast() {
            apt install speedtest-cli -y
            echo "开始测速"
            speedtest-cli
            echo "测速完成"
        }

        #SpeedCLI 测速
        netfast2() {
            echo "开始测速"
            curl -fsSL git.io/speedtest-cli.sh | sudo bash
            speedtest
            echo "测速完成"
        }
        #三网测速
        sanwang() {
            bash <(curl -Lso- https://down.wangchao.info/sh/superspeed.sh)
        }

        menuname='首页/网络/外网测速'
        options=("测速1" netfast "测速2-SpeedCLI" netfast2 "三网测速" sanwang)

        menu "${options[@]}"

    }
    #配置局域网ip
    lanfun() {

        staticip() {
            echo "备份原文件/etc/netplan/00-installer-config.yaml"
            cp /etc/netplan/00-installer-config.yaml /etc/netplan/00-installer-config.yaml.bak."$datevar"
            #获取网卡名称
            ens=$(getnetcard)

            until [[ -n "$ipaddresses" ]]; do
                read -ep "请输入ip地址+网络号 (x.x.x.x/x): " ipaddresses
            done
            until [[ -n "$gateway" ]]; do
                read -ep "请输入网关(x.x.x.x): " gateway
            done
            until [[ -n "$nameservers" ]]; do
                read -ep "请输入DNS(x.x.x.x): " nameservers
            done
            _red "请仔细检查配置是否正确!"
            echo "网卡为" $ens
            echo "网络地址为(x.x.x.x/x):$ipaddresses"
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
            echo "备份原文件/etc/netplan/00-installer-config.yaml"
            cp /etc/netplan/00-installer-config.yaml /etc/netplan/00-installer-config.yaml.bak."$datevar"
            #获取网卡名称
            ens=$(getnetcard)
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

        menuname='首页/网络/配置局域网ip'
        options=("配置静态ip" staticip "配置dhcp" dhcpip)

        menu "${options[@]}"

    }

    #配置临时代理
    http_proxy(){
        _blue '配置后仅当前窗口生效'
        until [[ -n "$url" ]]; do
                read -ep "请输入地址,如:http://x.x.x.x:x" url
            done
        export http_proxy=$url
        _green '已成功配置'
    }

    menuname='首页/网络'
    options=("网络信息" netinfo "外网测速" publicnettest "iperf3打流" iperftest "临时http代理" http_proxy "实时网速" vnstatfun "配置局域网ip" lanfun "nmap扫描" nmapfun "ufw" ufwfun "fail2ban" fail2banfun)

    menu "${options[@]}"
}

#系统
sysset() {

    #换源
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
        menuname='首页/系统/换源'
        options=("18.04(bionic)" a1804 "20.04(focal)" a2004 "22.04(jammy)" a2204)
        menu "${options[@]}"
        cp /etc/apt/sources.list /etc/apt/sources.list.bak."$datevar"
        echo 'ok'
        echo "原source list已备份至 /etc/apt/sources.list.bak.$datevar"
        rm /etc/apt/sources.list
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
    #配置仅秘钥rootssh登录
    sshpubonly() {
        echo "备份原文件Back up the sshd_config"
        cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak."$datevar"
        echo "port 22" >>/etc/ssh/sshd_config
        echo "PermitRootLogin yes" >>/etc/ssh/sshd_config
        echo "PasswordAuthentication no" >>/etc/ssh/sshd_config
        _blue "重启服务Restart service"
        service sshd restart
        jumpfun "ok"
    }
    #生成ssh密钥对
    sshgetpub() {
        _blue "默认使用 ed25519 加密算法"
        read -ep "请输入email 仅做注释(可选): " email
        ssh-keygen -t ed25519 -C "$email"
        echo
        echo "ssh秘钥生成成功"
        echo
        echo "公钥："
        cat ~/.ssh/id_ed25519.pub
    }
    #往authorized_keys写入公钥
    sshsetpub() {
        echo "请填入ssh公钥 (Write into /root/.ssh/authorized_keys)"
        read -ep "请粘贴至命令行回车(Please paste and enter): " sshpub
        echo -e $sshpub >>/root/.ssh/authorized_keys
        echo
        echo "ssh公钥写入成功Write success"
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
        jumpfun "--主机--" 0.04
        echo "主机名:        $hostname" 0.02
        echo "系统名称:      $system"
        _blue "系统版本:      $version $codename"
        echo "内核版本:      $kernel"
        echo "系统类型:      $platform"
        _green "CPU型号:      $cpumodel"
        echo "CPU核数:       $cpu"
        echo "CPU缓存:       $ccache"
        if [ -n "$cpu_aes" ]; then
            _blue "AES指令集:     yes"
        fi
        echo "机器型号:      $machinemodel"
        echo "系统时间:      $date"
        echo "本机IP地址:    $address"
        _blue "拥塞控制:      $tcpalgorithm"
        echo
        jumpfun "--磁盘--" 0.04
        df -h
        nextrun
    }
    #磁盘详细信息
    diskinfo() {
        jumpfun "--PV物理卷查看--" 0.04
        pvscan
        jumpfun "--vgs虚拟卷查看--" 0.04
        vgs
        jumpfun "--lvscan逻辑卷扫描--" 0.04
        lvscan
        jumpfun "--文件系统信息--" 0.04
        more /etc/fstab | grep -v "^#" | grep -v "^$"
        echo
        jumpfun "--分区信息--" 0.04
        df -Th
        lsblk
        jumpfun "--fdisk信息--" 0.04
        fdisk -l
        nextrun
    }
    #系统检查
    systemcheck() {
        echo "正常登录到本机30天内的所有用户的历史记录:"
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
        nextrun
    }
    #ps进程搜索
    pssearch() {
        read -rp "ps -aux | grep ? <- :" -e name
        if [[ "$name" = "" ]]; then
            ps -aux

        else
            ps -aux | grep $name

        fi

        nextrun
    }
    #性能测试
    performancetest() {
        stresscputest() {
            echo "检查安装stress"
            apt install stress -y
            echo "默认单核60s测速 手动测试命令: stress -c 2 -t 100  #2代表核数 测试时间100s"
            waitinput
            stress -c 1 -t 60
        }
        sysbenchcputest() {
            echo "检查安装sysbench"
            apt install sysbench -y
            waitinput
            sysbench cpu run
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
        menuname='首页/系统/性能测试'
        options=("sysbench-cpu测试" sysbenchcputest "stress-cpu压测" cputest "磁盘测速" iotestspeed)

        menu "${options[@]}"

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

    # 配置自定义服务
    customservicefun() {

        serviceadd() {

            _yellow "service ?? stop/start"
            _red "服务名称需与脚本名称一致"

            read -ep "请输入服务名称: " servicename

            read -ep "请输入脚本绝对路径: " shpwd

            execcmd="nohup bash $shpwd  >> /root/$servicename.log 2>&1 &"

            jumpfun '开始配置 ----------------------------' 0.02
            echo

            sysvinitfun() {

                touch /etc/init.d/$servicename
                echo "#!/bin/sh" >>/etc/init.d/$servicename
                echo " " >>/etc/init.d/$servicename
                echo "### BEGIN INIT INFO" >>/etc/init.d/$servicename
                echo "# Provides: $servicename" >>/etc/init.d/$servicename
                echo '# Required-Start: $network $remote_fs $local_fs' >>/etc/init.d/$servicename
                echo '# Required-Stop: $network $remote_fs $local_fs' >>/etc/init.d/$servicename
                echo "# Default-Start: 2 3 4 5" >>/etc/init.d/$servicename
                echo "# Default-Stop: 0 1 6" >>/etc/init.d/$servicename
                echo "# Short-Description: $servicename" >>/etc/init.d/$servicename
                echo "# Description: $servicename" >>/etc/init.d/$servicename
                echo "### END INIT INFO" >>/etc/init.d/$servicename
                echo " " >>/etc/init.d/$servicename
                echo "start() {" >>/etc/init.d/$servicename
                echo "$execcmd" >>/etc/init.d/$servicename
                echo "}" >>/etc/init.d/$servicename
                echo "stop() {" >>/etc/init.d/$servicename
                echo " pkill -f $servicename" >>/etc/init.d/$servicename
                echo "}" >>/etc/init.d/$servicename
                echo 'case "$1" in' >>/etc/init.d/$servicename
                echo "  start)" >>/etc/init.d/$servicename
                echo " start" >>/etc/init.d/$servicename
                echo " ;;" >>/etc/init.d/$servicename
                echo "  stop)" >>/etc/init.d/$servicename
                echo "  stop" >>/etc/init.d/$servicename
                echo " ;;" >>/etc/init.d/$servicename
                echo " *)" >>/etc/init.d/$servicename
                echo " exit 1" >>/etc/init.d/$servicename
                echo " ;;" >>/etc/init.d/$servicename
                echo "esac" >>/etc/init.d/$servicename
                echo " " >>/etc/init.d/$servicename
                echo "exit 0" >>/etc/init.d/$servicename
                chmod +x /etc/init.d/$servicename

                update-rc.d $servicename defaults

                echo
                _green "文件位置 /etc/init.d/$servicename "

                echo
            }
            systemdfun() {

                touch /etc/systemd/system/$servicename.service
                echo "[Unit]" >>/etc/systemd/system/$servicename.service
                echo "Description=$servicename Service" >>/etc/systemd/system/$servicename.service
                echo "After=network.target" >>/etc/systemd/system/$servicename.service
                echo " " >>/etc/systemd/system/$servicename.service
                echo "[Service]" >>/etc/systemd/system/$servicename.service
                echo "ExecStart=$shpwd" >>/etc/systemd/system/$servicename.service
                echo " " >>/etc/systemd/system/$servicename.service
                echo "[Install]" >>/etc/systemd/system/$servicename.service
                echo "WantedBy=default.target" >>/etc/systemd/system/$servicename.service

                echo
                _green "文件位置 /etc/systemd/system/$servicename.service"

                echo
            }
            menuname='首页/系统/自定义服务/添加服务'
            options=("sysvinit方式(首选)" sysvinitfun "systemd方式" systemdfun)

            menu "${options[@]}"

            systemctl enable $servicename

            service $servicename start
            echo
            _blue "操作完成"
            echo add $servicename $datevar >>/etc/s/service.log

            service $servicename status

            _green "操作命令为 $execcmd"

            _blue "现在可以使用service $servicename  start/stop/status"

        }

        servicedel() {

            more /etc/s/service.log
            echo
            read -ep "请输入删除的服务名称: " servicename
            service $servicename stop
            systemctl disable $servicename
            update-rc.d -f $servicename remove

            rm -rf /etc/init.d/$servicename
            rm -rf /etc/systemd/system/$servicename.service

            echo del $servicename $datevar >>/etc/s/service.log
            _blue "操作完成"
            echo " "

        }

        menuname='首页/系统/自定义服务'
        options=("添加服务" serviceadd "删除服务" servicedel)

        menu "${options[@]}"

    }

    menuname='首页/系统'
    options=("sysinfo系统信息" sysinfo "磁盘详细信息" diskinfo "ps进程搜索" pssearch "sshpubset写入ssh公钥" sshsetpub "rootsshpubkeyonly仅密钥root" sshpubonly "换阿里源" huanyuanfun "同步时间" synchronization_time "生成密钥对" sshgetpub "catkeys查看已存在ssh公钥" catkeys "计划任务" crontabfun "配置rc.local" rclocalfun "配置自定义服务" customservicefun "系统检查" systemcheck "性能测试" performancetest)

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
    menuname='首页/docker'
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
        _yellow '检查系统环境..'
        if ! command -v git &>/dev/null; then
            echo "Git没有安装"
            _blue "Git is already installed"
        elif which sgit >/dev/null; then
            _red '系统已存在sgit程序,停止安装,请检查!'
            exit
        else
            touch /bin/sgit
            chmod +x /bin/sgit
            echo 'git add . && git commit -m "`date +%y%m%d%H%M%S`" && git push' >/bin/sgit
            _blue '安装完成'
            echo
            echo '如卸载删掉/bin/sgit 即可'
            echo '现在使用sgit命令 完成git add commit +时间字符串 push 提交'
            echo
        fi
    }
    siegetest() {
        apt install siege -y
        read -rp "输入被测试的url:" -e url
        read -rp "输入并发数1-255: " -e -i 10 erupt
        read -rp "输入测试时间: " -e -i 10 time
        echo
        _yellow '-c 并发数 -t 时间 -b 禁用请求之间的延迟(暴力模式)'
        echo "siege -c $erupt -t $time $url"
        echo
        waitinput

        jumpfun '开始测试...' 0.06
        siege -c $erupt -t $time $url

    }
    pingalways() {
        read -rp "目标主机:" -e target_host
        read -rp "ping请求的参数: " -e -i -t -l 4096 ping_options
        read -rp "并发数: " -e -i 10 concurrency

        # 数组用于存储ping进程的进程ID
        pids=()

        # 定义终止信号的处理函数
        function cleanup() {
            echo "Terminating ping processes..."
            for pid in "${pids[@]}"; do
                kill $pid
            done
            exit
        }

        # 注册终止信号的处理函数
        trap cleanup SIGINT SIGTERM

        # 并发执行ping请求
        for ((i = 1; i <= concurrency; i++)); do
            ping $ping_options $target_host >/dev/null &
            pids+=($!)
        done

        echo "Ping requests have been sent."

        # 等待所有ping进程完成
        wait

    }
    menuname='首页/其他工具'
    options=("统计目录文件行数" countfileslines "安装git便捷提交" igitcommiteasy "Siege-web压力测试" siegetest "死亡之ping" pingalways)
    menu "${options[@]}"
}
#主函数
main() {

    menuname='首页'
    options=("soft软件管理" software "network网络管理" networktools "system系统管理" sysset "docker" dockerfun "其他工具" ordertools "升级脚本" updateself "卸载脚本" removeself)
    menu "${options[@]}"
}

#初始化
initself

#检查脚本是否已安装
which init.sh >/dev/null 2>&1
if [ $? == 1 ]; then
    menuname='脚本安装'
    selfinstall
fi

main
