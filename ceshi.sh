#!/usr/bin/env bash
set -euo pipefail

# Global constants
TENGINE_VERSION="2.3.3"
TENGINE_DOWNLOAD_URL="http://tengine.taobao.org/download/tengine-${TENGINE_VERSION}.tar.gz"
TENGINE_DIR="/root/tengine-${TENGINE_VERSION}"

# Dependencies for different OS
CENTOS_PACKAGES=( epel-release gcc gcc-c++ autoconf automake pcre-devel openssl-devel libmcrypt libmcrypt-devel mcrypt mhash kernel-headers kernel-devel make )
DEBIAN_PACKAGES=( build-essential libpcre3 libpcre3-dev zlib1g-dev openssl libssl-dev gcc make iperf3 vim )

# Color codes for terminal
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# Functions
handle_error() {
    echo -e "${RED}[ERROR]${NC} $1"
    exit 1
}

handle_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

is_centos() {
    [ -f /etc/redhat-release ] || grep -q -i "centos" /etc/os-release
}

is_debian() {
    grep -q -i "debian" /etc/os-release
}

is_ubuntu() {
    grep -q -i "ubuntu" /etc/os-release
}

install_dependencies() {
    handle_info "Installing dependencies..."
    if is_centos; then
        sudo yum install -y "${CENTOS_PACKAGES[@]}" || handle_error "Failed to install dependencies on CentOS."
    elif is_debian || is_ubuntu; then
        sudo apt-get update && sudo apt-get install -y "${DEBIAN_PACKAGES[@]}" || handle_error "Failed to install dependencies on Debian or Ubuntu."
    else
        handle_error "Unsupported OS. This script supports CentOS, Debian and Ubuntu only."
    fi
}

download_tengine() {
    handle_info "Downloading Tengine..."
    wget -O "${TENGINE_DIR}.tar.gz" "$TENGINE_DOWNLOAD_URL" || handle_error "Failed to download Tengine."
    tar zxf "${TENGINE_DIR}.tar.gz" || handle_error "Failed to extract Tengine."
}

install_tengine() {
    handle_info "Installing Tengine..."
    pushd "$TENGINE_DIR"
    ./configure --with-http_realip_module --without-http_upstream_keepalive_module --with-stream --with-stream_ssl_module --with-stream_sni --add-module=modules/ngx_http_upstream_* --add-module=modules/ngx_debug_* --add-module=modules/ngx_http_slice_module --add-module=modules/ngx_http_user_agent_module --add-module=modules/ngx_http_reqstat_module --add-module=modules/ngx_http_proxy_connect_module --add-module=modules/ngx_http_footer_filter_module
    make && sudo make install || handle_error "Failed to install Tengine."
    sudo ln -sf /usr/local/nginx/sbin/nginx /usr/bin/nginx
    popd
}

configure_tengine() {
    handle_info "Configuring Tengine..."
    sudo mkdir -p /usr/local/nginx/mytcp /usr/local/nginx/meip
    sudo bash -c "cat > /usr/local/nginx/conf/nginx.conf" <<EOF
user  root;
worker_processes auto;
worker_rlimit_nofile 51200;
pid        /usr/local/nginx/logs/nginx.pid;
events
    {
        use epoll;
        worker_connections 51200;
        multi_accept on;
    }
stream {
    include /usr/local/nginx/mytcp/*.conf;
}
http {
    include       mime.types;
    default_type  application/octet-stream;
    sendfile        on;
    keepalive_timeout  120;
    keepalive_requests 10000;
    check_shm_size 50m;
    #rewrite
    include /usr/local/nginx/meip/*.conf;
}
EOF
}

start_tengine() {
    handle_info "Starting Tengine..."
    sudo systemctl start nginx || handle_error "Failed to start Tengine."
}

reload_tengine() {
    handle_info "Reloading Tengine..."
    sudo nginx -s reload || handle_error "Failed to reload Tengine."
}

# Main
install_dependencies
download_tengine
install_tengine
configure_tengine
start_tengine
reload_tengine
handle_info "Installation completed successfully!"
