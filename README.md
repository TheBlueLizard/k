---
copyright: Copyright (c) K Team. All Rights Reserved.
permalink: README.html
---

[Join the chat at Riot](https://riot.im/app/#/room/#k:matrix.org)

# Introduction

The K Framework is a tool for designing and modeling programming languages
and software/hardware systems.
At the core of the K Framework is a programming, modeling, and specification
language called K.
The K Framework includes tools for compiling K specifications to build
interpreters, model checkers, verifiers, associated documentation, and more.

## Quick Start

If you are not a K developer, but just want to get started using K, we provide a
streamlined installation process for any system that supports
[Nix](https://nixos.org/download.html):
```shell
bash <(curl https://kframework.org/install)
kup install k
```

For more information on the `kup` tool and other packaged releases of K, please
refer to our [installation notes](k-distribution/INSTALL.md).

## Preface

This is a readme file for _K developers_. Users should feel comfortable using
the command line, as we do not provide GUI tools at this time.

_K-based tool users_ should:

1.  Consult their tool documentation for build/installation instructions.
2.  If needed, download a [packaged release](https://github.com/runtimeverification/k/releases/)
    of the K Framework as part of their tool setup process.

If you are interested in quickly trying out the K Framework without building
from source, please see our
[packaged release installation guide](https://github.com/runtimeverification/k/blob/master/k-distribution/INSTALL.md).

The rest of this file assumes you intend to build and install the K Framework
from source.

Note that the K Framework can only be built on (x86-64) Linux-like systems,
e.g., this also includes macOS/brew (x86-64) as well as the Windows Subsystem
for Linux.
All 32-bit systems are **not supported**.
See the
[installation notes](https://github.com/runtimeverification/k/blob/master/k-distribution/INSTALL.md)
for details about supported configurations and system setup.

## Contents

1.  [Prerequisite Install Guide](#prerequisite-install-guide)
2.  [Build and Install Guide](#build-and-install-guide)
3.  [IDE Setup](#ide-setup)
4.  [Running the Test Suite](#running-the-test-suite)
5.  [Changing the KORE Data Structures](#changing-the-kore-data-structures)
6.  [Building the Final Release Directory/Archives](#building-the-final-release-directoryarchives)
7.  [Compiling Definitions and Running Programs](#compiling-definitions-and-running-programs)
8.  [Installing Python Support](#installing-python-support)
9.  [Troubleshooting](#troubleshooting)

# Prerequisite Install Guide

Before building and installing the K Framework, the following prerequisites
must first be installed.

## The Short Version

On Ubuntu Linux 20.04 (Focal) or 22.04 (Jammy):

```shell
git submodule update --init --recursive
sudo apt-get install build-essential m4 openjdk-11-jdk libfmt-dev libgmp-dev libmpfr-dev pkg-config flex bison z3 libz3-dev maven python3 python3-dev cmake gcc g++ clang-12 lld-12 llvm-12-tools zlib1g-dev libboost-test-dev libyaml-dev libjemalloc-dev
curl -sSL https://get.haskellstack.org/ | sh
```

Note: we require a version between 10 and 14 for clang, lld, and llvm-tools.

On Arch Linux:

```shell
git submodule update --init --recursive
sudo pacman -S git maven jdk-openjdk cmake boost fmt libyaml jemalloc clang llvm lld zlib gmp mpfr z3 curl stack base-devel base python
```

If you install this list of dependencies, continue directly to the [Build and Install Guide](#build-and-install-guide).

On macOS using [Homebrew](https://brew.sh/):
```shell
git submodule update --init --recursive
brew install bison boost cmake flex fmt gcc gmp openjdk jemalloc libyaml llvm@14 make maven mpfr pkg-config python stack zlib z3
```

## The Long Version

The following dependencies are needed either at build time or runtime:

*   [bison](https://www.gnu.org/software/bison/)
*   [boost](https://www.boost.org/)
*   [cmake](https://cmake.org/)
*   [flex](https://github.com/westes/flex)
*   [fmt](https://fmt.dev/)
*   [gcc](https://gcc.gnu.org/)
*   [gmp](https://gmplib.org/)
*   [jdk](https://openjdk.java.net/) (version 11 or greater)
*   [libjemalloc](https://github.com/jemalloc/jemalloc)
*   [libyaml](https://pyyaml.org/wiki/LibYAML)
*   [llvm](https://llvm.org/) (We require version 10 or greater for clang, lld, and llvm-tools. On some distributions, the utilities below are also needed and packaged separately.)
    * [clang](http://clang.llvm.org/)
    * [lld](https://lld.llvm.org/)
*   [make](https://www.gnu.org/software/make/)
*   [maven](https://maven.apache.org/)
*   [mpfr](http://www.mpfr.org/)
*   [pkg-config](https://www.freedesktop.org/wiki/Software/pkg-config/)
*   [python](https://www.python.org)
*   [stack](https://docs.haskellstack.org/en/stable/README/)
*   [zlib](https://www.zlib.net/)
*   [z3](https://github.com/Z3Prover/z3) (on some distributions libz3 is also
    needed and packaged separately) Note that you need version 4.8.15 of Z3,
    which may require you to build and install from source if your package
    manager does not supply it. Other versions are known to have bugs and
    performance regressions likely to cause issues in the K test suite.

Typically, these can all be installed from your package manager.
On some system configurations, special installation steps or post-installation
configuration steps are required.
See the notes below.

### Installation Notes

1.  Java Development Kit (required JDK11 or higher)

    *   Linux: Download from package manager
        (e.g. `sudo apt-get install openjdk-11-jdk`).

    *   macOS/brew: Download from package manager
        (e.g. `brew install java`).

    To make sure that everything works you should be able to call
    `java -version` and `javac -version` from a terminal.

2.  LLVM

    *   macOS/brew: Since LLVM is distributed as a keg-only package, we must
        explicitly make it available for command line usage. See the results
        of the `brew info llvm` command for more information on how to do this.
        Additionally, the default version of LLVM supplied by Homebrew is newer
        than the version supported by K. The formula `llvm@14` should be used
        instead of `llvm`.

3.  Flex / Bison

    *   macOS/brew: The versions of these packages supplied by the OS are too
        old, and are not compatible with the K build. You must ensure that the
        Homebrew-installed versions are first on your `PATH` when building K
        (i.e. `which flex` is **not** `/usr/bin/flex`).

4.  Apache Maven

    *   Linux: Download from package manager
        (e.g. `sudo apt-get install maven`).

    *   macOS/brew: Download it from a package manager or from
        http://maven.apache.org/download.cgi and follow the instructions on
        the webpage.

    Maven usually requires setting an environment variable `JAVA_HOME` pointing
    to the installation directory of the JDK (not to be mistaken with JRE).

    You can test if it works by calling `mvn -version` in a terminal.
    This will provide the information about the JDK Maven is using, in case
    it is the wrong one.

5.   Haskell Stack

     To install, go to <https://docs.haskellstack.org/en/stable/README/> and
     follow the instructions.
     You may need to do `stack upgrade` to ensure the latest version of Haskell
     Stack.

# Build and Install Guide

## Building with Maven

Checkout the project source at your desired location and call `mvn package`
from the main directory to build the distribution. For convenient usage, you
can update your `$PATH` with
`<checkout-dir>/k-distribution/target/release/k/bin`
(strongly recommended, but optional).

You are also encouraged to set the environment variable `MAVEN_OPTS` to
`-XX:+TieredCompilation`, which will significantly speed up the incremental
build process.

### Apple Silicon Support

K currently offers partial support for Apple Silicon; the toolchain has been
tested and works on ARM macOS, but is not yet part of our CI/CI pipeline. To
build K on an Apple Silicon machine, ensure the following steps are followed in
addition to the usual Maven build setup:
* Ensure that Homebrew-installed versions of `llvm-config`, `flex` and `bison`
  are on your `PATH` ahead of any macOS-supplied versions.
  * [`direnv`](https://direnv.net/) offers a convenient way to automate this. To
    do so:
    ```shell
    brew install direnv
    # Follow the instructions at https://direnv.net/docs/hook.html
    # ...for example, if your shell is bash, run:
    #   echo 'eval "$(direnv hook bash)"' >> ~/.bashrc
    # then restart your shell.
    cp macos-envrc .envrc
    direnv allow
    # You should see a message like:
    #   direnv: loading .../k/.envrc
    #   direnv: export ~PATH
    # The llvm-config binary should also be on your PATH; check with:
    which llvm-config
    ```
* Pass `-Dstack.extra-opts='--compiler ghc-8.10.7 --system-ghc'` as an
  additional argument to `mvn package` when building the toolchain.
  * This is a workaround for `stack` and `ghc` not yet properly supporting ARM
    macOS; the underlying problem is likely to be fixed at some point in the
    future.
  * See [the documentation](https://github.com/kframework/kore#apple-silicon)
    and [associated PR](https://github.com/kframework/kore/pull/2893) for more
    details.

## Building with Nix flakes (Recommended)

We now support building K using [nix flakes](https://nixos.wiki/wiki/Flakes).
To set up nix flakes you will need to be on `nix` 2.4 or higher and follow the instructions [here](https://nixos.wiki/wiki/Flakes).

For example, if you are on a standard Linux distribution, such as Ubuntu, first [install nix](https://nixos.org/download.html#download-nix)
and then enable flakes by editing either `~/.config/nix/nix.conf` or `/etc/nix/nix.conf` and adding:

```
experimental-features = nix-command flakes
```

This is needed to expose the Nix 2.0 CLI and flakes support that are hidden behind feature-flags.


By default, Nix will build the project and its transitive dependencies from
source, which can take up to an hour. We recommend setting up
[the binary cache](https://app.cachix.org/cache/kore) to speed up the build
process significantly. You will also need to add the following sections to `/etc/nix/nix.conf` or, if you are a trusted user, `~/.config/nix/nix.conf` (if you don't know what a "trusted user" is, you probably want to do the former):

```
trusted-public-keys = ... hydra.iohk.io:f/Ea+s+dFdN+3Y/G+FDgSq+a5NEWhJGzdjvKNGv0/EQ=
substituters = ... https://cache.iog.io
```

i.e. if the file was originally

```
substituters = https://cache.nixos.org
trusted-public-keys = cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY=
```

it will now read

```
substituters = https://cache.nixos.org https://cache.iog.io
trusted-public-keys = cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY= hydra.iohk.io:f/Ea+s+dFdN+3Y/G+FDgSq+a5NEWhJGzdjvKNGv0/EQ=
```

To build the K Framework itself, run:

```bash
nix build .
```

This will build all of K and put a link to the resulting binaries in the `result/` folder.


_Note: Mac users, especially those running M1/M2 Macs may find nix segfaulting on occasion. If this happens, try running the nix command like this: `GC_DONT_GC=1 nix build .`_ 


If you want to temporarily add the K binaries (such as `kompile` or `kast`) to the current shell, run

```bash
nix shell .
```

To run the integration tests:

```
nix build .#test
```

If you change any `pom.xml`, you must run 

```
nix run .#update-maven
```

and commit the updated `nix/mavenix.lock` file.

## Building with Nix (not recommended, use Nix flakes)

To build the K Framework itself, run:

```bash
nix-build -A k
```

The various backends are provided as separate packages:

```bash
nix-build -A llvm-backend
nix-build -A haskell-backend
```

To run the integration tests:

```bash
nix-build test.nix
```

You can enter a development environment for working on the K Framework frontend
by running:

```bash
nix-shell
```

To create a development environment for a project that depends on the K
Framework, you can add a `shell.nix` based on this template:

```.nix
# shell.nix
let
  kframework = import ./path/to/k {};
  inherit (kframework) mkShell;
in
mkShell {
  buildInputs = [
    kframework.k
    clang kframework.llvm-backend
    kframework.haskell-backend
  ];
}
```

If you change any `pom.xml`, you must run `./nix/update-maven.sh`.

# IDE Setup

## General

You should run K from the k-distribution project, because it is the only project to have the complete
classpath and therefore all backends.

## Eclipse
_N.B. the Eclipse internal compiler may generate false compilation errors (there are bugs in its support of Scala mixed compilation). We recommend using IntelliJ IDEA if at all possible._

To autogenerate an Eclipse project for K, run `mvn install -DskipKTest; mvn eclipse:eclipse` on the
command line, and then go into each of the `kore` and `tiny` directories and run `sbt eclipse`.
Then start eclipse and go to File->Import->General->Existing projects into workspace, and select
the directory of the installation. You should only add the leaves to the workspace, because
eclipse does not support hierarchical projects.

## IntelliJ IDEA

IntelliJ IDEA comes with built-in maven integration. For more information, refer to
the [IntelliJ IDEA wiki](http://wiki.jetbrains.net/intellij/Creating_and_importing_Maven_projects)

# Running the Test Suite

To completely test the current version of the K framework, run `mvn verify`.
This normally takes roughly 30 minutes on a fast machine. If you are interested only
in running the unit tests and checkstyle goals, run `mvn verify -DskipKTest` to
skip the lengthy `ktest` execution.

# Changing the KORE Data Structures
If you need to change the KORE data structures (unless you are a K core developer, you probably do not), see [Guide-for-changing-the-KORE-data-structures](https://github.com/runtimeverification/k/wiki/Guide-for-changing-the-KORE-data-structures).

# Building the Final Release Directory/Archives
Call `mvn install` in the base directory. This will attach an artifact to the local
maven repository containing a zip and tar.gz of the distribution.

The functionality to create a tagged release is currently incomplete.

# Compiling Definitions and Running Programs
Assuming k-distribution/target/release/k/bin is in your path, you can compile definitions using
the `kompile` command.  To execute a program you can use `krun`.

For running either program in the debugger, use the main class `org.kframework.main.Main` with an additional argument `-kompile` or `-krun` added before other command line arguments, and use the classpath from the `k-distribution` module.

# Installing Python Support

Python tools for K can be found under [runtimeverification/pyk](https://github.com/runtimeverification/pyk).

# Troubleshooting
Common build-time error messages:

-   `Error: JAVA_HOME not found in your environment.
     Please set the JAVA_HOME variable in your environment to match the
     location of your Java installation.`
    + Make sure `JAVA_HOME` points to the JDK and not the JRE directory.

-   `[WARNING] Cannot get the branch information from the git repository:
     Detecting the current branch failed: 'git' is not recognized as an internal or external command,
     operable program or batch file.`
    + `git` might not be installed on your system. Make sure that you can execute
      `git` from the command line.

-   `1) Error injecting constructor, java.lang.Error: Unresolved compilation problems:
          The import org.kframework.parser.outer.Outer cannot be resolved
          Outer cannot be resolved`
    + You may run into this issue if target/generated-sources/javacc is not added to the
      build path of your IDE. Generally this is solved by regenerating your project /
      re-syncing it with the pom.xml.

-   `[ERROR] Failed to execute goal org.apache.maven.plugins:maven-compiler-plugin:3.1:compile
     (default-compile) on project k-core: Fatal error compiling: invalid target release: 11 -> [Help 1]`
    + You either do not have Java 11 installed, or `$JAVA_HOME` does not point to a Java 11 JDK.

-   `[ERROR] Failed to execute goal org.apache.maven.plugins:maven-antrun-plugin:1.7:run
     (build-haskell) on project haskell-backend: An Ant BuildException has occured: exec returned: 1`

    and scrolling up, you see an error message similar to:

    `[exec] Installing GHC ...
     [exec] ghc-pkg: Couldn't open database $HOME/.stack/programs/x86_64-linux/ghc-tinfo6-8.10.1/lib/ghc-8.10.1/package.conf.d for modification:
     {handle: $HOME/.stack/programs/x86_64-linux/ghc-tinfo6-8.10.1/lib/ghc-8.10.1/package.conf.d/package.cache.lock}:
     hLock: invalid argument (Invalid argument)`
    + If you are using a [WSL version 1 environment](https://docs.microsoft.com/en-us/windows/wsl/compare-versions),
      then you have encountered a known issue with the latest versions of GHC. In this
      case, please either:
      -   upgrade to [WSL version 2](https://docs.microsoft.com/en-us/windows/wsl/install-win10),
      -   install a [packaged release for your WSL version 1 distribution](https://github.com/runtimeverification/k/releases/),
      -   switch to a supported system configuration (e.g. Linux on a virtual machine), or
      -   if you do not need the symbolic execution capabilities of the K Framework, disable them
          at build time (and remove the GHC dependency) by doing: `mvn package -Dhaskell.backend.skip`.

If something unexpected happens and the project fails to build, try `mvn clean` and
rebuild the entire project. Generally speaking, however, the project should build incrementally
without needing to be cleaned first.

If you are doing work with snapshot dependencies, you can update them to the latest version by
running maven with the `-U` flag.

If you are configuring artifacts in a repository and need to purge the local repository's cache
of artifacts, you can run `mvn dependency:purge-local-repository`.

If tests fail but you want to run the build anyway to see what happens, you can use `mvn package -DskipTests`.

If you still cannot build, please contact a K developer.
