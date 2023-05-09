#!/bin/bash

mount_dir='MOUNT_DIR_HERE'
bucket_name='BUCKET_NAME_HERE'


function mount_and_fstab() {

    if [[ ! -d $mount_dir ]]; then 
    
        echo "$mount_dir not present. Creating folder"
        mkdir -p $mount_dir

    else
        echo "$mount_dir already exists, moving on..."
    fi

    echo "Mount bucket to $mount_dir"
    s3fs $bucket_name -o use_cache=/tmp/cache -o allow_other -o uid=1001 -o mp_umask=002 -o multireq_max=5 $mount_dir

    echo "Check FSTAB"

    s3fs_fstab=$(cat /etc/fstab | grep s3fs)

    if [[ $? == 0 ]]; then
        echo "FSTAB entry already exists, moving on..."
    
    else
        echo "FSTAB entry does not exists, adding now..."
        echo "s3fs#$bucket_name $mount_dir fuse _netdev,allow_other,umask=227,uid=33,gid=33,use_cache=/root/cache 0 0" >> /etc/fstab
    fi
}

mount_and_fstab