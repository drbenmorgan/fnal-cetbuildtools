# Declare the install path from the cmake command line using either a relative or full path
# create a build directory (MyBuild) and an install direcotory (MyInstall),
# which are outside the source code directory (MySource)
#
#   cd MyBuild
#   cmake -DCMAKE_INSTALL_PREFIX=MyInstall MySource
#   make
#   make test
#   make install
#
# If you change any of the Cmake* files, you need to run the cmake step again

# use cmake 2.6 or later
cmake_minimum_required (VERSION 2.6)
# project name
project(ToyCmake)
set( version v0_0_0 )
SET (qualifier a1)
SET (flavorqual sl5.x86_64.${qualifier})
SET (flavorqual_dir ${version}/${flavorqual} )

# because we want to move these libraries about,
# do not embed full path in shared libraries or executables
set (CMAKE_SKIP_RPATH)

ENABLE_TESTING()

# require GCC
set( GCC_VERSION $ENV{GCC_VERSION} )
if ( NOT GCC_VERSION )
  message(FATAL_ERROR "Can't locate GCC_VERSION, required for building ToyCmake")
endif ()

# include search path
include_directories ("${PROJECT_BINARY_DIR}")
include_directories ("${PROJECT_SOURCE_DIR}")
# add PRODUCT_INC for each dependent product here
# notice use of ENV to invoke an external variable
#include_directories ( $ENV{BOOST_INC} )
#include_directories ( $ENV{FHICLCPP_INC} )

# define ROOT libraries
#find_library( REFLEX NAMES Reflex PATHS $ENV{ROOTSYS}/lib )
#find_library( CINT   NAMES Cint   PATHS $ENV{ROOTSYS}/lib )
# define genreflex executable
#find_program( GENREFLEX NAMES genreflex PATHS $ENV{ROOTSYS}/bin )

# define FHICLCPP
#find_library( FHICLCPP NAMES fhiclcpp PATHS $ENV{FHICLCPP_LIB} )

#build all libraries in a single directory to enable testing
SET(LIBRARY_OUTPUT_PATH ${PROJECT_BINARY_DIR}/lib)
#build all executables in a single directory
SET(EXECUTABLE_OUTPUT_PATH ${PROJECT_BINARY_DIR}/bin)

# source
subdirs (ToyCmake)

# testing
subdirs(test)

# ups - table and config files
subdirs(ups)
