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
#  this has to get smarter
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

# add external packages to the include search path
# add PRODUCT_INC for each dependent product here
# notice use of ENV to invoke an external variable
#include_directories ( $ENV{BOOST_INC} )
#include_directories ( $ENV{FHICLCPP_INC} )

# let cmake define variables for external libraries and executables

# define ROOT libraries
#find_library( REFLEX NAMES Reflex PATHS $ENV{ROOTSYS}/lib )
#find_library( CINT   NAMES Cint   PATHS $ENV{ROOTSYS}/lib )
# define genreflex executable
#find_program( GENREFLEX NAMES genreflex PATHS $ENV{ROOTSYS}/bin )

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
