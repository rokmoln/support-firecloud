# Bootstrap your system

We support Darwin (OSX) and Linux (Ubuntu) architectures.
The former is the main development architecture, while the latter is the main CI/CD architecture.

**We do NOT support Windows Subshell for Linux**,
but we do know that it is possible to successfully bootstrap Ubuntu distributions under it.
If you feel adventurous, read and improve our experimental notes on [working with WSL](README.wsl.md).


## GNU

In order to simplify our ~scripts~ lives, we expect GNU binaries, even on Darwin.

We hear you: but wouldn't it be possible to support BSD (Darwin) alternatives?
More like [unpossible](https://ponderthebits.com/2017/01/know-your-tools-linux-gnu-vs-mac-bsd-command-line-utilities-grep-strings-sed-and-find/)
because it's not enough to keep yourself to a POSIX common denominator, or to be a great Unix programmer,
but you really have to know and watch out for cornercases
driven by differences in implementation between GNU and BSD versions,
and that means everyone has to be that person.

We hear you again: will that not screw up other software on my computer expecting BSD behavior of `find`, `sed`, `grep`, etc?
If software depends on BSD behavior on Darwin, then they **SHOULD** use the full path e.g. `/usr/bin/find` instead of `find`.
Chances are in the 99%-realm high that everything will work just fine.


## Installation

Developer system-wide dependencies can be installed by

1. appending to your `~/.bashrc` (or `~/.bash_profile`), `~/.zshrc`, etc.:

```shell
# keep the next line as the last line in your shell rc/profile file
source ~/git/firecloud/support-firecloud/sh/dev.inc.sh
```

2. restarting your shell

3. running `~/git/firecloud/support-firecloud/dev/bootstrap`

**NOTE** You can also try to bootstrap without using `sudo`.
Run `SF_SUDO=sf_nosudo ~/git/firecloud/support-firecloud/dev/bootstrap` instead.

4. testing that everything is fine by checking that running `echo $SF_DEV_INC_SH` prints `true`.


## Repository

Repositories might require more system-wide dependencies e.g. `electron` or `erlang` or `go`.

These are defined in a file called `Brewfile.inc.sh` within each repository.

Run `make bootstrap` to install them.