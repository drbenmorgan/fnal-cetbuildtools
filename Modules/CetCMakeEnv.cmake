# cet_cmake_env
#
# factor out the boiler plate at the top of every main CMakeLists.txt file
# cet_cmake_env( [arch] )
# allow optional architecture declaration
# noarch is recognized, others are used at your own discretion
# 

# Dummy use of CET_TEST_GROUPS to quell warning.
if (CET_TEST_GROUPS)
endif()

include(CetGetProductInfo)
include(CetRegexEscape)
include(CetHaveQual)

# Verify that the compiler is set as desired, and is consistent with our
# current known use of qualifiers.

function(_verify_cc COMPILER)
  if(NOT CMAKE_C_COMPILER) # Languages disabled.
    return()
  endif()
  if(COMPILER STREQUAL "cc")
    set(compiler_ref "^/usr/bin/cc$")
  elseif(COMPILER MATCHES "^(gcc.*)$")
    cet_regex_escape("$ENV{GCC_FQ_DIR}/bin/${CMAKE_MATCH_0}" escaped_path)
    set(compiler_ref "^${escaped_path}$")
  elseif(COMPILER STREQUAL icc)
    cet_regex_escape("$ENV{ICC_FQ_DIR}/bin/intel64/${COMPILER}" escaped_path)
    set(compiler_ref "^${escaped_path}$")
  elseif(COMPILER STREQUAL clang)
    message(FATAL_ERROR "Clang not yet supported.")
  elseif(COMPILER MATCHES "[-_]gcc\\$")
    message(FATAL_ERROR "Cross-compiling not yet supported")
  else()
    message(FATAL_ERROR "Unrecognized C compiler \"${COMPILER}\": use cc, gcc(-XXX)?, icc, or clang.")
  endif()
  get_filename_component(cr_dir "${compiler_ref}" DIRECTORY)
  _cet_real_dir("${cr_dir}" cr_dir)
  get_filename_component(cr_name "${compiler_ref}" NAME)
  set(compiler_ref "${cr_dir}/${cr_name}")
  if(NOT (CMAKE_C_COMPILER MATCHES "${compiler_ref}"))
    message(FATAL_ERROR "CMAKE_C_COMPILER set to ${CMAKE_C_COMPILER}: expected match to \"${compiler_ref}\".\n"
      "Use buildtool or preface cmake invocation with \"env CC=${CETPKG_CC}.\" Use buildtool -c if changing qualifier.")
  endif()
endfunction()

function(_verify_cxx COMPILER)
  if(NOT CMAKE_CXX_COMPILER) # Languages disabled.
    return()
  endif()
  if(COMPILER STREQUAL "c++")
    set(compiler_ref "^/usr/bin/c\\+\\+$")
  elseif(COMPILER MATCHES "^(g\\+\\+.*)$")
    cet_regex_escape("$ENV{GCC_FQ_DIR}/bin/${CMAKE_MATCH_0}" escaped_path)
    set(compiler_ref "^${escaped_path}$")
  elseif(COMPILER STREQUAL icpc)
    set(compiler_ref "$ENV{ICC_FQ_DIR}/bin/intel64/${COMPILER}")
  elseif(COMPILER STREQUAL clang++)
    message(FATAL_ERROR "Clang not yet supported.")
  elseif(COMPILER MATCHES "[-_]g\\+\\+$")
    message(FATAL_ERROR "Cross-compiling not yet supported")
  else()
    message(FATAL_ERROR "Unrecognized C++ compiler \"${COMPILER}\": use c++, g++(-XXX)?, icpc, or clang++.")
  endif()
  get_filename_component(cr_dir "${compiler_ref}" DIRECTORY)
  _cet_real_dir("${cr_dir}" cr_dir)
  get_filename_component(cr_name "${compiler_ref}" NAME)
  set(compiler_ref "${cr_dir}/${cr_name}")
  if(NOT (CMAKE_CXX_COMPILER MATCHES "${compiler_ref}"))
    message(FATAL_ERROR "CMAKE_CXX_COMPILER set to ${CMAKE_CXX_COMPILER}: expected match to \"${compiler_ref}\".\n"
      "Use buildtool or preface cmake invocation with \"env CXX=${CETPKG_CXX}.\" Use buildtool -c if changing qualifier.")
  endif()
endfunction()

