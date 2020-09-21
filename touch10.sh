#!/bin/bash
stty erase ^H
shuiji(){
zimu=({a..z})
i=1
while (( $i <= 10 ));do
    zi=${zimu[`echo $[$RANDOM%10]`]}
    let i++
    echo -n "$zi"
done
}
echo -e " 
 a.在/qfedu目录中创建10个随机文件
 b.将/qfedu目录中的文件重命名为HTML结尾
 c.仅保留/qfedu目录中最新的文件
 q.退出"
while :
do
read -p "请输入选项[a|b|c|q]: " num
case $num in
a)
if [ -d /qfedu ];then
    cd /qfedu
else
    mkdir /qfedu
    cd /qfedu
fi
for i in {1..10}
do
    let i++
    touch `shuiji`_html
done
echo "创建完成"
sleep 1
;;
b)
cd /qfedu
for i in `ls *html`
do
    name=`echo $i|awk -F"_" '{print $1}'`
    mv  $i  ${name}_HTML
done
echo "改名完成"
sleep 1
;;
c)
cd /qfedu
file=`ls -t`
i=1
for g in $file
do
    if [ $i -gt 10 ];then
    rm -rf $g
    fi
    let i++
done
    echo "删除完成"
sleep 1
;;
q)
exit
;;
*)
echo "输入无效"
sleep 1
exit 0
;;
esac
done   
