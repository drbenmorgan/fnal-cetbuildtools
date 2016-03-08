
install(PROGRAMS
  buildtool
  build_table
  build_version_file
  cet_report
  cmake-graphviz-filt
  code-dep-graph
  increment-version
  set_dev_products
  report_product_info
  migrate-package

  filter-output
  cet_exec_test
  DESTINATION "${CMAKE_INSTALL_BINDIR}"
  )

# Not clear why these are in cet_script, put them in PROGRAMS for now
#cet_script(filter-output cet_exec_test)

install(FILES
  cet_test_functions.sh
  cmake_parse_deps.pm
  parse_deps.pm
  set_dep_check_report
  set_dev_bin
  set_dev_check
  set_dev_check_report
  set_dev_fhicl
  set_dev_lib
  set_dev_report
  DESTINATION "${CMAKE_INSTALL_BINDIR}"
  )