function(_verify_fc COMPILER)
  if(NOT CMAKE_Fortran_COMPILER) # Languages disabled.
    return()
  endif()
  if(COMPILER MATCHES "^(gfortran.*)$")
    cet_regex_escape("$ENV{GCC_FQ_DIR}/bin/${CMAKE_MATCH_0}" escaped_path)
    set(compiler_ref "^${escaped_path}$")
  elseif(COMPILER STREQUAL ifort)
    set(compiler_ref "$ENV{ICC_FQ_DIR}/bin/intel64/${COMPILER}")
  elseif(COMPILER STREQUAL clang)
    message(FATAL_ERROR "Clang not yet supported.")
  elseif(COMPILER MATCHES "[-_]gfortran$")
    message(FATAL_ERROR "Cross-compiling not yet supported")
  else()
    message(FATAL_ERROR "Unrecognized Fortran compiler \"${COMPILER}\": use , gfortran(-XXX)? or ifort.")
  endif()
  get_filename_component(cr_dir "${compiler_ref}" DIRECTORY)
  _cet_real_dir("${cr_dir}" cr_dir)
  get_filename_component(cr_name "${compiler_ref}" NAME)
  set(compiler_ref "${cr_dir}/${cr_name}")
  if(NOT (CMAKE_Fortran_COMPILER MATCHES "${compiler_ref}"))
    message(FATAL_ERROR "CMAKE_Fortran_COMPILER set to ${CMAKE_Fortran_COMPILER}: expected match to \"${compiler_ref}\".\n"
      "Use buildtool or preface cmake invocation with \"env FC=${CETPKG_FC}.\" Use buildtool -c if changing qualifier.")
  endif()
endfunction()

function(_study_compiler CTYPE)
  # CTYPE = CC, CXX or FC
  if (NOT CTYPE STREQUAL "CC" AND
      NOT CTYPE STREQUAL "CXX" AND
      NOT CTYPE STREQUAL "FC")
    message(FATAL_ERROR "INTERNAL ERROR: unrecognized CTYPE ${CTYPE} to _study_compiler")
  endif()
  cet_get_product_info_item(${CTYPE} rcompiler ec_compiler)
  if (NOT rcompiler)
    message(FATAL_ERROR "Unable to obtain compiler suite setting: re-source setup_for_development?")
  endif()
  if (CTYPE STREQUAL "CC")
    _verify_cc(${rcompiler})
  elseif(CTYPE STREQUAL "CXX")
    _verify_cxx(${rcompiler})
  elseif(CTYPE STREQUAL "FC")
    _verify_fc(${rcompiler})
  else()
    message(FATAL_ERROR "INTERNAL ERROR: case missing for CTYPE ${CTYPE} in _study_compiler")
  endif()
endfunction()

function(_verify_compiler_quals)
  _study_compiler(CC)
  _study_compiler(FC)
  _study_compiler(CXX)
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
  set( mrb_qual $ENV{MRB_QUALS} )
  if ( mrb_qual )
    set(full_qualifier ${mrb_qual} CACHE STRING "Package UPS full_qualifier" FORCE)
  else()
    set(full_qualifier ${rqual} CACHE STRING "Package UPS full_qualifier" FORCE)
  endif()
  set(${product}_full_qualifier ${rqual} CACHE STRING "Package UPS ${product}_full_qualifier" FORCE)
  #message(STATUS "_get_cetpkg_info: found ${product} ${version} ${${product}_full_qualifier}")

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
  
  # temporarily set this policy
  # silently ignore non-existent dependencies
  cmake_policy(SET CMP0046 OLD)

  # Silently ignore the lack of an RPATH setting on OS X.
  cmake_policy(SET CMP0042 OLD)

  if( ${product}_full_qualifier )
    # extract base qualifier
    STRING( REGEX REPLACE ":debug" "" Q1 "${${product}_full_qualifier}" )
    STRING( REGEX REPLACE ":opt" "" Q2 "${Q1}" )
    STRING( REGEX REPLACE ":prof" "" Q3 "${Q2}" )
    set(qualifier ${Q3} CACHE STRING "Package UPS qualifier" FORCE)
    if(qualifier)
      # NOP to quell warning
    endif()
    message( STATUS "full qual ${${product}_full_qualifier} reduced to ${qualifier}")
  endif()

  # do not embed full path in shared libraries or executables
  # because the binaries might be relocated
  set(CMAKE_SKIP_RPATH)

  message(STATUS "Product is ${product} ${version} ${${product}_full_qualifier}")
  message(STATUS "Module path is ${CMAKE_MODULE_PATH}")

  set_install_root()
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
  ##message(STATUS "cet_cmake_env debug: ${arch} ${EOSB_DEFAULT_ARGS}")

  # Useful includes.
  include(FindUpsPackage)
  include(FindUpsBoost)
  include(FindUpsRoot)
  include(FindUpsGeant4)
  include(ParseUpsVersion)
  include(SetCompilerFlags)
  include(SetFlavorQual)
  include(InstallSource)
  include(InstallFiles)
  include(InstallPerllib)
  include(CetCMakeUtils)
  include(CetMake)
  include(CetCMakeConfig)

  # initialize cmake config file fragments
  _cet_init_config_var()

  # Make sure compiler is set as the configuration requires.
  if( "${arch}" MATCHES "noarch" )
  message(STATUS "${product} is null flavored")
  else()
  _verify_compiler_quals()
  endif()

  #set package version from ups version
  set_version_from_ups( ${version} )
  # look for the case where there are no underscores
  string(REGEX MATCHALL "_" nfound ${version} )
  list(LENGTH nfound nfound)
  ##message(STATUS "project version components: ${VERSION_MAJOR} ${VERSION_MINOR} ${VERSION_PATCH} ${VERSION_TWEAK}" )
  ##if( ${VERSION_MAJOR} MATCHES "nightly" )
  if( ${nfound} EQUAL 0 )
     set( cet_dot_version ${VERSION_MAJOR} CACHE STRING "Package dot version" FORCE)
  else()
     set_dot_version( ${product} ${version} )
     ##message(STATUS "project dot version: ${${PRODUCTNAME_UC}_DOT_VERSION}" )
     set( cet_dot_version  ${${PRODUCTNAME_UC}_DOT_VERSION} CACHE STRING "Package dot version" FORCE)
  endif()
  message(STATUS "cet dot version: ${cet_dot_version}" )
  #define flavorqual and flavorqual_dir
  set_flavor_qual( ${arch} )
  cet_set_lib_directory()
  cet_set_bin_directory()
  cet_set_inc_directory()
  cet_set_fcl_directory()
  cet_set_fw_directory()
  cet_set_gdml_directory()
  cet_set_perllib_directory()
  cet_set_test_directory()

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
  # find $CETBUILDTOOLS_DIR/bin/report_fcldir
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

