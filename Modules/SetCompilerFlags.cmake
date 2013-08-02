
########################################################################
# cet_set_compiler_flags( [extra flags] ) 
#
#    sets the default compiler flags
#
# default gcc/g++ flags:
# DEBUG           -g
# RELEASE         -O3 -DNDEBUG
# MINSIZEREL      -Os -DNDEBUG
# RELWITHDEBINFO  -O2 -g
#
# CET flags
# (debug)   DEBUG           -g -O0
# (prof)    PROF            -O3 -g -DNDEBUG -fno-omit-frame-pointer
# (opt)     OPT             -O3 -g -DNDEBUG
# (prof)    MINSIZEREL      -O3 -g -DNDEBUG -fno-omit-frame-pointer
# (opt)     RELEASE         -O3 -g -DNDEBUG
# (default) RELWITHDEBINFO  unchanged
#
# Plus the diagnostic option set indicated by the DIAG option.
#
# Optional arguments
#    DIAGS <diag-level>
#      This option may be CAVALIER, CAUTIOUS, VIGILANT or PARANOID.
#      Default is CAUTIOUS.
#    ENABLE_ASSERTS
#      Enable asserts regardless of debug level (default is to disable
#      asserts for PROF and OPT levels).
#    EXTRA_FLAGS (applied to both C and CXX) <flags>
#    EXTRA_C_FLAGS <flags>
#    EXTRA_CXX_FLAGS <flags>
#    EXTRA_DEFINITIONS <flags>
#      This list parameters will append tbe appropriate items.
#    NO_UNDEFINED
#      Unresolved symbols will cause an error when making a shared
#      library.
#    WERROR
#      All warnings are flagged as errors.
#
####################################
# cet_enable_asserts()
#
#   Enable use of assserts (ie remove -DNDEBUG) regardless of
#   optimization level.
#
####################################
# cet_disable_asserts()
#
#   Disable use of assserts (ie ensure -DNDEBUG) regardless of
#   optimization level.
#
####################################
# cet_maybe_disable_asserts()
#
#   Possibly disable use of assserts (ie ensure -DNDEBUG) based on
#   optimization level.
#
####################################
# cet_add_compiler_flags(<options>)
#
#   Add the specified compiler flags.
#
# Options:
#
#   C <flags>
#     Add <flags> to C compile flags.
#
#   CXX <flags>
#    Add <flags> to CXX compile flags.
#
####################################
# cet_remove_compiler_flags(<options>)
#
#   Remove the specifiied compiler flag (one only).
#
# Options:
#
#   C <flag>
#     Remove <flag> from C compile flags.
#
#   CXX <flags>
#    Remove <flag> from CXX compile flags.
#
####################################
# cet_report_compiler_flags()
#
#   Print the compiler flags currently in use.
#
####################################
# cet_query_system()
#
#   List the values of various variables
#
########################################################################
include(CetParseArgs)

macro( cet_report_compiler_flags )
  string(TOUPPER ${CMAKE_BUILD_TYPE} BTYPE_UC )
  message( STATUS "compiler flags for directory " ${CURRENT_SUBDIR} " and below")
  message( STATUS "   C++ FLAGS:   ${CMAKE_CXX_FLAGS_${BTYPE_UC}}")
  message( STATUS "   C   FLAGS:   ${CMAKE_C_FLAGS_${BTYPE_UC}}")
endmacro( cet_report_compiler_flags )

