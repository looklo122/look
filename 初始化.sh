#!/usr/bin/bash
#此脚本是初始化脚本
stty erase ^H
rl=`df -hl|awk 'NR==2{print $2}'`
yy=`df -hl|awk 'NR==2{print $3}'`
ky=`df -hl|awk 'NR==2{print $4}'`
syl=`df -hl|awk 'NR==2{print $5}'`
nc=`free -h |awk 'NR==2{print $2}'`
ncyy=`free -h |awk 'NR==2{print $3}'`
ncsy=`free -h |awk 'NR==2{print $7}'`
TIME_INTERVAL=5
LAST_CPU_INFO=$(cat /proc/stat | grep -w cpu | awk '{print $2,$3,$4,$5,$6,$7,$8}')
LAST_SYS_IDLE=$(echo $LAST_CPU_INFO | awk '{print $4}')
LAST_TOTAL_CPU_T=$(echo $LAST_CPU_INFO | awk '{print $1+$2+$3+$4+$5+$6+$7}')
sleep ${TIME_INTERVAL}
NEXT_CPU_INFO=$(cat /proc/stat | grep -w cpu | awk '{print $2,$3,$4,$5,$6,$7,$8}')
NEXT_SYS_IDLE=$(echo $NEXT_CPU_INFO | awk '{print $4}')
NEXT_TOTAL_CPU_T=$(echo $NEXT_CPU_INFO | awk '{print $1+$2+$3+$4+$5+$6+$7}')
SYSTEM_IDLE=`echo ${NEXT_SYS_IDLE} ${LAST_SYS_IDLE} | awk '{print $1-$2}'`
TOTAL_TIME=`echo ${NEXT_TOTAL_CPU_T} ${LAST_TOTAL_CPU_T} | awk '{print $1-$2}'`
CPU_USAGE=`echo ${SYSTEM_IDLE} ${TOTAL_TIME} | awk '{printf "%.2f", 100-$1/$2*100}'`
ncbfb=`free -m | sed -n '2p' | awk '{print ""$3"M,"$2"M, "$3/$2*100"%"}'| awk '{print $2}'`
echo -e "\033[46;30m
--------------------------------------------------------------
+                   初始化脚本v1.2                           +
--------------------------------------------------------------
+    此脚本由大宝不胖但是很壮和黑哥编写，如果有什么问题可以联+
+系我们，邮箱：db88788@163.com，感谢您的使用，谢谢。         +
--------------------------------------------------------------
+   a.一键部署固定ip         e.                              +
+   b.一键安装常用软件       f.                              +
+   c.关闭防火墙和selinux    g.                              +
+   d.安装阿里源和扩展源     h.                              +
+                                                            +
--------------------------------------------------------------
+   磁盘   容量:$rl   已用:$yy 可用:$ky  使用率:$syl         +
+   内存   容量:$nc  已用:$ncyy 可用:$ncsy 使用率:$ncbfb    +
+   CPU     使用率:${CPU_USAGE}%                                     +
--------------------------------------------------------------
+        l.清理内存          s.刷新           q.退出         +
--------------------------------------------------------------
\033[0m"
while :
do
read -p "请输入你需要操作的序号："  num
case $num in 
a):
ipaddr=`ip a |grep 'scope global' |awk  '{print $2}'|awk -F'/' '{print $1}'`
gateway=`ip r|grep via|awk '{print $3}'`
dns=`cat /etc/resolv.conf|awk NR==3'{print $2}'`
netmask=255.255.255.0 
sed -i 's/ONBOOT="no"/ONBOOT="yes"/g' `grep ONBOOT -rl /etc/sysconfig/network-scripts/ifcfg-ens33`
sed -i 's/BOOTPROTO="dhcp"/BOOTPROTO="none"/g' `grep BOOTPROTO -rl /etc/sysconfig/network-scripts/ifcfg-ens33`

cat /etc/sysconfig/network-scripts/ifcfg-ens33|grep IPADDR &>/dev/null 
if [ $? -eq 0 ] 
then
                 echo "ip已设置，无需重复设置。ip:`cat /etc/sysconfig/network-scripts/ifcfg-ens33|grep IPADDR|awk -F'=' '{print $2}'`"   
else
                 echo IPADDR=$ipaddr >>/etc/sysconfig/network-scripts/ifcfg-ens33
                 echo "ip设置完毕$ipaddr"
fi
sleep 2

cat /etc/sysconfig/network-scripts/ifcfg-ens33|grep NETMASK &>/dev/null
if [ $? -eq 0 ]
then
                 echo "子网掩码已设置，无需重复设置。子网掩码:`cat /etc/sysconfig/network-scripts/ifcfg-ens33|grep NETMASK|awk -F'=' '{print $2}'`"
else
                 echo NETMASK=$netmask >>/etc/sysconfig/network-scripts/ifcfg-ens33
                 echo "子网掩码设置完毕$netmask"
fi    
sleep 2

cat /etc/sysconfig/network-scripts/ifcfg-ens33|grep GATEWAY &>/dev/null
if [ $? -eq 0 ] 
then
                 echo "网关已设置，无需重复设置。网关:`cat /etc/sysconfig/network-scripts/ifcfg-ens33|grep GATEWAY|awk -F'=' '{print $2}'`"
else
                 echo GATEWAY=$gateway >>/etc/sysconfig/network-scripts/ifcfg-ens33
                 echo "网关设置完毕$gateway"
