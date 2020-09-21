#!/bin/bash
ls /backup/  &> /dev/null||mkdir  /backup/
cat <<-EOF > /tmp/wan.sh
#!/bin/bash
innobackupex --user=root --password=123456 /backup/  &> /dev/null 
EOF

cat <<'EQF' > /tmp/zeng.sh
#!/bin/bash
jichu=`ls -t /backup/|sed -n 1p`
if [ -f /backup/$jichu ];then
innobackupex --user=root --password=123456 --incremental /backup/ --incremental-basedir=/backup/$jichu/   &> /dev/null
else
    innobackupex --user=root --password=123456 /backup/  &> /dev/null
    xin=$(ls /backup/)
    innobackupex --user=root --password=123456 --incremental /backup/ --incremental-basedir=/backup/$xin/  &> /dev/null
fi
EQF
echo "00 03 * * 7 /usr/bin/sh /tmp/wan.sh" >> /var/spool/cron/root
echo "00 03 * * 1-6 /usr/bin/sh /tmp/zeng.sh" >> /var/spool/cron/root
echo "添加备份任务成功，请勿重复执行此脚本！"
