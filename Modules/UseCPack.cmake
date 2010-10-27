# define the environment for cpack
# 

# note that parse_ups_version is used to define VERSION_MAJOR, etc.
set( CPACK_PACKAGE_VERSION_MAJOR ${VERSION_MAJOR} )
set( CPACK_PACKAGE_VERSION_MINOR ${VERSION_MINOR} )
set( CPACK_PACKAGE_VERSION_PATCH ${VERSION_PATCH} )

set( CPACK_INCLUDE_TOPLEVEL_DIRECTORY 0 )
set( CPACK_GENERATOR TGZ )
if ( ${SLTYPE} MATCHES "noarch" )
  if ( NOT qualifier )
    set( CPACK_SYSTEM_NAME ${SLTYPE} )
  else ()
    set( CPACK_SYSTEM_NAME ${SLTYPE}-${qualifier} )
  endif ()
else ()
  if ( NOT qualifier )
    set( CPACK_SYSTEM_NAME ${SLTYPE}-${CMAKE_SYSTEM_PROCESSOR} )
  else ()
    set( CPACK_SYSTEM_NAME ${SLTYPE}-${CMAKE_SYSTEM_PROCESSOR}-${qualifier} )
  endif ()
endif ()


include(CPack)
