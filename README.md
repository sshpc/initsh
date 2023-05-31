# 简单的 Ubuntu 初始化&工具脚本
## 一、介绍

交互式数字操作
单 s 命令
支持Ubuntu 18、20、22 Debian 10、11


## 二、功能
* 一键换阿里源
* 配置静态ip，dhcp
* 一键安装常用工具
* 强力卸载web环境&软件
* 系统、网络、磁盘、硬件信息查看
* 磁盘测速
* 同步系统时间
* 外网测网速
* 查看监听端口
* ufw配置
* docker
* 便捷生成、导入ssh秘钥
* crontab 计划任务
* 统计目录文件行数
* 脚本安装进\bin 执行了软连接 s
## 三、安装使用
#### 一键运行脚本
> 需root用户
```
wget -N  http://raw.githubusercontent.com/sshpc/initsh/main/init.sh && chmod +x init.sh && sudo ./init.sh
```

>首次运行会直接安装，安装后任意位置可用 s 命令直接运行
 
```
 root@server:~#  s
```
---
## 四、示例
#### 主页
```
>~~~~~~~~~~~~~~ Ubuntu tools 脚本工具 ~~~~~~~~~~~~<  版本:v23.5.26

当前菜单: 主页 

----------------------------------------------------------------------
1:软件      2:网络     3:ufw防火墙&安全
----------------------------------------------------------------------
4:系统      5:docker   6:其他工具
----------------------------------------------------------------------
666:脚本升级  999:脚本卸载
----------------------------------------------------------------------
0: exit 退出

请输入命令数字: 

```

#### 新装
```
# Ubuntu初始化&工具脚本
# Author:SSHPC <https://github.com/sshpc>

  ________       
 |\   ____\      
 \ \  \___|_     
  \ \_____  \    
   \|____|\  \   
     ____\_\  \  
    |\_________\ 
    \|_________| 


>~~~~~~~~~~~~~~ Ubuntu tools 脚本工具 ~~~~~~~~~~~~<  版本:v23.5.31

当前菜单: 开箱页面 

------------------------------------------------------------

欢迎使用！
```
