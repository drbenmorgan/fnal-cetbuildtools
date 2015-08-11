
install_scripts( LIST buildtool
  build_table
  build_version_file
  cmake-graphviz-filt
  code-dep-graph
  increment-version
  set_dev_products
  report_bindir
  report_incdir
  report_libdir
  report_fcldir
  report_fcldir_base
  report_fwdir
  report_gdmldir
  report_perllib
  report_testdir
  report_product_info
  migrate-package
  )

cet_script(filter-output cet_exec_test)

INSTALL ( FILES cet_test_functions.sh
  cmake_parse_deps.pm
  parse_deps.pm
  set_dep_check_report
  set_dev_bin
  set_dev_check
  set_dev_check_report
  set_dev_fhicl
  set_dev_lib
  set_dev_report
  DESTINATION ${product}/${version}/bin
  )
