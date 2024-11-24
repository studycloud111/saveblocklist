# 使用官方的 Ubuntu 镜像作为基础镜像
FROM ubuntu:22.04 AS build

# 设置环境变量
ENV LANG=en_US.UTF-8 LANGUAGE=en_US:en LC_ALL=en_US.UTF-8

# 设置工作目录
WORKDIR /root/tengine-3.1.0

# 复制文件到工作目录
COPY ./tengine-3.1.0 .

# 安装依赖并清理缓存
RUN apt-get update -qq \
    && apt-get install -y --no-install-recommends build-essential libpcre3 libpcre3-dev zlib1g-dev openssl libssl-dev gcc make iperf3 vim wget locales curl \
    && locale-gen en_US.UTF-8 \
    && ./configure --prefix=/app/tengine \
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
    && make -j$(nproc) \
    && make install \
    && apt-get remove -y build-essential gcc make \
    && apt-get autoremove -y \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

FROM ubuntu:22.04

# 设置环境变量
ENV TZ=Asia/Shanghai

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
    access_log off; \n\
    include       mime.types; \n\
    default_type  application/octet-stream; \n\
    sendfile        on; \n\
    keepalive_timeout  120; \n\
    keepalive_requests 10000; \n\
    check_shm_size 50m; \n\
    #rewrite \n\
    include /usr/local/nginx/meip/*.conf; \n\
}' > /app/tengine/conf/nginx.conf

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

# 复制 entrypoint 脚本到容器中
COPY entrypoint.sh /usr/local/bin/entrypoint.sh

# 使脚本可执行
RUN chmod +x /usr/local/bin/entrypoint.sh

# 设置容器的启动命令
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

# 暴露容器端口号
EXPOSE 80 443 3389
