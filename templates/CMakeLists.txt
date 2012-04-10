
set( installFiles README
                  product_deps.template
		  setup_for_development.template )

INSTALL (FILES ${installFiles}
         DESTINATION ${product}/${version}/templates )

