# ======================================================================
# Create build and install directories which are outside the source code directory
# Declare the install path from the cmake command line using either a relative or full path
#
#   cd .../path/to/build/directory
#   source .../path/to/ToyCmake/ups/setup_for_development [-d]
#   cmake [-DCMAKE_INSTALL_PREFIX=.../path/to/install/directory] $TOYCMAKE_SOURCE
#   make
#   make test
#   make install
#   make package
# ======================================================================

cmake_minimum_required (VERSION 2.6)  # use cmake 2.6 or later

# project name
project(ToyCmake)
# the ups convention is that product names are all lower case, but this is a choices
set( product toycmake )
set( version v1_02_00 )
SET (qualifier a4)

# cetbuildtools contains our cmake modules
set( CETBUILDTOOLS_VERSION $ENV{CETBUILDTOOLS_VERSION} )
if( NOT CETBUILDTOOLS_VERSION )
  message( FATAL_ERROR "ERROR: setup cetbuildtools to get the cmake modules" )
endif()
set( CMAKE_MODULE_PATH "${CMAKE_ROOT}/Modules" )
set( CMAKE_MODULE_PATH $ENV{CETBUILDTOOLS_DIR}/Modules ${CMAKE_MODULE_PATH} )
message( STATUS "module path is ${CMAKE_MODULE_PATH}" )

set( CMAKE_SKIP_RPATH ) # don't embed path in shared lib's or executables

enable_testing()

# make sure someone isn't typing cmake in the source code tree
include(EnsureOutOfSourceBuild)
cet_ensure_out_of_source_build()

# define some necessary modules
include( FindUpsPackage )
include( FindUpsBoost )
include( SetFlavorQual )
include( ParseUpsVersion )
include( InstallSource )

#set package version from ups version
set_version_from_ups( ${version} )
#define flavorqual and flavorqual_dir
set_flavor_qual()

# ----------------------------------------------------------------------

# require GCC
set( GCC_VERSION $ENV{GCC_VERSION} )
if( NOT GCC_VERSION )
  message( FATAL_ERROR
           "Can't locate GCC_VERSION, required to build and test ${PROJECT_NAME}"
         )
endif()

# find external packages
# product versions here are meant to be minimum required versions
#find_ups_product( gccxml v0_9 )
# find_ups_boost takes a minimum required version and an optional list of boost libraries
#find_ups_boost( v1_46_1 filesystem regex unit_test_framework )
# this will also define the ROOT library variables
#find_ups_root( v5_26_00 )
find_ups_product( cetbuildtools v1_13_00 )
#find_ups_product( cpp0x v1_02_02 )

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

# Building  all libraries and binaries in a single lib and bin directory
# is useful for a complex product like art.
# You may not want to do this for smaller products.

#build all libraries in a single directory
if( NOT LIBRARY_OUTPUT_PATH )
SET(LIBRARY_OUTPUT_PATH ${PROJECT_BINARY_DIR}/lib)
endif()

#build all executables in a single directory
if( NOT EXECUTABLE_OUTPUT_PATH )
SET(EXECUTABLE_OUTPUT_PATH ${PROJECT_BINARY_DIR}/bin)
endif()

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
