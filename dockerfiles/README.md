# Docker images

Docker images are built on each release of `support-firecloud`,
and pushed to https://hub.docker.com/u/rokmoln .

These images can then be used in CIs to skip not only the time-consuming process of bootstrapping,
but also to increase the determinism of the execution,
since there's absolute control on when and how the execution environment changes.

The images have

* an `sf:sf` sudoer user, intended as default user (don't use `root`)
* a `/support-firecloud` git clone
* a `/support-firecloud.bootstrapped` marker to denote that this machine has been bootstrapped
  * the file contents are the git hash of the `/support-firecloud` HEAD
* no aptitude cache (to reduce size)
* shallow git clones (to reduce size)
* linuxbrew installed, along with a collection of minimal/common packages


## `make docker-ci`

Same images can be used locally to run `make docker-ci`
which will spin a local Docker container, to mimic the environment in which the CI pipeline runs.
We say *mimic* because there's no access to the same environment variables, or the same bind mounts.

The container will have

* a `/support-firecloud/docker-ci` to denote that this machine is a docker-ci one
* a bind mount of the repository, to the same location relative to `$HOME` as on the host
e.g. `/Users/andrei/git/repo` on host will be `/home/sf/git/repo` on the container
* a sudoer user with the same UID:GID as on the host, same name,
possibly same group as well (if no collision)
