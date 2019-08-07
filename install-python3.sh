#!/bin/bash
# System: CentOS 6.6
url='https://www.python.org/ftp/python/3.6.4/Python-3.6.4.tgz'
installPath='/usr/local/python3'

yum install -y gcc zlib-devel readline-devel openssl-devel
if [[ $? -ne 0 ]]; then
    echo 'It failed to install gcc.'
fi

wget $url -O python.tgz
if [[ $? -ne 0 ]]; then
    echo 'To download Python failed.'
    exit
fi

mkdir python3
tar -zxvf python.tgz -C python3 --strip-components 1

cd python3
# 创建安装目录
mkdir -p $installPath
# 指定到安装目录
./configure --prefix=$installPath
# 编译安装，耐心等待
make && make install

#2和3共存
ln -s /usr/local/python3/bin/python3 /usr/bin/python3
ln -s /usr/local/python3/bin/pip3 /usr/bin/pip3

# # 替换
# mv /usr/bin/python /usr/bin/python2.6.6
# ln -sf /usr/bin/python2.6.6 /usr/bin/python2
# ln -s /usr/local/python3/bin/python3 /usr/bin/python
# ln -s /usr/local/python3/bin/pip3 /usr/bin/pip
# sed -i 's/#!\/usr\/bin\/python/#!\/usr\/bin\/python2/g' /usr/bin/yum

pip3 install --upgrade pip