# ======================================================================
#  ToyCmake main build file
#
#  cd .../path/to/build/directory
#  cmake [-DCMAKE_INSTALL_PREFIX=/install/path] /path/to/source
#  make
#  make test
#  make install
#  make package
# ======================================================================



# use cmake 2.8 or later
cmake_minimum_required (VERSION 2.8)

project(ToyCmake)

# cetbuildtools contains our cmake modules
find_package(cetbuildtools 1.0.0 REQUIRED)

# Run the known things needed to set stuff up
# This means a developer *does not* need to source setup_for_development
# However, setup_for_development may do more complicated stuff, yet
# absolutely will not run without ups present. set_dev_products only
# needs files in the project - need to learn what 'simple' vs other args
# do
execute_process(COMMAND ${cetbuildtools_BINDIR}/set_dev_products ${PROJECT_SOURCE_DIR} ${PROJECT_BINARY_DIR} simple)


include(CetCMakeEnv)
cet_cmake_env()

cet_set_compiler_flags(DIAGS VIGILANT WERROR EXTRA_FLAGS -pedantic)
cet_report_compiler_flags()

# these are minimum required versions, not the actual product versions
#find_package(fhiclcpp 2.16.0 REQUIRED)
#find_package(ROOT 5.34.30 REQUIRED)
#find_package(Boost 1.55.0 REQUIRED filesystem unit_test_framework)

# source
add_subdirectory(ToyCmake)

# testing
add_subdirectory(test)

# ups - table and config files
add_subdirectory(ups)

# packaging utility - enable building a package tarball
include(UseCPack)
