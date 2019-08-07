#!/bin/sh
#
#install golang
GO_DOWNLOAD_URL='https://dl.google.com/go/go1.9.3.linux-amd64.tar.gz'
GO_INSTALL_DIR='/usr/local'
GOROOT=$GO_INSTALL_DIR/go
GOPATH=$GO_INSTALL_DIR/gocode

wget $GO_DOWNLOAD_URL -O golang.tar.gz
if [[ $? -ne 0 ]]; then
    echo "It failed to download Golang!"
    exit
fi

tar -zxvf golang.tar.gz -C $GO_INSTALL_DIR
if [[ $? -ne 0 ]]; then
    echo "It failed to untar!"
    exit
fi

echo "export GOROOT="$GOROOT >> ~/.bashrc
echo "export GOPATH="$GOPATH >> ~/.bashrc
echo "export PATH=$PATH:"$GOROOT"/bin:"$GOPATH"/bin" >> ~/.bashrc
source ~/.bashrc
if [[ $? -ne 0 ]]; then
    echo "It failed to set environment variable!"
    exit
fi