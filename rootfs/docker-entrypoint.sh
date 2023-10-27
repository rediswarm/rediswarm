#!/bin/bash
# vim:sw=2:ts=2:sts=2:et
set -e
source "/.rediswarm"

ME=$(basename "$0")
MAXWAIT=30

cat /etc/redis-swarm/banner.txt

echo "- REDISWARM_MODE=${REDISWARM_MODE}"
echo "- REDISWARM_SLOT=${REDISWARM_SLOT}"
echo "- REDISWARM_SLOT_RETRY=${REDISWARM_SLOT_RETRY}"
echo "- REDISWARM_SLOT_TIMEOUT=${REDISWARM_SLOT_TIMEOUT}"
echo ""

function entrypoint_log() {
    if [ -z "${REDIS_QUIET_LOGS:-}" ]; then
        echo "$@"
    fi
}

function run_sentinel() {
    sleep $((RANDOM % MAXWAIT))

    # Attempt to connect to existing Sentinel
    # If we can't connect, we are the first node
    entrypoint_log -n "$ME: Attempting to contact existing Sentinel: "
    if redis-cli -h ${REDIS_SENTINEL_ADDR} -p ${REDIS_SENTINEL_PORT} INFO 2>&1 /dev/null; then
        while true; do
            _tmp_master=$(redis-cli -h ${REDIS_SENTINEL_ADDR} -p ${REDIS_SENTINEL_PORT} --csv SENTINEL get-master-addr-by-name mymaster | tr ',' ' ' | cut -d' ' -f1)
            if [[ -n ${_tmp_master} ]]; then
                REDIS_PRIMARY_ADDR="${_tmp_master//\"}"
            fi

            if redis-cli -h ${REDIS_PRIMARY_ADDR} INFO 2>&1 /dev/null; then
                export REDIS_PRIMARY_ADDR
                break
            fi

            entrypoint_log "$ME: Connecting to primary failed.  Waiting..."
            sleep 5
        done
    else
        export REDIS_PRIMARY_ADDR="${REDIS_HOSTNAME_PREFIX}1"
        echo ""
        entrypoint_log "$ME: No existing Sentinel node found, starting a new instance!"
        entrypoint_log "$ME: Auto-configuring \"${REDIS_PRIMARY_ADDR}\" as primary node!"
    fi

    # Generate sentinel.conf
    local template_file="/etc/redis/templates/sentinel.conf.template"
    local config_file="${REDIS_CONFIG_PATH}/sentinel.conf"
    local filter=""

    local defined_envs
    defined_envs=$(printf '${%s} ' $(awk "END { for (name in ENVIRON) { print ( name ~ /${filter}/ ) ? name : \"\" } }" < /dev/null ))

    entrypoint_log "$ME: Running envsubst on $template_file to $config_file"
    envsubst "$defined_envs" < "$template_file" > "$config_file"

    entrypoint_log "$ME: Starting Sentinel..."
    redis-sentinel "$config_file"
}

function run_redis() {
    sleep $((RANDOM % MAXWAIT))

    # Connect to Sentinel and request for primary node
    while true; do
        entrypoint_log -n "$ME: Attempting to contact existing Sentinel: "
        if redis-cli -h ${REDIS_SENTINEL_ADDR} -p ${REDIS_SENTINEL_PORT} INFO 2>&1 /dev/null; then
            echo ""

            _tmp_master=$(redis-cli -h ${REDIS_SENTINEL_ADDR} -p ${REDIS_SENTINEL_PORT} --csv SENTINEL get-master-addr-by-name mymaster | tr ',' ' ' | cut -d' ' -f1)
            if [[ -n ${_tmp_master} ]]; then
                REDIS_PRIMARY_ADDR="${_tmp_master//\"}"
            fi

            # Check if we are the primary node
            if [[ "$(hostname)" == "${REDIS_PRIMARY_ADDR}" ]]; then
                export REDIS_PRIMARY_ADDR
                entrypoint_log "$ME: Sentinel set me \"${REDIS_PRIMARY_ADDR}\" as the primary node!"
                break
            fi

            if redis-cli -h ${REDIS_PRIMARY_ADDR} INFO 2>&1 /dev/null; then
                export REDIS_PRIMARY_ADDR
                break
            fi

            entrypoint_log "$ME: Connecting to primary failed.  Waiting..."
        fi
        sleep 5
    done

    # Generate redis.conf
    local template_file="/etc/redis/templates/redis.conf.template"
    local config_file="${REDIS_CONFIG_PATH}/redis.conf"
    local filter=""

    local defined_envs
    defined_envs=$(printf '${%s} ' $(awk "END { for (name in ENVIRON) { print ( name ~ /${filter}/ ) ? name : \"\" } }" < /dev/null ))

    entrypoint_log "$ME: Running envsubst on $template_file to $config_file"
    envsubst "$defined_envs" < "$template_file" > "$config_file"

    entrypoint_log "$ME: Starting Redis..."
    redis-server "$config_file"
}

if [[ "${REDISWARM_MODE}" == "sentinel" ]]; then
    run_sentinel
    exit 0
fi

if [[ "${REDISWARM_MODE}" == "redis" ]]; then
    run_redis
    exit 0
fi
