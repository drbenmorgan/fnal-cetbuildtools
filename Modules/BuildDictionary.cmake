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

# dictionaries are built in art with this
macro (build_dictionary maindir subdir)
  get_directory_property( genpath INCLUDE_DIRECTORIES )
  foreach( inc ${genpath} )
      set( GENREFLEX_INCLUDES -I ${inc} ${GENREFLEX_INCLUDES} )
  endforeach(inc)
  set(dictionary_liblist "${ARGN}" ${REFLEX} )
  set(dictname "${maindir}${subdir}" )
  add_custom_command(
     OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/${dictname}_dict.cpp  
            ${CMAKE_CURRENT_BINARY_DIR}/${dictname}_map.cpp
     COMMAND ${GENREFLEX} ${CMAKE_CURRENT_SOURCE_DIR}/classes.h
        	 -s ${CMAKE_CURRENT_SOURCE_DIR}/classes_def.xml
		 -I ${CMAKE_SOURCE_DIR}
		 -I ${CMAKE_CURRENT_SOURCE_DIR}
		 ${GENREFLEX_INCLUDES} ${GENREFLEX_FLAGS}
        	 -o ${dictname}_dict.cpp || 
		 { ${CMAKE_COMMAND} -E remove -f ${dictname}_dict.cpp\; 
	           ${CMAKE_COMMAND} -E remove -f classes_ids.cc\; 
		   /bin/false\; }
     COMMAND ${CMAKE_COMMAND} -E copy classes_ids.cc ${dictname}_map.cpp
     COMMAND ${CMAKE_COMMAND} -E remove -f classes_ids.cc
     DEPENDS ${CMAKE_CURRENT_SOURCE_DIR}/classes.h
             ${CMAKE_CURRENT_SOURCE_DIR}/classes_def.xml
  )
  add_library(${dictname}_dict SHARED ${CMAKE_CURRENT_BINARY_DIR}/${dictname}_dict.cpp )
  add_library(${dictname}_map  SHARED ${CMAKE_CURRENT_BINARY_DIR}/${dictname}_map.cpp )
  target_link_libraries( ${dictname}_dict ${dictionary_liblist} )
  target_link_libraries( ${dictname}_map  ${dictionary_liblist} )
  install ( TARGETS ${dictname}_dict DESTINATION ${flavorqual_dir}/lib )
  install ( TARGETS ${dictname}_map  DESTINATION ${flavorqual_dir}/lib )
endmacro (build_dictionary)