fi
sleep 2

cat /etc/sysconfig/network-scripts/ifcfg-ens33|grep DNS1 &>/dev/null
if [ $? -eq 0 ]
then 
                 echo "DNS已设置，无需重复设置。DNS:`cat /etc/sysconfig/network-scripts/ifcfg-ens33|grep DNS1|awk -F'=' '{print $2}'`"
else
                 echo DNS1=$dns >>/etc/sysconfig/network-scripts/ifcfg-ens33
                 echo "DNS设置完毕$dns"
fi
;;
d):
mkdir /tmp/yum.repo
ping -w1 -c1 www.baidu.com
if [[ $? -ne 0 ]];then
                 echo "网络不通畅，请检查网络通畅性"
        continue
else
                 echo "网络通畅，正在进行wget软件下载"
fi
sleep 3
yum -y install wget
mv /etc/yum.repos.d/*  /tmp/yum.repo
if [[ $? -ne 0 ]];then
                 echo "yum源备份失败"
	exit
else
                 echo "yum源备份成功,已经备份到/tmp/yum.repo/下面"
fi
read -p "请选择需要下载的centos基础镜像包版本，根据系统版本选择(6|7|8):" centos
case $centos in
6):
	wget -O /etc/yum.repos.d/CentOS-Base.repo  -nc http://mirrors.aliyun.com/repo/Centos-6.repo
;;
7):
	wget -O /etc/yum.repos.d/CentOS-Base.repo  -nc http://mirrors.aliyun.com/repo/Centos-7.repo
;;
8):
	wget -O /etc/yum.repos.d/CentOS-Base.repo  -nc http://mirrors.aliyun.com/repo/Centos-8.repo
;;
*):
                 echo "请按照提示输入"
	break
;;	
esac
read -p "请选择需要下载的repo扩展镜像包版本，根据系统版本选择(5|6|7|8):" epel
case $epel in
5):
	wget -O /etc/yum.repos.d/epel.repo -nc http://mirrors.aliyun.com/repo/epel-5.repo
;;
6):
        wget -O /etc/yum.repos.d/epel.repo -nc http://mirrors.aliyun.com/repo/epel-6.repo
;;
7):
        wget -O /etc/yum.repos.d/epel.repo  -nc http://mirrors.aliyun.com/repo/epel-7.repo
;;
8):
        yum install -y https://mirrors.aliyun.com/epel/epel-release-latest-8.noarch.rpm
	sed -i 's|^#baseurl=https://download.fedoraproject.org/pub|baseurl=https://mirrors.aliyun.com|' /etc/yum.repos.d/epel*
	sed -i 's|^metalink|#metalink|' /etc/yum.repos.d/epel*
;;
*):
                 echo "请按照提示输入"
        break
;;
esac
yum makecache
;;
c):
                echo "正在关闭防火墙"
systemctl stop firewalld      &>/dev/null
systemctl disable firewalld   &>/dev/null
sleep 2
setenforce 0
sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' `grep 'SELINUX=enforcing' -rl  /etc/selinux/config`    &>/dev/null
                echo "防火墙已关闭"
;;
s):
                echo "正在重启脚本"
cd /root/
sh 123.sh
break
;;
l):
		echo "正在清理内存"
echo 3 > /proc/sys/vm/drop_caches
sleep 2
		echo "内存清理结束"
;;
b):
echo "正在安装请稍等。。。"
sleep 2

rpm -q lrzsz     
if [ $? -eq 0 ]
then 
                echo "已经安装lrzsz无需重复安装"
else
                echo "正在为您安装lrzsz"
yum install -y    lrzsz    &>/dev/null
                echo "lrzsz安装成功"
fi
sleep 1
rpm -q sysstat
if [ $? -eq 0 ]
then
                echo "已经安装sysstat无需重复安装"
else
                echo "正在为您安装sysstat"
yum install -y    sysstat    &>/dev/null
                echo "sysstat安装成功"
fi
sleep 1
rpm -q elinks
if [ $? -eq 0 ]
then
                echo "已经安装elinks无需重复安装"
else
                echo "正在为您安装elinks"
yum install -y    elinks     &>/dev/null
                echo "elinks安装成功"
fi
sleep 1
rpm -q wget
if [ $? -eq 0 ]
then
                echo "已经安装wget无需重复安装"
else
                echo "正在为您安装wget"
yum install -y    wget    &>/dev/null   
                echo "wget安装成功"
fi
sleep 1
rpm -q net-tools
if [ $? -eq 0 ] 
then 
                echo "已经安装net-tools无需重复安装"
else
                echo "正在为您安装net-tools"
yum install -y    net-tools   &>/dev/null
                echo "net-tools安装成功"
fi
sleep 1
rpm -q bash-completion
if [ $? -eq 0 ]
then 
                echo "已经安装bash-completion无需重复安装"
else
                echo "正在为您安装bash-completion"
yum install -y    bash-completion       &>/dev/null
                echo "bash-completion安装成功"
fi
sleep 1
rpm -q vim-enhanced
if [ $? -eq 0 ]
then 
                echo "已经安装vim无需重复安装"
else
                echo "正在为您安装vim"
yum install -y    vim         &>/dev/null
                echo "vim安装成功"
fi
;;
q):
                echo "欢迎下次使用"
sleep 2
exit 0
;;
*):
                echo "输入无效，正在退出"
sleep 2
exit 0
;;
esac
done
