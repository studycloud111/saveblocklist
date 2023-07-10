FROM ubuntu:latest

# 设置工作目录
WORKDIR /root/tengine-2.4.1

# 复制文件到工作目录
COPY ./tengine-2.4.1 .

# 安装依赖，并清理缓存
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
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# 编译并安装
RUN ./configure --prefix=/app/tengine --with-debug --with-http_realip_module --without-http_upstream_keepalive_module --with-stream --with-stream_ssl_module --with-stream_sni --add-module=modules/ngx_http_upstream_* --add-module=modules/ngx_debug_* --add-module=modules/ngx_http_slice_module --add-module=modules/ngx_http_user_agent_module --add-module=modules/ngx_http_reqstat_module --add-module=modules/ngx_http_proxy_connect_module --add-module=modules/ngx_http_footer_filter_module \
    && make \
    && make install

# 设置容器时区，并创建配置文件目录
RUN ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime 

# 设置环境变量
ENV LANG=en_US.UTF-8

# 工作目录
WORKDIR /app/tengine
# 设置 Tengine 配置
RUN mkdir -p /usr/local/nginx/mytcp /usr/local/nginx/meip
RUN echo 'user  root; \n\
worker_processes auto; \n\
worker_rlimit_nofile 51200; \n\
pid        /app/tengine/logs/nginx.pid; \n\
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
    server_names_hash_bucket_size 256; \n\
    server_names_hash_max_size 1024; \n\
    keepalive_requests 10000; \n\
    check_shm_size 50m; \n\
    #rewrite \n\
    include /usr/local/nginx/meip/*.conf; \n\
}' > /app/tengine/conf/nginx.conf

# 暴露容器端口号
EXPOSE 80 443

# 启动容器时自动启动 tengine
CMD /app/tengine/sbin/nginx -g "daemon off;"
