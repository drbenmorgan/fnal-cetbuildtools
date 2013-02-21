# parse a ups version string and set the cmake project versions
#
# set_dot_version ( PRODUCTNAME UPS_VERSION )
# set_version_from_ups( UPS_VERSION )
# parse_ups_version( UPS_VERSION )
#  PRODUCTNAME - product name
#  UPS_VERSION - ups version of the form vx_y_z

macro( parse_ups_version UPS_VERSION )

  STRING( REGEX REPLACE "^[v](.*)[_](.*)[_](.*)$" "\\1" VMAJ "${UPS_VERSION}" )
  STRING( REGEX REPLACE "^[v](.*)[_](.*)[_](.*)$" "\\2" VMIN "${UPS_VERSION}" )
  STRING( REGEX REPLACE "^[v](.*)[_](.*)[_](.*)$" "\\3" VPRJ "${UPS_VERSION}" )
  #message(STATUS "version parses to ${VMAJ}.${VMIN}.${VPRJ}" )

endmacro( parse_ups_version )

macro( set_version_from_ups UPS_VERSION )

  parse_ups_version( ${UPS_VERSION} )

  set( VERSION_MAJOR ${VMAJ} CACHE STRING "Package major version" FORCE)
  set( VERSION_MINOR ${VMIN} CACHE STRING "Package minor version" FORCE )
  set( VERSION_PATCH ${VPRJ} CACHE STRING "Package patch version" FORCE )
  #message(STATUS "project version is ${VERSION_MAJOR}.${VERSION_MINOR}.${VERSION_PATCH}" )

endmacro( set_version_from_ups )

macro( set_dot_version PRODUCTNAME UPS_VERSION )

  string(TOUPPER  ${PRODUCTNAME} PRODUCTNAME_UC )
  STRING( REGEX REPLACE "_" "." VDOT "${UPS_VERSION}" )
  ##message(STATUS "temp version is ${VDOT}" )
  STRING( REGEX REPLACE "^[v]" "" ${PRODUCTNAME_UC}_DOT_VERSION "${VDOT}" )
  #message(STATUS "${PRODUCTNAME_UC}_DOT_VERSION version is ${${PRODUCTNAME_UC}_DOT_VERSION}" )

endmacro( set_dot_version )
