# use to install source code
#
# install_source()

macro( install_source )

STRING( REGEX REPLACE "^${CMAKE_SOURCE_DIR}(.*)" "\\1" CURRENT_SUBDIR "${CMAKE_CURRENT_SOURCE_DIR}" )
set(source_install_dir ${product}/${version}/source/${product}${CURRENT_SUBDIR} )
FILE(GLOB cc_files "*.cc" )
FILE(GLOB cpp_files "*.cpp" )
FILE(GLOB h_files "*.h" )
INSTALL( FILES ${cc_files} ${cpp_files} ${h_files}
         DESTINATION ${source_install_dir} )
message( STATUS "source code will be installed in is ${source_install_dir}" )


endmacro( install_source )
