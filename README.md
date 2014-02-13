# Groom your app’s Lua environment with luaenv.

Use luaenv to pick a Lua version for your application and guarantee
that your development environment matches production. It works exactly like
[rbenv](https://github.com/sstephenson/rbenv) since it is rbenv but with lua
names.

**Powerful in development.** Specify your app's Lua version once,
  in a single file. Keep all your teammates on the same page. No
  headaches running apps on different versions of Lua. Just Works™
  from the command line and with app servers.
  Override the Lua version anytime: just set an environment variable.

**Rock-solid in production.** Your application's executables are its
  interface with ops. With luaenv you'll never again need to `cd` in a cron job
  or Chef recipe to ensure you've selected the right runtime. The Lua version
  dependency lives in one place—your app—so upgrades and rollbacks are atomic,
  even when you switch versions.

**One thing well.** luaenv is concerned solely with switching Lua
  versions. It's simple and predictable. A rich plugin ecosystem lets
<<<<<<< HEAD
  you tailor it to suit your needs. Compile your own Lua versions, or
  use the [lua-build](https://github.com/cehoffman/lua-build)
=======
  you tailor it to suit your needs. Compile your own Lua versions, or
  use the [lua-build][]
>>>>>>> sstephenson/master
  plugin to automate the process. Specify per-application environment
  variables with [luaenv-vars](https://github.com/cehoffman/luaenv-vars).
  See more [plugins on the
  wiki](https://github.com/cehoffman/luaenv/wiki/Plugins).

## Table of Contents

* [How It Works](#how-it-works)
  * [Understanding PATH](#understanding-path)
  * [Understanding Shims](#understanding-shims)
  * [Choosing the Lua Version](#choosing-the-lua-version)
  * [Locating the Lua Installation](#locating-the-lua-installation)
* [Installation](#installation)
  * [Basic GitHub Checkout](#basic-github-checkout)
    * [Upgrading](#upgrading)
  * [Homebrew on Mac OS X](#homebrew-on-mac-os-x)
<<<<<<< HEAD
  * [Neckbeard Configuration](#neckbeard-configuration)
  * [Uninstalling Lua Versions](#uninstalling-lua-versions)
=======
  * [How luaenv hooks into your shell](#how-luaenv-hooks-into-your-shell)
  * [Installing Lua Versions](#installing-lua-versions)
  * [Uninstalling Lua Versions](#uninstalling-lua-versions)
>>>>>>> sstephenson/master
* [Command Reference](#command-reference)
  * [luaenv local](#luaenv-local)
  * [luaenv global](#luaenv-global)
  * [luaenv shell](#luaenv-shell)
  * [luaenv versions](#luaenv-versions)
  * [luaenv version](#luaenv-version)
  * [luaenv rehash](#luaenv-rehash)
  * [luaenv which](#luaenv-which)
  * [luaenv whence](#luaenv-whence)
* [Development](#development)
  * [Version History](#version-history)
  * [License](#license)

## How It Works

At a high level, luaenv intercepts Lua commands using shim
executables injected into your `PATH`, determines which Lua version
has been specified by your application, and passes your commands along
to the correct Lua installation.

### Understanding PATH

When you run a command like `lua` or `rake`, your operating system
searches through a list of directories to find an executable file with
that name. This list of directories lives in an environment variable
called `PATH`, with each directory in the list separated by a colon:

    /usr/local/bin:/usr/bin:/bin

Directories in `PATH` are searched from left to right, so a matching
executable in a directory at the beginning of the list takes
precedence over another one at the end. In this example, the
`/usr/local/bin` directory will be searched first, then `/usr/bin`,
then `/bin`.

### Understanding Shims

luaenv works by inserting a directory of _shims_ at the front of your
`PATH`:

    ~/.luaenv/shims:/usr/local/bin:/usr/bin:/bin

Through a process called _rehashing_, luaenv maintains shims in that
directory to match every Lua command across every installed version
of Lua—`luac`, `lake`, `lua`, and so on.

Shims are lightweight executables that simply pass your command along
to luaenv. So with luaenv installed, when you run, say, `luac`, your
operating system will do the following:

* Search your `PATH` for an executable file named `luac`
* Find the luaenv shim named `luac` at the beginning of your `PATH`
* Run the shim named `luac`, which in turn passes the command along to
  luaenv

### Choosing the Lua Version

When you execute a shim, luaenv determines which Lua version to use by
reading it from the following sources, in this order:

1. The `LUAENV_VERSION` environment variable, if specified. You can use
   the [`luaenv shell`](#luaenv-shell) command to set this environment
   variable in your current shell session.

<<<<<<< HEAD
2. The application-specific `.lua-version` file in the current
   directory, if present. You can modify the current directory's
   `.lua-version` file with the [`luaenv local`](#luaenv-local)
   command.

3. The first `.lua-version` file found by searching each parent
   directory until reaching the root of your filesystem, if any.
=======
2. The first `.lua-version` file found by searching the directory of the
   script you are executing and each of its parent directories until reaching
   the root of your filesystem.

3. The first `.lua-version` file found by searching the current working
   directory and each of its parent directories until reaching the root of your
   filesystem. You can modify the `.lua-version` file in the current working
   directory with the [`luaenv local`](#luaenv-local) command.
>>>>>>> sstephenson/master

4. The global `~/.luaenv/version` file. You can modify this file using
   the [`luaenv global`](#luaenv-global) command. If the global version
   file is not present, luaenv assumes you want to use the "system"
   Lua—i.e. whatever version would be run if luaenv weren't in your
   path.

### Locating the Lua Installation

Once luaenv has determined which version of Lua your application has
specified, it passes the command along to the corresponding Lua
installation.

Each Lua version is installed into its own directory under
`~/.luaenv/versions`. For example, you might have these versions
installed:

* `~/.luaenv/versions/5.1.5/`
* `~/.luaenv/versions/5.2.1/`
* `~/.luaenv/versions/luajit-2.0.1/`

Version names to luaenv are simply the names of the directories in
`~/.luaenv/versions`.

## Installation

### Basic GitHub Checkout

This will get you going with the latest version of luaenv and make it
easy to fork and contribute any changes back upstream.

1. Check out luaenv into `~/.luaenv`.

    ~~~ sh
<<<<<<< HEAD
    $ git clone git://github.com/cehoffman/luaenv.git ~/.luaenv
=======
    $ git clone https://github.com/sstephenson/luaenv.git ~/.luaenv
>>>>>>> sstephenson/master
    ~~~

2. Add `~/.luaenv/bin` to your `$PATH` for access to the `luaenv`
   command-line utility.

    ~~~ sh
    $ echo 'export PATH="$HOME/.luaenv/bin:$PATH"' >> ~/.bash_profile
    ~~~

    **Ubuntu Desktop note**: Modify your `~/.bashrc` instead of `~/.bash_profile`.

    **Zsh note**: Modify your `~/.zshrc` file instead of `~/.bash_profile`.

3. Add `luaenv init` to your shell to enable shims and autocompletion.

    ~~~ sh
    $ echo 'eval "$(luaenv init -)"' >> ~/.bash_profile
    ~~~

    _Same as in previous step, use `~/.bashrc` on Ubuntu, or `~/.zshrc` for Zsh._

<<<<<<< HEAD
4. Restart your shell as a login shell so the path changes take effect.
    You can now begin using luaenv.
=======
4. Restart your shell so that PATH changes take effect. (Opening a new
   terminal tab will usually do it.) Now check if luaenv was set up:
>>>>>>> sstephenson/master

    ~~~ sh
    $ type luaenv
    #=> "luaenv is a function"
    ~~~

<<<<<<< HEAD
5. Install [lua-build](https://github.com/cehoffman/lua-build),
   which provides an `luaenv install` command that simplifies the
   process of installing new Lua versions.

    ~~~
    $ luaenv install 5.2.1
    ~~~

   As an alternative, you can download and compile Lua yourself into
   `~/.luaenv/versions/`.

6. Rebuild the shim executables. You should do this any time you
   install a new Lua executable (for example, when installing a new
   Lua version, or when installing a gem that provides a command).

    ~~~
    $ luaenv rehash
    ~~~
=======
5. _(Optional)_ Install [lua-build][], which provides the
   `luaenv install` command that simplifies the process of
   [installing new Lua versions](#installing-lua-versions).
>>>>>>> sstephenson/master

#### Upgrading

If you've installed luaenv manually using git, you can upgrade your
installation to the cutting-edge version at any time.

~~~ sh
$ cd ~/.luaenv
$ git pull
~~~

To use a specific release of luaenv, check out the corresponding tag:

~~~ sh
$ cd ~/.luaenv
$ git fetch
$ git checkout v0.3.0
~~~

If you've [installed via Homebrew](#homebrew-on-mac-os-x), then upgrade
via its `brew` command:

~~~ sh
$ brew update
$ brew upgrade luaenv lua-build
~~~

### Homebrew on Mac OS X

<<<<<<< HEAD
You can also install luaenv using the
[Homebrew](http://mxcl.github.com/homebrew/) package manager on Mac OS
X.

~~~
$ brew update
$ brew install luaenv
$ brew install lua-build
~~~

To later update these installs, use `upgrade` instead of `install`.

Afterwards you'll still need to add `eval "$(luaenv init -)"` to your
=======
As an alternative to installation via GitHub checkout, you can install
luaenv and [lua-build][] using the [Homebrew](http://brew.sh) package
manager on Mac OS X:

~~~
$ brew update
$ brew install luaenv lua-build
~~~

Afterwards you'll still need to add `eval "$(luaenv init -)"` to your
>>>>>>> sstephenson/master
profile as stated in the caveats. You'll only ever have to do this
once.

### How luaenv hooks into your shell

Skip this section unless you must know what every line in your shell
profile is doing.

`luaenv init` is the only command that crosses the line of loading
extra commands into your shell. Coming from RVM, some of you might be
opposed to this idea. Here's what `luaenv init` actually does:

1. Sets up your shims path. This is the only requirement for luaenv to
   function properly. You can do this by hand by prepending
   `~/.luaenv/shims` to your `$PATH`.

2. Installs autocompletion. This is entirely optional but pretty
   useful. Sourcing `~/.luaenv/completions/luaenv.bash` will set that
   up. There is also a `~/.luaenv/completions/luaenv.zsh` for Zsh
   users.

3. Rehashes shims. From time to time you'll need to rebuild your
   shim files. Doing this automatically makes sure everything is up to
   date. You can always run `luaenv rehash` manually.

4. Installs the sh dispatcher. This bit is also optional, but allows
   luaenv and plugins to change variables in your current shell, making
   commands like `luaenv shell` possible. The sh dispatcher doesn't do
   anything crazy like override `cd` or hack your shell prompt, but if
   for some reason you need `luaenv` to be a real script rather than a
   shell function, you can safely skip it.

Run `luaenv init -` for yourself to see exactly what happens under the
hood.

<<<<<<< HEAD
### Uninstalling Lua Versions
=======
### Installing Lua Versions

The `luaenv install` command doesn't ship with luaenv out of the box, but
is provided by the [lua-build][] project. If you installed it either
as part of GitHub checkout process outlined above or via Homebrew, you
should be able to:

~~~ sh
# list all available versions:
$ luaenv install -l

# install a Lua version:
$ luaenv install 2.0.0-p247
~~~

Alternatively to the `install` command, you can download and compile
Lua manually as a subdirectory of `~/.luaenv/versions/`. An entry in
that directory can also be a symlink to a Lua version installed
elsewhere on the filesystem. luaenv doesn't care; it will simply treat
any entry in the `versions/` directory as a separate Lua version.

### Uninstalling Lua Versions
>>>>>>> sstephenson/master

As time goes on, Lua versions you install will accumulate in your
`~/.luaenv/versions` directory.

To remove old Lua versions, simply `rm -rf` the directory of the
version you want to remove. You can find the directory of a particular
Lua version with the `luaenv prefix` command, e.g. `luaenv prefix
luajit-2.0.1`.

<<<<<<< HEAD
The [lua-build](https://github.com/cehoffman/lua-build) plugin
provides an `luaenv uninstall` command to automate the removal
process.
=======
The [lua-build][] plugin provides an `luaenv uninstall` command to
automate the removal process.
>>>>>>> sstephenson/master

## Command Reference

Like `git`, the `luaenv` command delegates to subcommands based on its
first argument. The most common subcommands are:

### luaenv local

Sets a local application-specific Lua version by writing the version
name to a `.lua-version` file in the current directory. This version
overrides the global version, and can be overridden itself by setting
the `LUAENV_VERSION` environment variable or with the `luaenv shell`
command.

    $ luaenv local 5.1.5

When run without a version number, `luaenv local` reports the currently
configured local version. You can also unset the local version:

    $ luaenv local --unset

Previous versions of luaenv stored local version specifications in a
file named `.luaenv-version`. For backwards compatibility, luaenv will
read a local version specified in an `.luaenv-version` file, but a
`.lua-version` file in the same directory will take precedence.

### luaenv global

Sets the global version of Lua to be used in all shells by writing
the version name to the `~/.luaenv/version` file. This version can be
overridden by an application-specific `.lua-version` file, or by
setting the `LUAENV_VERSION` environment variable.

    $ luaenv global 5.2.1

The special version name `system` tells luaenv to use the system Lua
(detected by searching your `$PATH`).

When run without a version number, `luaenv global` reports the
currently configured global version.

### luaenv shell

Sets a shell-specific Lua version by setting the `LUAENV_VERSION`
environment variable in your shell. This version overrides
application-specific versions and the global version.

    $ luaenv shell luajit-2.0.1

When run without a version number, `luaenv shell` reports the current
value of `LUAENV_VERSION`. You can also unset the shell version:

    $ luaenv shell --unset

Note that you'll need luaenv's shell integration enabled (step 3 of
the installation instructions) in order to use this command. If you
prefer not to use shell integration, you may simply set the
`LUAENV_VERSION` variable yourself:

    $ export LUAENV_VERSION=luajit-2.0.1

### luaenv versions

Lists all Lua versions known to luaenv, and shows an asterisk next to
the currently active version.

    $ luaenv versions
      5.1.5
      5.2.1
    * luajit-2.0.1 (set by /Users/cehoffman/.luaenv/version)

### luaenv version

Displays the currently active Lua version, along with information on
how it was set.

    $ luaenv version
    luajit-2.0.1 (set by /Users/cehoffman/Projects/lpm/.lua-version)

### luaenv rehash

Installs shims for all Lua executables known to luaenv (i.e.,
`~/.luaenv/versions/*/bin/*`). Run this command after you install a new
version of Lua, or install a rock that provides commands.

    $ luaenv rehash

### luaenv which

Displays the full path to the executable that luaenv will invoke when
you run the given command.

    $ luaenv which luac
    /Users/sam/.luaenv/versions/5.2.1/bin/luac

### luaenv whence

Lists all Lua versions with the given command installed.

    $ luaenv whence luac
    5.1.5
    5.2.1

## Development

The luaenv source code is [hosted on
GitHub](https://github.com/cehoffman/luaenv). It's clean, modular,
and easy to understand, even if you're not a shell hacker.

Tests are executed using [Bats](https://github.com/sstephenson/bats):

    $ bats test
    $ bats test/<file>.bats

Please feel free to submit pull requests and file bugs on the [issue
tracker](https://github.com/cehoffman/luaenv/issues).

It is also likely any bugs you find exist in the original source from which
luaenv has been adapted. Check out
[luaenv](https://github.com/sstephenson/luaenv) to see if they have a fix that
should be ported over or need the bug squashed too.

### Version History

**0.4.0** (March 2, 2013)

* Converted luaenv and lua references to luaenv and lua respectively
* Initial public release.

### License

(The MIT license)

Copyright (c) 2013 Sam Stephenson, Chris Hoffman

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.


  [lua-build]: https://github.com/sstephenson/lua-build#readme
