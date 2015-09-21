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

# Basic CMake project setup (NONE project as we're not compiling anything)
cmake_minimum_required(VERSION 2.8.12)
project(cetbuildtools NONE)

# - Include CMake core functionality
# Standard install dirs, plus locations for cmake files
include(GNUInstallDirs)
set(CMAKE_INSTALL_CMAKEDIR ${CMAKE_INSTALL_DATAROOTDIR}/${PROJECT_NAME}/cmake)
set(CMAKE_INSTALL_MODULEDIR ${CMAKE_INSTALL_CMAKEDIR}/Modules)

# Local configure/build time paths so that programs are picked up
# *without* requiring PATH to be set.
set(cetbuildtools_BINDIR ${PROJECT_SOURCE_DIR}/bin)
set(CMAKE_MODULE_PATH ${PROJECT_SOURCE_DIR}/Modules)

# Run the known things needed to set stuff up
# This means a developer *does not* need to source setup_for_development
# However, setup_for_development may do more complicated stuff, yet
# absolutely will not run without ups present. set_dev_products only
# needs files in the project
execute_process(COMMAND ${cetbuildtools_BINDIR}/set_dev_products ${PROJECT_SOURCE_DIR} ${PROJECT_BINARY_DIR} simple)

include(CetCMakeEnv)

# cetbuildtools has no architecture dependence
cet_cmake_env( noarch )

# source code
add_subdirectory(templates)
add_subdirectory(Modules)
add_subdirectory(bin)
add_subdirectory(example)

# For now ignore UPS dir because we want to override the generation of
# the project config file - this allows us to use a custom template
# that allows the binary path to be set, and hence does not require
# PATH etc to be set.
configure_package_config_file(cetbuildtoolsConfig.cmake.in
  ${CMAKE_CURRENT_BINARY_DIR}/cetbuildtoolsConfig.cmake
  INSTALL_DESTINATION ${CMAKE_INSTALL_CMAKEDIR}
  PATH_VARS CMAKE_INSTALL_BINDIR CMAKE_INSTALL_MODULEDIR
  )
write_basic_package_version_file(
  ${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}ConfigVersion.cmake
  VERSION ${cet_dot_version}
  COMPATIBILITY AnyNewerVersion
  )
install(FILES
  ${CMAKE_CURRENT_BINARY_DIR}/cetbuildtoolsConfig.cmake
  ${CMAKE_CURRENT_BINARY_DIR}/cetbuildtoolsConfigVersion.cmake
  DESTINATION ${CMAKE_INSTALL_CMAKEDIR}
  )

# packaging utility
include(UseCPack)

