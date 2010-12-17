
execute_process( COMMAND date
                 OUTPUT_VARIABLE datime
                 OUTPUT_STRIP_TRAILING_WHITESPACE )

CONFIGURE_FILE ( ${cetbuildtools_SOURCE_DIR}/ups/cetbuildtools.table.in
                 ${cetbuildtools_BINARY_DIR}/ups/cetbuildtools.table @ONLY )
CONFIGURE_FILE ( ${cetbuildtools_SOURCE_DIR}/ups/cetbuildtools.version.in
                 ${cetbuildtools_BINARY_DIR}/ups/${version}.version @ONLY )

INSTALL (FILES ${cetbuildtools_BINARY_DIR}/ups/cetbuildtools.table
         DESTINATION ${product}/${version}/ups)
INSTALL (FILES ${cetbuildtools_BINARY_DIR}/ups/${version}.version
         DESTINATION ${product} )

