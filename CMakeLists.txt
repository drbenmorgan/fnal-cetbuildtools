#
#  cetbuildtools/CMakeLists.txt
#
#  CMake build file for cetbuildtools 
#  This simply copies files into an install directory - there is no build
#
#   cmake [-DCMAKE_INSTALL_PREFIX=/install/path] /path/to/source/code

CMAKE_MINIMUM_REQUIRED (VERSION 2.6)

PROJECT (cetbuildtools)
set (product cetbuildtools)
SET (version v1_2_0)

# cetbuildtools has no architecture dependence

# source code
subdirs(templates)
subdirs(ups)
subdirs(example)

