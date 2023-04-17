# 一个简单的 Ubuntu 初始化&工具脚本


---

# 介绍

* 交互式操作
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

### 一键运行脚本（root用户）

```
wget -N  http://raw.githubusercontent.com/sshpc/initsh/main/init.sh && chmod +x init.sh && sudo ./init.sh
```
###### 再次执行
```
 ./init.sh
```
---
## 示例图
```
>~~~~~~~~~~~~~~ Ubuntu tools 脚本工具 ~~~~~~~~~~~~<  版本:v23.4.17

当前菜单: 主页 

----------------------------------------------------------------------
1:软件      2:网络     3:ufw防火墙&安全
----------------------------------------------------------------------
4:系统      5:docker   
----------------------------------------------------------------------
66:脚本升级 
----------------------------------------------------------------------
0: exit 退出

Please enter the command number 请输入命令数字:
```
