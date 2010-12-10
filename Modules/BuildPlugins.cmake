# macros for building plugin libraries
#

# simple plugin libraries
macro (simple_plugin name)
  set(plugin_name "${PROJECT_NAME}_${name}")
  #message(STATUS "SIMPLE_PLUGIN: generating ${plugin_name}")
  add_library(${plugin_name} SHARED ${name}.cc )
  set(simple_plugin_liblist "${ARGN}")
  if( simple_plugin_liblist )
    target_link_libraries( ${plugin_name} ${simple_plugin_liblist} )
  endif( simple_plugin_liblist )
  install( TARGETS ${plugin_name}  DESTINATION ${flavorqual_dir}/lib )
endmacro (simple_plugin name)
