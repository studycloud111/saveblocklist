#!/bin/bash

# 定义证书下载路径和证书 URL
CERT_DIR="/usr/local/nginx"
KEY_URL="https://raw.githubusercontent.com/studycloud111/saveblocklist/refs/heads/main/ng.key"
CRT_URL="https://raw.githubusercontent.com/studycloud111/saveblocklist/refs/heads/main/ngcrt.crt"

# 创建证书目录（确保目录存在）
mkdir -p $CERT_DIR

# 下载 .key 文件
echo "Downloading ng.key..."
curl -o $CERT_DIR/ng.key $KEY_URL

# 下载 .crt 文件
echo "Downloading ngcrt.crt..."
curl -o $CERT_DIR/ngcrt.crt $CRT_URL

# 启动 nginx
nginx -g "daemon off;"
