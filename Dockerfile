FROM alpine:3.12.1 as config-alpine

RUN apk add --no-cache tzdata

RUN cp -v /usr/share/zoneinfo/America/New_York /etc/localtime
RUN echo "America/New_York" > /etc/timezone

FROM alpine:edge as src-gitea

RUN apk add --no-cache bash build-base git go nodejs npm

RUN git clone --branch v1.13.0 --depth 1 https://github.com/go-gitea/gitea.git

WORKDIR /gitea

RUN TAGS="bindata" make build

FROM alpine:3.12.1

COPY --from=config-alpine /etc/localtime /etc/localtime
COPY --from=config-alpine /etc/timezone  /etc/timezone

EXPOSE 8080

RUN apk add --no-cache bash git

COPY --from=src-gitea /gitea/gitea /usr/bin/gitea
COPY --from=src-gitea /gitea/custom/conf/app.example.ini /etc/gitea/app.ini

RUN addgroup git \
 && adduser -D -s /bin/bash -G git git \
 && echo 'git:git' | chpasswd \
 && mkdir -p /opt/gitea-data/custom \
 && mkdir -p /opt/gitea-data/data \
 && mkdir -p /opt/gitea-data/log \
 && mkdir -p /opt/gitea-data/repos \
 && chown -R git:git /opt/gitea-data \
 && chmod -R 750 /opt/gitea-data 
#  && mkdir -p /etc/gitea \
#  && chown -R git:git /etc/gitea \
#  && chmod -R 770 /etc/gitea 

COPY app.ini /etc/gitea/app.ini
RUN chown -R git:git /etc/gitea \
 && chmod -R 770 /etc/gitea

COPY key-git.pub /home/git/.ssh/authorized_keys

USER git
WORKDIR /opt/gitea-data

ENTRYPOINT ["/usr/bin/gitea", "--config", "/opt/gitea-data/app.ini", "--work-path", "/opt/gitea-data", "--custom-path", "/opt/gitea-data/cusom"]
CMD ["web", "--port", "8080"]
# CMD ["tail", "-f", "/dev/null"]
