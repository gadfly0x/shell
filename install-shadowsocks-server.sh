#!/bin/bash
yum install -y python-setuptools
easy_install pip
pip install shadowsocks

read -p "server_port:" server_port
read -p "local_port:" local_port
read -p "password:" password

echo '{
"server":"0.0.0.0",
"server_port":'$server_port',
"local_address": "127.0.0.1",
"local_port":'$local_port',
"password":"'$password'",
"timeout":300,
"method":"aes-256-cfb",
"fast_open": false,
"workers": 1
}' > /etc/shadowsocks.json

ssserver -c /etc/shadowsocks.json -d start