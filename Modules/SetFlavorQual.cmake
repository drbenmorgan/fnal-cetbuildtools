# determine the system flavor and define flavorqual_dir
#
# set_flavor_qual( [arch] )
# allow optional architecture declaration
# noarch is recognized, others are used at your own discretion
#
# process_ups_files()
#   the configure and install steps for ups version and table files

macro( set_flavor_qual )

set(arch "${ARGN}")

# sl5 is 2.6.18
# sl4 is 2.6.9
if(${CMAKE_SYSTEM_NAME} MATCHES "Linux" )
   # set sltype
   set( CETBUILDTOOLS_DIR $ENV{CETBUILDTOOLS_DIR} )
   if( NOT CETBUILDTOOLS_DIR )
       FIND_PROGRAM( CETB_GET_DIRECTORY_NAME get-directory-name 
                     ${CMAKE_SOURCE_DIR}/bin )
   else()
       FIND_PROGRAM( CETB_GET_DIRECTORY_NAME get-directory-name 
                     ${CETBUILDTOOLS_DIR}/bin  )
   endif ()
   EXEC_PROGRAM( ${CETB_GET_DIRECTORY_NAME} ARGS os OUTPUT_VARIABLE SLTYPE )
   # find ups flavor
   set( UPS_DIR $ENV{UPS_DIR} )
   if( NOT UPS_DIR )
       if( ${CMAKE_HOST_SYSTEM_VERSION} MATCHES "^2.6.9.*" )
	   if( ${CMAKE_SYSTEM_PROCESSOR} MATCHES "x86_64" )
               set( UPSFLAVOR Linux64bit+2.6-2.3.4)
	   elseif( ${CMAKE_SYSTEM_PROCESSOR} MATCHES "ppc" )
               set( UPSFLAVOR Linuxppc+2.6-2.3.4)
	   else ()
               set( UPSFLAVOR Linux+2.6-2.3.4)
	   endif ()
       endif ()
       if( ${CMAKE_HOST_SYSTEM_VERSION} MATCHES "^2.6.18.*" )
	   if( ${CMAKE_SYSTEM_PROCESSOR} MATCHES "x86_64" )
               set( UPSFLAVOR Linux64bit+2.6-2.5)
	   elseif( ${CMAKE_SYSTEM_PROCESSOR} MATCHES "ppc" )
               set( UPSFLAVOR Linuxppc+2.6-2.5)
	   else ()
               set( UPSFLAVOR Linux+2.6-2.5)
	   endif ()
       endif ()
   else()
       FIND_PROGRAM( CET_UPS ups ${UPS_DIR}/bin  )
       EXEC_PROGRAM( ${CET_UPS} ARGS flavor OUTPUT_VARIABLE UPSFLAVOR )
   endif ()
   if( CMAKE_CROSSCOMPILING )
       if( ${CMAKE_SYSTEM_PROCESSOR} MATCHES "ppc" )
	   if( ${CMAKE_HOST_SYSTEM_VERSION} MATCHES "^2.6.9.*" )
        	   set( UPSFLAVOR Linuxppc+2.6-2.3.4)
	   elseif( ${CMAKE_HOST_SYSTEM_VERSION} MATCHES "^2.6.18.*" )
        	   set( UPSFLAVOR Linuxppc+2.6-2.5)
	   else ()
        	   set( UPSFLAVOR Linuxppc)
	   endif ()
       endif()
   endif ()
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
message(STATUS "Building for ${CMAKE_SYSTEM_NAME} ${SLTYPE} ${CMAKE_SYSTEM_PROCESSOR}" )

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

# check for extra qualifiers
message(STATUS "set_flavor_qual: build type is ${CMAKE_BUILD_TYPE}")
if( NOT  CMAKE_BUILD_TYPE )
   SET( extra_qualifier "" )
   set( full_qualifier ${qualifier} )
else()
   #message(STATUS "set_flavor_qual: found build type ${CMAKE_BUILD_TYPE}" )
   STRING(TOLOWER ${CMAKE_BUILD_TYPE} CMAKE_BUILD_TYPE_TOLOWER)
   if( ${CMAKE_BUILD_TYPE_TOLOWER} MATCHES "debug")
      set(extra_qualifier debug )
   elseif( ${CMAKE_BUILD_TYPE_TOLOWER} MATCHES "opt")
      set(extra_qualifier opt )
   elseif( ${CMAKE_BUILD_TYPE_TOLOWER} MATCHES "prof")
      set(extra_qualifier prof )
   elseif( ${CMAKE_BUILD_TYPE_TOLOWER} MATCHES "release")
      set(extra_qualifier opt )
   elseif( ${CMAKE_BUILD_TYPE_TOLOWER} MATCHES "minsizerel")
      set(extra_qualifier prof )
   endif()   
   if( extra_qualifier )
      set( flavorqual_dir ${product}/${version}/${flavorqual}.${extra_qualifier} )
      set( flavorqual ${flavorqual}.${extra_qualifier})
      set( full_qualifier ${qualifier}:${extra_qualifier} )
   else()
      set( flavorqual_dir ${product}/${version}/${flavorqual} )
      set( full_qualifier ${qualifier}:${extra_qualifier} )
   endif()
endif()
message(STATUS "set_flavor_qual: flavorqual is ${flavorqual}" )
message(STATUS "set_flavor_qual: ups flavor is ${UPSFLAVOR}" )
message(STATUS "set_flavor_qual: flavorqual directory is ${flavorqual_dir}" )

endmacro( set_flavor_qual )

macro( process_ups_files )
  if( NOT product )
    message(FATAL_ERROR "product name is not defined")
  endif()

  # table file
  configure_file( ${CMAKE_CURRENT_SOURCE_DIR}/${product}.table.in
                  ${CMAKE_CURRENT_BINARY_DIR}/${product}.table @ONLY )
  install( FILES ${CMAKE_CURRENT_BINARY_DIR}/${product}.table
           DESTINATION ${product}/${version}/ups )

  # version file
  if( extra_qualifier )
     message(STATUS "extra qualifier ${extra_qualifier}")
     configure_file( ${CMAKE_CURRENT_SOURCE_DIR}/${product}.version.in
                     ${CMAKE_CURRENT_BINARY_DIR}/${UPSFLAVOR}_${qualifier}_${extra_qualifier}  @ONLY )
     install( FILES ${CMAKE_CURRENT_BINARY_DIR}/${UPSFLAVOR}_${qualifier}_${extra_qualifier} 
              DESTINATION ${product}/${version}.version )
  else()
     configure_file( ${CMAKE_CURRENT_SOURCE_DIR}/${product}.version.in
                     ${CMAKE_CURRENT_BINARY_DIR}/${UPSFLAVOR}_${qualifier}  @ONLY )
     install( FILES ${CMAKE_CURRENT_BINARY_DIR}/${UPSFLAVOR}_${qualifier} 
              DESTINATION ${product}/${version}.version )
  endif()

endmacro( process_ups_files )