macro( _cet_process_flags PTYPE_UC )
   # turn a space separated string into a colon separated list
  STRING( REGEX REPLACE " " ";" tmp_cxx_flags "${CMAKE_CXX_FLAGS_${PTYPE_UC}}")
  STRING( REGEX REPLACE " " ";" tmp_c_flags "${CMAKE_C_FLAGS_${PTYPE_UC}}")
  ##message( STATUS "tmp_cxx_flags: ${tmp_cxx_flags}")
  ##message( STATUS "tmp_c_flags: ${tmp_c_flags}")
  foreach( flag ${tmp_cxx_flags} )
     if( ${flag} MATCHES "^-W(.*)" )
        ##message( STATUS "Warning: ${flag}" )
     elseif( ${flag} MATCHES "-pedantic" )
        ##message( STATUS "Ignoring: ${flag}" )
     elseif( ${flag} MATCHES "-std[=]c[+][+]98" )
        ##message( STATUS "Ignoring: ${flag}" )
     else()
        ##message( STATUS "keep ${flag}" )
        list(APPEND TMP_CXX_FLAGS_${PTYPE_UC} ${flag} )
     endif()
  endforeach( flag )
  foreach( flag ${tmp_c_flags} )
     if( ${flag} MATCHES "^-W(.*)" )
        ##message( STATUS "Warning: ${flag}" )
     elseif( ${flag} MATCHES "-pedantic" )
        ##message( STATUS "Ignoring: ${flag}" )
     else()
        ##message( STATUS "keep ${flag}" )
        list(APPEND TMP_C_FLAGS_${PTYPE_UC} ${flag} )
     endif()
  endforeach( flag )
  ##message( STATUS "TMP_CXX_FLAGS_${PTYPE_UC}: ${TMP_CXX_FLAGS_${PTYPE_UC}}")
  ##message( STATUS "TMP_C_FLAGS_${PTYPE_UC}: ${TMP_C_FLAGS_${PTYPE_UC}}")

endmacro( _cet_process_flags )

macro( cet_base_flags )
  foreach( mytype DEBUG;OPT;PROF )
     ##message( STATUS "checking ${mytype}" )
     _cet_process_flags( ${mytype} )
     ##message( STATUS "${mytype} C   flags: ${TMP_C_FLAGS_${mytype}}")
     ##message( STATUS "${mytype} CXX flags: ${TMP_CXX_FLAGS_${mytype}}")
     set( CET_BASE_CXX_FLAG_${mytype} ${TMP_CXX_FLAGS_${mytype}}
          CACHE STRING "base CXX ${mytype} flags for ups table"
	  FORCE)
     set( CET_BASE_C_FLAG_${mytype} ${TMP_C_FLAGS_${mytype}}
          CACHE STRING "base C ${mytype} flags for ups table"
	  FORCE)
  endforeach( mytype )
  ##message( STATUS "CET_BASE_CXX_FLAG_DEBUG: ${CET_BASE_CXX_FLAG_DEBUG}")
  ##message( STATUS "CET_BASE_CXX_FLAG_OPT:   ${CET_BASE_CXX_FLAG_OPT}")
  ##message( STATUS "CET_BASE_CXX_FLAG_PROF:  ${CET_BASE_CXX_FLAG_PROF}")
endmacro( cet_base_flags )

macro( _cet_add_build_types )
  SET( CMAKE_CXX_FLAGS_OPT "${CMAKE_CXX_FLAGS_RELEASE}" CACHE STRING
    "Flags used by the C++ compiler for optimized builds."
    FORCE )
  SET( CMAKE_C_FLAGS_OPT "${CMAKE_C_FLAGS_RELEASE}" CACHE STRING
    "Flags used by the C compiler for optimized builds."
    FORCE )
  SET( CMAKE_EXE_LINKER_FLAGS_OPT "${CMAKE_EXE_LINKER_FLAGS_RELEASE}"
    CACHE STRING
    "Flags used for linking binaries for optimized builds."
    FORCE )
  SET( CMAKE_SHARED_LINKER_FLAGS_OPT "${CMAKE_SHARED_LINKER_FLAGS_RELEASE}"
    CACHE STRING
    "Flags used by the shared libraries linker for optimized builds."
    FORCE )
  MARK_AS_ADVANCED(
    CMAKE_CXX_FLAGS_OPT
    CMAKE_C_FLAGS_OPT
    CMAKE_EXE_LINKER_FLAGS_OPT
    CMAKE_SHARED_LINKER_FLAGS_OPT )

  SET( CMAKE_CXX_FLAGS_PROF "${CMAKE_CXX_FLAGS_MINSIZEREL}" CACHE STRING
    "Flags used by the C++ compiler for optimized builds."
    FORCE )
  SET( CMAKE_C_FLAGS_PROF "${CMAKE_C_FLAGS_MINSIZEREL}" CACHE STRING
    "Flags used by the C compiler for optimized builds."
    FORCE )
  SET( CMAKE_EXE_LINKER_FLAGS_PROF "${CMAKE_EXE_LINKER_FLAGS_MINSIZEREL}"
    CACHE STRING
    "Flags used for linking binaries for optimized builds."
    FORCE )
  SET( CMAKE_SHARED_LINKER_FLAGS_PROF "${CMAKE_SHARED_LINKER_FLAGS_MINSIZEREL}"
    CACHE STRING
    "Flags used by the shared libraries linker for optimized builds."
    FORCE )

  MARK_AS_ADVANCED(
    CMAKE_CXX_FLAGS_PROF
    CMAKE_C_FLAGS_PROF
    CMAKE_EXE_LINKER_FLAGS_PROF
    CMAKE_SHARED_LINKER_FLAGS_PROF )

  # Update the documentation string of CMAKE_BUILD_TYPE for GUIs
  SET( CMAKE_BUILD_TYPE "${CMAKE_BUILD_TYPE}" CACHE STRING
    "Choose the type of build, options are: None Debug Release RelWithDebInfo MinSizeRel Opt Prof."
    FORCE )

