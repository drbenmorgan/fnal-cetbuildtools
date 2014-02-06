#
#  cetbuildtools/CMakeLists.txt
#
#  CMake build file for cetbuildtools
#  This simply copies files into an install directory - there is no build
#
#  install steps:
#  cd /path/to/build/directory
#  source /path/to/cetbuildtools/ups/setup_for_development 
#  cmake [-DCMAKE_INSTALL_PREFIX=/install/path] $CETBUILDTOOLS_SOURCE
#  make install
#  make package (tar file for ups)

CMAKE_MINIMUM_REQUIRED (VERSION 2.8)

set(CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/Modules)

include(CetCMakeEnv)

# Project name. Necessary before call to cet_cmake_env()
project(cetbuildtools NONE)

# cetbuildtools has no architecture dependence
cet_cmake_env( noarch )

# source code
add_subdirectory(templates)
add_subdirectory(Modules)
add_subdirectory(bin)
add_subdirectory(ups)
add_subdirectory(example)

# packaging utility
include(UseCPack)

