# define the environment for cpack
#
include(FindCompilerVersion)

# note that parse_ups_version is used to define VERSION_MAJOR, etc.
set( CPACK_PACKAGE_VERSION_MAJOR ${VERSION_MAJOR} )
set( CPACK_PACKAGE_VERSION_MINOR ${VERSION_MINOR} )
set( CPACK_PACKAGE_VERSION_PATCH ${VERSION_PATCH} )

set( CPACK_INCLUDE_TOPLEVEL_DIRECTORY 0 )
set( CPACK_GENERATOR TBZ2 )
set( CPACK_PACKAGE_NAME ${product} )

find_compiler()

FIND_PROGRAM( CETB_GET_DIRECTORY_NAME get-directory-name )
set( THIS_PLATFORM ${CMAKE_SYSTEM_PROCESSOR} )
if(${CMAKE_SYSTEM_NAME} MATCHES "Darwin" )
   execute_process(COMMAND ${CETB_GET_DIRECTORY_NAME} platform
                   OUTPUT_VARIABLE THIS_PLATFORM 
		   OUTPUT_STRIP_TRAILING_WHITESPACE
		   )
endif ()

if ( ${OSTYPE} MATCHES "noarch" )
  set( PACKAGE_BASENAME ${OSTYPE} )
else ()
  set( PACKAGE_BASENAME ${OSTYPE}-${THIS_PLATFORM} )
endif ()
if ( NOT full_qualifier )
  set( CPACK_SYSTEM_NAME ${PACKAGE_BASENAME} )
else ()
  # all qualifiers are passed
  STRING( REGEX REPLACE ":" "-" QUAL_NAME "${full_qualifier}" )
  #message(STATUS "UseCPack: full_qualifiers ${full_qualifier} ${QUAL_NAME}")
  set( CPACK_SYSTEM_NAME ${PACKAGE_BASENAME}-${QUAL_NAME} )
endif ()

message(STATUS "CPACK_PACKAGE_NAME and CPACK_SYSTEM_NAME are ${CPACK_PACKAGE_NAME} ${CPACK_SYSTEM_NAME}" )

include(CPack)
