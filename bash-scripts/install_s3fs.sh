#!/bin/bash

# To run with sudo bash -x <script_name>
os=$(lsb_release -i | cut -f 2-)

if [[ $os == 'Debian' ]]; then
    apt-get install -y automake autotools-dev fuse g++ git libcurl4-gnutls-dev libfuse-dev libssl-dev libxml2-dev make pkg-config

elif [[ $os == 'AlmaLinux' ]]; then
    yum install automake fuse fuse-devel gcc-c++ git libcurl-devel libxml2-devel make openssl-devel  

else
    echo "Different OS"

fi

function install_s3fs() {

    s3fs_installed=$(which s3fs | grep s3fs)

    if [[ $? == 0 ]]; then
	    echo "S3FS already installed on this machine, moving on..."

    else
	    echo "S3FS not installed, installing now"

        git clone https://github.com/s3fs-fuse/s3fs-fuse.git
        cd s3fs-fuse && ./autogen.sh && ./configure --prefix=/usr --with-openssl
        make && make install
        which s3fs
    
    fi

}

install_s3fs