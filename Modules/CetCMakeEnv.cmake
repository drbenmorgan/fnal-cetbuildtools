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

include(CetGetProductInfo)

# Verify that the compiler is set as desired, and is consistent with our
# current known use of qualifiers.
function(_verify_compiler_quals)
  if(NOT CMAKE_C_COMPILER) # Languages disabled.
    return()
  endif()
  cet_get_product_info_item(compiler rcompiler ec_compiler)
  if (NOT rcompiler)
    cet_have_qual("e[24]" REGEX legacy)
    if (legacy)
      message(INFO "Compiler not specified: set to GCC based on qualifier e[24].")
      set(rcompiler gcc)
    endif()
  endif()
  set(compiler ${rcompiler} CACHE STRING "Compiler suite identifier" FORCE)
  if(rcompiler STREQUAL "cc")
    set(c_compiler_ref "/usr/bin/cc")
  elseif(compiler STREQUAL "gcc")
    set(c_compiler_ref "$ENV{GCC_FQ_DIR}/bin/gcc")
  elseif(rcompiler STREQUAL icc)
    message(FATAL_ERROR "Intel compiler suite not yet supported.")
  elseif(rcompiler STREQUAL clang)
    message(FATAL_ERROR "Clang not yet supported.")
  elseif(rcompiler MATCHES "[-_]gcc\\$")
    message(FATAL_ERROR "Cross-compiling not yet supported")
  else()
    message(FATAL_ERROR "Unrecognized compiler suite \"${rcompiler}\": use cc (default), gcc, icc, or clang.")
  endif()
  if(NOT (c_compiler_ref STREQUAL CMAKE_C_COMPILER))
    message(FATAL_ERROR "CMAKE_C_COMPILER set to ${CMAKE_C_COMPILER}: expected ${c_compiler_ref}.\n"
      "Use buildtool or preface cmake invocation with \"env CC=${CETPKG_COMPILER}.\" Use buildtool -c if changing qualifier.")
  endif()
  # Verify consistency of qualifier with compiler choice.
endfunction()



macro(_get_cetpkg_info)

  cet_get_product_info_item(product rproduct ec_product)
  if(ec_product)
    message(FATAL_ERROR "Unable to obtain product information: need to re-source setup_for_development?")
  endif()

  cet_get_product_info_item(version rversion)
  cet_get_product_info_item(default_version rdefault_version)
  cet_get_product_info_item(qualifier rqual)

  set(product ${rproduct} CACHE STRING "Package UPS name" FORCE)
  set(version ${rversion} CACHE STRING "Package UPS version" FORCE)
  set(default_version ${rdefault_version} CACHE STRING "Package UPS default version" FORCE)
  set(full_qualifier ${rqual} CACHE STRING "Package UPS full_qualifier" FORCE)
  #message(STATUS "_get_cetpkg_info: found ${product} ${version} ${full_qualifier}")

  set( cet_ups_dir ${CMAKE_CURRENT_SOURCE_DIR}/ups CACHE STRING "Package UPS directory" FORCE )
  ##message( STATUS "_get_cetpkg_info: cet_ups_dir is ${cet_ups_dir}")
endmacro(_get_cetpkg_info)

macro(cet_cmake_env)

  # project() must have been called before us.
  if(NOT CMAKE_PROJECT_NAME)
    message (FATAL_ERROR
      "CMake project() command must have been invoked prior to cet_cmake_env()."
      "\nIt must be invoked at the top level, not in an included .cmake file.")
  endif()

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
  
  include(CetParseArgs)
  cet_parse_args( EOSB "" "ALLOW_IN_SOURCE_BUILD" ${ARGN})
  if( EOSB_DEFAULT_ARGS)
    set(arch "${EOSB_DEFAULT_ARGS}")
  endif()
  # Ensure out of source build before anything else
  if( NOT EOSB_ALLOW_IN_SOURCE_BUILD )
    include(EnsureOutOfSourceBuild)
    cet_ensure_out_of_source_build()
  endif()

  # Useful includes.
  include(FindUpsPackage)
  include(FindUpsBoost)
  include(FindUpsRoot)
  include(FindUpsGeant4)
  include(ParseUpsVersion)
  include(SetCompilerFlags)
  include(SetFlavorQual)
  include(InstallSource)
  include(CetCMakeUtils)
  include(CetMake)
  include(CetCMakeConfig)

  # initialize cmake config file fragments
  _cet_init_config_var()

  # Make sure compiler is set as the configuration requires.
  _verify_compiler_quals()

  #set package version from ups version
  set_version_from_ups( ${version} )
  # look for the case where there are no underscores
  string(REGEX MATCHALL "_" nfound ${version} )
  list(LENGTH nfound nfound)
  ##if( ${VERSION_MAJOR} MATCHES "nightly" )
  if( ${nfound} EQUAL 0 )
     set( cet_dot_version ${VERSION_MAJOR} CACHE STRING "Package dot version" FORCE)
  else()
     set( cet_dot_version ${VERSION_MAJOR}.${VERSION_MINOR}.${VERSION_PATCH}  CACHE STRING "Package dot version" FORCE)
  endif()
  #define flavorqual and flavorqual_dir
  set_flavor_qual( ${arch} )
  cet_set_lib_directory()
  cet_set_bin_directory()
  cet_set_inc_directory()
  cet_set_fcl_directory()

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
  message(WARNING "Obsolete function cet_check_gcc called -- NOP.")
