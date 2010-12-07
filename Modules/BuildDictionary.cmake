# macros for building plugin libraries
#
# this is how we do the genreflex step
# define flags for genreflex
set( GENREFLEX_FLAGS --deep
                     --fail_on_warnings
		     --capabilities=classes_ids.cc
		     -D_REENTRANT
		     -DGNU_SOURCE
		     -DGNU_GCC 
		     -DPROJECT_NAME="${PROJECT_NAME}"
		     -DPROJECT_VERSION="${version}" )

# just the code generation step
macro (generate_dictionary maindir subdir)
  get_directory_property( genpath INCLUDE_DIRECTORIES )
  foreach( inc ${genpath} )
      set( GENREFLEX_INCLUDES -I ${inc} ${GENREFLEX_INCLUDES} )
  endforeach(inc)
  set(dictname "${maindir}${subdir}" )
  add_custom_command(
     OUTPUT ${PROJECT_BINARY_DIR}/dict/${dictname}_dict.cpp  
            ${PROJECT_BINARY_DIR}/dict/${dictname}_map.cpp 
     COMMAND ${GENREFLEX} ${CMAKE_CURRENT_SOURCE_DIR}/classes.h
        	 -s ${CMAKE_CURRENT_SOURCE_DIR}/classes_def.xml
		 -I ${CMAKE_SOURCE_DIR}
		 -I ${CMAKE_CURRENT_SOURCE_DIR}
		 ${GENREFLEX_INCLUDES} ${GENREFLEX_FLAGS}
        	 -o ${dictname}_dict.cpp 
     COMMAND ${CMAKE_COMMAND} -E copy classes_ids.cc ${dictname}_map.cpp
     COMMAND ${CMAKE_COMMAND} -E remove -f classes_ids.cc
     DEPENDS ${CMAKE_CURRENT_SOURCE_DIR}/classes.h
             ${CMAKE_CURRENT_SOURCE_DIR}/classes_def.xml
  )
  add_custom_target( ${dictname}_generated 
                     DEPENDS ${PROJECT_BINARY_DIR}/dict/${dictname}_dict.cpp 
                             ${PROJECT_BINARY_DIR}/dict/${dictname}_map.cpp )
endmacro (generate_dictionary)

# dictionaries are built in art with this
macro (build_dictionary maindir subdir)
  set(dictionary_liblist "${ARGN}" ${REFLEX} )
  set(dictname "${maindir}${subdir}" )
  add_library(${dictname}_dict SHARED ${PROJECT_BINARY_DIR}/dict/${dictname}_dict.cpp )
  add_library(${dictname}_map  SHARED ${PROJECT_BINARY_DIR}/dict/${dictname}_map.cpp )
  SET_SOURCE_FILES_PROPERTIES(${PROJECT_BINARY_DIR}/dict/${dictname}_dict.cpp 
                              ${PROJECT_BINARY_DIR}/dict/${dictname}_map.cpp
                              PROPERTIES GENERATED 1)
  target_link_libraries( ${dictname}_dict ${dictionary_liblist} )
  target_link_libraries( ${dictname}_map  ${dictionary_liblist} )
  add_dependencies( ${dictname}_dict ${dictname}_generated )
  add_dependencies( ${dictname}_map  ${dictname}_generated )
  install ( TARGETS ${dictname}_dict DESTINATION ${flavorqual_dir}/lib )
  install ( TARGETS ${dictname}_map  DESTINATION ${flavorqual_dir}/lib )
endmacro (build_dictionary)

