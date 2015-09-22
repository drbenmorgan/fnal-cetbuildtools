# Comments on Specific Modules
Many modules in `cetbuildtools` appear to contain redundant/superfluous/overcompilated functionality. The sections
below comment on these aspects and suggest improvements using pure CMake. Note that pure CMake may involve "more lines", but aims to be cleaner, more explicit and with many fewer side effects that `cetbuildtools` equivalents.

## General Issues
### Globs in CMake vs Make
CMake provides functionality to "glob" a list of files matching a regex pattern, however, these *do not* work in 
the same way wildcards in Make do. For example, to avoid explicit listing all the files that go into a program a 
classic Makefile might use:

```make
SOURCES := $(wildcard *.cc)

mytarget: $(SOURCES)
  ... compile ...
```

Here, the call to the `$(wildcard)` function happens everytime `make` is run, so `SOURCES` immediately reflects
any additions/removals of source files on disk.

A common CMake practice is to try and reproduce this with the `file(GLOB ..)` command:

```cmake
file(GLOB SOURCES "*.cc")

add_executable(mytarget ${SOURCES})
```

If we now run CMake to generate Makefiles, everything is fine on the first pass:

```
$ ls
CMakeLists.txt  a.cc  b.cc 
$ cmake .
$ make
Scanning dependencies of target mytarget
[ 33%] Building CXX object CMakeFiles/mytarget.dir/a.cc.o
[ 66%] Building CXX object CMakeFiles/mytarget.dir/b.cc.o
[100%] Linking CXX executable mytarget
[100%] Built target mytarget
$
```

However, if we now add an extra file that matches the globbing pattern and try running make again:

```sh
$ touch c.cc
... edit c.cc ...
$ ls
CMakeLists.txt  Makefile  a.cc  b.cc  c.cc  ...othercmakefiles...
$ make
[100%] Built target mytarget
$
```

we see that `c.cc` has *not* been added to the build and compiled. This is because the `file(GLOB ...)` command *is only called when CMake runs*. CMake writes rules into the Makefiles (in this case) to trigger a re-run of 
CMake, *but only if any input to CMake changes*. In the above case, adding `c.cc` did not change `CMakeLists.txt`,
so the Makefile does not trigger a rerun of CMake. We therefore need to remember to rerun CMake manually between
every build invocation:

```sh
$ make
[100%] Built target mytarget
... o.k., forgot to rerun cmake ...
$ cmake .
... scripts re-evaluated, so re-glob is performed ...
$ make
Scanning dependencies of target mytarget
[ 25%] Building CXX object CMakeFiles/mytarget.dir/c.cc.o
[ 50%] Linking CXX executable mytarget
[100%] Built target mytarget
$
```

Whilst this may not seem a great limitation, it can easily cause inconsistent builds especially in a distributed development environment with git/svn. Here the developer also needs to remember to re-run CMake after any update
in case the update has added/removed files. This is also an issue if developers wish to use IDEs (e.g. Xcode) as they have to manually swap back to command line to rerun CMake and reload the project.

CMake themselves do not recommend use of globbing to collect source files for the above reason. Instead, explicit listing is preferred:

```cmake
set(SOURCES a.cc b.cc)

add_executable(mytarget ${SOURCES})
```

On the first pass of CMake/build, this produces exactly the same behaviour as globbing:

```
$ ls
CMakeLists.txt  a.cc  b.cc 
$ cmake .
$ make
Scanning dependencies of target mytarget
[ 33%] Building CXX object CMakeFiles/mytarget.dir/a.cc.o
[ 66%] Building CXX object CMakeFiles/mytarget.dir/b.cc.o
[100%] Linking CXX executable mytarget
[100%] Built target mytarget
$
```

When we add `c.cc`, in addition to writing the source itself we must also add it to the `SOURCES` list in the CMake script:

```cmake
set(SOURCES a.cc b.cc c.cc)

add_executable(mytarget ${SOURCES})
```

To build, all we do now is rerun Make:

```sh
$ make
-- Configuring done
-- Generating done
-- Build files have been written to: /Users/bmorgan/tmp/example
Scanning dependencies of target mytarget
[ 25%] Building CXX object CMakeFiles/mytarget.dir/c.cc.o
[ 50%] Linking CXX executable mytarget
[100%] Built target mytarget
$
```

and we see that because we changed the `CMakeLists.txt` file, re-running the build has triggered a re-run of CMake, and a subsequent automatic build of the new `c.cc` source file. Similarly, if we had pulled changes from a git/svn repository, all we would have needed to do was rerun make. This would also have occured in an IDE, where
rebuilding would also have automatically regenerated the project for us without any manual intervention.

Of course, explicit listing means that developers must remember to edit their CMake scripts. This is often cited
as an objection to explicit listing over globbing, but whilst it does place more onus on developers, explicit listing has several advantages for them and the project as a whole:

1. Only one task needs to be remembered - 'add/remove sources from CMake scripts', rather than when to run a specific command and under what conditions.
2. Defining and declaring what and how sources are compiled into binary products is a core responsibility of developers. Knowledge of this area leads to more robust and portable products.
3. Changes to the build are recorded in the CMake scripts, and hence as commits in the VCS. Inconsistent builds may still occur, but can be compared with the relevant commit.

Explicit listing also leads to cleaner and more logical CMake scripting. For example, a typical use case is to add
sources to a build if an optional feature is requested. With explicit listing this is clean and precise:

