function install::nginx() {
  sudo apt-get install gcc libpcre3 libpcre3-dev zlib1g zlib1g-dev libssl-dev

  wget http://nginx.org/download/nginx-1.29.0.tar.gz
  tar -zxvf nginx-1.29.0.tar.gz && cd nginx-1.29.0

  ./configure --prefix=/usr/local/nginx \
    --with-http_ssl_module \
    --with-stream \
    --with-http_v2_module

  make && sudo make install
}

function install::keepalived() {
    sudo apt install keepalived
    keepalived --version
}