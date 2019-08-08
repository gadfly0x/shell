#!/bin/bash
# System: CentOS 6+
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


REDISUSER=redis
read -p "Please input password:" REDISPORT
REDISCONF=/home/$REDISUSER/$REDISPORT.conf
REDISRUN=/home/$REDISUSER/run
REDISLOG=/home/$REDISUSER/log
REDISDIR=/home/$REDISUSER/lib/$REDISPORT
REDISSERVER=redisd
PIDFILE=$REDISRUN/$REDISPORT.pid
EXEC=/usr/local/bin/redis-server
CLIEXEC=/usr/local/bin/redis-cli


# 添加redis用户
useradd -s /sbin/nologin $REDISUSER
# 拷贝配置文件
cp redis.conf $REDISCONF
chown $REDISUSER.$REDISUSER $REDISCONF
# 创建目录
mkdir -p $REDISRUN $REDISLOG $REDISDIR
chown -R $REDISUSER.$REDISUSER $REDISRUN $REDISLOG $REDISDIR
# 修改命令所有者和所属组
chown $REDISUSER.$REDISUSER $EXEC
chown $REDISUSER.$REDISUSER $CLIEXEC
# 修改redis目录
sed -i "s#^dir ./#dir $REDISDIR#g" $REDISCONF
# 后台运行
sed -i 's/^daemonize no/daemonize yes/g' $REDISCONF
# 修改端口
sed -i "s/^port 6379/port $REDISPORT/g" $REDISCONF
# 允许外网访问
sed -i 's/^protected-mode yes/protected-mode no/g' $REDISCONF
# 修改pid文件
sed -i "s#^pidfile /var/run/redis_6379.pid#pidfile $PIDFILE#g" $REDISCONF
# 取消ip绑定
sed -i 's/^bind 127.0.0.1/#bind 127.0.0.1/g' $REDISCONF
# 关闭rdb
sed -i 's/^save 900 1/#save 900 1/g' $REDISCONF
sed -i 's/^save 300 10/#save 300 10/g' $REDISCONF
sed -i 's/^save 60 10000/#save 60 10000/g' $REDISCONF
sed -i 's/^#   save ""/save ""/g' $REDISCONF
# 开启aof
sed -i 's/appendonly no/appendonly yes/g' $REDISCONF
# 输入redis密码
read -p "Please input password:" PASSWORD
# 设置密码
sed -i "s/# requirepass foobared/requirepass $PASSWORD/g" $REDISCONF


# 关闭THP
echo never > /sys/kernel/mm/transparent_hugepage/enabled
# 永久关闭THP
echo 'echo never > /sys/kernel/mm/transparent_hugepage/enabled' >> /etc/rc.local
# 内存分配控制
sysctl vm.overcommit_memory=1
echo 'vm.overcommit_memory = 1' >> /etc/sysctl.conf
# TCP backlog
echo 511 > /proc/sys/net/core/somaxconn

# 添加环境变量
echo 'export PATH=$PATH:/usr/local/bin' >> ~/.bash_profile
source ~/.bash_profile
# 启动脚本复制一份放到/etc/init.d目录下
cp utils/redis_init_script /etc/init.d/$REDISSERVER
# 修改端口
sed -i "s/REDISPORT=6379/REDISPORT=$REDISPORT/g" /etc/init.d/$REDISSERVER
sed -i 's#PIDFILE=/var/run/redis_${REDISPORT}.pid#PIDFILE='$PIDFILE'#g' /etc/init.d/$REDISSERVER
sed -i 's#CONF="/etc/redis/${REDISPORT}.conf"#CONF='$REDISCONF'#g' /etc/init.d/$REDISSERVER
sed -i 's#$EXEC $CONF#su - '$REDISUSER' -s /bin/bash -c "$EXEC $CONF"#g' /etc/init.d/$REDISSERVER
# 开机自启
chkconfig $REDISSERVER on
# 用普通用户启动
# /usr/local/bin/redis-server $REDISCONF
service $REDISSERVER start

#二、性能
#设置最大内存maxmemory,推荐为主机内存的45%