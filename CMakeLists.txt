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
# we don't need a qualifier for a utility product
##SET (qualifier a1)

# This is a NULL flavored product, 
SET( SLTYPE noarch )
SET (flavorqual ${SLTYPE}.${qualifier})
SET (flavorqual_dir ${product}/${version}/${flavorqual} )

# cetbuildtools has no architecture dependence

# source code
subdirs(templates)
subdirs(ups)
subdirs(example)

