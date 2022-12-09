#!/bin/bash

if [[ -z "${MODE_ENV}" ]]; then
    MODE="backup"
else
    MODE="${MODE_ENV}"
fi

if [[ -z "${FILENAME_ENV}" ]]; then
    FILENAME="output".tar.gz
else
    FILENAME="${FILENAME_ENV}".tar.gz
fi

if [[ -z "${MAX_FILESIZE_ENV}" ]]; then
    MAX_FILESIZE=4000m
else
    MAX_FILESIZE=${MAX_FILESIZE_ENV}
fi

if ! [[ "$MODE" == "backup" || "$MODE" == "restore" ]]; then
    echo "FAILING"
    exit 1
fi

BACKUPS_DIR=/backup
TO_BACKUP_DIR=/tobackup
RESTORED_DIR=/restored

#### BACKUP UTILITY ####
if [[ "$MODE" == "backup" ]]; then
    echo "---- STARTING BACKUP ----"
    cd $BACKUPS_DIR
    rm -rf $FILENAME*
    tar -C $TO_BACKUP_DIR -cvzf - . | split -b $MAX_FILESIZE - "$FILENAME".
    echo "---- BACKUP ENDED ----"
    exit 0
fi
# --------------------- #

#### RESTORE UTILITY ####
if [[ "$MODE" == "restore" ]]; then
    echo "---- STARTING RESTORE ----"
    mkdir $RESTORED_DIR
    cd $RESTORED_DIR
    cat $BACKUPS_DIR/$FILENAME.* | tar xzvf -
    for dir in $RESTORED_DIR/*/ ; do
        basename=$(basename $dir)2
        docker volume create "$basename"
        
        docker run -v $basename:/data --name helper busybox true
        docker cp $dir/. helper:/data
        docker rm helper
        
        echo "DIRECTORY $basename"
    done
    echo "---- RESTORE ENDED ----"
    exit 0
fi
# --------------------- #