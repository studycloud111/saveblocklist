# 使用官方的 Ubuntu 镜像作为基础镜像
FROM ubuntu:22.04 AS build

# 设置环境变量
ENV LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    LC_ALL=en_US.UTF-8

# 设置工作目录
WORKDIR /root/tengine-3.1.0

# 复制文件到工作目录
COPY ./tengine-3.1.0 .

# 安装依赖并清理缓存
RUN apt-get update -qq \
    # 安装编译必需的包
    && apt-get install -y --no-install-recommends \
       build-essential \
       libpcre3-dev \
       zlib1g-dev \
       libssl-dev \
       gcc \
       make \
       wget \
       locales \
    # 生成语言环境
    && locale-gen en_US.UTF-8 \
    # 配置编译选项
    && ./configure --prefix=/usr/local/nginx \
       --with-debug \
       --with-http_realip_module \
       --without-http_upstream_keepalive_module \
       --with-stream \
       --with-stream_ssl_module \
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
    # 编译并安装
    && make -j$(nproc) \
    && make install \
    # 清理编译环境
    && apt-get remove -y build-essential gcc make \
    && apt-get autoremove -y \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

FROM ubuntu:22.04

# 设置环境变量
ENV TZ=Asia/Shanghai

# 安装运行时必需的包
RUN apt-get update -qq \
    && apt-get install -y --no-install-recommends \
       libpcre3 \
       zlib1g \
       openssl \
       curl \
       ca-certificates \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# 设置工作目录
WORKDIR /usr/local/nginx

# 从构建阶段复制文件
COPY --from=build /usr/local/nginx /usr/local/nginx

# 创建nginx命令的软链接
RUN ln -s /usr/local/nginx/sbin/nginx /usr/sbin/nginx

# 设置时区，创建配置文件目录，并设置 Tengine 配置
RUN ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && mkdir -p /usr/local/nginx/mytcp /usr/local/nginx/meip \
    # 创建 SSL 通用配置文件
    && echo 'ssl_certificate /usr/local/nginx/ngcrt.crt;\n\
ssl_certificate_key /usr/local/nginx/ng.key;\n\
ssl_session_cache shared:SSL:10m;\n\
ssl_session_timeout 10m;\n\
ssl_protocols TLSv1.2 TLSv1.3;' > /usr/local/nginx/mytcp/ssl_common.conf \
    # 创建代理通用配置文件
    && echo 'proxy_connect_timeout 5s;\n\
proxy_timeout 20s;\n\
proxy_next_upstream on;\n\
proxy_next_upstream_tries 3;\n\
proxy_next_upstream_timeout 10s;\n\
proxy_socket_keepalive on;\n\
proxy_protocol on;' > /usr/local/nginx/mytcp/proxy_common.conf \
    && echo 'user  root; \n\
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
    access_log off; \n\
    include       mime.types; \n\
    default_type  application/octet-stream; \n\
    sendfile        on; \n\
    keepalive_timeout  120; \n\
    keepalive_requests 10000; \n\
    check_shm_size 50m; \n\
    #rewrite \n\
    include /usr/local/nginx/meip/*.conf; \n\
}' > /usr/local/nginx/conf/nginx.conf

# 创建配置文件并写入内容
RUN echo 'server { \n\
        listen 80 default_server; \n\
        server_name _; \n\
        if ($server_port !~ 443){ \n\
            rewrite ^(/.*)$ https://$host$1 permanent; \n\
        } \n\
        location / { \n\
            root   html; \n\
            index  index.html index.htm; \n\
        } \n\
        error_page   500 502 503 504  /50x.html; \n\
        location = /50x.html { \n\
            root   html; \n\
        } \n\
    }' > /usr/local/nginx/mytcp/mysp.conf

# 添加 nginx.service 文件
RUN echo '[Unit] \n\
Description=The nginx HTTP and reverse proxy server \n\
After=syslog.target network.target remote-fs.target nss-lookup.target \n\
 \n\
[Service] \n\
Type=forking \n\
PIDFile=/usr/local/nginx/logs/nginx.pid \n\
ExecStartPre=/usr/local/nginx/sbin/nginx -t \n\
ExecStart=/usr/local/nginx/sbin/nginx \n\
ExecReload=/usr/local/nginx/sbin/nginx -s reload \n\
ExecStop=/usr/local/nginx/sbin/nginx -s stop \n\
PrivateTmp=true \n\
Restart=always \n\
 \n\
[Install] \n\
WantedBy=multi-user.target' > /etc/systemd/system/nginx.service

# 创建必要的目录
RUN mkdir -p /usr/local/nginx/logs \
    && touch /usr/local/nginx/logs/nginx.pid

# 复制 entrypoint 脚本到容器中
COPY entrypoint.sh /usr/local/bin/entrypoint.sh

# 使脚本可执行
RUN chmod +x /usr/local/bin/entrypoint.sh

# 设置容器的启动命令
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

# 暴露容器端口号
EXPOSE 80 443 3389
