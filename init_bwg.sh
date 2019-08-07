#!/bin/bash
#本脚本适用于centos7.4
#
#创建用户，并设置sudo权限
read -p "Please input new username:" name
read -p "Please input new password:" password
useradd $name
if [ $? -eq 0 ];then
   echo "user ${name} is created successfully!!!"
else
   echo "user ${name} is created failly!!!"
   exit 1
fi
#sudo passwd $name会要求填入密码，下面将$pass作为密码传入
echo $password | passwd $name --stdin
if [ $? -eq 0 ];then
   echo "${name}'s password is set successfully"
else
   echo "${name}'s password is set failly!!!"
fi

# 添加sudo权限
echo "${name}    ALL=(ALL)       ALL" >> /etc/sudoers

#禁用密码登录
cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak
sed -i "s/^PasswordAuthentication yes/PasswordAuthentication no/g" /etc/ssh/sshd_config
#不允许root用户以ssh方式登陆
sed -i "s/^PermitRootLogin yes/PermitRootLogin no/g" /etc/ssh/sshd_config
#比较修改后的文件差异
diff /etc/ssh/sshd_config /etc/ssh/sshd_config.bak
#询问是否确认修改，确认则重启sshd，否则回滚配置文件
read -p "Are you sure？[y/N]" confirm
if [[ confirm -eq y ]]; then
    service sshd restart
else
    rm -f /etc/ssh/sshd_config
    mv /etc/ssh/sshd_config.bak /etc/ssh/sshd_config
fi

# 复制ssh公钥
cd /home/$name
mkdir .ssh
chmod 700 .ssh
chgrp $name .ssh
chown $name .ssh
read -p "Please input new public key:" public_key
echo "ssh-rsa ${public_key} ${name}" > /home/$name/.ssh/authorized_keys
chgrp $name /home/$name/.ssh/authorized_keys
chown $name /home/$name/.ssh/authorized_keys


### 禁用端口
# 启动
systemctl start firewalld
# 开机启动
systemctl enable firewalld
# 获取ssh端口
ssh_port=`netstat -ntlp|grep sshd |awk -F: '{if($4!="")print $4}'`
firewall-cmd --zone=public --add-port=$ssh_port/tcp --permanent
systemctl restart firewalld

