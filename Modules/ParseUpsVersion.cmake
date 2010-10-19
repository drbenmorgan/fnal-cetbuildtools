# parse a ups version string and set the cmake project versions
#
# set_version_from_ups( ups_version )
# parse_ups_version( ups_version )
#  ups_version - ups version of the form vx_y_z

macro( parse_ups_version ups_version )

STRING( REGEX REPLACE "^[v](.*)[_](.*)[_](.*)$" "\\1" VMAJ "${ups_version}" )
STRING( REGEX REPLACE "^[v](.*)[_](.*)[_](.*)$" "\\2" VMIN "${ups_version}" )
STRING( REGEX REPLACE "^[v](.*)[_](.*)[_](.*)$" "\\3" VPRJ "${ups_version}" )
message(STATUS "version parses to ${VMAJ}.${VMIN}.${VPRJ}" )

endmacro( parse_ups_version )

macro( set_version_from_ups UPS_VERSION )

parse_ups_version( ${UPS_VERSION} )

set( VERSION_MAJOR ${VMAJ} )
set( VERSION_MINOR ${VMIN} )
set( VERSION_PATCH ${VPRJ} )
message(STATUS "project version is ${VERSION_MAJOR}.${VERSION_MINOR}.${VERSION_PATCH}" )


endmacro( set_version_from_ups )