endmacro( _cet_add_build_types )

macro( cet_enable_asserts )
  remove_definitions(-DNDEBUG)
endmacro( cet_enable_asserts )

macro( cet_disable_asserts )
  remove_definitions(-DNDEBUG)
  add_definitions(-DNDEBUG)
endmacro( cet_disable_asserts )

macro( cet_maybe_disable_asserts )
  string(TOUPPER ${CMAKE_BUILD_TYPE} BTYPE_UC )
  cet_enable_asserts() # Starting point
  if( ${BTYPE_UC} MATCHES "OPT" OR
      ${BTYPE_UC} MATCHES "PROF" OR
      ${BTYPE_UC} MATCHES "RELEASE" OR
      ${BTYPE_UC} MATCHES "MINSIZEREL" )
    cet_disable_asserts()
  endif()
endmacro( cet_maybe_disable_asserts )

macro( cet_add_compiler_flags )
  CET_PARSE_ARGS(CSCF
    "C;CXX"
    ""
    ${ARGN}
    )
  if (CSCF_DEFAULT_ARGS)
    message(FATAL "Unexpected extra arguments: ${CSCF_DEFAULT_ARGS}.\nConsider C OR CXX")
  endif()

  STRING(REGEX REPLACE ";" " " CSCF_C "${CSCF_C}")
  STRING(REGEX REPLACE ";" " " CSCF_CXX "${CSCF_CXX}")
  STRING(TOUPPER ${CMAKE_BUILD_TYPE} BTYPE_UC )
  IF (CSCF_C)
    SET(CMAKE_C_FLAGS_DEBUG "${CMAKE_C_FLAGS_DEBUG} ${CSCF_C}")
    SET(CMAKE_C_FLAGS_OPT   "${CMAKE_C_FLAGS_OPT} ${CSCF_C}")
    SET(CMAKE_C_FLAGS_PROF  "${CMAKE_C_FLAGS_PROF} ${CSCF_C}")
  ENDIF()
  IF (CSCF_CXX)
    SET(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} ${CSCF_CXX}")
    SET(CMAKE_CXX_FLAGS_OPT   "${CMAKE_CXX_FLAGS_OPT} ${CSCF_CXX}")
    SET(CMAKE_CXX_FLAGS_PROF  "${CMAKE_CXX_FLAGS_PROF} ${CSCF_CXX}")
  ENDIF()
endmacro( cet_add_compiler_flags )