endmacro(cet_check_gcc)

function( cet_have_qual findq )
  cet_parse_args(CHQ "" "REGEX" ${ARGN})
  list(LENGTH CHQ_DEFAULT_ARGS chq_def_args_length)
  if (chq_def_args_length GREATER 0)
    list(GET CHQ_DEFAULT_ARGS 0 ans_var)
  else()
    set(ans_var CET_HAVE_QUAL)
  endif()
  if (CHQ_REGEX)
    set(qual_index -1)
    STRING(REGEX MATCH "(^|:)${findq}(:|$)" found_match "${full_qualifier}")
    if (found_match)
      set(qual_index 0)
    endif()
  else()
    STRING( REGEX REPLACE ":" ";" qualifier_as_list "${full_qualifier}" )
    list(FIND qualifier_as_list ${findq} qual_index)
    #message(STATUS "cet_have_qual: qual_index is ${qual_index}")
  endif()
  if( qual_index LESS 0 ) 
    set( ${ans_var} "FALSE" PARENT_SCOPE) # Not found.
  else()
    set( ${ans_var} "TRUE" PARENT_SCOPE) # Found.
  endif()
  #message(STATUS "cet_have_qual: returning ${CET_HAVE_QUAL}")
endfunction(cet_have_qual)

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
     set( ${product}_lib_dir ${flavorqual_dir}/lib CACHE STRING "Package lib directory" FORCE )
  elseif( ${REPORT_LIB_DIR_MSG} MATCHES "NONE" )
     set( ${product}_lib_dir ${REPORT_LIB_DIR_MSG} CACHE STRING "Package lib directory" FORCE )
  elseif( ${REPORT_LIB_DIR_MSG} MATCHES "ERROR" )
     set( ${product}_lib_dir ${REPORT_LIB_DIR_MSG} CACHE STRING "Package lib directory" FORCE )
  else()
    STRING( REGEX REPLACE "flavorqual_dir" "${flavorqual_dir}" ldir1 "${REPORT_LIB_DIR_MSG}" )
    STRING( REGEX REPLACE "product_dir" "${product}/${version}" ldir2 "${ldir1}" )
    set( ${product}_lib_dir ${ldir2}  CACHE STRING "Package lib directory" FORCE )
  endif()
  #message( STATUS "cet_set_lib_directory: ${product}_lib_dir is ${${product}_lib_dir}")
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
     set( ${product}_bin_dir ${flavorqual_dir}/bin CACHE STRING "Package bin directory" FORCE )
  elseif( ${REPORT_BIN_DIR_MSG} MATCHES "NONE" )
     set( ${product}_bin_dir ${REPORT_BIN_DIR_MSG} CACHE STRING "Package bin directory" FORCE )
  elseif( ${REPORT_BIN_DIR_MSG} MATCHES "ERROR" )
     set( ${product}_bin_dir ${REPORT_BIN_DIR_MSG} CACHE STRING "Package bin directory" FORCE )
  else()
    STRING( REGEX REPLACE "flavorqual_dir" "${flavorqual_dir}" bdir1 "${REPORT_BIN_DIR_MSG}" )
    STRING( REGEX REPLACE "product_dir" "${product}/${version}" bdir2 "${bdir1}" )
    set( ${product}_bin_dir ${bdir2}  CACHE STRING "Package bin directory" FORCE )
  endif()
  #message( STATUS "cet_set_bin_directory: ${product}_bin_dir is ${${product}_bin_dir}")
