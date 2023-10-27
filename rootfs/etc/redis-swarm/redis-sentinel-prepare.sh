#!/command/with-contenv bash
# vim:sw=2:ts=2:sts=2:et
set -e
source "/.rediswarm"

ME=$(basename "$0")

entrypoint_log() {
    if [ -z "${REDIS_QUIET_LOGS:-}" ]; then
        echo "$@"
    fi
}

REDISWARM_SLOT_machine() {
    if [ ${REDISWARM_SLOT} -eq 1 ]; then
        entrypoint_log "$ME: Redis is running on slot 1, posibliy primary!"
        export REDIS_PRIMARY_ADDR="${REDIS_HOSTNAME_PREFIX}1"
    else
        REDIS_PRIMARY_ADDR=""
        for((i=1;i<=${REDISWARM_SLOT_RETRY};i++)); do
            entrypoint_log "$ME: Attempting to find master on slot ${i}"
            REDIS_PRIMARY_ADDR="${REDIS_HOSTNAME_PREFIX}${i}"
            wait-for-it.sh --quiet -t ${REDISWARM_SLOT_TIMEOUT} "${REDIS_PRIMARY_ADDR}:${REDIS_PRIMARY_PORT}" -s && break
        done
        export REDIS_PRIMARY_ADDR
        entrypoint_log "$ME: Redis is running on slot ${REDISWARM_SLOT}, identify as replica of ${REDIS_PRIMARY_ADDR} ${REDIS_PRIMARY_PORT}!"
    fi
}

auto_envsubst() {
    local template_file="/etc/redis/templates/sentinel.conf.template"
    local config_file="${REDIS_CONFIG_PATH}/sentinel.conf"
    local filter=""

    local defined_envs
    defined_envs=$(printf '${%s} ' $(awk "END { for (name in ENVIRON) { print ( name ~ /${filter}/ ) ? name : \"\" } }" < /dev/null ))

    if [ -f "$config_file" ]; then
        entrypoint_log "$ME: Sentinel config file \"$config_file\" already exists! [SKIPPED]"
    else
        entrypoint_log "$ME: Running envsubst on $template_file to $config_file"
        envsubst "$defined_envs" < "$template_file" > "$config_file"
    fi
    
}

REDISWARM_SLOT_machine
auto_envsubst
