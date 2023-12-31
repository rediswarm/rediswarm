FROM redis:alpine

RUN apk update && apk add bash curl envsubst && rm -rf /var/cache/apk/*

# https://github.com/socheatsok78/s6-overlay-installer
ARG S6_OVERLAY_VERSION=v3.1.5.0
ARG S6_OVERLAY_INSTALLER=main/s6-overlay-installer.sh
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/socheatsok78/s6-overlay-installer/${S6_OVERLAY_INSTALLER})"
ARG S6_VERBOSITY=1
ARG S6_BEHAVIOUR_IF_STAGE2_FAILS=2
ENV S6_KEEP_ENV=1
ENV S6_VERBOSITY=${S6_VERBOSITY}
ENV S6_BEHAVIOUR_IF_STAGE2_FAILS=${S6_BEHAVIOUR_IF_STAGE2_FAILS}
CMD [ "sleep", "infinity" ]
ENTRYPOINT [ "/init" ]

# wait-for-it.sh
ADD https://raw.githubusercontent.com/vishnubob/wait-for-it/master/wait-for-it.sh /usr/local/bin/wait-for-it
RUN chmod +x /usr/local/bin/wait-for-it

ENV REDISWARM_MODE=redis
ENV REDISWARM_SLOT=1
# ENV REDISWARM_SECRET=
# ENV REDISWARM_SECRET_FILE=

ENV REDIS_HOSTNAME_PREFIX=replica-
ENV REDIS_PRIMARY_PORT=6379
ENV REDIS_CONFIG_PATH=/etc/redis/config

ENV REDIS_SENTINEL_ADDR=sentinel
ENV REDIS_SENTINEL_PORT=26379
ENV REDIS_SENTINEL_QUORUM=2
ENV REDIS_SENTINEL_HOSTNAME_PREFIX=sentinel-

ADD rootfs /
VOLUME [ "/etc/redis/config" ]

# redis
EXPOSE 6379
# sentinel
EXPOSE 26379