macro( cet_set_fw_directory )
  # find $CETBUILDTOOLS_DIR/bin/report_fwdir
  set( CETBUILDTOOLS_DIR $ENV{CETBUILDTOOLS_DIR} )
  if( ${product} MATCHES "cetbuildtools" )
      # building cetbuildtools - use our copy
      #message(STATUS "looking in ${PROJECT_SOURCE_DIR}/bin")
      FIND_PROGRAM( REPORT_FW_DIR report_fwdir
                    ${PROJECT_SOURCE_DIR}/bin  )
  elseif( NOT CETBUILDTOOLS_DIR )
      FIND_PROGRAM( REPORT_FW_DIR report_fwdir )
  else()
      FIND_PROGRAM( REPORT_FW_DIR report_fwdir
                    ${CETBUILDTOOLS_DIR}/bin  )
  endif ()
  #message(STATUS "REPORT_FW_DIR: ${REPORT_FW_DIR}")
  if( NOT REPORT_FW_DIR )
      message(FATAL_ERROR "Can't find report_fwdir")
  endif()
  #message( STATUS "cet_make: cet_ups_dir is ${cet_ups_dir}")
  execute_process(COMMAND ${REPORT_FW_DIR} 
                          ${cet_ups_dir} 
                  OUTPUT_VARIABLE REPORT_FW_DIR_MSG
		  OUTPUT_STRIP_TRAILING_WHITESPACE
		  )
  #message( STATUS "${REPORT_FW_DIR} returned ${REPORT_FW_DIR_MSG}")
  if( ${REPORT_FW_DIR_MSG} MATCHES "DEFAULT" )
     set( ${product}_fw_dir "NONE" CACHE STRING "Package fw directory" FORCE )
  elseif( ${REPORT_FW_DIR_MSG} MATCHES "NONE" )
     set( ${product}_fw_dir ${REPORT_FW_DIR_MSG} CACHE STRING "Package fw directory" FORCE )
  elseif( ${REPORT_FW_DIR_MSG} MATCHES "ERROR" )
     set( ${product}_fw_dir ${REPORT_FW_DIR_MSG} CACHE STRING "Package fw directory" FORCE )
  else()
    STRING( REGEX REPLACE "flavorqual_dir" "${flavorqual_dir}" fdir1 "${REPORT_FW_DIR_MSG}" )
    STRING( REGEX REPLACE "product_dir" "${product}/${version}" fdir2 "${fdir1}" )
    set( ${product}_fw_dir ${fdir2}  CACHE STRING "Package fw directory" FORCE )
  endif()
  #message( STATUS "cet_set_fw_directory: ${product}_fw_dir is ${${product}_fw_dir}")
