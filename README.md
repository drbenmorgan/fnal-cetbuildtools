fnal-cetbuildtools
==================
This is a basic mirror of FNAL's CET cetbuildtools system. Built on top of CMake,
it tightly couples FNAL/CET's UPS configuration management system. This mirror
aims to modernize and decouple the system so that:

- Clients of CET software, such as Art/LArSoft, can use these without requiring the
full UPS software stack.
- CET/FNAL can still use UPS as the runtime configuration management system.

All work is done on this `modern-cmake` branch. The `master` branch is the pristine
upstream master branch, which is updated here and merged with `modern-cmake`
as needed.

This README also acts as a basic documentation of the issues encountered and their
resolutions.

Installing Cetbuildtools
========================
Create a build directory somewhere outside the directory tree where this
README is rooted. To illustrate the proceedure, we will use the layout:

```
+- /some/prefix
   +- cetbuildtools/
   |  +- README.md      # This file
   |  +- CMakeLists.txt
   +- build/            # Where we will build cetbuildtools
   +- install/          # Where cetbuildtools will be installed
```

To build and install, assuming you start in a working directory equal to
`/some/prefix` as above

```
$ cd build
$ cmake -DCMAKE_INSTALL_PREFIX=/some/prefix/install ../cetbuildtools
$ make install
```

If all is successful, then the `install/` directory will be populated with
a "UPS Product" style install of cetbuildtools:

```
├── cetbuildtools
│   ├── v4_12_05
│   │   ├── Modules
│   │   ├── bin
│   │   ├── cmake
│   │   ├── example
│   │   │   └── ToyCmake
│   │   │       ├── ToyCmake
│   │   │       │   ├── Hello
│   │   │       │   ├── Math
│   │   │       │   ├── MathIO
│   │   │       │   └── Square
│   │   │       ├── test
│   │   │       └── ups
│   │   ├── templates
│   │   └── ups
│   └── v4_12_05.version
```

The `ToyCmake` subdirectory contains an example C++ project demonstrating
a minimal use of `cetbuildtools`. It can be copied out of the install tree
and tested out as follows:

```
$ cp -R install/cetbuildtools/v4_12_05/example/ToyCmake .
$ mkdir ToyCmake-build
$ cd ToyCmake-build
$ cmake -DCMAKE_PREFIX_PATH=/some/prefix/install/cetbuildtools/v4_12_05 \
../ToyCmake
$ make
$ make test
... this currently fails on Mac...
```

Note the use of CMake's `CMAKE_PREFIX_PATH` variable to point the build of
ToyCmake to the correct cetbuildtools instance. This variable acts like
a UNIX PATH, but for package lookup, so can also be set in the environment
as

```
$ export CMAKE_PREFIX_PATH="/some/prefix/install/cetbuildtools/v4_12_05:${CMAKE_PREFIX_PATH}"
$ cd ToyCmake-build
$ cmake ../ToyCmake
... should pick up the correct cetbuildtools instance ...
```

Environment setting of `CMAKE_PREFIX_PATH` can be done by hand or any SCM
system of choice (e.g. UPS or Environment Modules).


Installing CetBuildTools (Full Record)
======================================
An initial go at installing `cetbuildtools` from scratch

