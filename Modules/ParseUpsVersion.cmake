# parse a ups version string and set the cmake project versions
#
# set_dot_version ( PRODUCTNAME UPS_VERSION )
# set_version_from_ups( UPS_VERSION )
# parse_ups_version( UPS_VERSION )
#  PRODUCTNAME - product name
#  UPS_VERSION - ups version of the form vx_y_z

macro(parse_ups_version UPS_VERSION)
  string(REGEX MATCHALL "_" ulist ${UPS_VERSION})
  list(LENGTH ulist nunder)

  if(${nunder} STREQUAL 0)
    string(REGEX REPLACE "^[v](.*)$" "\\1" VMAJ "${UPS_VERSION}")
  elseif( ${nunder} STREQUAL 1 )
    string(REGEX REPLACE "^[v](.*)[_](.*)$" "\\1" VMAJ "${UPS_VERSION}")
    string(REGEX REPLACE "^[v](.*)[_](.*)$" "\\2" VMIN "${UPS_VERSION}")
  elseif(${nunder} STREQUAL 2)
    string(REGEX REPLACE "^[v](.*)[_](.*)[_](.*)$" "\\1" VMAJ "${UPS_VERSION}")
    string(REGEX REPLACE "^[v](.*)[_](.*)[_](.*)$" "\\2" VMIN "${UPS_VERSION}")
    string(REGEX REPLACE "^[v](.*)[_](.*)[_](.*)$" "\\3" VPRJ "${UPS_VERSION}")
  elseif(${nunder} STREQUAL 3 )
    string(REGEX REPLACE "^[v](.*)[_](.*)[_](.*)[_](.*)$" "\\1" VMAJ "${UPS_VERSION}")
    string(REGEX REPLACE "^[v](.*)[_](.*)[_](.*)[_](.*)$" "\\2" VMIN "${UPS_VERSION}")
    string(REGEX REPLACE "^[v](.*)[_](.*)[_](.*)[_](.*)$" "\\3" VPRJ "${UPS_VERSION}")
    string(REGEX REPLACE "^[v](.*)[_](.*)[_](.*)[_](.*)$" "\\4" VPT "${UPS_VERSION}")
  else()
    message(STATUS "NOTE: ups version ${UPS_VERSION} has extra underscores")
    string(REGEX REPLACE "^[v](.*)[_](.*)[_](.*)[_](.*)$" "\\1" VMAJ "${UPS_VERSION}")
    string(REGEX REPLACE "^[v](.*)[_](.*)[_](.*)[_](.*)$" "\\2" VMIN "${UPS_VERSION}")
    string(REGEX REPLACE "^[v](.*)[_](.*)[_](.*)[_](.*)$" "\\3" VPRJ "${UPS_VERSION}")
    string(REGEX REPLACE "^[v](.*)[_](.*)[_](.*)[_](.*)$" "\\4" VPT "${UPS_VERSION}")
  endif()
endmacro()


macro(set_version_from_ups UPS_VERSION)
  parse_ups_version(${UPS_VERSION})
  set(VERSION_MAJOR ${VMAJ} CACHE STRING "Package major version" FORCE)
  set(VERSION_MINOR ${VMIN} CACHE STRING "Package minor version" FORCE)
  set(VERSION_PATCH ${VPRJ} CACHE STRING "Package patch version" FORCE)
  set(VERSION_TWEAK ${VPT} CACHE STRING "Package tweak version" FORCE)
endmacro()


macro(set_dot_version PRODUCTNAME UPS_VERSION)
  string(TOUPPER  ${PRODUCTNAME} PRODUCTNAME_UC)
  string(REGEX REPLACE "_" "." VDOT "${UPS_VERSION}")
  string(REGEX REPLACE "^[v]" "" ${PRODUCTNAME_UC}_DOT_VERSION "${VDOT}")
endmacro()

