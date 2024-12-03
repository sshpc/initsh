# 文档

## 软件

### 安装常用包 
异步安装
"wget" "curl" "net-tools" "vim" "openssh-server" "screen" "git" "zip" "htop"

### 换源
切换软件源 国内、海外 脚本提供： https://github.com/SuperManito/LinuxMirrors

### 安装xray八合一
代理搭建常用 脚本提供：https://github.com/mack-a/v2ray-agent

### 安装xui
xray UI面版 脚本提供：https://github.com/vaxilu/x-ui

### 安装openvpn

openvpn server 端 脚本提供：https://github.com/angristan/openvpn-install


### 安装btop
btop 提供了CPU 使用率、内存使用率、磁盘使用率和网络流量直观的界面，以图形化的形式显示系统资源的使用情况

### 安装aapanel
宝塔国际版 无需登录 https://aapanel.com/new/download.html#install


### 卸载
手动输入 
软件包名 或服务名 批量执行类似 rm -rf /etc/ rm -rf /usr/bin
执行前做好备份，名字不精确可能会误伤 谨慎操作

## 网络

### fail2banfun

安装配置sshd  开启ssh密码连接错误拦截ip

### iperf3打流
2台机器
作为服务器的一台运行服务端
客户端模式默认 iperf3 -u -c $serversip -b 2000M -t 40

### 实时网速
使用的是vnstat

### 外网测速
SpeedCLI 测速
curl -fsSL git.io/speedtest-cli.sh | sudo bash

三网测速
脚本提供：https://www.wangchao.info/2204.html  https://down.wangchao.info/sh/superspeed.sh
多地区测速
'21541' 'Los Angeles, US'
'43860' 'Dallas, US'
'40879' 'Montreal, CA'
'24215' 'Paris, FR'
'28922' 'Amsterdam, NL'
'24447' 'Shanghai, CN'
'5530' 'Chongqing, CN'
'60572' 'Guangzhou, CN'
'32155' 'Hongkong, CN'
'23647' 'Mumbai, IN'
'13623' 'Singapore, SG'
'21569' 'Tokyo, JP'
### 配置局域网ip
修改主机的网口ip
仅为测试机用 ，配置文件/etc/netplan/00-installer-config.yaml

### 配置临时代理
窗口http代理  export http_proxy=http://x.x.x.x:x

## 系统

### 同步时间
同步主机时间为上海时间
### 配置仅秘钥rootssh登录
在/etc/ssh/sshd_config 配置开启root远程访问
并打开秘钥验证关闭密码验证
>确保已添加主机秘钥，见[往authorized_keys写入公钥]

### 往authorized_keys写入公钥
>仅root
将秘钥对的公钥粘贴至命令行
会写入/root/.ssh/authorized_keys

### 查看本机authorized_keys
cat /root/.ssh/authorized_keys

### 生成ssh密钥对
使用 ed25519 在.ssh目录下生成公私钥
并cat公钥用于复制

### ps进程搜索
默认
ps -aux
有参数
ps -aux | grep $name

### 性能测试
磁盘测速
cpu压测

### 计划任务crontab
crontab -e

service cron reload 立即生效
### 配置开机运行脚本 rc.local
有一个sh脚本想配置成开机自启 最简洁的办法  
若想灵活启停,推荐配置成系统服务[配置自定义服务]

### 配置自定义服务

适用：需要配置成守护进程的程序  一个无限循环的sh脚本（例如DDNS，检测。。）想要 灵活启停 开机自启

sysvinit方式 service xxx start/stop 传统方式兼容性好  
systemd方式(推荐) systemctl start/stop xxx 采用并行启动的方式提供了更多的功能和特性.主流init系统 

需要提供  
服务名称（最后配置好 service xxx start/stop  里的xxx的名字）
启动命令
终止命令可选 默认pkill -f 服务名称

同时在/etc/s/ 计入日志



## docker
基本docker命令

docker-composer 支持

## 其他工具

### 统计目录文件行数
例如想统计 /www/abc 里面html、php、sh的代码行数

### 安装git便捷提交
目标：
如若git提交时只需要在提交信息中写个时间 

安装完成后直接在仓库目录下执行 sgit


对应命令 “git add . && git commit -m "字符串时间" && git push”








