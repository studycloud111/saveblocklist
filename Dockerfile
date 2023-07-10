# 使用官方的 Ubuntu 镜像作为基础镜像
FROM ubuntu:latest AS build

# 设置环境变量
ENV LANG=en_US.UTF-8

# 设置工作目录
WORKDIR /root/tengine-2.4.1

# 复制文件到工作目录
COPY ./tengine-2.4.1 .

# 安装依赖并清理缓存
RUN apt-get update -qq && apt-get install -y -qq \
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
RUN ./configure --prefix=/app/tengine \
--with-debug --with-http_realip_module \
--without-http_upstream_keepalive_module \
--with-stream --with-stream_ssl_module \
--with-stream_sni \
--add-module=modules/ngx_http_upstream_consistent_hash_module \
--add-module=modules/ngx_http_upstream_vnswrr_module \
--add-module=modules/ngx_http_upstream_dynamic_module \
--add-module=modules/ngx_http_upstream_dyups_module \
--add-module=modules/ngx_http_upstream_keepalive_module \
--add-module=modules/ngx_http_upstream_session_sticky_module \
--add-module=modules/ngx_http_upstream_check_module \
--add-module=modules/ngx_debug_pool \
--add-module=modules/ngx_debug_timer \
--add-module=modules/ngx_http_slice_module \
--add-module=modules/ngx_http_user_agent_module \
--add-module=modules/ngx_http_reqstat_module \
--add-module=modules/ngx_http_proxy_connect_module \
--add-module=modules/ngx_http_footer_filter_module \
    && make \
    && make install

FROM ubuntu:latest

# 设置工作目录
WORKDIR /app/tengine

# 从构建阶段复制文件
COPY --from=build /app/tengine /app/tengine

# 创建nginx命令的软链接
RUN ln -s /app/tengine/sbin/nginx /usr/sbin/nginx

# 设置时区，创建配置文件目录，并设置 Tengine 配置
RUN ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && mkdir -p /usr/local/nginx/mytcp /usr/local/nginx/meip \
    && echo 'user  root; \n\
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
    keepalive_requests 10000; \n\
    check_shm_size 50m; \n\
    #rewrite \n\
    include /usr/local/nginx/meip/*.conf; \n\
}' > /app/tengine/conf/nginx.conf

# 暴露容器端口号
EXPOSE 80 443

# 启动容器时自动启动 tengine
CMD ["nginx", "-g", "daemon off;"]
