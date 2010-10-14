
set( installFiles README generic.table.in generic.version.in )

INSTALL (FILES ${installFiles}
         DESTINATION ${product}/${version}/templates )

