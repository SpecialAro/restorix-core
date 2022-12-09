#!/bin/bash
APP_NAME_TAG="[RESTORIX]:"

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

if ! [[ -z "$SSH_HOST_ENV" && "$SSH_USERNAME_ENV" && -z "$SSH_PASSWORD_ENV" && -z "$SSH_PATH_ENV" ]]; then
    
    SSH_HOST="${SSH_HOST_ENV}"
    SSH_USERNAME="${SSH_USERNAME_ENV}"
    SSH_PASSWORD="${SSH_PASSWORD_ENV}"
    SSH_PATH="${SSH_PATH_ENV}"

    if [[ -z "${SSH_PORT_ENV}" ]]; then
        SSH_PORT="backup"
    else
        SSH_PORT="${SSH_PORT_ENV}"
    fi

    USE_SSH=true
fi

BACKUPS_DIR=/backup
TO_BACKUP_DIR=/tobackup
RESTORED_DIR=/restored

#### BACKUP UTILITY ####
if [[ "$MODE" == "backup" ]]; then
    
    echo "$APP_NAME_TAG ---- STARTING BACKUP ----"
    cd $BACKUPS_DIR
    rm -rf $FILENAME*
    tar -C $BACKUPS_DIR -cvzf - . | split -b $MAX_FILESIZE - "$FILENAME".
    
    if [[ "$USE_SSH" == "true" ]]; then
        echo "$APP_NAME_TAG SEND FILE THROUGH SSH: started"
        sshpass -p "$SSH_PASSWORD" scp -o "StrictHostKeyChecking=no" -r $BACKUPS_DIR/* $SSH_USERNAME@$SSH_HOST:$SSH_PATH
        echo "$APP_NAME_TAG SEND FILE THROUGH SSH: ended"
    fi
    
    echo "$APP_NAME_TAG ---- BACKUP ENDED ----"
    exit 0
fi
# --------------------- #

#### RESTORE UTILITY ####
if [[ "$MODE" == "restore" ]]; then
    echo "$APP_NAME_TAG ---- STARTING RESTORE ----"
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
    echo "$APP_NAME_TAG ---- RESTORE ENDED ----"
    exit 0
fi
# --------------------- #