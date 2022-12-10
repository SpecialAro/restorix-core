#!/bin/bash
source ./utils/functions.sh

export WORKDIR=$(pwd)
export MODE=$(InitializeVars "MODE" "backup" "")
export APP_NAME_TAG="[RESTORIX]"
APP_VERSION=$(cat version.txt)

cat << "EOF"
██████  ███████ ███████ ████████  ██████  ██████  ██ ██   ██ 
██   ██ ██      ██         ██    ██    ██ ██   ██ ██  ██ ██  
██████  █████   ███████    ██    ██    ██ ██████  ██   ███   
██   ██ ██           ██    ██    ██    ██ ██   ██ ██  ██ ██  
██   ██ ███████ ███████    ██     ██████  ██   ██ ██ ██   ██ 
                                                                                                                                                                                     
                                                                                                                                                                                     
EOF
echo "                        Version:                             "
echo "                        $APP_VERSION                         "
echo "                                                             "
echo "                                                             "


if [[ -z "$CRONTAB_ENV" || $MODE != "backup" ]]; then
    bash ./main.sh
    exit 0
fi

# Load the crontab file
bash ./main.sh
crontab -l | { cat; echo "$CRONTAB_ENV bash $WORKDIR/main.sh"; } | crontab -

# Start cron
echo "$APP_NAME_TAG Starting cron..."
crond -f