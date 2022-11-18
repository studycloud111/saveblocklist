#!/usr/bin/env bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
rm -rf  /root/ipd.sh
wget -P /root https://raw.githubusercontent.com/studycloud111/saveblocklist/main/ipd.sh
#写入定时任务文件
ipddns(){
cat > /root/ipddns << EOF
10.10.10.10
EOF
}
#写入定时任务文件
cron_file(){
cat > /usr/lib/systemd/system/ddns.service << EOF
[Unit]
Description=DDNS_check

[Service]
ExecStart=/bin/bash /root/ipd.sh

EOF


cat > /usr/lib/systemd/system/ddns.timer << EOF

[Unit]
Description=Runs mytimer 5 min

[Timer]
OnBootSec=5min
OnUnitActiveSec=5min
Unit=ddns.service

[Install]
WantedBy=multi-user.target

EOF
systemctl restart ddns.service
systemctl restart ddns.timer
systemctl daemon-reload

} 
ipddns
cron_file
