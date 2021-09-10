# gitea

[gitea](https://gitea.io/en-us/)  Gitea is a community managed lightweight code hosting solution.

## Container

### Repositories

- [Source Code](https://github.com/go-gitea/gitea)
- [Container](https://hub.docker.com/repository/docker/gautada/git

### Versions

- [September 10, 2021](https://dl.gitea.io/gitea) - Active version is 1.15.2 as tag [v1.15.2](https://github.com/go-gitea/gitea/tags)

### Manual

#### Build

```
docker build --build-arg ALPINE_TAG=3.14.2 --build-arg BRANCH=v1.15.2 --file Containerfile --tag gitea:dev .
```



 
