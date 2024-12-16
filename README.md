# Ubuntu 初始化&工具脚本

## 安装

### 一键安装(推荐)
> 推荐 root 用户

```sh
wget -N  http://raw.githubusercontent.com/sshpc/initsh/main/init.sh && chmod +x init.sh && sudo ./init.sh
```

> 再次执行只需要输入 “s” 

```sh
 root@server:~#  s
```


> 跳过安装,仅执行脚本
```sh
bash <(curl -sSL http://raw.githubusercontent.com/sshpc/initsh/main/init.sh)
```
## 示例

```sh
>~~~~~~~~~~~~~~ Ubuntu tools 脚本工具 ~~~~~~~~~~~~<  v: x.x

当前菜单: 首页 

1: soft软件管理      2: network网络管理

3: system系统管理    4: docker

5: 其他工具          6: 升级脚本

7: 卸载脚本

q: 退出  

请输入命令号: 
```

## 介绍

1. 简单交互式操作 
2. Ubuntu 1804+  Debian 10+ 
3. [查看文档](Documents.md)

## 功能

* 一键换阿里源
* 配置物理机静态ip，dhcp
* 软件卸载
* 系统、网络、磁盘、硬件信息查看
* cpu压力测试，磁盘测速，外网测网速
* 同步系统时间
* ufw配置、进程监听端口查看
* docker
* ssh密钥对生成、导入
* crontab 计划任务
* 统计目录文件行数
* git一键提交
* nmap扫描、iperf测速
* 自定义脚本服务
* web压力测试
* 多线程下载
* 临时http代理
* 持续更新...