endmacro( cet_set_bin_directory )

macro( cet_set_fcl_directory )
  # find $CETBUILDTOOLS_DIR/fcl/report_fcldir
  set( CETBUILDTOOLS_DIR $ENV{CETBUILDTOOLS_DIR} )
  if( ${product} MATCHES "cetbuildtools" )
      # building cetbuildtools - use our copy
      #message(STATUS "looking in ${PROJECT_SOURCE_DIR}/fcl")
      FIND_PROGRAM( REPORT_FCL_DIR report_fcldir
                    ${PROJECT_SOURCE_DIR}/bin  )
  elseif( NOT CETBUILDTOOLS_DIR )
      FIND_PROGRAM( REPORT_FCL_DIR report_fcldir )
  else()
      FIND_PROGRAM( REPORT_FCL_DIR report_fcldir
                    ${CETBUILDTOOLS_DIR}/bin  )
  endif ()
  #message(STATUS "REPORT_FCL_DIR: ${REPORT_FCL_DIR}")
  if( NOT REPORT_FCL_DIR )
      message(FATAL_ERROR "Can't find report_fcldir")
  endif()
  #message( STATUS "cet_make: cet_ups_dir is ${cet_ups_dir}")
  execute_process(COMMAND ${REPORT_FCL_DIR} 
                          ${cet_ups_dir} 
                  OUTPUT_VARIABLE REPORT_FCL_DIR_MSG
		  OUTPUT_STRIP_TRAILING_WHITESPACE
		  )
  #message( STATUS "${REPORT_FCL_DIR} returned ${REPORT_FCL_DIR_MSG}")
  if( ${REPORT_FCL_DIR_MSG} MATCHES "DEFAULT" )
     set( ${product}_fcl_dir ${product}/${version}/fcl CACHE STRING "Package fcl directory" FORCE )
  elseif( ${REPORT_FCL_DIR_MSG} MATCHES "NONE" )
     set( ${product}_fcl_dir ${REPORT_FCL_DIR_MSG} CACHE STRING "Package fcl directory" FORCE )
  elseif( ${REPORT_FCL_DIR_MSG} MATCHES "ERROR" )
     set( ${product}_fcl_dir ${REPORT_FCL_DIR_MSG} CACHE STRING "Package fcl directory" FORCE )
  else()
    STRING( REGEX REPLACE "flavorqual_dir" "${flavorqual_dir}" fdir1 "${REPORT_FCL_DIR_MSG}" )
    STRING( REGEX REPLACE "product_dir" "${product}/${version}" fdir2 "${fdir1}" )
    set( ${product}_fcl_dir ${fdir2}  CACHE STRING "Package fcl directory" FORCE )
  endif()
  #message( STATUS "cet_set_fcl_directory: ${product}_fcl_dir is ${${product}_fcl_dir}")
endmacro( cet_set_fcl_directory )

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
     set( ${product}_inc_dir "${product}/${version}/include" CACHE STRING "Package include directory" FORCE )
  elseif( ${REPORT_INC_DIR_MSG} MATCHES "NONE" )
     set( ${product}_inc_dir ${REPORT_INC_DIR_MSG} CACHE STRING "Package include directory" FORCE )
  elseif( ${REPORT_INC_DIR_MSG} MATCHES "ERROR" )
     set( ${product}_inc_dir ${REPORT_INC_DIR_MSG} CACHE STRING "Package include directory" FORCE )
  else()
    STRING( REGEX REPLACE "flavorqual_dir" "${flavorqual_dir}" ldir1 "${REPORT_INC_DIR_MSG}" )
    STRING( REGEX REPLACE "product_dir" "${product}/${version}" ldir2 "${ldir1}" )
    set( ${product}_inc_dir ${ldir2}  CACHE STRING "Package include directory" FORCE )
  endif()
  #message( STATUS "cet_set_inc_directory: ${product}_inc_dir is ${${product}_inc_dir}")
endmacro( cet_set_inc_directory )

macro(_cet_debug_message)
  string(TOUPPER ${CMAKE_BUILD_TYPE} BTYPE_UC )
    if( ${BTYPE_UC} MATCHES "DEBUG" )
      message( STATUS "${ARGN}")
    endif()
endmacro(_cet_debug_message)
