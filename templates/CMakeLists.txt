
set( installFiles README
                  generic.table.in
		  generic.version.in
		  setup_for_development.template )

INSTALL (FILES ${installFiles}
         DESTINATION ${product}/${version}/templates )

