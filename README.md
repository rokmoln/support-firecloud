# support-firecloud [![Github Actions CI Status][2]][1]

`support-firecloud` is software and configuration that supports various cycles of software development, through a canonical set of commands.

This was conceived within [TobiiPro's Cloud Services](https://github.com/tobiipro/support-firecloud).

---

`git clone` this repository and you will gain access to:
  * **a bootstrap process of a developer machine based around GNU and Homebrew**
    * <a name="cross-platform"></a> cross-platform. No more worries about this is how it works on a developer machine (e.g. MacOS/Windows) and this is how it works in the CI (Linux). **Everything works the same everywhere!**
      * Apple MacOS
      * Linux (Alpine)
      * Linux (Debian)
      * Linux (Ubuntu)
      * Microsoft Windows (WSL)
      * [potentially more if you request/contribute it](https://github.com/rokmoln/support-firecloud/issues/new/choose)
    * brings common GNU utilities (bash, make, grep, sed, find, etc), version locked. No more worries about different flags, different behaviour or missing features!
    * brings [Homebrew](https://brew.sh). No more worries about different versions available in distros' repositositories, or libraries/utilities not being available at all.
  * **sane per-user configuration** (e.g. git)
  * **various utility scripts**, most of them written in pure bash making them easy to read through, easy to run
  * **documentation of common tasks** like bootstrapping, create github repositories, managing secrets, etc

---

Import this repository as a `submodule`, and you will gain access to:
  * **a bootstrap process of a CI machine based around GNU and Homebrew**
    * cross-provider. No more worries about the effort to add another CI or to switch to another CI. **Everything works the same everywhere!**
      * `AppVeyor_________` [![AppVeyor Status][14]][13]
      * `CircleCI_________` [![CircleCI Status][4]][3]
      * `Cirrus CI________` [![Cirrus CI Status][16]][15]
      * `Codeship_________` [![Codeship Status][8]][7]
      * `Drone CI_________` [![Drone CI Status][18]][17]
      * `Github Actions CI` [![Github Actions CI Status][2]][1]
      * `Gitlab CI________` [![Gitlab CI Status][12]][11]
      * `Semaphore________` [![Semaphore Status][10]][9]
      * `Travis CI________` [![Travis CI Status][6]][5]
        * Integration with Travis CI is unstable since it now requires a subscription.
        * [The new pricing model for travis-ci.com](https://blog.travis-ci.com/2020-11-02-travis-ci-new-billing)
        * [Travis CI's new pricing plan threw a wrench in my open source works](https://www.jeffgeerling.com/blog/2020/travis-cis-new-pricing-plan-threw-wrench-my-open-source-works)
        * [Travis CI is no longer providing CI minutes for open source projects](https://news.ycombinator.com/item?id=25338983)
    * cross-platform. See [above](#cross-platform).
    * Docker images available for Linux
      * Ubuntu 14.04 [minimal](https://hub.docker.com/r/rokmoln/sf-ubuntu-xenial-minimal) [common](https://hub.docker.com/r/rokmoln/sf-ubuntu-xenial-common)
      * Ubuntu 16.04 [minimal](https://hub.docker.com/r/rokmoln/sf-ubuntu-bionic-minimal) [common](https://hub.docker.com/r/rokmoln/sf-ubuntu-bionic-common)
      * Ubuntu 20.04 [minimal](https://hub.docker.com/r/rokmoln/sf-ubuntu-focal-minimal) [common](https://hub.docker.com/r/rokmoln/sf-ubuntu-focal-common)
      * Ubuntu 20.04 [minimal](https://hub.docker.com/r/rokmoln/sf-ubuntu-focal-minimal) [common](https://hub.docker.com/r/rokmoln/sf-ubuntu-focal-common)
      * Debian 9 [minimal](https://hub.docker.com/r/rokmoln/sf-debian-stretch-minimal) [common](https://hub.docker.com/r/rokmoln/sf-debian-stretch-common)
      * Debian 10 [minimal](https://hub.docker.com/r/rokmoln/sf-debian-buster-minimal) [common](https://hub.docker.com/r/rokmoln/sf-debian-buster-common)
      * [potentially more if you request/contribute it](https://github.com/rokmoln/support-firecloud/issues/new/choose)
  * **a robust yet flexible build system based on GNU Make**
  * **sane per-repo configuration** (e.g. vscode)
  * **various utility scripts**
  * **a robust yet flexible AWS CloudFormation build system based on GNU Make**

---

## Show me!

TODO

---

## Structure

* `/bin` has executable scripts, mostly shell
* `/sh` has common include shell scripts e.g. sourced from `/bin` shell scripts
*
* `/bootstrap` has scripts that help bootstrap a machine
* `/dev` has scripts that help bootstrap a developer machine
* `/dockerfiles` has bootstrapped Dockerfiles
*
* `/ci` has scripts that help steer the CI pipelines
*
* `/gitconfig` has git configuration
*
* `/repo` has configuration that is repo-specific, for those repositories bootstrapped with `support-firecloud`

---

## Documentation

* newcomer
  * [bootstrap](bootstrap/README.md)
* daily work
  * [`git` (and Github) Pull Requests](doc/working-with-git-pr.md)
  * [working with `make`](doc/working-with-make.md)
  * [working with a local `npm` dependency](doc/working-with-a-local-npm-dep.md)
  * [how to release](doc/how-to-release.md)
  * style
    * `Use common sense and BE CONSISTENT. (Google)`
    * [shell](doc/style-sh.md)
    * [Makefile](doc/style-mk.md)
    * [JavaScript/TypeScript](https://github.com/rokmoln/eslint-config-firecloud)
    * [SASS](https://github.com/rokmoln/sass-lint-config-firecloud)
* set up a new `git` repository
  * [new `git` (and Github) repositories](doc/working-with-git-new.md)
  * [how to license](doc/how-to-license.md)
  * [integrate Travis CI](doc/integrate-travis-ci.md)
  * [.ci.sh](ci/README.md)
  * [how to manage secrets](doc/how-to-manage-secrets.md)
* Amazon Web Services
  * [CloudFormation](aws-cfn.mk/README.md)
  * [Identity Access Management](doc/aws-iam.md)

---

## Writing

* https://developers.google.com/tech-writing/overview
* https://github.com/google/styleguide/blob/gh-pages/docguide/philosophy.md
* https://www.julian.com/guide/write/intro

---

## License

[Apache-2.0](LICENSE)


  [1]: https://github.com/rokmoln/support-firecloud/actions?query=workflow%3ACI+branch%3Amaster
  [2]: https://github.com/rokmoln/support-firecloud/workflows/CI/badge.svg?branch=master
  [3]: https://circleci.com/gh/rokmoln/support-firecloud/tree/master
  [4]: https://circleci.com/gh/rokmoln/support-firecloud/tree/master.svg?style=svg
  [5]: https://travis-ci.com/rokmoln/support-firecloud
  [6]: https://travis-ci.com/rokmoln/support-firecloud.svg?branch=master
  [7]: https://app.codeship.com/projects/388210
  [8]: https://app.codeship.com/projects/8fe9ad00-438f-0138-d313-2e664bcb50ed/status?branch=master
  [9]: https://rokmoln.semaphoreci.com/branches/3afa32fb-b027-4a02-8e99-8a4ba73dac12
  [10]: https://rokmoln.semaphoreci.com/badges/support-firecloud/branches/master.svg
  [11]: https://gitlab.com/rokmoln/support-firecloud/commits/master
  [12]: https://gitlab.com/rokmoln/support-firecloud/badges/master/pipeline.svg
  [13]: https://ci.appveyor.com/project/andreineculau/support-firecloud/branch/master
  [14]: https://ci.appveyor.com/api/projects/status/da744jauw31fi66h/branch/master?svg=true
  [15]: https://cirrus-ci.com/github/rokmoln/support-firecloud/master
  [16]: https://api.cirrus-ci.com/github/rokmoln/support-firecloud.svg?branch=master
  [17]: https://cloud.drone.io/rokmoln/support-firecloud
  [18]: https://cloud.drone.io/api/badges/rokmoln/support-firecloud/status.svg

[![Build Status]()]()
