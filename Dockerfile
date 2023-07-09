# 使用 Ubuntu 作为基础镜像
FROM ubuntu:20.04

# 设置环境变量
ENV TENGINE_VERSION="2.4.1"
ENV TENGINE_DOWNLOAD_URL="https://github.com/studycloud111/saveblocklist/raw/main/tengine-2.4.1.tar.gz"
ENV TENGINE_DIR="/root/tengine-${TENGINE_VERSION}"

# 安装依赖
RUN apt-get update && apt-get install -y \
    build-essential \
    libpcre3 \
    libpcre3-dev \
    zlib1g-dev \
    openssl \
    libssl-dev \
    gcc \
    make \
    iperf3 \
    vim \
    wget \
    && rm -rf /var/lib/apt/lists/*

# 下载并解压 Tengine，并列出解压后的目录结构
RUN wget -O "${TENGINE_DIR}.tar.gz" "$TENGINE_DOWNLOAD_URL" \
    && tar zxf "${TENGINE_DIR}.tar.gz" -C /root/ \
    && rm "${TENGINE_DIR}.tar.gz" \
    && ls -alh "${TENGINE_DIR}"

# 编译并安装 Tengine
WORKDIR $TENGINE_DIR
RUN ./configure --with-http_realip_module --without-http_upstream_keepalive_module --with-stream --with-stream_ssl_module --with-stream_sni --add-module=modules/ngx_http_upstream_* --add-module=modules/ngx_debug_* --add-module=modules/ngx_http_slice_module --add-module=modules/ngx_http_user_agent_module --add-module=modules/ngx_http_reqstat_module --add-module=modules/ngx_http_proxy_connect_module --add-module=modules/ngx_http_footer_filter_module && \
    make && make install && \
    ln -sf /usr/local/nginx/sbin/nginx /usr/bin/nginx

# 设置 Tengine 配置
RUN mkdir -p /usr/local/nginx/mytcp /usr/local/nginx/meip
RUN echo 'user  root; \n\
worker_processes auto; \n\
worker_rlimit_nofile 51200; \n\
pid        /usr/local/nginx/logs/nginx.pid; \n\
events \n\
    { \n\
        use epoll; \n\
        worker_connections 51200; \n\
        multi_accept on; \n\
    } \n\
stream { \n\
    include /usr/local/nginx/mytcp/*.conf; \n\
} \n\
http { \n\
    include       mime.types; \n\
    default_type  application/octet-stream; \n\
    sendfile        on; \n\
    keepalive_timeout  120; \n\
    keepalive_requests 10000; \n\
    check_shm_size 50m; \n\
    #rewrite \n\
    include /usr/local/nginx/meip/*.conf; \n\
}' > /usr/local/nginx/conf/nginx.conf

# 暴露端口
EXPOSE 80 443

# 启动 Tengine
CMD ["nginx", "-g", "daemon off;"]
