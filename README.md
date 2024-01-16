# gitea

flipflop

[gitea](https://gitea.io/en-us/)  Gitea is a community managed lightweight code hosting solution.

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
DROP DATABASE testdb;
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





