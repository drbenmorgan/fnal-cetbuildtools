
set( installFiles README
                  generic.table.in
		  generic.version.in
                  product_list.template
		  setup_for_development.template )

INSTALL (FILES ${installFiles}
         DESTINATION ${product}/${version}/templates )

