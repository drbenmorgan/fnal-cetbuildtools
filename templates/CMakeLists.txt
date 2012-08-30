
configure_file ( ${CMAKE_CURRENT_SOURCE_DIR}/product_deps.template.in
                 ${CMAKE_CURRENT_BINARY_DIR}/product_deps.template @ONLY )

INSTALL (FILES ${CMAKE_CURRENT_BINARY_DIR}/product_deps.template
               README
               setup_for_development.template
         DESTINATION ${product}/${version}/templates )
