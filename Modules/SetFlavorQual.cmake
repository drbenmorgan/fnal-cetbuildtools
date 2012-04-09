# determine the system flavor and define flavorqual_dir
#
# set_flavor_qual( [arch] )
# allow optional architecture declaration
# noarch is recognized, others are used at your own discretion
#
# process_ups_files()
#   the configure and install steps for ups version and table files

include(CetBuildTable)

macro( set_flavor_qual )

set(arch "${ARGN}")

# sl5 is 2.6.18
# sl4 is 2.6.9
if(${CMAKE_SYSTEM_NAME} MATCHES "Linux" )
   # set sltype
   FIND_PROGRAM( CETB_GET_DIRECTORY_NAME get-directory-name )
   execute_process(COMMAND ${CETB_GET_DIRECTORY_NAME} os 
                   OUTPUT_VARIABLE SLTYPE 
		   OUTPUT_STRIP_TRAILING_WHITESPACE
		   )
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
       execute_process(COMMAND ${CET_UPS} flavor 
                       OUTPUT_VARIABLE UPSFLAVOR
		       OUTPUT_STRIP_TRAILING_WHITESPACE
		       )
       #message( STATUS " flavor is ${UPSFLAVOR}" )
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
   if( ${CMAKE_HOST_SYSTEM_VERSION} MATCHES "^10.7.*" )
       set( SLTYPE d11 )
       set( UPSFLAVOR Darwin+11 )
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

# all qualifiers are passed
STRING( REGEX REPLACE ":" "." QUAL_SUBDIR "${full_qualifier}" )
#message(STATUS "qualifiers: ${full_qualifier} ${QUAL_SUBDIR}")

if( ${arch} MATCHES "noarch" )
    SET (flavorqual ${SLTYPE}.${QUAL_SUBDIR} )
else ()
    SET (flavorqual ${SLTYPE}.${CMAKE_SYSTEM_PROCESSOR}.${QUAL_SUBDIR})
endif ()
SET (flavorqual_dir ${product}/${version}/${flavorqual} )

#message(STATUS "set_flavor_qual: flavorqual is ${flavorqual}" )
#message(STATUS "set_flavor_qual: ups flavor is ${UPSFLAVOR}" )
message(STATUS "set_flavor_qual: flavorqual directory is ${flavorqual_dir}" )

endmacro( set_flavor_qual )

macro( cet_version_file )

  STRING( REGEX REPLACE ":" ";" QUAL_LIST "${full_qualifier}" )
  STRING( REGEX REPLACE ":" "_" VQUAL "${full_qualifier}" )
  
  configure_file( ${CMAKE_CURRENT_SOURCE_DIR}/${product}.version.in
                  ${CMAKE_CURRENT_BINARY_DIR}/${UPSFLAVOR}_${VQUAL}  @ONLY )
  install( FILES ${CMAKE_CURRENT_BINARY_DIR}/${UPSFLAVOR}_${VQUAL} 
           DESTINATION ${product}/${version}.version )

endmacro( cet_version_file )

macro( process_ups_files )
  if( NOT product )
    message(FATAL_ERROR "product name is not defined")
  endif()

  # table file
  cet_build_table()

  # version file
  cet_version_file()

endmacro( process_ups_files )
