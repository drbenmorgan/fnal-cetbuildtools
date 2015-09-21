# - What's the purpose of this, as product_deps.template.in appears
# to contain cruft...
configure_file ( ${CMAKE_CURRENT_SOURCE_DIR}/product_deps.template.in
                 ${CMAKE_CURRENT_BINARY_DIR}/product_deps.template @ONLY )

install(FILES
  ${CMAKE_CURRENT_BINARY_DIR}/product_deps.template
  README
  product-config.cmake.in.template
  setup_for_development.template
  setup_deps.template
  DESTINATION ${CMAKE_INSTALL_DATADIR}/${PROJECT_NAME}/templates
  )
