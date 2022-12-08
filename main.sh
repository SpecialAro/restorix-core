#!/bin/bash

if [[ -z "${MODE_ENV}" ]]; then
    MODE="backup"
else
    MODE="${MODE_ENV}"
fi

if [[ -z "${FILENAME_ENV}" ]]; then
    FILENAME="output"
else
    FILENAME="${FILENAME_ENV}"
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
    tar -C $TO_BACKUP_DIR -czvf "$FILENAME.tar.gz" .
    cp "$FILENAME.tar.gz" $BACKUPS_DIR
    echo "---- BACKUP ENDED ----"
    exit 0
fi
# --------------------- #

#### RESTORE UTILITY ####
if [[ "$MODE" == "restore" ]]; then
    echo "---- STARTING RESTORE ----"
    mkdir $RESTORED_DIR
    tar xvzf $BACKUPS_DIR/$FILENAME.tar.gz -C $RESTORED_DIR/.
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