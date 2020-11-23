# support-firecloud [![Github Actions CI Status][2]][1]

`support-firecloud` is software and configuration that supports various cycles of software development:
* as a standalone checkout, it provides
  * bootstrapping for a developer MacOS/Linux machine
    * bring common GNU utilities up-to-date on Linux and make them accesible on MacOS (BSD)
  * a builder for canonical Docker images
  * common per-user configuration (e.g. git)
  * various utility scripts
  * documentation of common tasks (e.g. licensing, managing secrets)
* as a submodule checkout, it provides
  * bootstrapping for a CI machine
    * the bootstrapping is so generic that it is very easy to use `support-firecloud` in a multitude of CI solutions
      * `AppVeyor_________` [![AppVeyor Status][14]][13]
      * `CircleCI_________` [![CircleCI Status][4]][3]
      * `Codeship_________` [![Codeship Status][8]][7]
      * `Github Actions CI` [![Github Actions CI Status][1]][2]
      * `Gitlab CI________` [![Gitlab CI Status][12]][11]
      * `Semaphore________` [![Semaphore Status][10]][9]
      * `Travis CI________` [![Travis CI Status][6]][5]
  * a robust yet flexible build system based on GNU Make
  * an AWS CloudFormation build system based on GNU Make
  * common per-repo configuration (e.g. vscode)
  * various utility scripts

This initially supported [TobiiPro's Cloud Services development](https://github.com/tobiipro/support-firecloud).


**IMPORTANT:** Repositories that have `support-firecloud` as a git submodule, need to be cloned **recursively**:
* by using `git clone --recursive ...`
* or by running `git submodule update --init --recursive` after cloning.


## Documentation

* newcomer
  * [bootstrap](doc/bootstrap.md)
  * [bootstrap your editor](doc/bootstrap-your-editor.md)
  * [bootstrap AWS (console and CLI)](doc/bootstrap-aws.md) (optional)
  * [bootstrap your `gpg` signature](doc/bootstrap-gpg.md) (optional)
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
  * [.ci.sh](doc/ci-sh.md)
  * [how to manage secrets](doc/how-to-manage-secrets.md)
* Amazon Web Services
  * [CloudFormation](repo/cfn/README.md)
  * [Identity Access Management](doc/aws-iam.md)


## Structure

* `/bin` has executable shell scripts
* `/sh` has common include shell scripts e.g. sourced from `/bin` shell scripts
*
* `/ci` has scripts that help bootstrap a CI machine
* `/dev` has scripts that help bootstrap a developer machine
* `/dockerfiles` has Dockerfiles bootstrapped with `support-firecloud`
*
* `/generic` has configuration that is not repo-specific
* `/repo` has configuration that is repo-specific, for those repositories bootstrapped with `support-firecloud`


## Writing

* https://developers.google.com/tech-writing/overview
* https://github.com/google/styleguide/blob/gh-pages/docguide/philosophy.md


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
