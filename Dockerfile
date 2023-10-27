FROM redis:alpine

RUN apk update && apk add bash curl envsubst && rm -rf /var/cache/apk/*

# https://github.com/socheatsok78/s6-overlay-installer
ARG S6_OVERLAY_VERSION=v3.1.5.0
ARG S6_OVERLAY_INSTALLER=main/s6-overlay-installer.sh
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/socheatsok78/s6-overlay-installer/${S6_OVERLAY_INSTALLER})"
ENV S6_KEEP_ENV=1
ENV S6_VERBOSITY=1
ENV S6_BEHAVIOUR_IF_STAGE2_FAILS=2
CMD [ "sleep", "infinity" ]
ENTRYPOINT [ "/init" ]

# wait-for-it.sh
ADD https://raw.githubusercontent.com/vishnubob/wait-for-it/master/wait-for-it.sh /usr/local/bin/wait-for-it.sh
RUN chmod +x /usr/local/bin/wait-for-it.sh

# redis
EXPOSE 6379
# sentinel
EXPOSE 26379

ENV REDISWARM_MODE=redis
ENV REDISWARM_SLOT=1
ENV REDISWARM_SLOT_RETRY=10
ENV REDISWARM_SLOT_TIMEOUT=30
ENV REDISWARM_SECRET=redis-swarm

ENV REDIS_HOSTNAME_PREFIX=redis-
ENV REDIS_PRIMARY_ADDR=redis-1
ENV REDIS_PRIMARY_PORT=6379
ENV REDIS_CONFIG_PATH=/etc/redis/config

ENV SENTINEL_HOSTNAME_PREFIX=sentinel-
ENV SENTINEL_QUORUM=2


ADD rootfs /

VOLUME [ "/etc/redis/config" ]
