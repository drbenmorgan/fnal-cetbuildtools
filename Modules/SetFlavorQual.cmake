# determine the system flavor and define flavorqual_dir
#
# set_flavor_qual( QUAL )

macro( set_flavor_qual )

# sl5 is 2.6.18
# sl4 is 2.6.9
if(${CMAKE_SYSTEM_NAME} MATCHES "Linux" )
   if( ${CMAKE_HOST_SYSTEM_VERSION} MATCHES "^2.6.9.*" )
       SET( SLTYPE sl4 )
   endif ()
   if( ${CMAKE_HOST_SYSTEM_VERSION} MATCHES "^2.6.18.*" )
       SET( SLTYPE sl5 )
   endif ()
   message(STATUS "Building on Linux ${SLTYPE} ${CMAKE_SYSTEM_PROCESSOR}" )
endif ()
# require SLTYPE
if ( NOT SLTYPE )
  message(FATAL_ERROR "Can't determine system type")
endif ()
SET (flavorqual ${SLTYPE}.${CMAKE_SYSTEM_PROCESSOR}.${qualifier})
SET (flavorqual_dir ${product}/${version}/${flavorqual} )
message(STATUS "Flavorqual is ${flavorqual}" )

endmacro( set_flavor_qual )
