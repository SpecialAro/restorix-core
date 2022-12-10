#!/bin/bash
cd $WORKDIR
source ./utils/functions.sh

APP_NAME_TAG="[RESTORIX]"
BACKUPS_DIR=/backup
TO_BACKUP_DIR=/tobackup
RESTORED_DIR=/restored


FILENAME=$(InitializeVars "FILENAME" "output" ".tar.gz")
MAX_FILESIZE=$(InitializeVars "MAX_FILESIZE" "4000m" "")

if ! [[ "$MODE" == "backup" || "$MODE" == "restore" ]]; then
    echo "FAILING"
    exit 1
fi

if ! [[ -z "${SSH_HOST_ENV}" && -z "${SSH_USERNAME_ENV}" && -z "${SSH_PASSWORD_ENV}" && -z "${SSH_PATH_ENV}" ]]; then
    SSH_HOST="${SSH_HOST_ENV}"
    SSH_USERNAME="${SSH_USERNAME_ENV}"
    SSH_PASSWORD="${SSH_PASSWORD_ENV}"
    SSH_PATH="${SSH_PATH_ENV}"
    BACKUPS_DIR="$BACKUPS_DIR"_temp

    if [[ -z "${SSH_PORT_ENV}" ]]; then
        SSH_PORT="backup"
    else
        SSH_PORT="${SSH_PORT_ENV}"
    fi
    USE_SSH=true
fi

mkdir -p $BACKUPS_DIR
#### BACKUP UTILITY ####
if [[ "$MODE" == "backup" ]]; then

    echo "$APP_NAME_TAG ---- STARTING BACKUP ----"
    pushd $BACKUPS_DIR 1> /dev/null
    rm -rf $FILENAME*
    tar -C $TO_BACKUP_DIR -cvzf - ./ | split -b $MAX_FILESIZE - "$FILENAME".

    if [[ "$USE_SSH" == "true" ]]; then
        echo "$APP_NAME_TAG SEND FILE THROUGH SSH: started"
        sshpass -p "$SSH_PASSWORD" scp -o "StrictHostKeyChecking=no" -r $BACKUPS_DIR/* $SSH_USERNAME@$SSH_HOST:$SSH_PATH
        echo "$APP_NAME_TAG SEND FILE THROUGH SSH: ended"
    fi
    popd 1> /dev/null
    echo "$APP_NAME_TAG ---- BACKUP ENDED ----"
    exit 0
fi
# --------------------- #

#### RESTORE UTILITY ####
if [[ "$MODE" == "restore" ]]; then
    echo "$APP_NAME_TAG ---- STARTING RESTORE ----"

    if [[ "$USE_SSH" == "true" ]]; then
        echo "$APP_NAME_TAG RECEIVE FILE THROUGH SSH: started"
        sshpass -p "$SSH_PASSWORD" scp -o "StrictHostKeyChecking=no" -r $SSH_USERNAME@$SSH_HOST:$SSH_PATH/* $BACKUPS_DIR
        echo "$APP_NAME_TAG RECEIVE FILE THROUGH SSH: ended"
    fi

    mkdir $RESTORED_DIR
    pushd $RESTORED_DIR 1> /dev/null
    cat $BACKUPS_DIR/$FILENAME.* | tar xzvf -

    for dir in $RESTORED_DIR/*/ ; do
        basename=$(basename $dir)
        docker volume create "$basename" 1> /dev/null

        docker run -v $basename:/data --name helper busybox true 1> /dev/null
        docker cp $dir/. helper:/data 1> /dev/null
        docker rm helper 1> /dev/null
    done
    popd 1> /dev/null
    echo "$APP_NAME_TAG ---- RESTORE ENDED ----"
    exit 0
fi
# --------------------- #