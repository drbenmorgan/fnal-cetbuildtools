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
# (prof)    MINSIZEREL      -O3 -g -DNDEBUG -fno-omit-frame-pointer
# (opt)     RELEASE         -O3 -g -DNDEBUG
# (default) RELWITHDEBINFO  unchanged
#
# Plus the diagnostic option set indicated by the DIAG option.
#
# Optional arguments
#    DIAGS
#      This option may be CAVALIER, CAUTIOUS, VIGILANT or PARANOID.
#      Default is CAUTIOUS.
#
#    EXTRA_FLAGS (applied to both C and CXX)
#    EXTRA_C_FLAGS
#    EXTRA_CXX_FLAGS
#    EXTRA_DEFINITIONS
#      This list parameters will append tbe appropriate items.
#
####################################
#
# cet_query_system() just lists the values of various variables
#
########################################################################
include(CMakeParseArguments)

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

macro( cet_set_compiler_flags )
  CMAKE_PARSE_ARGUMENTS(CSCF
    "ENABLE_ASSERTS"
    "DIAGS"
    "EXTRA_FLAGS;EXTRA_C_FLAGS;EXTRA_CXX_FLAGS;EXTRA_DEFINITIONS"
    ${ARGN}
    )

  if (CSCF_UNPARSED_ARGUMENTS)
    message(FATAL "Unexpected extra arguments: ${CSCF_UNPARSED_ARGUMENTS}.\nConsider EXTRA_FLAGS, EXTRA_C_FLAGS, EXTRA_CXX_FLAGS or EXTRA_DEFINITIONS")
  endif()
  
  # turn a colon separated list into a space separated string
  STRING( REGEX REPLACE ";" " " CSCF_EXTRA_CXX_FLAGS "${CSCF_EXTRA_CXX_FLAGS}")
  STRING( REGEX REPLACE ";" " " CSCF_EXTRA_C_FLAGS "${CSCF_EXTRA_C_FLAGS}")
  STRING( REGEX REPLACE ";" " " CSCF_EXTRA_FLAGS "${CSCF_EXTRA_FLAGS}")

  set( DFLAGS_CAVALIER "" )
  set( DXXFLAGS_CAVALIER "" )
  set( DFLAGS_CAUTIOUS "-Wall -Werror=return-type" )
  set( DXXFLAGS_CAUTIOUS "" )
  set( DFLAGS_VIGILANT "${DFLAGS_CAUTIOUS} -Wextra -Wno-long-long -Winit-self" )
  set( DXXFLAGS_VIGILANT "-Woverloaded-virtual" )
  set( DFLAGS_PARANOID "${DFLAGS_VIGILANT} -pedantic -Wformat-y2k -Wswitch-default -Wsync-nand -Wtrampolines -Wlogical-op -Wshadow -Wcast-qual" )
  set( DXXFLAGS_PARANOID "" )

  if (NOT CSCF_DIAGS)
    SET(CSCF_DIAGS "CAUTIOUS")
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

  set( CMAKE_C_FLAGS_DEBUG "-g -O0 ${CSCF_EXTRA_FLAGS} ${CSCF_EXTRA_C_FLAGS} ${DFLAGS_${CSCF_DIAGS}}" )
  set( CMAKE_CXX_FLAGS_DEBUG "-std=c++98 -g -O0 ${CSCF_EXTRA_FLAGS} ${CSCF_EXTRA_CXX_FLAGS} ${DFLAGS_${CSCF_DIAGS}} ${DXXFLAGS_${CSCF_DIAGS}}" )
  set( CMAKE_C_FLAGS_MINSIZEREL "-O3 -g -fno-omit-frame-pointer ${CSCF_EXTRA_FLAGS} ${CSCF_EXTRA_C_FLAGS} ${DFLAGS_${CSCF_DIAGS}}" )
  set( CMAKE_CXX_FLAGS_MINSIZEREL "-std=c++98 -O3 -g -fno-omit-frame-pointer ${CSCF_EXTRA_FLAGS} ${CSCF_EXTRA_CXX_FLAGS} ${DFLAGS_${CSCF_DIAGS}} ${DXXFLAGS_${CSCF_DIAGS}}" )
  set( CMAKE_C_FLAGS_RELEASE "-O3 -g ${CSCF_EXTRA_FLAGS} ${CSCF_EXTRA_C_FLAGS} ${DFLAGS_${CSCF_DIAGS}}" )
  set( CMAKE_CXX_FLAGS_RELEASE "-std=c++98 -O3 -g ${CSCF_EXTRA_FLAGS} ${CSCF_EXTRA_CXX_FLAGS} ${DFLAGS_${CSCF_DIAGS}} ${DXXFLAGS_${CSCF_DIAGS}}" )

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
  if( ${BTYPE_UC} MATCHES "DEBUG")
  elseif( ${BTYPE_UC} MATCHES "RELEASE" )
    if ( NOT CSCF_ENABLE_ASSERTS )
      add_definitions(-DNDEBUG)
    endif()
  elseif( ${BTYPE_UC} MATCHES "MINSIZEREL")
    if ( NOT CSCF_ENABLE_ASSERTS )
      add_definitions(-DNDEBUG)
    endif()
  endif()
  add_definitions(${CSCF_EXTRA_DEFINITIONS})
  
  #message( STATUS "compiling with ${CMAKE_BASE_NAME} ${CMAKE_CXX_FLAGS}")
  
  message( STATUS "compiler flags for directory " ${CURRENT_SUBDIR} " and below")
  message( STATUS "   C++ FLAGS:   ${CMAKE_CXX_FLAGS_${BTYPE_UC}}")
  message( STATUS "   C   FLAGS:   ${CMAKE_C_FLAGS_${BTYPE_UC}}")
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
