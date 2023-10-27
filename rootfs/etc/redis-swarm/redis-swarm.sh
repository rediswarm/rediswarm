#!/bin/bash
# vim:sw=2:ts=2:sts=2:et
set -e
source "/.rediswarm"

cat /etc/redis-swarm/banner.txt

echo "- REDISWARM_MODE=${REDISWARM_MODE}"
echo "- REDISWARM_SLOT=${REDISWARM_SLOT}"
echo "- REDISWARM_SLOT_RETRY=${REDISWARM_SLOT_RETRY}"
echo "- REDISWARM_SLOT_TIMEOUT=${REDISWARM_SLOT_TIMEOUT}"
echo ""
