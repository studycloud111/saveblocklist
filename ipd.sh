#!/usr/bin/env bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH


# 检查dig命令是否存在，如果不存在则尝试安装dnsutils
if ! command -v dig &> /dev/null; then
    echo "'dig' command could not be found. Attempting to install dnsutils..."
    sudo apt-get update
    sudo apt-get install -y dnsutils
fi

# 想要检查的域名列表
domains=("hinet1.camdvr.org")

# 存储旧IP的文件的基本路径
old_ip_file_base='/tmp/old_ip_'

# 检查每个域名
for domain in "${domains[@]}"; do

    # 为每个域名设置一个单独的旧IP文件
    old_ip_file="${old_ip_file_base}${domain}"

    # 检查旧IP文件是否存在，如果不存在则创建一个空的
    if [ ! -f $old_ip_file ]; then
        touch $old_ip_file
    fi

    # 使用dig命令获取当前IP
    current_ip=$(dig +short $domain)

    # 从旧IP文件中读取旧IP
    old_ip=$(cat $old_ip_file)

    # 比较当前IP和旧IP，如果不同则重载Nginx配置
    if [ "$current_ip" != "$old_ip" ]; then
        echo "IP address for $domain has changed to $current_ip, reloading Nginx configuration"
    
        # 更新旧IP文件
        echo $current_ip > $old_ip_file

        # 重载Nginx配置
        sudo docker exec -it nginx nginx -s reload
    fi
done

