# Ubuntu 初始化&工具脚本

## 一、介绍

### 大道至简理念

1. 交互式数字操作 [查看示例](#chapter1)
2. 支持Ubuntu、 Debian 系

> 后续支持其他Linux发行版

## 二、功能

* 一键换阿里源
* 配置物理机静态ip，dhcp
* 一键安装常用工具
* 软件强力卸载通用
* 专项web环境卸载
* 系统、网络、磁盘、硬件信息查看
* 磁盘测速
* cpu跑分、压力测试
* 同步系统时间
* 外网网速测试
* ufw配置、进程监听端口查看
* docker
* ssh密钥对生成、导入
* crontab 计划任务
* 统计目录文件行数
* git一键提交
* 持续更新...

## 三、安装使用

#### 1.一键运行脚本

> root 用户

```sh
wget -N  http://raw.githubusercontent.com/sshpc/initsh/main/init.sh && chmod +x init.sh && sudo ./init.sh
```

##### 2.首次运行会直接安装`<a id="chapter1"></a>`

> 脚本安装进\bin 执行了软连接 s
> 安装后任意位置可用命令 s 直接运行

```sh
 root@server:~#  s
```

---

## 四、示例

#### 主页

```sh
# Ubuntu初始化&工具脚本
# Author:SSHPC <https://github.com/sshpc>

>~~~~~~~~~~~~~~ Ubuntu tools 脚本工具 ~~~~~~~~~~~~<  版本:v23.x

当前菜单: 主页 

1:软件         2:网络        3:系统 

4:docker       5:其他工具

666:脚本升级   777:脚本卸载

0: 退出

请输入命令数字: 

```

#### 新装

```sh
# Ubuntu初始化&工具脚本
# Author:SSHPC <https://github.com/sshpc>

>~~~~~~~~~~~~~~ Ubuntu tools 脚本工具 ~~~~~~~~~~~~<  版本:v23.x
当前菜单: 开箱页面 

  ________   
 |\   ____\  
 \ \  \___|_   
  \ \_____  \  
   \|____|\  \   
     ____\_\  \  
    |\_________\ 
    \|_________| 

welcome !
脚本安装 (按任意键继续) ...
```