macro( cet_remove_compiler_flag )
  CET_PARSE_ARGS(CSCF
    "C;CXX"
    ""
    ${ARGN}
    )
  if (CSCF_DEFAULT_ARGS)
    message(FATAL "Unexpected extra arguments: ${CSCF_DEFAULT_ARGS}.\nConsider C OR CXX")
  endif()

  IF (CSCF_C)
    STRING(REGEX REPLACE "${CSCF_C}" "" CMAKE_C_FLAGS_${BTYPE_UC} "${CMAKE_C_FLAGS_${BTYPE_UC}" )
  ENDIF()
  IF (CSCF_CXX)
    STRING(REGEX REPLACE "${CSCF_CXX}" "" CMAKE_CXX_FLAGS_${BTYPE_UC} "${CMAKE_CXX_FLAGS_${BTYPE_UC}" )
  ENDIF()

endmacro(cet_remove_compiler_flag)

macro( cet_set_compiler_flags )
  CET_PARSE_ARGS(CSCF
    "DIAGS;EXTRA_FLAGS;EXTRA_C_FLAGS;EXTRA_CXX_FLAGS;EXTRA_DEFINITIONS"
    "ENABLE_ASSERTS;NO_UNDEFINED;WERROR"
    ${ARGN}
    )

  if (CSCF_DEFAULT_ARGS)
    message(FATAL "Unexpected extra arguments: ${CSCF_DEFAULT_ARGS}.\nConsider EXTRA_FLAGS, EXTRA_C_FLAGS, EXTRA_CXX_FLAGS or EXTRA_DEFINITIONS")
  endif()

  # turn a colon separated list into a space separated string
  STRING( REGEX REPLACE ";" " " CSCF_EXTRA_CXX_FLAGS "${CSCF_EXTRA_CXX_FLAGS}")
  STRING( REGEX REPLACE ";" " " CSCF_EXTRA_C_FLAGS "${CSCF_EXTRA_C_FLAGS}")
  STRING( REGEX REPLACE ";" " " CSCF_EXTRA_FLAGS "${CSCF_EXTRA_FLAGS}")

  set( DFLAGS_CAVALIER "" )
  set( DXXFLAGS_CAVALIER "" )
  set( DFLAGS_CAUTIOUS "-Wall -Werror=return-type" )
  set( DXXFLAGS_CAUTIOUS "" )
  set( DFLAGS_VIGILANT "${DFLAGS_CAUTIOUS} -Wextra -Wno-long-long -Winit-self -Wno-unused-local-typedefs" )
  set( DXXFLAGS_VIGILANT "-Woverloaded-virtual" )
  set( DFLAGS_PARANOID "${DFLAGS_VIGILANT} -pedantic -Wformat-y2k -Wswitch-default -Wsync-nand -Wtrampolines -Wlogical-op -Wshadow -Wcast-qual" )
  set( DXXFLAGS_PARANOID "" )

  if (NOT CSCF_DIAGS)
    SET(CSCF_DIAGS "CAUTIOUS")
  endif()

  if (${CMAKE_SYSTEM_NAME} MATCHES "Darwin")
    set(CMAKE_SHARED_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS} -Wl,-flat_namespace")
  endif()

  if (CSCF_NO_UNDEFINED)
    if (${CMAKE_SYSTEM_NAME} MATCHES "Darwin")
      set(CMAKE_SHARED_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS} -Wl,-undefined,error")
    else()
      set(CMAKE_SHARED_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS} -Wl,--no-undefined")
    endif()
  endif()


  if (CSCF_WERROR)
    set(CSCF_WERROR "-Werror")
  else()
    set(CSCF_WERROR "")
  endif()

  string(TOUPPER "${CSCF_DIAGS}" CSCF_DIAGS)
  if (CSCF_DIAGS STREQUAL "CAVALIER" OR
      CSCF_DIAGS STREQUAL "CAUTIOUS" OR
      CSCF_DIAGS STREQUAL "VIGILANT" OR
      CSCF_DIAGS STREQUAL "PARANOID")
    message(STATUS "Selected diagnostics option ${CSCF_DIAGS}")
  else()
    message(FATAL "Unrecognized DIAGS option ${CSCF_DIAGS}")
  endif()

  set( CMAKE_C_FLAGS_DEBUG "-g -O0 ${CSCF_WERROR} ${CSCF_EXTRA_FLAGS} ${CSCF_EXTRA_C_FLAGS} ${DFLAGS_${CSCF_DIAGS}}" )
  set( CMAKE_CXX_FLAGS_DEBUG "-std=c++98 -g -O0 ${CSCF_WERROR} ${CSCF_EXTRA_FLAGS} ${CSCF_EXTRA_CXX_FLAGS} ${DFLAGS_${CSCF_DIAGS}} ${DXXFLAGS_${CSCF_DIAGS}}" )
  set( CMAKE_C_FLAGS_MINSIZEREL "-O3 -g -fno-omit-frame-pointer ${CSCF_WERROR} ${CSCF_EXTRA_FLAGS} ${CSCF_EXTRA_C_FLAGS} ${DFLAGS_${CSCF_DIAGS}}" )
  set( CMAKE_CXX_FLAGS_MINSIZEREL "-std=c++98 -O3 -g -fno-omit-frame-pointer ${CSCF_WERROR} ${CSCF_EXTRA_FLAGS} ${CSCF_EXTRA_CXX_FLAGS} ${DFLAGS_${CSCF_DIAGS}} ${DXXFLAGS_${CSCF_DIAGS}}" )
  set( CMAKE_C_FLAGS_RELEASE "-O3 -g ${CSCF_WERROR} ${CSCF_EXTRA_FLAGS} ${CSCF_EXTRA_C_FLAGS} ${DFLAGS_${CSCF_DIAGS}}" )
  set( CMAKE_CXX_FLAGS_RELEASE "-std=c++98 -O3 -g ${CSCF_WERROR} ${CSCF_EXTRA_FLAGS} ${CSCF_EXTRA_CXX_FLAGS} ${DFLAGS_${CSCF_DIAGS}} ${DXXFLAGS_${CSCF_DIAGS}}" )

 _cet_add_build_types() 

  if(NOT CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE RelWithDebInfo CACHE STRING "" FORCE)
  endif()

  if( PACKAGE_TOP_DIRECTORY )
     STRING( REGEX REPLACE "^${PACKAGE_TOP_DIRECTORY}/(.*)" "\\1" CURRENT_SUBDIR "${CMAKE_CURRENT_SOURCE_DIR}" )
     if( CURRENT_SUBDIR STREQUAL PACKAGE_TOP_DIRECTORY)
       SET ( CURRENT_SUBDIR "<top>" )
     endif()
  else()
     STRING( REGEX REPLACE "^${CMAKE_SOURCE_DIR}/(.*)" "\\1" CURRENT_SUBDIR "${CMAKE_CURRENT_SOURCE_DIR}" )
     if( CURRENT_SUBDIR STREQUAL CMAKE_SOURCE_DIR )
       SET ( CURRENT_SUBDIR "<top>" )
     endif()
  endif()

  message(STATUS "cmake build type set to ${CMAKE_BUILD_TYPE} in directory " ${CURRENT_SUBDIR} " and below")

  string(TOUPPER ${CMAKE_BUILD_TYPE} BTYPE_UC )
  remove_definitions(-DNDEBUG)
  if ( CSCF_ENABLE_ASSERTS )
    cet_enable_asserts()
  else()
    cet_maybe_disable_asserts()
  endif()
  add_definitions(${CSCF_EXTRA_DEFINITIONS})
  
  #message( STATUS "compiling with ${CMAKE_BASE_NAME} ${CMAKE_CXX_FLAGS}")

  get_directory_property( CSCF_CD COMPILE_DEFINITIONS )
  if( CSCF_CD )
    message( STATUS "   DEFINE (-D): ${CSCF_CD}")
  endif()
 
