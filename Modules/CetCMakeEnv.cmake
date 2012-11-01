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
