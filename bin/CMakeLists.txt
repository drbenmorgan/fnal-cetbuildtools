
INSTALL ( PROGRAMS buildtool
 		   build_table
                   genreflex-wrapper
          DESTINATION ${product}/${version}/bin )

INSTALL ( FILES cet_test_functions.sh
                parse_deps.pm
          DESTINATION ${product}/${version}/bin )
