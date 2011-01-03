# macros for building plugin libraries
#
# The plugin type is expected to be service, source, or module, 
# but we do not enforce this.

# simple plugin libraries
macro (simple_plugin name type)
  set(plugin_name "${PROJECT_NAME}_${name}_${type}")
  set(codename "${name}_${type}.cc")
  STRING(REGEX MATCH [_] has_underscore ${name})
  if( has_underscore )
     message(SEND_ERROR  "found underscore in plugin name: ${name}" )
  endif( has_underscore )
  #message(STATUS "SIMPLE_PLUGIN: generating ${plugin_name}")
  add_library(${plugin_name} SHARED ${codename} )
  set(simple_plugin_liblist "${ARGN}")
  if( simple_plugin_liblist )
    target_link_libraries( ${plugin_name} ${simple_plugin_liblist} )
  endif( simple_plugin_liblist )
  install( TARGETS ${plugin_name}  DESTINATION ${flavorqual_dir}/lib )
endmacro (simple_plugin name)
