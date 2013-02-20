# cet_cmake_env
#
# factor out the boiler plate at the top of every main CMakeLists.txt file
# cet_cmake_env( [arch] )
# allow optional architecture declaration
# noarch is recognized, others are used at your own discretion
# 
# make sure gcc has been setup
# cet_check_gcc()
# 
# search for a particular qualifier string 
# (e.g. "a7" in "a7:debug")
# returns ${CET_HAVE_QUAL}
# cet_have_qual( <qualifier> )

# Dummy use of CET_TEST_GROUPS to quell warning.
if (CET_TEST_GROUPS)
endif()

macro(_get_cetpkg_info)

   # find $CETBUILDTOOLS_DIR/bin/
   set( CETBUILDTOOLS_DIR $ENV{CETBUILDTOOLS_DIR} )
   if( NOT CETBUILDTOOLS_DIR )
       #message(STATUS "_get_cetpkg_info: looking in path")
       FIND_PROGRAM( GET_PRODUCT_INFO report_product_info $ENV{PATH} )
   else()
       #message(STATUS "_get_cetpkg_info: looking in ${CETBUILDTOOLS_DIR}/bin")
       FIND_PROGRAM( GET_PRODUCT_INFO report_product_info
                     ${CETBUILDTOOLS_DIR}/bin  )
   endif ()
   #message(STATUS "GET_PRODUCT_INFO: ${GET_PRODUCT_INFO}")
   if( NOT GET_PRODUCT_INFO )
       message(FATAL_ERROR "_get_cetpkg_info: Can't find report_product_info")
   endif()

   execute_process(COMMAND ${GET_PRODUCT_INFO} 
			   ${CMAKE_CURRENT_BINARY_DIR}
			   product
                   OUTPUT_VARIABLE rproduct
		   OUTPUT_STRIP_TRAILING_WHITESPACE
		   )

   execute_process(COMMAND ${GET_PRODUCT_INFO} 
			   ${CMAKE_CURRENT_BINARY_DIR}
			   version
                   OUTPUT_VARIABLE rversion
		   OUTPUT_STRIP_TRAILING_WHITESPACE
		   )

   execute_process(COMMAND ${GET_PRODUCT_INFO} 
			   ${CMAKE_CURRENT_BINARY_DIR}
			   default_version
                   OUTPUT_VARIABLE rdefault_version
		   OUTPUT_STRIP_TRAILING_WHITESPACE
		   )

   execute_process(COMMAND ${GET_PRODUCT_INFO} 
			   ${CMAKE_CURRENT_BINARY_DIR}
			   qualifier
                   OUTPUT_VARIABLE rqual
		   OUTPUT_STRIP_TRAILING_WHITESPACE
		   )

   set(product ${rproduct} CACHE STRING "Package UPS name" FORCE)
   set(version ${rversion} CACHE STRING "Package UPS version" FORCE)
   set(default_version ${rdefault_version} CACHE STRING "Package UPS default version" FORCE)
   set(full_qualifier ${rqual} CACHE STRING "Package UPS full_qualifier" FORCE)
   #message(STATUS "_get_cetpkg_info: found ${product} ${version} ${full_qualifier}")

   set( cet_ups_dir ${CMAKE_CURRENT_SOURCE_DIR}/ups CACHE STRING "Package UPS directory" FORCE )
   ##message( STATUS "_get_cetpkg_info: cet_ups_dir is ${cet_ups_dir}")

  # initialize cmake config file fragments
  set(CONFIG_FIND_UPS_COMMANDS "
## find_ups_product directives
## remember that these are minimum required versions" 
      CACHE STRING "UPS product directives for config" FORCE)
  set(CONFIG_FIND_LIBRARY_COMMANDS "
## find_library directives" 
      CACHE STRING "find_library directives for config" FORCE)
  set(CONFIG_LIBRARY_LIST CACHE INTERNAL "libraries created by this package" )

endmacro(_get_cetpkg_info)

macro(cet_cmake_env)

  set(arch "${ARGN}")

  _get_cetpkg_info()

  if( full_qualifier )
    # extract base qualifier
    STRING( REGEX REPLACE ":debug" "" Q1 "${full_qualifier}" )
    STRING( REGEX REPLACE ":opt" "" Q2 "${Q1}" )
    STRING( REGEX REPLACE ":prof" "" Q3 "${Q2}" )
    set(qualifier ${Q3} CACHE STRING "Package UPS qualifier" FORCE)
    if(qualifier)
      # NOP to quell warning
    endif()
    #message( STATUS "full qual ${full_qualifier} reduced to ${qualifier}")
  endif()

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
  include(CetCMakeConfig)

  #set package version from ups version
  set_version_from_ups( ${version} )
  #define flavorqual and flavorqual_dir
  set_flavor_qual( ${arch} )
  cet_set_lib_directory()
  cet_set_bin_directory()
  cet_set_inc_directory()

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
  
  # this is a dummy test needed by buildtool
  add_test(NAME NOP COMMAND echo)
  set(library_list "" CACHE STRING "list of product librares" FORCE)
  set(product_list "" CACHE STRING "list of ups products" FORCE)
  set(find_library_list "" CACHE STRING "list of find_library calls" FORCE)

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

