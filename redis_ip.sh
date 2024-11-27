#!/bin/bash

# 获取本机IP
get_local_ip() {
    local_ip=$(curl -s http://ipv4.icanhazip.com || wget -qO- http://ipv4.icanhazip.com)
    if [ -z "$local_ip" ]; then
        local_ip=$(ip addr | grep 'inet ' | grep -v '127.0.0.1' | awk '{print $2}' | cut -d/ -f1 | head -n 1)
    fi
    echo "$local_ip"
}

# Redis配置
REDIS_HOST="127.0.0.1"
REDIS_PORT="6379"
REDIS_KEY="sp_ip"

# 获取本机IP
local_ip=$(get_local_ip)

# 使用 SISMEMBER 直接检查IP是否存在，返回1表示存在，0表示不存在
is_exist=$(redis-cli -h $REDIS_HOST -p $REDIS_PORT SISMEMBER $REDIS_KEY "$local_ip")

if [ "$is_exist" = "0" ]; then
    # IP不存在，添加到集合
    redis-cli -h $REDIS_HOST -p $REDIS_PORT SADD $REDIS_KEY "$local_ip"
    echo "新IP已添加到Redis: $local_ip"
else
    echo "IP已存在于Redis中: $local_ip"
fi
