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

# make sure gcc has been set
# we aren't going to compile - just need this when building ToyCmake
# note that gcc has no qualifier
SET ( GCC_VERSION $ENV{GCC_VERSION} )
IF (NOT GCC_VERSION)
    MESSAGE (FATAL_ERROR "gcc has not been setup")
ENDIF()
message(STATUS "GCC version is ${GCC_VERSION} " )

# cetbuildtools has no architecture dependence

# source code
subdirs(templates)
subdirs(ups)
subdirs(example)