macro( cet_have_qual findq )
   if(${ARGC} GREATER 1)
     set(ans_var ${ARGV1})
   else()
     set(ans_var CET_HAVE_QUAL)
   endif()
   STRING( REGEX REPLACE ":" ";" qualifier_as_list "${full_qualifier}" )
   list(FIND qualifier_as_list ${findq} qual_index)
   #message(STATUS "cet_have_qual: qual_index is ${qual_index}")
   if( ${qual_index} LESS 0 ) 
     set( ${ans_var} "FALSE") # Not found.
   else()
     set( ${ans_var} "TRUE") # Found.
   endif()
   #message(STATUS "cet_have_qual: returning ${CET_HAVE_QUAL}")
endmacro(cet_have_qual)

macro( cet_set_lib_directory )
  # find $CETBUILDTOOLS_DIR/bin/report_libdir
  set( CETBUILDTOOLS_DIR $ENV{CETBUILDTOOLS_DIR} )
  if( ${product} MATCHES "cetbuildtools" )
      # building cetbuildtools - use our copy
      #message(STATUS "looking in ${PROJECT_SOURCE_DIR}/bin")
      FIND_PROGRAM( REPORT_LIB_DIR report_libdir
                    ${PROJECT_SOURCE_DIR}/bin  )
  elseif( NOT CETBUILDTOOLS_DIR )
      FIND_PROGRAM( REPORT_LIB_DIR report_libdir )
  else()
      FIND_PROGRAM( REPORT_LIB_DIR report_libdir
                    ${CETBUILDTOOLS_DIR}/bin  )
  endif ()
  #message(STATUS "REPORT_LIB_DIR: ${REPORT_LIB_DIR}")
  if( NOT REPORT_LIB_DIR )
      message(FATAL_ERROR "Can't find report_libdir")
  endif()
  #message( STATUS "cet_make: cet_ups_dir is ${cet_ups_dir}")
  execute_process(COMMAND ${REPORT_LIB_DIR} 
                          ${cet_ups_dir} 
                  OUTPUT_VARIABLE REPORT_LIB_DIR_MSG
		  OUTPUT_STRIP_TRAILING_WHITESPACE
		  )
  #message( STATUS "${REPORT_LIB_DIR} returned ${REPORT_LIB_DIR_MSG}")
  if( ${REPORT_LIB_DIR_MSG} MATCHES "DEFAULT" )
     set( cet_lib_dir ${flavorqual_dir}/lib CACHE STRING "Package lib directory" FORCE )
  elseif( ${REPORT_LIB_DIR_MSG} MATCHES "NONE" )
     set( cet_lib_dir ${REPORT_LIB_DIR_MSG} CACHE STRING "Package lib directory" FORCE )
  elseif( ${REPORT_LIB_DIR_MSG} MATCHES "ERROR" )
     set( cet_lib_dir ${REPORT_LIB_DIR_MSG} CACHE STRING "Package lib directory" FORCE )
  else()
    STRING( REGEX REPLACE "flavorqual_dir" "${flavorqual_dir}" ldir1 "${REPORT_LIB_DIR_MSG}" )
    STRING( REGEX REPLACE "product_dir" "${product}/${version}" ldir2 "${ldir1}" )
    set( cet_lib_dir ${ldir2}  CACHE STRING "Package lib directory" FORCE )
  endif()
  #message( STATUS "cet_set_lib_directory: cet_lib_dir is ${cet_lib_dir}")
endmacro( cet_set_lib_directory )

macro( cet_set_bin_directory )
  # find $CETBUILDTOOLS_DIR/bin/report_bindir
  set( CETBUILDTOOLS_DIR $ENV{CETBUILDTOOLS_DIR} )
  if( ${product} MATCHES "cetbuildtools" )
      # building cetbuildtools - use our copy
      #message(STATUS "looking in ${PROJECT_SOURCE_DIR}/bin")
      FIND_PROGRAM( REPORT_BIN_DIR report_bindir
                    ${PROJECT_SOURCE_DIR}/bin  )
  elseif( NOT CETBUILDTOOLS_DIR )
      FIND_PROGRAM( REPORT_BIN_DIR report_bindir )
  else()
      FIND_PROGRAM( REPORT_BIN_DIR report_bindir
                    ${CETBUILDTOOLS_DIR}/bin  )
  endif ()
  #message(STATUS "REPORT_BIN_DIR: ${REPORT_BIN_DIR}")
  if( NOT REPORT_BIN_DIR )
      message(FATAL_ERROR "Can't find report_bindir")
  endif()
  #message( STATUS "cet_make: cet_ups_dir is ${cet_ups_dir}")
  execute_process(COMMAND ${REPORT_BIN_DIR} 
                          ${cet_ups_dir} 
                  OUTPUT_VARIABLE REPORT_BIN_DIR_MSG
		  OUTPUT_STRIP_TRAILING_WHITESPACE
		  )
  #message( STATUS "${REPORT_BIN_DIR} returned ${REPORT_BIN_DIR_MSG}")
  if( ${REPORT_BIN_DIR_MSG} MATCHES "DEFAULT" )
     set( cet_bin_dir ${flavorqual_dir}/bin CACHE STRING "Package bin directory" FORCE )
  elseif( ${REPORT_BIN_DIR_MSG} MATCHES "NONE" )
     set( cet_bin_dir ${REPORT_BIN_DIR_MSG} CACHE STRING "Package bin directory" FORCE )
  elseif( ${REPORT_BIN_DIR_MSG} MATCHES "ERROR" )
     set( cet_bin_dir ${REPORT_BIN_DIR_MSG} CACHE STRING "Package bin directory" FORCE )
  else()
    STRING( REGEX REPLACE "flavorqual_dir" "${flavorqual_dir}" bdir1 "${REPORT_BIN_DIR_MSG}" )
    STRING( REGEX REPLACE "product_dir" "${product}/${version}" bdir2 "${bdir1}" )
    set( cet_bin_dir ${bdir2}  CACHE STRING "Package bin directory" FORCE )
  endif()
  #message( STATUS "cet_set_bin_directory: cet_bin_dir is ${cet_bin_dir}")
