# macros for building plugin libraries
#
# this is how we do the genreflex step
# define flags for genreflex
set( GENREFLEX_FLAGS --deep
                     --fail_on_warnings
		     --capabilities=classes_ids.cc
                     -DCMS_DICT_IMPL
		     -D_REENTRANT
		     -DGNU_SOURCE
		     -DGNU_GCC
		     -DPROJECT_NAME="${PROJECT_NAME}"
		     -DPROJECT_VERSION="${version}" )

# a generic build for use outside of art
macro (build_simple_dictionary dictname  )
  get_directory_property( geninc INCLUDE_DIRECTORIES )
  foreach( inc ${geninc} )
      set( GENINCLUDES -I ${inc} ${GENINCLUDES} )
  endforeach(inc)
  set(dictionary_liblist "${ARGN}")
  add_custom_command(
     OUTPUT ${dictname}_dict.cpp
     COMMAND ${GENREFLEX}  ${CMAKE_CURRENT_SOURCE_DIR}/classes.h
        	 -s  ${CMAKE_CURRENT_SOURCE_DIR}/classes_def.xml
		 -I ${CMAKE_SOURCE_DIR}
		 ${GENINCLUDES}
        	 -o ${dictname}_dict.cpp
		 ${GENREFLEX_FLAGS} || { rm -f ${dictname}_dict.cpp\; /bin/false\; }
     DEPENDS  ${CMAKE_CURRENT_SOURCE_DIR}/classes.h
              ${CMAKE_CURRENT_SOURCE_DIR}/classes_def.xml
  )
  add_custom_command(
     OUTPUT ${dictname}_map.cpp
     DEPENDS ${dictname}_dict.cpp
     COMMAND mv classes_ids.cc ${dictname}_map.cpp
  )
  add_library(${dictname}_dict SHARED ${dictname}_dict.cpp )
  add_library(${dictname}_map SHARED ${dictname}_map.cpp )
  target_link_libraries( ${dictname}_dict ${dictionary_liblist} 
                                          ${REFLEX} )
  target_link_libraries( ${dictname}_map ${dictionary_liblist} 
                                          ${REFLEX} )
  install ( TARGETS ${dictname}_dict DESTINATION ${flavorqual_dir}/lib )
  install ( TARGETS ${dictname}_map  DESTINATION ${flavorqual_dir}/lib )
endmacro (build_simple_dictionary)

# dictionaries are built in art with this
macro (build_dictionary maindir subdir)
  get_directory_property( genpath INCLUDE_DIRECTORIES )
  foreach( inc ${genpath} )
      set( GENREFLEX_INCLUDES -I ${inc} ${GENREFLEX_INCLUDES} )
  endforeach(inc)
  set(dictionary_liblist "${ARGN}" ${REFLEX} )
  set(dictname "${maindir}${subdir}" )
  add_custom_command(
     OUTPUT ${dictname}_dict.cpp classes_ids.cc
     COMMAND ${GENREFLEX} ${CMAKE_CURRENT_SOURCE_DIR}/classes.h
        	 -s ${CMAKE_CURRENT_SOURCE_DIR}/classes_def.xml
		 -I ${CMAKE_SOURCE_DIR}
		 -I ${CMAKE_CURRENT_SOURCE_DIR}
		 ${GENREFLEX_INCLUDES} ${GENREFLEX_FLAGS}
        	 -o ${dictname}_dict.cpp || { rm -f ${dictname}_dict.cpp\; rm -f classes_ids.cc\; /bin/false\; }
     DEPENDS ${CMAKE_CURRENT_SOURCE_DIR}/classes.h
             ${CMAKE_CURRENT_SOURCE_DIR}/classes_def.xml
  )
  add_custom_command(
     OUTPUT ${dictname}_map.cpp
     DEPENDS ${dictname}_dict.cpp
     COMMAND mv classes_ids.cc ${dictname}_map.cpp
  )
  add_library(${dictname}_dict SHARED ${dictname}_dict.cpp )
  add_library(${dictname}_map SHARED ${dictname}_map.cpp )
  target_link_libraries( ${dictname}_dict ${dictionary_liblist} )
  target_link_libraries( ${dictname}_map  ${dictionary_liblist} )
  install ( TARGETS ${dictname}_dict DESTINATION ${flavorqual_dir}/lib )
  install ( TARGETS ${dictname}_map  DESTINATION ${flavorqual_dir}/lib )
endmacro (build_dictionary)
