
INSTALL ( PROGRAMS buildtool
 		   build_table
                   genreflex-wrapper
		   set_dev_products
          DESTINATION ${product}/${version}/bin )

INSTALL ( FILES cet_test_functions.sh
                parse_deps.pm
		set_dev_bin
		set_dev_check
		set_dev_fhicl
		set_dev_lib
		set_dev_report
          DESTINATION ${product}/${version}/bin )