endmacro( cet_set_bin_directory )

macro( cet_set_inc_directory )
  # find $CETBUILDTOOLS_DIR/bin/report_incdir
  set( CETBUILDTOOLS_DIR $ENV{CETBUILDTOOLS_DIR} )
  if( ${product} MATCHES "cetbuildtools" )
      # building cetbuildtools - use our copy
      #message(STATUS "looking in ${PROJECT_SOURCE_DIR}/bin")
      FIND_PROGRAM( REPORT_INC_DIR report_incdir
                    ${PROJECT_SOURCE_DIR}/bin  )
  elseif( NOT CETBUILDTOOLS_DIR )
      FIND_PROGRAM( REPORT_INC_DIR report_incdir )
  else()
      FIND_PROGRAM( REPORT_INC_DIR report_incdir
                    ${CETBUILDTOOLS_DIR}/bin  )
  endif ()
  #message(STATUS "REPORT_INC_DIR: ${REPORT_INC_DIR}")
  if( NOT REPORT_INC_DIR )
      message(FATAL_ERROR "Can't find report_incdir")
  endif()
  #message( STATUS "cet_make: cet_ups_dir is ${cet_ups_dir}")
  execute_process(COMMAND ${REPORT_INC_DIR} 
                          ${cet_ups_dir} 
                  OUTPUT_VARIABLE REPORT_INC_DIR_MSG
		  OUTPUT_STRIP_TRAILING_WHITESPACE
		  )
  #message( STATUS "${REPORT_INC_DIR} returned ${REPORT_INC_DIR_MSG}")
  if( ${REPORT_INC_DIR_MSG} MATCHES "DEFAULT" )
     set( cet_inc_dir "${product}/${version}/include" CACHE STRING "Package include directory" FORCE )
  elseif( ${REPORT_INC_DIR_MSG} MATCHES "NONE" )
     set( cet_inc_dir ${REPORT_INC_DIR_MSG} CACHE STRING "Package include directory" FORCE )
  elseif( ${REPORT_INC_DIR_MSG} MATCHES "ERROR" )
     set( cet_inc_dir ${REPORT_INC_DIR_MSG} CACHE STRING "Package include directory" FORCE )
  else()
    STRING( REGEX REPLACE "flavorqual_dir" "${flavorqual_dir}" ldir1 "${REPORT_INC_DIR_MSG}" )
    STRING( REGEX REPLACE "product_dir" "${product}/${version}" ldir2 "${ldir1}" )
    set( cet_inc_dir ${ldir2}  CACHE STRING "Package include directory" FORCE )
  endif()
  #message( STATUS "cet_set_inc_directory: cet_inc_dir is ${cet_inc_dir}")
endmacro( cet_set_inc_directory )

macro(cet_find_library)
  STRING( REGEX REPLACE ";" " " find_library_commands "${ARGN}" )
  #message(STATUS "cet_find_library debug: find_library_commands ${find_library_commands}" )
  #message(STATUS "cet_find_library debug: product_list ${product_list}")
  #message(STATUS "cet_find_library debug: find_library_list ${find_library_list}")
  set(no_product_match TRUE)
  foreach(prod ${product_list})
    if( ${prod} MATCHES ${ARGV2} )
       set(no_product_match FALSE)
    endif()
  endforeach(prod)
  if(no_product_match)
    set(find_library_list ${ARGV2} ${find_library_list})
    # add to library list for package configure file
    set(CONFIG_FIND_LIBRARY_COMMANDS "${CONFIG_FIND_LIBRARY_COMMANDS}
    cet_find_library( ${find_library_commands} )" )
  endif(no_product_match)
  # call find_library
  find_library( ${ARGN} )
endmacro(cet_find_library)

macro(_cet_debug_message)
  string(TOUPPER ${CMAKE_BUILD_TYPE} BTYPE_UC )
    if( ${BTYPE_UC} MATCHES "DEBUG" )
      message( STATUS "${ARGN}")
    endif()
endmacro(_cet_debug_message)
