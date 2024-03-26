# gitea

[gitea](https://gitea.io/en-us/)  Gitea is a community managed lightweight code hosting solution.

ff

Features

- **git** - Provides a complete git host.

**UPGRADING**

Setup a `testdb` so the upgrade can be tested.

Dump the existing database
```
pg_dump -U gitea giteadb > giteadb.sql
``` 

Create the test db
```
createdb -h localhost -U gitea -T template0 testdb
```

Restore the old db to new db
```
psql -U gitea testdb -f giteadb.sql
```

Drop the test db after the test
```
dropdb testdb

```

Run the upgrade doctor
```
/usr/bin/gitea -c /mnt/volumes/configmaps/gitea.ini doctor recreate-table project system_setting
```
---


### Feature Detail

{ Provide specific details regarding the feature }

## Development | Testing | Deploy

Converted to `docker compose`

## Architecture

### Context

### Container

### Components

## Administration

### Checklist

- [ X ] README conforms to the [gist](https://gist.github.com/gautada/ec549c846e8e50daf355d01b06eb0665)
- [ ] .gitignore conforms to the [gist](https://gist.github.com/gautada/3a0a4a76d3c7e4539e71fc02c7f599ad)
- [ ] Confirm the drone.yml file
- [ ] Volume folders are present (development-volume & backup-volume)
- [ ] docker-compose(.yml) works
- [ ] Manifst folder present (and origin to private repository is correct
- [ ] Issue List is linked to proper URI
- [ ] Signoff ({date and signature of last check})
- [ ] Confirm backup (maybe add to testing layer)
- [ ] Confirm healthcheck (maybe add to testing layer)
- [ ] Regenerate all architecture images


### Issues

The official to list is kept in a [GitHub Issue List](https://github.com/gautada/gitea-container/issues)

## Notes

- Change origin on git repo: `git remote set-url origin https://git.gautier.org/kubernetes/gitea-manifest.git `
- 2024-02-05: Updating to use the hourly backup mechanism 









# Begin env-to-ini build
# RUN go build contrib/environment-to-ini/environment-to-ini.go

# ╭―------------------------------------------------------------------------╮
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

# FOLDERS
RUN /bin/chown -R $USER:$USER /mnt/volumes/container \
 && /bin/chown -R $USER:$USER /mnt/volumes/backup 
 
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
EXPOSE 8080/tcp
WORKDIR /home/$USER