endmacro( cet_set_compiler_flags )

macro( cet_query_system )
  ### This macro is useful if you need to check a variable
  ## http://cmake.org/Wiki/CMake_Useful_Variables#Compilers_and_Tools
  ## also see http://cmake.org/Wiki/CMake_Useful_Variables/Logging_Useful_Variables
  message( STATUS "cet_query_system: begin compiler report")
  message( STATUS "CMAKE_SYSTEM_NAME is ${CMAKE_SYSTEM_NAME}" )
  message( STATUS "CMAKE_BASE_NAME is ${CMAKE_BASE_NAME}" )
  message( STATUS "CMAKE_BUILD_TYPE is ${CMAKE_BUILD_TYPE}")
  message( STATUS "CMAKE_CONFIGURATION_TYPES is ${CMAKE_CONFIGURATION_TYPES}" )
  message( STATUS "BUILD_SHARED_LIBS  is ${BUILD_SHARED_LIBS}")
  message( STATUS "CMAKE_CXX_COMPILER_ID is ${CMAKE_CXX_COMPILER_ID}" )
  message( STATUS "CMAKE_COMPILER_IS_GNUCXX is ${CMAKE_COMPILER_IS_GNUCXX}" )
  message( STATUS "CMAKE_COMPILER_IS_MINGW is ${CMAKE_COMPILER_IS_MINGW}" )
  message( STATUS "CMAKE_COMPILER_IS_CYGWIN is ${CMAKE_COMPILER_IS_CYGWIN}" )
  message( STATUS "CMAKE_AR is ${CMAKE_AR}" )
  message( STATUS "CMAKE_RANLIB is ${CMAKE_RANLIB}" )
  message( STATUS "CMAKE_CXX_COMPILER is ${CMAKE_CXX_COMPILER}")
  message( STATUS "CMAKE_CXX_OUTPUT_EXTENSION is ${CMAKE_CXX_OUTPUT_EXTENSION}" )
  message( STATUS "CMAKE_CXX_FLAGS_DEBUG is ${CMAKE_CXX_FLAGS_DEBUG}" )
  message( STATUS "CMAKE_CXX_FLAGS_RELEASE is ${CMAKE_CXX_FLAGS_RELEASE}" )
  message( STATUS "CMAKE_CXX_FLAGS_MINSIZEREL is ${CMAKE_CXX_FLAGS_MINSIZEREL}" )
  message( STATUS "CMAKE_CXX_FLAGS_RELWITHDEBINFO is ${CMAKE_CXX_FLAGS_RELWITHDEBINFO}" )
  message( STATUS "CMAKE_CXX_STANDARD_LIBRARIES is ${CMAKE_CXX_STANDARD_LIBRARIES}" )
  message( STATUS "CMAKE_CXX_LINK_FLAGS is ${CMAKE_CXX_LINK_FLAGS}" )
  message( STATUS "CMAKE_C_COMPILER is ${CMAKE_C_COMPILER}")
  message( STATUS "CMAKE_C_FLAGS is ${CMAKE_C_FLAGS}")
  message( STATUS "CMAKE_C_FLAGS_DEBUG is ${CMAKE_C_FLAGS_DEBUG}" )
  message( STATUS "CMAKE_C_FLAGS_RELEASE is ${CMAKE_C_FLAGS_RELEASE}" )
  message( STATUS "CMAKE_C_FLAGS_MINSIZEREL is ${CMAKE_C_FLAGS_MINSIZEREL}" )
  message( STATUS "CMAKE_C_FLAGS_RELWITHDEBINFO is ${CMAKE_C_FLAGS_RELWITHDEBINFO}" )
  message( STATUS "CMAKE_C_OUTPUT_EXTENSION is ${CMAKE_C_OUTPUT_EXTENSION}")
  message( STATUS "CMAKE_SHARED_LIBRARY_CXX_FLAGS is ${CMAKE_SHARED_LIBRARY_CXX_FLAGS}" )
  message( STATUS "CMAKE_SHARED_MODULE_CXX_FLAGS is ${CMAKE_SHARED_MODULE_CXX_FLAGS}" )
  message( STATUS "CMAKE_SHARED_LIBRARY_LINK_CXX_FLAGS is ${CMAKE_SHARED_LIBRARY_LINK_CXX_FLAGS}" )
  message( STATUS "CMAKE_SHARED_LINKER_FLAGS  is ${CMAKE_SHARED_LINKER_FLAGS}")
  message( STATUS "cet_query_system: end compiler report")
endmacro( cet_query_system )
