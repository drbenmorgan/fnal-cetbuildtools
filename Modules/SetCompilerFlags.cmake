#
# cet_set_compiler_flags( [extra flags] ) 
#    sets the default compiler flags
#
# cet_query_system() just lists the values of various variables
#

macro( cet_set_compiler_flags )

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

  set( CMAKE_CXX_FLAGS_DEBUG "-g -O0" )
  set( CMAKE_CXX_FLAGS_MINSIZEREL "-O3 -g -DNDEBUG -fno-omit-frame-pointer" )
  set( CMAKE_CXX_FLAGS_RELEASE "-O3 -g -DNDEBUG" )

  if(NOT CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE RelWithDebInfo CACHE STRING "" FORCE)
  endif()
  message(STATUS "cmake build type set to ${CMAKE_BUILD_TYPE}")

  string(TOUPPER ${CMAKE_BUILD_TYPE} BTYPE_UC )
  if( ${BTYPE_UC} MATCHES "DEBUG")
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS_DEBUG}")
  elseif( ${BTYPE_UC} MATCHES "RELEASE")
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS_RELEASE}")
  elseif( ${BTYPE_UC} MATCHES "MINSIZEREL")
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS_MINSIZEREL}")
  endif()
  set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${ARGN}")
  
  message( STATUS "compiling with ${CMAKE_BASE_NAME} ${CMAKE_CXX_FLAGS}")

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
  message( STATUS "CMAKE_CXX_FLAGS is ${CMAKE_CXX_FLAGS}" )
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
