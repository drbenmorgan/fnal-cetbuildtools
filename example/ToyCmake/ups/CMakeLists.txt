
execute_process( COMMAND date
                 OUTPUT_VARIABLE datime
                 OUTPUT_STRIP_TRAILING_WHITESPACE )

process_ups_files()

configure_file ( ${ToyCmake_SOURCE_DIR}/ups/ToyCmake-config.cmake.in
                 ${ToyCmake_BINARY_DIR}/ups/ToyCmake-config.cmake @ONLY )
configure_file ( ${ToyCmake_SOURCE_DIR}/ups/ToyCmake-config-version.cmake.in
                 ${ToyCmake_BINARY_DIR}/ups/ToyCmake-config-version.cmake @ONLY )

install (FILES ${ToyCmake_BINARY_DIR}/ups/ToyCmake-config.cmake
               ${ToyCmake_BINARY_DIR}/ups/ToyCmake-config-version.cmake
         DESTINATION ${flavorqual_dir}/lib/ToyCmake-${version} )

