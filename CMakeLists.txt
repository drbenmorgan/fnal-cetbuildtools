#
#  cetbuildtools/CMakeLists.txt
#
#  CMake build file for cetbuildtools 
#  This simply copies files into an install directory - there is no build
#
#   cmake [-DCMAKE_INSTALL_PREFIX=/install/path] /path/to/source/code

CMAKE_MINIMUM_REQUIRED (VERSION 2.6)

PROJECT (cetbuildtools)
SET (version v1_1_0)

# source code
subdirs(templates)
subdirs(ups)
subdirs(example)