```cmake
set(SOURCES a.cc b.cc c.cc)

if(WANT_FOO)
  find_package(Foo REQUIRED)
  list(APPEND SOURCES foo.cc foo_impl.cc)
endif()

add_executable(mytarget ${SOURCES})
```

With globbing, the greediness of globbing means we may have to filter out certain sources, and have a more complex conditional on use of the feature:

```cmake
file(GLOB SOURCES "*.cc")

if(NOT WANT_FOO)
  # Note that the path is needed and will be dependent on how the above GLOB is called
  list(REMOVE_ITEM SOURCES "${CMAKE_CURRENT_SOURCE_DIR}/foo.cc")
  list(REMOVE_ITEM SOURCES "${CMAKE_CURRENT_SOURCE_DIR}/foo_impl.cc")
else()
  find_package(FOO REQUIRED)
endif()

add_executable(mytarget ${SOURCES})
```

`cetbuildtools` makes extensive use of globbing, and the concrete cases below list particular areas where problems
of reliability and clarity occur.

### Unit Testing with Boost.Unit
Boost's Unit test framework is used as the core testing system for FNAL products (up to Art/LArSoft at least).
Building test enabled programs/libraries usually requires applying certain compile definitions to source files
together with linking to the relevant library. Modules in `cetbuildtools` do handle this for the user, but the 
functionality is reproduced in several modules. The interface for enabling testing is also tightly coupled to the interface for declaring programs/libraries.

A possible improvement here would be to factor the setting of preprocessor defintions and linking into
dedicated declarative interfaces, e.g.:

```cmake
boost_unit_test_enable(mytarget)
```

which would apply the correct compile definitions and linking to `mytarget` as appropriate. If more flexibility was required, this could be renamed to:

```cmake
cet_unit_test_enable(mytarget)
```

which would potentially allow the actual unit test framework to be swapped out in a transparent way in the build system (though developers would still need to write tests using the appropriate C++ code).


## [BasicPlugin.cmake] (BasicPlugin.cmake)
Not completely clear if this is truly global functionality or part of `cetlib` because it is essentially a heavy wrapper around `add_library` enforcing a naming convention only used by `cetlib`'s Plugin functionality (ergo,
it's strictly speaking part of the `cetlib` interface).

It can, barring the naming convention, be reduced to a pure CMake declarative interface:

```cmake
add_library(PluginName_PluginType SHARED ${SOURCES})
target_link_libraries(PluginName_PluginType ${USED_LIBRARIES})

# If And Only If this is a plugin for unit testing
boost_unit_test_enable(PluginName_PluginType)

# If And Only If install is needed (e.g. a pure testing plugin wouldn't be!)
install(TARGETS PluginName_PluginType DESTINATION ${CMAKE_INSTALL_LIBDIR})
```

This is simple and flexible, plus it is also forward compatible with modern CMake target property declarations.

As other plugin systems (e.g. Qt, Poco, ROOT) do not require a naming convention, it's likely `cetlib` can be
refactored to use a better plugin location/loading mechanism.

## [BuildSubdirectories.cmake](BuildSubdirectories.cmake)
Uses a glob to locate directories under the current source dir which hold `CMakeLists.txt` and then use `add_subdirectory` to recurse CMake into them. This means it suffers from the globbing issue discussed above, and can be replaced by trivial direct calls to `add_subdirectory`. For example, it might be used in a layout like:

```
├── CMakeLists.txt
├── foo
│   └── CMakeLists.txt
├── bar
│   ├── CMakeLists.txt
└── baz
    └── CMakeLists.txt
```

Where the top `CMakeLists.txt` uses it as:

```cmake
include(BuildSubdirectories)
build_subdirectories()
```

Identical behaviour is obtained with the pure CMake:

```cmake
add_subdirectory(foo)
add_subdirectory(bar)
add_subdirectory(baz)
```

which is cleaner and has fewer side effects.

##[CetCMakeEnv.cmake](CetCMakeEnv.cmake)
Some variables of note:

- `PACKAGE_TOP_DIRECTORY` : What is the purpose of this variable and how does it differ from CMake's inbuilt [`PROJECT_SOURCE_DIR`](http://www.cmake.org/cmake/help/v3.3/variable/PROJECT_SOURCE_DIR.html)?

##[CetCopy.cmake](CetCopy.cmake)
I have no idea what the purpose of this is over and above CMake's builtin `configure_file` command. Retriggering a run of CMake is not generally a bad thing.


##[InstallPerllib.cmake](InstallPerllib.cmake)
Contains hard dependence on higher level `cetlib` package in `_cet_perl_plugin_version` function. In turn, this will hard fail unless the environment variable `CETLIB_DIR` is set. `cetbuildtools` does not declare any dependence on `cetlib` in its UPS files.

If the functionality in the module is dependent on `cetlib` then the module should be promoted to `cetlib` itself to avoid a circular dependency and to properly associate functionality.

##[ProcessSmc.cmake](ProcessSmc.cmake)
Relies on UPS to find SMC package, and *assumes* suitable `java` program in the `PATH`. 

Instead, a proper `FindSMC` CMake module should be provided. This can provide the `process_smc` function as part of its interface like other CMake Find modules (e.g. moc generation in Qt4).
Instead, provide proper `FindSMC.cmake` package
