# define the environment for cpack
# 

# note that parse_ups_version is used to define VERSION_MAJOR, etc.
set( CPACK_PACKAGE_VERSION_MAJOR ${VERSION_MAJOR} )
set( CPACK_PACKAGE_VERSION_MINOR ${VERSION_MINOR} )
set( CPACK_PACKAGE_VERSION_PATCH ${VERSION_PATCH} )

set( CPACK_INCLUDE_TOPLEVEL_DIRECTORY 0 )
set( CPACK_GENERATOR TGZ )
set( CPACK_SYSTEM_NAME ${SLTYPE} )

include(CPack)
