# create the cmake configure files for this package
#
# cet_cmake_config( [NO_FLAVOR] )
#   build and install PackageConfig.cmake and PackageConfigVersion.cmake
#   these files are installed in ${flavorqual_dir}/lib/PACKAGE/cmake
#   if NO_FLAVOR is specified, the files are installed under ${product}/${version}/include

# this requires cmake 2.8.8 or later
include(CMakePackageConfigHelpers)

include(CetParseArgs)

macro( cet_write_version_file _filename )

  cet_parse_args( CWV "VERSION;COMPATIBILITY" "" ${ARGN})

  find_file( versionTemplateFile
             NAMES CetBasicConfigVersion-${CWV_COMPATIBILITY}.cmake.in
             PATHS ${CMAKE_MODULE_PATH} )
  if(NOT EXISTS "${versionTemplateFile}")
    message(FATAL_ERROR "Bad COMPATIBILITY value used for cet_write_version_file(): \"${CWV_COMPATIBILITY}\"")
  endif()

  if("${CWV_VERSION}" STREQUAL "")
    message(FATAL_ERROR "No VERSION specified for cet_write_version_file()")
  endif()

  configure_file("${versionTemplateFile}" "${_filename}" @ONLY)
endmacro( cet_write_version_file )

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
      set( ${${my_library}_UC}  \$ENV{${${product}_UC}_LIB}/lib${my_library}\${CMAKE_SHARED_LIBRARY_SUFFIX} )" )
    #cet_find_library( ${${my_library}_UC} NAMES ${my_library} PATHS ENV ${${product}_UC}_LIB NO_DEFAULT_PATH )" )
    ##message(STATUS "cet_cmake_config: cet_find_library( ${${my_library}_UC} NAMES ${my_library} PATHS ENV ${${product}_UC}_LIB NO_DEFAULT_PATH )" )
    ##message(STATUS "cet_cmake_config: set( ${${my_library}_UC}  \$ENV{${${product}_UC}_LIB}/lib${my_library}\${CMAKE_SHARED_LIBRARY_SUFFIX} )" )
  endforeach(my_library)
  #message(STATUS "cet_cmake_config debug: ${CONFIG_FIND_LIBRARY_COMMANDS}")
  
  # add include path to CONFIG_FIND_LIBRARY_COMMANDS
  ##message(STATUS "cet_cmake_config: ${product}_inc_dir is ${${product}_inc_dir}")
  if( NOT ${${product}_inc_dir} MATCHES "NONE" )
    set(CONFIG_FIND_LIBRARY_COMMANDS "${CONFIG_FIND_LIBRARY_COMMANDS}
      include_directories ( \$ENV{${${product}_UC}_INC} )" )
  endif()
  ##message(STATUS "cet_cmake_config: CONFIG_INCLUDE_DIRECTORY is ${CONFIG_INCLUDE_DIRECTORY}")

  configure_package_config_file( 
             ${CMAKE_CURRENT_SOURCE_DIR}/product-config.cmake.in
             ${CMAKE_CURRENT_BINARY_DIR}/${product}Config.cmake 
	     INSTALL_DESTINATION ${distdir} )

  # allowed COMPATIBILITY values are:
  # AnyNewerVersion ExactVersion SameMajorVersion
  if( CCC_NO_FLAVOR )
    cet_write_version_file(
               ${CMAKE_CURRENT_BINARY_DIR}/${product}ConfigVersion.cmake
	       VERSION ${cet_dot_version}
	       COMPATIBILITY AnyNewerVersion )
  else()
    write_basic_package_version_file(
               ${CMAKE_CURRENT_BINARY_DIR}/${product}ConfigVersion.cmake
	       VERSION ${cet_dot_version}
	       COMPATIBILITY AnyNewerVersion )
  endif()

  install( FILES ${CMAKE_CURRENT_BINARY_DIR}/${product}Config.cmake
        	 ${CMAKE_CURRENT_BINARY_DIR}/${product}ConfigVersion.cmake
           DESTINATION ${distdir} )

endmacro( cet_cmake_config )
