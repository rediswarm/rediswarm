#!/command/with-contenv bash
# vim:sw=2:ts=2:sts=2:et
set -e

ME=$(basename "$0")

export REDIS_MASTER_PORT=${REDIS_MASTER_PORT:-6379}
export REDIS_SENTINEL_QUORUM=${REDIS_SENTINEL_QUORUM:-2}

entrypoint_log() {
    if [ -z "${REDIS_QUIET_LOGS:-}" ]; then
        echo "$@"
    fi
}

redis_slot_machine() {
    if [ ${REDIS_SLOT} -eq 1 ]; then
        entrypoint_log "$ME: Redis is running on slot 1, identify as primary!"
        export REDIS_MASTER_ADDR="${REDIS_HOSTNAME_PREFIX}1"
    else
        entrypoint_log "$ME: Redis is running on slot ${REDIS_SLOT}, identify as replica!"
        REDIS_MASTER_ADDR=""
        for((i=1;i<=${REDIS_SLOT_RETRY};i++)); do
            entrypoint_log "$ME: Attempting to find master on slot ${i}"
            REDIS_MASTER_ADDR="${REDIS_HOSTNAME_PREFIX}${i}"
            wait-for-it.sh --quiet -t 30 "${REDIS_MASTER_ADDR}:${REDIS_MASTER_PORT}" -s -- echo "$ME: Redis primary is up at ${REDIS_MASTER_ADDR}" && break
        done
        export REDIS_MASTER_ADDR
    fi
}

auto_envsubst() {
    local template_file="/etc/redis/template/sentinel.conf.template"
    local config_file="${REDIS_CONFIG_PATH}/sentinel.conf"
    local filter=""

    local defined_envs
    defined_envs=$(printf '${%s} ' $(awk "END { for (name in ENVIRON) { print ( name ~ /${filter}/ ) ? name : \"\" } }" < /dev/null ))

    entrypoint_log "$ME: Running envsubst on $template_file to $config_file"
    envsubst "$defined_envs" < "$template_file" > "$config_file"
}

redis_slot_machine
auto_envsubst

exit 0
