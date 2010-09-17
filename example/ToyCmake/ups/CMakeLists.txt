
execute_process( COMMAND date 
                 OUTPUT_VARIABLE datime 
                 OUTPUT_STRIP_TRAILING_WHITESPACE )

configure_file ( ${ToyCmake_SOURCE_DIR}/ups/ToyCmake-config.cmake.in
                 ${ToyCmake_BINARY_DIR}/ups/ToyCmake-config.cmake @ONLY )
configure_file ( ${ToyCmake_SOURCE_DIR}/ups/ToyCmake-config-version.cmake.in
                 ${ToyCmake_BINARY_DIR}/ups/ToyCmake-config-version.cmake @ONLY )

CONFIGURE_FILE ( ${ToyCmake_SOURCE_DIR}/ups/ToyCmake.table.in
                 ${ToyCmake_BINARY_DIR}/ups/ToyCmake.table @ONLY )
CONFIGURE_FILE ( ${ToyCmake_SOURCE_DIR}/ups/ToyCmake.version.in
                 ${ToyCmake_BINARY_DIR}/ups/${version}.version @ONLY )

install (FILES ${ToyCmake_BINARY_DIR}/ups/ToyCmake-config.cmake
               ${ToyCmake_BINARY_DIR}/ups/ToyCmake-config-version.cmake
         DESTINATION ${flavorqual_dir}/lib/ToyCmake-${version} )

INSTALL (FILES ${ToyCmake_BINARY_DIR}/ups/ToyCmake.table
         DESTINATION ${version}/ups)
INSTALL (FILES ${ToyCmake_BINARY_DIR}/ups/${version}.version
         DESTINATION ${CMAKE_INSTALL_PREFIX} )

