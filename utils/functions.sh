function InitializeVars() {
    local argEnv=$(printenv | grep "$1_ENV" | cut -d '=' -f 2)
    if [[ -z "$argEnv" ]]; then
        local outVar=$2$3
    else
        local outVar=$argEnv$3
    fi
    echo $outVar
}