endmacro( cet_set_fw_directory )

macro( cet_set_gdml_directory )
  # find $CETBUILDTOOLS_DIR/bin/report_gdmldir
  set( CETBUILDTOOLS_DIR $ENV{CETBUILDTOOLS_DIR} )
  if( ${product} MATCHES "cetbuildtools" )
      # building cetbuildtools - use our copy
      #message(STATUS "looking in ${PROJECT_SOURCE_DIR}/bin")
      FIND_PROGRAM( REPORT_GDML_DIR report_gdmldir
                    ${PROJECT_SOURCE_DIR}/bin  )
  elseif( NOT CETBUILDTOOLS_DIR )
      FIND_PROGRAM( REPORT_GDML_DIR report_gdmldir )
  else()
      FIND_PROGRAM( REPORT_GDML_DIR report_gdmldir
                    ${CETBUILDTOOLS_DIR}/bin  )
  endif ()
  #message(STATUS "REPORT_GDML_DIR: ${REPORT_GDML_DIR}")
  if( NOT REPORT_GDML_DIR )
      message(FATAL_ERROR "Can't find report_gdmldir")
  endif()
  #message( STATUS "cet_make: cet_ups_dir is ${cet_ups_dir}")
  execute_process(COMMAND ${REPORT_GDML_DIR} 
                          ${cet_ups_dir} 
                  OUTPUT_VARIABLE REPORT_GDML_DIR_MSG
		  OUTPUT_STRIP_TRAILING_WHITESPACE
		  )
  #message( STATUS "${REPORT_GDML_DIR} returned ${REPORT_GDML_DIR_MSG}")
  if( ${REPORT_GDML_DIR_MSG} MATCHES "DEFAULT" )
     set( ${product}_gdml_dir "NONE" CACHE STRING "Package gdml directory" FORCE )
  elseif( ${REPORT_GDML_DIR_MSG} MATCHES "NONE" )
     set( ${product}_gdml_dir ${REPORT_GDML_DIR_MSG} CACHE STRING "Package gdml directory" FORCE )
  elseif( ${REPORT_GDML_DIR_MSG} MATCHES "ERROR" )
     set( ${product}_gdml_dir ${REPORT_GDML_DIR_MSG} CACHE STRING "Package gdml directory" FORCE )
  else()
    STRING( REGEX REPLACE "flavorqual_dir" "${flavorqual_dir}" fdir1 "${REPORT_GDML_DIR_MSG}" )
    STRING( REGEX REPLACE "product_dir" "${product}/${version}" fdir2 "${fdir1}" )
    set( ${product}_gdml_dir ${fdir2}  CACHE STRING "Package gdml directory" FORCE )
  endif()
  #message( STATUS "cet_set_gdml_directory: ${product}_gdml_dir is ${${product}_gdml_dir}")
endmacro( cet_set_gdml_directory )

macro( cet_set_perllib_directory )
  # find $CETBUILDTOOLS_DIR/bin/report_perllib
  set( CETBUILDTOOLS_DIR $ENV{CETBUILDTOOLS_DIR} )
  if( ${product} MATCHES "cetbuildtools" )
      # building cetbuildtools - use our copy
      #message(STATUS "looking in ${PROJECT_SOURCE_DIR}/bin")
      FIND_PROGRAM( REPORT_PERLLIB report_perllib
                    ${PROJECT_SOURCE_DIR}/bin  )
  elseif( NOT CETBUILDTOOLS_DIR )
      FIND_PROGRAM( REPORT_PERLLIB report_perllib )
  else()
      FIND_PROGRAM( REPORT_PERLLIB report_perllib
                    ${CETBUILDTOOLS_DIR}/bin  )
  endif ()
  #message(STATUS "REPORT_PERLLIB: ${REPORT_PERLLIB}")
  if( NOT REPORT_PERLLIB )
      message(FATAL_ERROR "Can't find report_perllib")
  endif()
  #message( STATUS "cet_make: cet_ups_dir is ${cet_ups_dir}")
  execute_process(COMMAND ${REPORT_PERLLIB} 
                          ${cet_ups_dir} 
                  OUTPUT_VARIABLE REPORT_PERLLIB_MSG
		  OUTPUT_STRIP_TRAILING_WHITESPACE
		  )
  #message( STATUS "${REPORT_PERLLIB} returned ${REPORT_PERLLIB_MSG}")
  if( ${REPORT_PERLLIB_MSG} MATCHES "DEFAULT" )
     set( ${product}_perllib "NONE" CACHE STRING "Package perllib directory" FORCE )
  elseif( ${REPORT_PERLLIB_MSG} MATCHES "NONE" )
     set( ${product}_perllib ${REPORT_PERLLIB_MSG} CACHE STRING "Package perllib directory" FORCE )
  elseif( ${REPORT_PERLLIB_MSG} MATCHES "ERROR" )
     set( ${product}_perllib ${REPORT_PERLLIB_MSG} CACHE STRING "Package perllib directory" FORCE )
  else()
    STRING( REGEX REPLACE "flavorqual_dir" "${flavorqual_dir}" fdir1 "${REPORT_PERLLIB_MSG}" )
    STRING( REGEX REPLACE "product_dir" "${product}/${version}" fdir2 "${fdir1}" )
    set( ${product}_perllib ${fdir2}  CACHE STRING "Package perllib directory" FORCE )
    set( ${product}_ups_perllib ${REPORT_PERLLIB_MSG}  CACHE STRING "Package perllib ups directory" FORCE )
    get_filename_component( ${product}_perllib_subdir "${REPORT_PERLLIB_MSG}" NAME CACHE STRING "Package perllib subdirectory" FORCE)
  endif()
  #message( STATUS "cet_set_perllib_directory: ${product}_perllib is ${${product}_perllib}")
  #message( STATUS "cet_set_perllib_directory: ${product}_perllib_subdir is ${${product}_perllib_subdir}")
