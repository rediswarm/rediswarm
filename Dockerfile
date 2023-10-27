FROM redis:alpine

RUN apk update && apk add bash curl envsubst && rm -rf /var/cache/apk/*

# redis
EXPOSE 6379
# sentinel
EXPOSE 26379

ENV REDISWARM_MODE=redis
ENV REDISWARM_SLOT=1
ENV REDISWARM_SLOT_RETRY=10
ENV REDISWARM_SLOT_TIMEOUT=30
ENV REDISWARM_SECRET=redis-swarm

ENV REDIS_HOSTNAME_PREFIX=replica-
ENV REDIS_PRIMARY_PORT=6379
ENV REDIS_CONFIG_PATH=/etc/redis/config

ENV SENTINEL_HOSTNAME_PREFIX=sentinel-
ENV SENTINEL_QUORUM=2


ADD rootfs /

VOLUME [ "/etc/redis/config" ]
ENTRYPOINT [ "/docker-entrypoint.sh" ]
