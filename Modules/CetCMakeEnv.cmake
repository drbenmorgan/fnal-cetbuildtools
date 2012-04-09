# cet_cmake_env
#
# factor out the boiler plate at the top of every main CMakeLists.txt file
# cet_cmake_env( <package name>  
#                <package version>
#                [package qualifier] )
# 
# make sure gcc has been setup
# cet_check_gcc()
# 

macro(cet_cmake_env)

#  if(ARGN AND NOT qualifier)
#    get( ARGN 0 qualifier)
#    message(STATUS "qualifier set to ${qualifier}")
#  endif()

  set(product $ENV{CETPKG_NAME} CACHE STRING "Package UPS name" FORCE)
  set(version $ENV{CETPKG_VERSION} CACHE STRING "Package UPS version" FORCE)
  set(full_qualifier $ENV{CETPKG_QUAL} CACHE STRING "Package UPS full_qualifier" FORCE)

  # extract base qualifier
  STRING( REGEX REPLACE ":debug" "" Q1 "${full_qualifier}" )
  STRING( REGEX REPLACE ":opt" "" Q2 "${Q1}" )
  STRING( REGEX REPLACE ":prof" "" Q3 "${Q2}" )
  set(qualifier ${Q3} CACHE STRING "Package UPS qualifier" FORCE)
  #message( STATUS "full qual ${full_qualifier} reduced to ${qualifier}")

  # do not embed full path in shared libraries or executables
  # because the binaries might be relocated
  set(CMAKE_SKIP_RPATH)

  message(STATUS "Product is ${product} ${version} ${full_qualifier}")
  message(STATUS "Module path is ${CMAKE_MODULE_PATH}")

  enable_testing()
  
  # Ensure out of source build before anything else
  include(EnsureOutOfSourceBuild)
  cet_ensure_out_of_source_build()

  # Useful includes.
  include(SetCompilerFlags)
  include(FindUpsPackage)
  include(FindUpsBoost)
  include(FindUpsRoot)
  include(ParseUpsVersion)
  include(SetFlavorQual)
  include(InstallSource)
  include(CetMake)

  # More setup.
  set_version_from_ups(${version})
  set_flavor_qual()

  #set package version from ups version
  set_version_from_ups( ${version} )
  #define flavorqual and flavorqual_dir
  set_flavor_qual()

  set(CETPKG_BUILD $ENV{CETPKG_BUILD})
  if(NOT CETPKG_BUILD)
    message(FATAL_ERROR "Can't locate CETPKG_BUILD, required to build this package.")
  endif()

  # add to the include path
  include_directories ("${PROJECT_BINARY_DIR}")
  include_directories("${PROJECT_SOURCE_DIR}" )
  # make sure all libraries are in one directory
  set(LIBRARY_OUTPUT_PATH    ${PROJECT_BINARY_DIR}/lib)
  # make sure all executables are in one directory
  set(EXECUTABLE_OUTPUT_PATH ${PROJECT_BINARY_DIR}/bin)

endmacro(cet_cmake_env)

macro(cet_check_gcc)

  # make sure gcc has been set
  # note that gcc has no qualifier
  SET ( GCC_VERSION $ENV{GCC_VERSION} )
  IF (NOT GCC_VERSION)
      MESSAGE (FATAL_ERROR "gcc has not been setup")
  ENDIF()
  #message(STATUS "GCC version is ${GCC_VERSION}")

endmacro(cet_check_gcc)
