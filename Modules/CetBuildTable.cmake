# determine the system flavor and define flavorqual_dir
#
# cet_build_table( [arch] )
# allow optional architecture declaration
# noarch is recognized, others are used at your own discretion
#
# process_ups_files()
#   the configure and install steps for ups version and table files

macro( cet_build_table )
   # set sltype
   set( CETBUILDTOOLS_DIR $ENV{CETBUILDTOOLS_DIR} )
   if( NOT CETBUILDTOOLS_DIR )
       FIND_PROGRAM( BUILD_TABLE_NAME build_table )
   else()
       FIND_PROGRAM( BUILD_TABLE_NAME build_table
                     ${CETBUILDTOOLS_DIR}/bin  )
   endif ()
   if( NOT BUILD_TABLE_NAME )
       message(FATAL_ERROR "Can't find build_table")
   endif()

   EXEC_PROGRAM( ${BUILD_TABLE_NAME} OUTPUT_VARIABLE MSG )
   message( STATUS "${BUILD_TABLE_NAME} returned ${MSG}")

endmacro( cet_build_table )

