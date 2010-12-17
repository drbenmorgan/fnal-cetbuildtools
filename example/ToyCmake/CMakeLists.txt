# Create a build directory and an install direcotory which are outside the source code directory
# Declare the install path from the cmake command line using either a relative or full path
#
#   cd .../path/to/build/directory
#   source .../path/to/ToyCmake/ups/setup_for_development
#   cmake -DCMAKE_INSTALL_PREFIX=/install/path $TOYCMAKE_SOURCE
#   make
#   make test
#   make install
#   make package
#

# use cmake 2.6 or later
cmake_minimum_required (VERSION 2.6)
# project name
project(ToyCmake)
# the ups convention is that product names are all lower case, but this is a choices
set( product toycmake )
set( version v1_0_0 )
SET (qualifier a1)

# cetbuildtools contains our cmake modules
SET ( CETBUILDTOOLS_VERSION $ENV{CETBUILDTOOLS_VERSION} )
IF (NOT CETBUILDTOOLS_VERSION)
    MESSAGE (FATAL_ERROR "ERROR: setup cetbuildtools to get the cmake modules")
ENDIF()
set(CMAKE_MODULE_PATH "${CMAKE_ROOT}/Modules")
set(CMAKE_MODULE_PATH $ENV{CETBUILDTOOLS_DIR}/Modules ${CMAKE_MODULE_PATH})
message(STATUS "module path is ${CMAKE_MODULE_PATH}" )

# because we want to move these libraries about,
# do not embed full path in shared libraries or executables
set (CMAKE_SKIP_RPATH)

ENABLE_TESTING()

# cetbuildtools contains our cmake modules
SET ( CETBUILDTOOLS_VERSION $ENV{CETBUILDTOOLS_VERSION} )
IF (NOT CETBUILDTOOLS_VERSION)
    MESSAGE (FATAL_ERROR "ERROR: setup cetbuildtools to get the cmake modules")
ENDIF()
set(CMAKE_MODULE_PATH "${CMAKE_ROOT}/Modules")
set(CMAKE_MODULE_PATH $ENV{CETBUILDTOOLS_DIR}/Modules ${CMAKE_MODULE_PATH})
message(STATUS "module path is ${CMAKE_MODULE_PATH}" )

# require GCC
set( GCC_VERSION $ENV{GCC_VERSION} )
if ( NOT GCC_VERSION )
  message(FATAL_ERROR "Can't locate GCC_VERSION, required for building ToyCmake")
endif ()

# define some necessary modules
include(FindUpsPackage)
# ToyCmake does not use either boost or root
include(FindUpsBoost)
include(FindUpsRoot)
include(SetFlavorQual)
include(ParseUpsVersion)

#set package version from ups version
set_version_from_ups( ${version} )
#define flavorqual and flavorqual_dir
set_flavor_qual(FindUpsRoot)

# Use cmake directive include_directories to define include search path

# We want to be able to #include "MyProduct/MyHeader.h" in source code,
# generated code, and user code.
# We achieve this by putting all headers into a MyProduct subdirectory
# instead of an include subdirectory.
# PROJECT_SOURCE_DIR is a cmake variable which points to the top of the
# source code tree.
include_directories ("${PROJECT_SOURCE_DIR}")

# Generated code will be created in the build directory,
# so we also add PROJECT_BINARY_DIR to the include search path.
# This step may be omitted if there are no generated headers.
include_directories ("${PROJECT_BINARY_DIR}")

# find external packages
# product versions here are meant to be minimum required versions
#find_ups_product( gccxml v0_9 )
# find_ups_boost takes a minimum required version and an optional list of boost libraries
#find_ups_boost( v1_42_0 filesystem )
# this will also define the ROOT library variables
#find_ups_root( v5_26_00 )

# let cmake define variables for external libraries and executables

# define FHICLCPP
#find_library( FHICLCPP NAMES fhiclcpp PATHS $ENV{FHICLCPP_LIB} )

# Building  all libraries and binaries in a single lib and bin directory
# is useful for a complex product like art.
# You may not want to do this for smaller products.

#build all libraries in a single directory
SET(LIBRARY_OUTPUT_PATH ${PROJECT_BINARY_DIR}/lib)

#build all executables in a single directory
SET(EXECUTABLE_OUTPUT_PATH ${PROJECT_BINARY_DIR}/bin)

# The environment has been established, now generate the Makefiles.

# source
subdirs (ToyCmake)

# testing
subdirs(test)

# ups - table and config files
subdirs(ups)

# This step enables building the package tarball
# packaging utility
include(UseCPack)
