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

