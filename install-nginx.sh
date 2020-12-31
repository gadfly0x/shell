#!/bin/bash
# System: CentOS 6.6
url='https://nginx.org/download/nginx-1.18.0.tar.gz'
# url='https://nginx.org/download/nginx-1.16.1.tar.gz'
installPath='/usr/local/nginx'

yum install -y gcc zlib-devel pcre-devel openssl openssl-devel
if [[ $? -ne 0 ]]; then
    echo 'It failed to install gcc,zlib-devel,pcre-devel.'
fi

wget $url -O nginx.tgz
if [[ $? -ne 0 ]]; then
    echo 'To download nginx failed.'
    exit
fi

mkdir nginx
tar -zxvf nginx.tgz -C nginx --strip-components 1

cd nginx
# 创建安装目录
mkdir -p $installPath
# 指定到安装目录
./configure --prefix=$installPath --with-http_stub_status_module --with-http_ssl_module --with-http_gzip_static_module --with-ipv6 --with-http_sub_module

# 编译安装，耐心等待
make -j && make install

echo 'export PATH=$PATH:/usr/local/nginx/sbin/' >> /etc/profile
echo 'export PATH' >> /etc/profile
source /etc/profile