# determine the system flavor and define flavorqual_dir
#
# cet_build_table( [arch] )
# allow optional architecture declaration
# noarch is recognized, others are used at your own discretion
#

macro( cet_build_table )
   # set sltype
   set( CETBUILDTOOLS_DIR $ENV{CETBUILDTOOLS_DIR} )
   if( ${product} MATCHES "cetbuildtools" )
       # building cetbuildtools - use our copy
       #message(STATUS "looking in ${PROJECT_SOURCE_DIR}/bin")
       FIND_PROGRAM( BUILD_TABLE_NAME build_table
                     ${PROJECT_SOURCE_DIR}/bin  )
   elseif( NOT CETBUILDTOOLS_DIR )
       FIND_PROGRAM( BUILD_TABLE_NAME build_table )
   else()
       FIND_PROGRAM( BUILD_TABLE_NAME build_table
                     ${CETBUILDTOOLS_DIR}/bin  )
   endif ()
   #message(STATUS "BUILD_TABLE_NAME: ${BUILD_TABLE_NAME}")
   if( NOT BUILD_TABLE_NAME )
       message(FATAL_ERROR "Can't find build_table")
   endif()

   execute_process(COMMAND ${BUILD_TABLE_NAME} 
                           ${CMAKE_CURRENT_SOURCE_DIR} 
			   ${CMAKE_CURRENT_BINARY_DIR}
                   OUTPUT_VARIABLE MSG
		   OUTPUT_STRIP_TRAILING_WHITESPACE
		   )
   ##message( STATUS "${BUILD_TABLE_NAME} returned ${MSG}")
   install( FILES ${CMAKE_CURRENT_BINARY_DIR}/${product}.table
           DESTINATION ${product}/${version}/ups )

endmacro( cet_build_table )

