# gitea

[gitea](https://gitea.io/en-us/)  Gitea is a community managed lightweight code hosting solution.

## Container

### Repositories

- [Source Code](https://github.com/go-gitea/gitea)
- [Container](https://hub.docker.com/repository/docker/gautada/git

### Versions

- [September 10, 2021](https://dl.gitea.io/gitea) - Active version is 1.15.2 as tag [v1.15.2](https://github.com/go-gitea/gitea/tags)
- [May 25, 2022](https://github.com/go-gitea/gitea/tags) - Active version is 1.16.8 as tag [v1.16.8](https://github.com/go-gitea/gitea/releases/tag/v1.16.8)
### Manual



#### Build

```
docker build --build-arg ALPINE_VERSION=3.15.4 --build-arg GITEA_VERSION=v1.16.8 --file Containerfile --tag gitea:dev .
```

```
 docker run --detach --name gitea --publish 8082:8080 --volume ~/Workspace/gitea/gitea-container:/opt/gitea --rm gautada/gitea:1.16.8 
 ```

 