1. Clone the repo.
2. No instructions in repository.
3. As it provides a CMake script, assume standard cmake-style build
  - Create separate build directory at base repo level.
  - Change into this.
  - Run `cmake ..`
  - Results in the error:
    ```
    $ cmake ..
    CMake Error at Modules/CetGetProductInfo.cmake:11 (message):
    CetGetProductInfo.cmake: Can't find report_product_info
    Call Stack (most recent call first):
    Modules/CetCMakeEnv.cmake:13 (include)
    CMakeLists.txt:18 (include)


    -- Configuring incomplete, errors occurred!
    ```
  - Error is due to use of `find_program` to locate `report_product_info`
    (supplied in this project under the `bin/` directory)
    via either `CETBUILDTOOLS_DIR` or `PATH` environment variables
    - In context of build/install of `cetbuildtools` itself, use of
      `find_program` is superfluous as we know where the program is.
    - In context of using an install of `cetbuildtools`, we'll *also*
      know where the program is as we know the install hierarchy.
    - TEMPFIX: For build only, set known bin path in top level CMakescript
      modify CetGetProductInfo to use this. Later, can set this variable
      appropriately in the `cetbuildtools-config.cmake` file
  - Next Error:
    ```
    $ cmake ..
    CMake Error at Modules/CetCMakeEnv.cmake:135 (message):
    Unable to obtain product information: need to re-source
    setup_for_development?
    Call Stack (most recent call first):
    Modules/CetCMakeEnv.cmake:167 (_get_cetpkg_info)
    CMakeLists.txt:25 (cet_cmake_env)


    -- Configuring incomplete, errors occurred!
    ```
    - Following trace, this occurs with the first call to `cet_get_product_info_item`.
      This is attempting to run `report_product_info ${PROJECT_BINARY_DIR} product rproduct`.
      Running that directly in the build directory gives an error `Couldn't open /<builddir>/cetpkg_variable_report at ../bin/report_product_info line 23.`.
      That file, `cetpkg_variable_report`, appears to be generated by sourcing
      the `setup_for_development` script in the `ups/` subdirectory.
      This sourcing results in the following environment variables being set:
      - `CETPKG_SOURCE` (apparently identical to cmake var `PROJECT_SOURCE_DIR`)
      - `CETPKG_BUILD` (apparently identical to cmake var `PROJECT_BINARY_DIR`)
      - It'll also prepend `bin` dirs in both to the PATH

      In addition, sourcing the script *also* sources the
      `bin/set_dev_products` script with the above paths and the `simple`
      argument, then later also source
      `bin/set_dev_check_report` script with the `simple` argument
    - Can fix by using `execute_process` to run the `set_dev_products` script
      as in `setup_for_development`
    - Now proceed to an error:
    ```
    CMake Error at Modules/CetCMakeEnv.cmake:263 (message):
     Can't locate CETPKG_BUILD, required to build this package.
    Call Stack (most recent call first):
     CMakeLists.txt:27 (cet_cmake_env)


    -- Configuring incomplete, errors occurred!
    ```
    - If `CETPKG_BUILD` is basically equivalent to the project binary dir,
      then simple replace this
    - Can then complete configuration, then make and install!

