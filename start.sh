#!/bin/bash
source ./utils/functions.sh

export WORKDIR=$(pwd)
export MODE=$(InitializeVars "MODE" "backup" "")

cat << "EOF"
██████  ███████ ███████ ████████  ██████  ██████  ██ ██   ██ 
██   ██ ██      ██         ██    ██    ██ ██   ██ ██  ██ ██  
██████  █████   ███████    ██    ██    ██ ██████  ██   ███   
██   ██ ██           ██    ██    ██    ██ ██   ██ ██  ██ ██  
██   ██ ███████ ███████    ██     ██████  ██   ██ ██ ██   ██ 
                                                                                                                          
v0.0.1-alpha.1
                                                                                                                          
EOF

if [[ -z "$CRONTAB_ENV" || $MODE != "backup" ]]; then
    bash ./main.sh
    exit 0
fi

# Load the crontab file
bash ./main.sh
crontab -l | { cat; echo "$CRONTAB_ENV bash $WORKDIR/main.sh"; } | crontab -

# Start cron
echo "Starting cron..."
crond -f