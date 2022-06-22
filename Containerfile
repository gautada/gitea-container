ARG ALPINE_VERSION=3.15.4

# ╭―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――╮
# │                                                                         │
# │ STAGE 1: src-postgres - Build postgres from source                      │
# │                                                                         │
# ╰―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――╯
FROM gautada/alpine:$ALPINE_VERSION as src-gitea

# ╭――――――――――――――――――――╮
# │ VERSION            │
# ╰――――――――――――――――――――╯
ARG GITEA_VERSION=1.16.8
ARG GITEA_BRANCH=v"$GITEA_VERSION"

# ╭――――――――――――――――――――╮
# │ PACKAGES           │
# ╰――――――――――――――――――――╯
RUN apk add --no-cache bash build-base git go nodejs npm

# ╭――――――――――――――――――――╮
# │ SOURCE             │
# ╰――――――――――――――――――――╯
RUN git clone --branch $GITEA_BRANCH --depth 1 https://github.com/go-gitea/gitea.git

# ╭――――――――――――――――――――╮
# │ BUILD              │
# ╰――――――――――――――――――――╯
WORKDIR /gitea
RUN TAGS="bindata" make build

# ╭―----------------------------------------------------------------------- -╮
# │                                                                         │
# │ STAGE 3: gitea-container                                                │
# │                                                                         │
# ╰―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――╯
FROM gautada/alpine:$ALPINE_VERSION

# ╭――――――――――――――――――――╮
# │ METADATA           │
# ╰――――――――――――――――――――╯
LABEL source="https://github.com/gautada/gitea-container.git"
LABEL maintainer="Adam Gautier <adam@gautier.org>"
LABEL description="A gitea container"

# ╭――――――――――――――――――――╮
# │ USER               │
# ╰――――――――――――――――――――╯
ARG UID=1001
ARG GID=1001
ARG USER=gitea
RUN /usr/sbin/addgroup -g $GID $USER \
 && /usr/sbin/adduser -D -G $USER -s /bin/ash -u $UID $USER \
 && /usr/sbin/usermod -aG wheel $USER \
 && /bin/echo "$USER:$USER" | chpasswd
 
# ╭――――――――――――――――――――╮
# │ PORTS              │
# ╰――――――――――――――――――――╯
EXPOSE 8080/tcp

# ╭――――――――――――――――――――╮
# │ ENTRYPOINT         │
# ╰――――――――――――――――――――╯
COPY 10-ep-container.sh /etc/container/entrypoint.d/10-ep-container.sh

# ╭――――――――――――――――――――╮
# │ BACKUP             │
# ╰――――――――――――――――――――╯
COPY container-backup.fnc /etc/container/backup.fnc

# ╭――――――――――――――――――――╮
# │ APPLICATION        │
# ╰――――――――――――――――――――╯
RUN apk add --no-cache bash git
COPY --from=src-gitea /gitea/gitea /usr/bin/gitea
COPY --from=src-gitea /gitea/custom/conf/app.example.ini /etc/gitea/app.example.ini
RUN mkdir -p /etc/gitea \
 && ln -s /opt/gitea/custom/conf/app.ini /etc/gitea/app.ini


# ╭――――――――――――――――――――╮
# │ FOLDERS            │
# ╰――――――――――――――――――――╯
RUN /bin/mkdir -p /opt/$USER/custom /opt/$USER/data /opt/$USER/log /opt/$USER/repos
RUN /bin/mkdir -p /opt/$USER \
 && /bin/chown -R $USER:$USER /opt/$USER /var/backup /tmp/backup /opt/backup
# RUN /bin/chown $USER:$USER -R /opt/$USER /etc/backup /var/backup /tmp/backup /opt/backup

# ╭――――――――――――――――――――╮
# │ SETTINGS           │
# ╰――――――――――――――――――――╯
USER $USER
WORKDIR /home/$USER
VOLUME /opt/$USER
