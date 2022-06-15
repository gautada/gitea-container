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




# ╭――――――――――――――――-------------------------------------------------------――╮
# │                                                                         │
# │ STAGE 3: postgres-container                                             │
# │                                                                         │
# ╰―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――╯
FROM gautada/alpine:$ALPINE_VERSION

# ╭――――――――――――――――――――╮
# │ METADATA           │
# ╰――――――――――――――――――――╯
LABEL source="https://github.com/gautada/gitea-container.git"
LABEL maintainer="Adam Gautier <adam@gautier.org>"
LABEL description="A gitea container"

# ╭――――――――――――――――――――╮
# │ PORTS              │
# ╰――――――――――――――――――――╯
EXPOSE 8080/tcp

# ╭――――――――――――――――――――╮
# │ ENTRYPOINT         │
# ╰――――――――――――――――――――╯
COPY 10-ep-container.sh /etc/entrypoint.d/10-ep-container.sh

# ╭――――――――――――――――――――╮
# │ BACKUP             │
# ╰――――――――――――――――――――╯
COPY container-backup.fnc /etc/backup/container-backup.fnc

# ╭――――――――――――――――――――╮
# │ APPLICATION        │
# ╰――――――――――――――――――――╯
COPY --from=src-gitea /gitea/gitea /usr/bin/gitea
COPY --from=src-gitea /gitea/custom/conf/app.example.ini /etc/gitea/app.ini


# ╭――――――――――――――――――――╮
# │ USER               │
# ╰――――――――――――――――――――╯
ARG USER=gitea
VOLUME /opt/$USER

RUN /bin/mkdir -p /opt/$USER/custom /opt/$USER/data /opt/$USER/log /opt/$USER/repos \
 && /usr/sbin/addgroup $USER \
 && /usr/sbin/adduser -D -s /bin/ash -G $USER $USER \
 && /usr/sbin/usermod -aG wheel $USER \
 && /bin/echo "$USER:$USER" | chpasswd \
 && /bin/chown $USER:$USER -R /opt/$USER

USER $USER
WORKDIR /home/$USER

