#!/bin/bash

user='ADMIN_USER_HERE'
backup='BACKUP_DIR_HERE'
backup_name=$backup/nextcloud_snap_backup_$(date +%Y%m%d).tar.gz
nextcloud_dir='/var/snap/nextcloud'
bucket_name='BUCKET_NAME_HERE'


function backing_up() {

    if [[ $EUID > 0 ]]

        then echo "Please run as root"
        exit

    fi

    # Note: This is intended to be used with an external mount on AWS S3 Bucket:
    if [ ! -d $backup ]
    
        then echo "$backup folder not available. Please check"

    fi

    # Check if the nextcloud dir exists

    if [[ ! -d $nextcloud_dir ]]

        then echo "Nextcloud folder does not exist. Please check"

    else
        echo "Stopping Nextcloud instance"
        /usr/bin/snap stop nextcloud
        echo "Stopped successfully"

        echo "Removing previous backups"
        rm -rf $backup/nextcloud*
        echo "Removed successfully"

        
        echo "Achiving and backing up Nextcloud snap instance"
        tar -zcvpf $backup_name $nextcloud_dir
        
        echo "Backed up successfully"

        echo "Starting Nextcloud instance"
        /usr/bin/snap start nextcloud
        echo "Started successfully"

    fi

}


function mount_fuse() {
    s3fs $bucket_name -o use_cache=/tmp/cache -o allow_other -o uid=1001 -o mp_umask=002 -o multireq_max=5 $backup
}


function main_func() {
    if mount | grep $backup > /dev/null; then
        backing_up
    else
        mount_fuse
        backing_up
    fi

}

main_func