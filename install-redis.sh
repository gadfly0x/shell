#!/bin/bash
# System: CentOS 6.6
yum install -y gcc wget
url='http://download.redis.io/releases/redis-5.0.5.tar.gz'
installPath='/usr/local/redis'

wget $url -O redis.tar.gz
if [[ $? -ne 0 ]]; then
    echo 'It failed to download Redis.'
    exit
fi

tar -vxzf redis.tar.gz
cd redis-5.0.5
make
cd src
make install
cd ..

read -p "Please input password:" password

mkdir /etc/redis
cp /etc/redis.conf /etc/redis/36000.conf
# 后台运行
sed -i 's/daemonize no/daemonize yes/g' /etc/redis/36000.conf
# 修改端口
sed -i 's/port 6379/port 36000/g' /etc/redis/36000.conf
# 允许外网访问
sed -i 's/protected-mode yes/protected-mode no/g' /etc/redis/36000.conf
# 设置密码
sed -i "s/# requirepass foobared/requirepass $password/g" /etc/redis/36000.conf
# 修改pid文件名
sed -i 's#pidfile /var/run/redis_6379.pid#pidfile /var/run/redis_36000.pid#g' /etc/redis/36000.conf
# 取消ip绑定
sed -i 's/^bind 127.0.0.1/#bind 127.0.0.1/g' /etc/redis/36000.conf

# 关闭rdb
sed -i 's/save 900 1/#save 900 1/g' /etc/redis/36000.conf
sed -i 's/save 300 10/#save 300 10/g' /etc/redis/36000.conf
sed -i 's/save 60 10000/#save 60 10000/g' /etc/redis/36000.conf
sed -i 's/#   save ""/save ""/g' /etc/redis/36000.conf
# 开启aof
sed -i 's/appendonly no/appendonly yes/g' /etc/redis/36000.conf
# 添加环境变量
echo 'export PATH=$PATH:/usr/local/bin' >> ~/.bash_profile
source ~/.bash_profile
# 启动脚本复制一份放到/etc/init.d目录下
cp utils/redis_init_script /etc/init.d/redisd
# 修改端口
sed -i 's/REDISPORT=6379/REDISPORT=36000/g' /etc/init.d/redisd
# 开机自启
chkconfig redisd on
# 启动
service redisd start