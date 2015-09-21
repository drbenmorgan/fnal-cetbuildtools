# we install all the example files here
# All cmake files below this directory are part of the example

# Looks like this is done purely to lock in version of cetbuildtools...
configure_file (${CMAKE_CURRENT_SOURCE_DIR}/ToyCmake/ups/product_deps.in
  ${CMAKE_CURRENT_BINARY_DIR}/ToyCmake/ups/product_deps @ONLY
  )

install(DIRECTORY ToyCmake
  DESTINATION "${CMAKE_INSTALL_DATAROOTDIR}/${PROJECT_NAME}/example"
  PATTERN "*.in" EXCLUDE
  )

install(FILES
  ${CMAKE_CURRENT_BINARY_DIR}/ToyCmake/ups/product_deps
  DESTINATION "${CMAKE_INSTALL_DATAROOTDIR}/${PROJECT_NAME}/example/ToyCmake/ups"
  )