Testing with ToyCMake reveals that further work is needed with regards to
reliance on PATH etc to use cetbuildtools programs (e.g. Some *may*
be intended for direct use from the command line, but otherwise we
don't have to rely on the PATH).

Customized "packageconfig" template used over the one in `ups` as this
allows us to set additional features of the package - it's this that
allows a binary dir variable that allows direct, non-PATH dependent calls
to the programs in `bin`.

Installation hard codes the UPS style layout, but this should be
configurable following standard install hierarchies (the UPS style
is then simply one configure time choice amongst others). Replace
hardcoded paths with standard 'GNUInstallDirs' CMake (core) module.
Use layout:

```
├── cetbuildtools
    ├── bin
    └── share
        └── cetbuildtools
            ├── cmake
            │   └── Modules
            ├── example
            │   └── ToyCmake
            └── templates
```

This means the client installing `cetbuildtools` will get a POSIX
style install by default. To use a UPS-style install, only
`CMAKE_INSTALL_PREFIX` would need to be set when configuring.
This doesn't account for installing UPS "deps/table" files, but this
is assumed to be the responsibility of the packager (as it would be
for any other packaging/SCM system).



Identified further work items:

- Identify further calls to programs in `bin` reliant on PATH being set.
  - Migrate to use of the binary directory variable pattern.
- Identify any further UPS etc environment variables that reproduce/shadow
  CMake functionality (`CETPKG_SOURCE == PROJECT_SOURCE_DIR`?).
  - Work out exactly what the environment result of `setup_for_development`
    is for any given package. Can any per-package variables be promoted to
    CMake variables set in the projects 'FooConfig.cmake' file?
- Promote Qualifiers to proper Build Modes?


Environment Variables
=====================
The fundamental issue limiting the portability of `cetbuildtools` is its use of UPS
specific environment variables rather than standard variables used by buildtools like
CMake, autotools and others.

- General/System:
  - Compilers: `CC`, `CXX`
  - Compiler/linker flags: `CFLAGS`, `CXXFLAGS`
  - Runtime: `PATH`, dynamic loader path
- CMake:
  - Package/file search paths, several covering both native and cross-compile
    cases. All covered in the [documentation for the various `find_XXX` commands](https://cmake.org/cmake/help/v3.3/manual/cmake-commands.7.html).
- pkg-config:
  - `PKG_CONFIG_PATH`

Use of non-standard variables is compounded by `cetbuildtools` exported its
functionality to the config scripts used by client packages, creating vendor
lock in on not only `cetbuildtools` but also UPS. In other words, if your
package is built with `cetbuildtools`, it *cannot* exist outside a UPS
installation tree.


Imported/Exported Targets
=========================
Despite CMake having full knowledge of both internal and found external
programs, `cetbuildtools` (and other CMake usage at FNAL) do not make real
use of this functionality. This can cause issues at build time if the user
has not configured their PATH to include certain directories under the
build directory.


Using Cetbuildtools
===================
In general, FNAL/CET projects using `cetbuildtools` include the following stanza
at the top of their main CMake script:

```cmake
project(ThisProject)

# cetbuildtools contains our cmake modules
set (CETBUILDTOOLS_VERSION $ENV{CETBUILDTOOLS_VERSION})
if(NOT CETBUILDTOOLS_VERSION)
  message(FATAL_ERROR "ERROR: setup cetbuildtools to get the cmake modules")
endif()
set(CMAKE_MODULE_PATH $ENV{CETBUILDTOOLS_DIR}/Modules ${CMAKE_MODULE_PATH})

# ... later on ...
find_ups_product(cetbuildtools v4_07_02)

```

This requires a client of `cetbuildtools` to have set at least two environment
variables, `CETBUILDTOOLS_VERSION` *and* `CETBUILDTOOLS_DIR`. In addition, the
call to `find_ups_product` *appears* redundant (though one can't use `find_ups_product`
until `cetbuildtools` is found). TODO: check what `find_ups_product` actually does.

Provided a core set of CMake functionality is a fairly common project task,
for example in (KDE's `extra-cmake-modules`)[http://api.kde.org/ecm/manual/ecm.7.html].
To this end, the above stanza should be replaced by:

```cmake
project(ThisProject)

find_package(cetbuildtools 4.7.2 REQUIRED NO_MODULE)

# NB, this update to CMAKE_MODULE_PATH could also (and probably should) be
# handled internally in the cetbuildtoolsConfig.cmake file that
# find_package uses above.
list(PREPEND CMAKE_MODULE_PATH "${CETBUILDTOOLS_MODULE_PATH}")
```

Location of `cetbuildtools` is guaranteed if its install prefix is present
in the `CMAKE_PREFIX_PATH` variable. If UPS is used for SCM, then it should
set this variable appropriately for the setup product.


Rejigging example `ToyCmake` to use Modern `cetbuildtools`
==========================================================
Bit circular - need to try build of `ToyCmake` to identify runtime
issues in `cetbuildtools`

As above, we've modified the top level `ToyCmake` `CMakeLists.txt` to:

```cmake
# use cmake 2.8 or later
cmake_minimum_required (VERSION 2.8)

project(ToyCmake)

# cetbuildtools contains our cmake modules
find_package(cetbuildtools 1.0.0 REQUIRED)

# Still, for some reason, need to run this...
# Run the known things needed to set stuff up
# This means a developer *does not* need to source setup_for_development
# However, setup_for_development may do more complicated stuff, yet
# absolutely will not run without ups present. set_dev_products only
# needs files in the project - need to learn what 'simple' vs other args
# do
execute_process(COMMAND ${cetbuildtools_BINDIR}/set_dev_products ${PROJECT_SOURCE_DIR} ${PROJECT_BINARY_DIR} simple)


include(CetCMakeEnv)
cet_cmake_env()

...
```

So first thing of note is requirement to run `set_dev_products` by hand
otherwise `cet_cmake_env` barfs.

Getting past that, the next error is immediate:

```
CMake Error at /Users/guest/tmp/cbt/share/cetbuildtools/cmake/Modules/CetCMakeEnv.cmake:58 (message):
  CMAKE_C_COMPILER set to /Users/guest/Software/Homebrew.git/bin/gcc-4.9:
  expected match to "/Users/guest/tmp/ToyCmake/^/usr/bin/cc$".

  Use buildtool or preface cmake invocation with "env CC=." Use buildtool -c
  if changing qualifier.
Call Stack (most recent call first):
  /Users/guest/tmp/cbt/share/cetbuildtools/cmake/Modules/CetCMakeEnv.cmake:129 (_verify_cc)
  /Users/guest/tmp/cbt/share/cetbuildtools/cmake/Modules/CetCMakeEnv.cmake:140 (_study_compiler)
  /Users/guest/tmp/cbt/share/cetbuildtools/cmake/Modules/CetCMakeEnv.cmake:245 (_verify_compiler_quals)
  CMakeLists.txt:32 (cet_cmake_env)
```

Trace that to the lockdown in the `_verify_cc` function to use the
UPS-specific `GCC_FQ_DIR` and similar to check UPS-setup compiler
against what CMake found (? possibly?). Provided UPS has set CC/CXX etc
correctly, this shouldn't be needed.








