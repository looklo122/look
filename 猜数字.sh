#!/bin/bash
shuiji=$[RANDOM%100+1] > /tmp/shshu.txt

for i in {1..6}
do
    read -p "请输入一个1到100的数字： " caishu
    feishu=`echo $caishu | sed 's/[0-9]//g'`
    let i++
        if [ ! -z "$feishu" ] || [ $caishu -z  ];then
           continue
        fi
    if [ "$shuiji" -eq "$caishu" ];then
        echo "这都被你猜中了！"
        exit
    elif [ "$caishu" -ge "$shuiji" ];then
        echo  "大了"
    else 
        echo  "小了"        
    fi
done
