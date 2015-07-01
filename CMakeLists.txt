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

#-----------------------------------------------------------------------
# Modifications Copyright 2015 Ben Morgan <Ben.Morgan@warwick.ac.uk
# Modifications Copyright 2015 University of Warwick



CMAKE_MINIMUM_REQUIRED (VERSION 2.8)
# Project name. Necessary before call to cet_cmake_env()
project(cetbuildtools NONE)

set(CMAKE_MODULE_PATH ${PROJECT_SOURCE_DIR}/Modules)
set(CETBUILDTOOLS_BINDIR ${PROJECT_SOURCE_DIR}/bin)

# Run the known things needed to set stuff up
execute_process(COMMAND ${CETBUILDTOOLS_BINDIR}/set_dev_products ${PROJECT_SOURCE_DIR} ${PROJECT_BINARY_DIR} simple)

include(CetCMakeEnv)

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

