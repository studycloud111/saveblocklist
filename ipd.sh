#!/usr/bin/env bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
myip=$(curl ip.qaros.com | awk 'NR==1')
twip=$(cat /root/ipddns | awk 'NR==1')
if [ ${myip} = ${twip} ]; then
    echo "ip没有变化,不需要重启"
else
    systemctl restart nginx
cat > /root/ipddns << EOF
${myip}
EOF
    echo "nginx重启成功"
fi
