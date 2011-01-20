# determine the system flavor and define flavorqual_dir
#
# set_flavor_qual( [arch] )
# allow optional architecture declaration
# noarch is recognized, others are used at your own discretion

macro( set_flavor_qual )

set(arch "${ARGN}")

# sl5 is 2.6.18
# sl4 is 2.6.9
if(${CMAKE_SYSTEM_NAME} MATCHES "Linux" )
   if( ${CMAKE_HOST_SYSTEM_VERSION} MATCHES "^2.6.9.*" )
       SET( SLTYPE slf4 )
       if( ${CMAKE_HOST_SYSTEM_PROCESSOR} MATCHES "x86_64" )
           set( UPSFLAVOR Linux64bit+2.6-2.3.4)
       else ()
           set( UPSFLAVOR Linux+2.6-2.3.4)
       endif ()
   endif ()
   if( ${CMAKE_HOST_SYSTEM_VERSION} MATCHES "^2.6.18.*" )
       SET( SLTYPE slf5 )
       if( ${CMAKE_HOST_SYSTEM_PROCESSOR} MATCHES "x86_64" )
           set( UPSFLAVOR Linux64bit+2.6-2.5)
       else ()
           set( UPSFLAVOR Linux+2.6-2.5)
       endif ()
   endif ()
   message(STATUS "Building on Linux ${SLTYPE} ${CMAKE_SYSTEM_PROCESSOR}" )
endif ()
if(${CMAKE_SYSTEM_NAME} MATCHES "Darwin" )
   if( ${CMAKE_HOST_SYSTEM_VERSION} MATCHES "^10.4.*" )
       set( SLTYPE d8 )
       set( UPSFLAVOR Darwin+8 )
   endif()
   if( ${CMAKE_HOST_SYSTEM_VERSION} MATCHES "^10.5.*" )
       set( SLTYPE d9 )
       set( UPSFLAVOR Darwin+9 )
   endif()
   if( ${CMAKE_HOST_SYSTEM_VERSION} MATCHES "^10.6.*" )
       set( SLTYPE d10 )
       set( UPSFLAVOR Darwin+10 )
   endif()
endif ()

if ( arch )
   set( SLTYPE ${arch} )
   set( UPSFLAVOR ${arch} )
   if( ${arch} MATCHES "noarch" )
       set( SLTYPE ${arch} )
       set( UPSFLAVOR NULL )
   endif ()
endif ()
# require SLTYPE
if ( NOT SLTYPE )
  message(FATAL_ERROR "Can't determine system type")
endif ()

if( ${arch} MATCHES "noarch" )
    SET (flavorqual ${SLTYPE}.${qualifier} )
else ()
    SET (flavorqual ${SLTYPE}.${CMAKE_SYSTEM_PROCESSOR}.${qualifier})
endif ()
SET (flavorqual_dir ${product}/${version}/${flavorqual} )
message(STATUS "Flavorqual is ${flavorqual}" )
message(STATUS "ups flavor is ${UPSFLAVOR}" )

endmacro( set_flavor_qual )
