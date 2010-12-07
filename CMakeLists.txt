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
SET (version v1_4_3)
# we don't use a qualifier for a utility product
##SET (qualifier a1)

set(CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/Modules)

#set package version from ups version
include(ParseUpsVersion)
set_version_from_ups( ${version} )

# This is a NULL flavored product, 
# We don't use flavorqual_dir, but we could
SET( SLTYPE noarch )
SET (flavorqual ${SLTYPE}.${qualifier})
SET (flavorqual_dir ${product}/${version}/${flavorqual} )

# cetbuildtools has no architecture dependence

# source code
subdirs(templates)
subdirs(Modules)
subdirs(bin)
subdirs(ups)
subdirs(example)

# packaging utility
include(UseCPack)

