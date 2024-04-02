ARG ALPINE_VERSION=latest
# │ STAGE: source gitea                                           
# ╰―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
FROM gautada/alpine:$ALPINE_VERSION as src-gitea

ARG CONTAINER_VERSION=1.21.3
ARG GITEA_VERSION=$CONTAINER_VERSION
ARG GITEA_BRANCH=v"$GITEA_VERSION"

RUN /sbin/apk add --no-cache bash build-base git go nodejs npm

RUN git config --global advice.detachedHead false
RUN git clone --verbose --branch $GITEA_BRANCH --depth 1 https://github.com/go-gitea/gitea.git

WORKDIR /gitea
RUN TAGS="bindata" make clean-all build

# ╭―------------------------------------------------------------------------╮
# │                                                                         │
# │ STAGE 2: gitea-container                                                │
# │                                                                         │
# ╰―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――╯
FROM gautada/alpine:$ALPINE_VERSION

# ╭――――――――――――――――――――╮
# │ METADATA           │
# ╰――――――――――――――――――――╯
LABEL source="https://github.com/gautada/gitea-container.git"
LABEL maintainer="Adam Gautier <adam@gautier.org>"
LABEL description="A gitea container"

# ╭―
# │ USER
# ╰――――――――――――――――――――
ARG USER=gitea
RUN /usr/sbin/usermod -l $USER alpine
RUN /usr/sbin/usermod -d /home/$USER -m $USER
RUN /usr/sbin/groupmod -n $USER alpine
RUN /bin/echo "$USER:$USER" | /usr/sbin/chpasswd

# ╭―
# │ PRIVILEGES
# ╰――――――――――――――――――――
COPY privileges /etc/container/privileges

# ╭―
# │ BACKUP
# ╰――――――――――――――――――――
COPY backup /etc/container/backup

# ╭―
# │ ENTRYPOINT
# ╰――――――――――――――――――――
COPY entrypoint /etc/container/entrypoint

# ╭――――――――――――――――――――╮
# │ APPLICATION        │
# ╰――――――――――――――――――――╯

# /opt/gitea and /etc/gitea are needed for legacy support (mostly webhooks).
RUN /bin/mkdir -p /etc/gitea /opt/gitea \
 && /bin/ln -fsv /etc/container/app.ini /etc/gitea/app.ini \
 && /bin/ln -fsv /mnt/volumes/configmaps/app.ini /etc/container/app.ini \
 && /bin/ln -fsv /mnt/volumes/container/app.ini /mnt/volumes/configmaps/app.ini \
 && /bin/ln -fsv /etc/container/app.ini /opt/gitea/app.ini
 
RUN /sbin/apk add --no-cache bash git openssh-client
COPY --from=src-gitea /gitea/gitea /usr/bin/gitea
COPY --from=src-gitea /gitea/custom/conf/app.example.ini /etc/gitea/app.example.ini

RUN /bin/mkdir -p /mnt/volumes/container/custom \
 && /bin/mkdir -p /mnt/volumes/container/data \
 && /bin/mkdir -p /mnt/volumes/container/log \
 && /bin/mkdir -p /mnt/volumes/container/repos

# ╭――――――――――――――――――――╮
# │ SETTINGS           │
# ╰――――――――――――――――――――╯
USER $USER
VOLUME /mnt/volumes/backup
VOLUME /mnt/volumes/configmaps
VOLUME /mnt/volumes/container
VOLUME /mnt/volumes/secrets
EXPOSE 8080/tcp
WORKDIR /home/$USER