endmacro( cet_set_perllib_directory )

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

macro( cet_set_test_directory )
  # The default is product_dir/test
  # find $CETBUILDTOOLS_DIR/bin/report_testdir
  set( CETBUILDTOOLS_DIR $ENV{CETBUILDTOOLS_DIR} )
  if( ${product} MATCHES "cetbuildtools" )
      # building cetbuildtools - use our copy
      #message(STATUS "looking in ${PROJECT_SOURCE_DIR}/bin")
      FIND_PROGRAM( REPORT_TEST_DIR report_testdir
                    ${PROJECT_SOURCE_DIR}/bin  )
  elseif( NOT CETBUILDTOOLS_DIR )
      FIND_PROGRAM( REPORT_TEST_DIR report_testdir )
  else()
      FIND_PROGRAM( REPORT_TEST_DIR report_testdir
                    ${CETBUILDTOOLS_DIR}/bin  )
  endif ()
  #message(STATUS "REPORT_TEST_DIR: ${REPORT_TEST_DIR}")
  if( NOT REPORT_TEST_DIR )
      message(FATAL_ERROR "Can't find report_testdir")
  endif()
  #message( STATUS "cet_make: cet_ups_dir is ${cet_ups_dir}")
  execute_process(COMMAND ${REPORT_TEST_DIR} 
                          ${cet_ups_dir} 
                  OUTPUT_VARIABLE REPORT_TEST_DIR_MSG
		  OUTPUT_STRIP_TRAILING_WHITESPACE
		  )
  #message( STATUS "${REPORT_TEST_DIR} returned ${REPORT_TEST_DIR_MSG}")
  if( ${REPORT_TEST_DIR_MSG} MATCHES "DEFAULT" )
     set( ${product}_test_dir ${product}/${version}/test CACHE STRING "Package test directory" FORCE )
  elseif( ${REPORT_TEST_DIR_MSG} MATCHES "NONE" )
     set( ${product}_test_dir ${REPORT_TEST_DIR_MSG} CACHE STRING "Package test directory" FORCE )
  elseif( ${REPORT_TEST_DIR_MSG} MATCHES "ERROR" )
     set( ${product}_test_dir ${REPORT_TEST_DIR_MSG} CACHE STRING "Package test directory" FORCE )
  else()
    STRING( REGEX REPLACE "flavorqual_dir" "${flavorqual_dir}" bdir1 "${REPORT_TEST_DIR_MSG}" )
    STRING( REGEX REPLACE "product_dir" "${product}/${version}" bdir2 "${bdir1}" )
    set( ${product}_test_dir ${bdir2}  CACHE STRING "Package test directory" FORCE )
  endif()
  #message( STATUS "cet_set_test_directory: ${product}_test_dir is ${${product}_test_dir}")
endmacro( cet_set_test_directory )

macro(_cet_debug_message)
  string(TOUPPER ${CMAKE_BUILD_TYPE} BTYPE_UC )
    if( ${BTYPE_UC} MATCHES "DEBUG" )
      message( STATUS "${ARGN}")
    endif()
endmacro(_cet_debug_message)

macro( set_install_root )
  set( PACKAGE_TOP_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR})
  message( STATUS "set_install_root: PACKAGE_TOP_DIRECTORY is ${PACKAGE_TOP_DIRECTORY}")
endmacro( set_install_root )
