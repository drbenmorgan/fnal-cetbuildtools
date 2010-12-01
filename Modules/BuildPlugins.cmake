# macros for building plugin libraries
#

# simple plugin libraries
macro (simple_plugin name)
  add_library(${name} SHARED ${name}.cc )
  set(simple_plugin_liblist "${ARGN}")
  if( simple_plugin_liblist )
    target_link_libraries( ${name} ${simple_plugin_liblist} )
  endif( simple_plugin_liblist )
  install( TARGETS ${name}  DESTINATION ${flavorqual_dir}/lib )
endmacro (simple_plugin name)
