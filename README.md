# Ubuntu 初始化&工具脚本

## 一、介绍

1. 交互式数字操作 [查看示例](#2首次运行会直接安装)
2. Ubuntu 1804+ (建议)、 Debian 10+ 

> 后续支持其他Linux发行版

## 二、功能

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
* 持续更新...

## 三、安装使用

#### 1.一键运行脚本

> 最好 root 用户

```sh
wget -N  http://raw.githubusercontent.com/sshpc/initsh/main/init.sh && chmod +x init.sh && sudo ./init.sh
```

##### 2.首次运行会直接安装

> 脚本安装进\bin 执行了软连接 s
> 安装后任意位置可用命令 s 直接运行

```sh
 root@server:~#  s
```

---

## 四、示例

#### 主页

```sh
>~~~~~~~~~~~~~~ Ubuntu tools 脚本工具 ~~~~~~~~~~~~<  版本:vx.x.x

当前菜单: 首页 

1: soft软件管理      2: network网络管理

3: system系统管理    4: docker

5: 其他工具          6: 升级脚本

7: 卸载脚本

q: 退出  

请输入命令号: 
```

