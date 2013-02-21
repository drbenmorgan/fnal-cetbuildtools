# create the cmake configure files for this package
#
# set_flavor_qual( [arch] )
# allow optional architecture declaration
# noarch is recognized, others are used at your own discretion
#
# cet_cmake_config( [NO_FLAVOR] )
#   build and install PACKAGE-config-cmake and PACKAGE-config-version.cmake
#   these files are installed in ${flavorqual_dir}/lib/PACKAGE/cmake
#   if NO_FLAVOR is specified, the files are installed under ${product}/${version}/include

# this requires cmake 2.8.8 or later
include(CMakePackageConfigHelpers)

include(CetParseArgs)

macro( cet_cmake_config  )

  cet_parse_args( CCC "" "NO_FLAVOR" ${ARGN})

  if( CCC_NO_FLAVOR )
    set( distdir "${product}/${version}/cmake" )
  else()
    set( distdir "${flavorqual_dir}/lib/${product}/cmake" )
  endif()

  #message(STATUS "cet_cmake_config debug: will install cmake configure files in ${distdir}")
  #message(STATUS "cet_cmake_config debug: ${CONFIG_FIND_UPS_COMMANDS}")
  #message(STATUS "cet_cmake_config debug: ${CONFIG_FIND_LIBRARY_COMMANDS}")
  #message(STATUS "cet_cmake_config debug: ${CONFIG_LIBRARY_LIST}")
 
  # add to library list for package configure file
  foreach( my_library ${CONFIG_LIBRARY_LIST} )
    string(TOUPPER  ${my_library} ${my_library}_UC )
    string(TOUPPER  ${product} ${product}_UC )
    set(CONFIG_FIND_LIBRARY_COMMANDS "${CONFIG_FIND_LIBRARY_COMMANDS}
    cet_find_library( ${${my_library}_UC} NAMES ${my_library} PATHS ENV ${${product}_UC}_LIB )" )
  endforeach(my_library)
  #message(STATUS "cet_cmake_config debug: ${CONFIG_FIND_LIBRARY_COMMANDS}")
 
  configure_package_config_file( 
             ${CMAKE_CURRENT_SOURCE_DIR}/product-config.cmake.in
             ${CMAKE_CURRENT_BINARY_DIR}/${product}-config.cmake 
	     INSTALL_DESTINATION ${distdir} )

  # allowed COMPATIBILITY values are:
  # AnyNewerVersion ExactVersion SameMajorVersion
  write_basic_package_version_file(
             ${CMAKE_CURRENT_BINARY_DIR}/${product}-config-version.cmake
	     VERSION ${VERSION_MAJOR}.${VERSION_MINOR}.${VERSION_PATCH}
	     COMPATIBILITY AnyNewerVersion )

  install( FILES ${CMAKE_CURRENT_BINARY_DIR}/${product}-config.cmake
        	 ${CMAKE_CURRENT_BINARY_DIR}/${product}-config-version.cmake
           DESTINATION ${distdir} )

endmacro( cet_cmake_config )
