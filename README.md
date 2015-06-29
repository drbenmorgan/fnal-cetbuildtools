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

Environment Variables
=====================
The fundamental issue limiting the portability of `cetbuildtools` is its use of UPS
specific environment variables rather than standard variables used by buildtools like
CMake, autotools and others.

- General:
  - Compilers: `CC`, `CXX`
  - Compiler/linker flags: `CFLAGS`, `CXXFLAGS`
  - Runtime: `PATH`, dynamic loader path
- CMake:
  - Package/file search paths
- pkg-config:
  - `PKG_CONFIG_PATH`

Use of non-standard variables compounded by `cetbuildtools` exported its functionality to
the config scripts used by client packages, creating vendor lock in on not only `cetbuildtools`
but also UPS.


Imported/Exported Targets
=========================
Despite CMake having full knowledge of both internal and found external programs, `cetbuildtools`
(and other CMake usage at FNAL) do not make real use of this functionality. This can cause issues
at build time if the user has not configured their PATH to include certain directories under the
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

list(PREPEND CMAKE_MODULE_PATH "${CETBUILDTOOLS_MODULE_PATH}")
```

Location of `cetbuildtools` is guaranteed if its install prefix is present
in the `CMAKE_PREFIX_PATH` variable. If UPS is used for SCM, then it should
set this variable appropritely for the setup product.








