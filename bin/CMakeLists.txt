
install_scripts( LIST buildtool
 		      build_table
		      build_version_file
		      code-dep-graph
		      increment-version
		      set_dev_products
		      report_bindir
		      report_incdir
		      report_libdir
		      report_product_info )

INSTALL ( FILES cet_test_functions.sh
                parse_deps.pm
		set_dep_check_report
		set_dev_bin
		set_dev_check
		set_dev_check_report
		set_dev_fhicl
		set_dev_lib
		set_dev_report
          DESTINATION ${product}/${version}/bin )
