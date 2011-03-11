# macros for building ROOT dictionaries
# In order to allow proper dependency matching,
# the dictionary input files need to be in their own subdirectory.
# .../somedir/CMakeLists.txt should invoke build_dictionary()
# .../somedir/dict/CMakeLists.txt should invoke generate_dictionary()
# You may use any name for the dictionary subdirectory,
# but "dict" is the default.
#
# USAGE:
# generate_dictionary( [dictionary_name] [subdir] )
# build_dictionary( [dictionary_name] [subdir]  [DICTIONARY_LIBRARIES <library list>])
#        dictionary_name defaults to ${PROJECT_NAME}
#        subdir defaults to "dict"
#        ${REFLEX} is always appended to the library list (even if it is empty)
#
#  any other macros or functions in this file are for internal use only
#

# define flags for genreflex
set( GENREFLEX_FLAGS --deep
                     --fail_on_warnings
		     --capabilities=classes_ids.cc
		     -D_REENTRANT
		     -DGNU_SOURCE
		     -DGNU_GCC
		     -DPROJECT_NAME="${PROJECT_NAME}"
		     -DPROJECT_VERSION="${version}" )
# make sure we have install_dictionary_source()
include(InstallSource)

# just the code generation step
macro (generate_dictionary  )
  set(generate_dictionary_usage "generate_dictionary( [dictionary_name] [subdir] )")
  #message(STATUS "calling generate_dictionary with ${ARGC} arguments: ${ARGV}")
  if(${ARGC} EQUAL 0)
     set(dictname ${PROJECT_NAME} )
     set(subdir "dict" )
  elseif(${ARGC} EQUAL 1)
     set(dictname  "${ARGV0}")
     set(subdir "dict" )
  elseif(${ARGC} EQUAL 2)
     set(dictname  "${ARGV0}")
     set(subdir "${ARGV1}" )
  else()
     message("GENERATE_DICTIONARY: Too many arguments. ${ARGV}")
     message(SEND_ERROR  ${generate_dictionary_usage})
  endif()
  #message(STATUS "GENERATE_DICTIONARY: generate dictionary source code for ${dictname} in ${subdir} ")
  get_directory_property( genpath INCLUDE_DIRECTORIES )
  foreach( inc ${genpath} )
      set( GENREFLEX_INCLUDES -I ${inc} ${GENREFLEX_INCLUDES} )
  endforeach(inc)
  add_custom_command(
     OUTPUT ${PROJECT_BINARY_DIR}/${subdir}/${dictname}_dict.cpp
            ${PROJECT_BINARY_DIR}/${subdir}/${dictname}_map.cpp
     COMMAND ${GENREFLEX} ${CMAKE_CURRENT_SOURCE_DIR}/classes.h
        	 -s ${CMAKE_CURRENT_SOURCE_DIR}/classes_def.xml
		 -I ${CMAKE_SOURCE_DIR}
		 -I ${CMAKE_CURRENT_SOURCE_DIR}
		 ${GENREFLEX_INCLUDES} ${GENREFLEX_FLAGS}
        	 -o ${dictname}_dict.cpp
     COMMAND ${CMAKE_COMMAND} -E copy classes_ids.cc ${dictname}_map.cpp
     COMMAND ${CMAKE_COMMAND} -E remove -f classes_ids.cc
     IMPLICIT_DEPENDS CXX ${CMAKE_CURRENT_SOURCE_DIR}/classes.h
     DEPENDS ${CMAKE_CURRENT_SOURCE_DIR}/classes_def.xml
     WORKING_DIRECTORY ${PROJECT_BINARY_DIR}/${subdir}
  )
  add_custom_target( ${dictname}_generated
                     DEPENDS ${PROJECT_BINARY_DIR}/${subdir}/${dictname}_dict.cpp
                             ${PROJECT_BINARY_DIR}/${subdir}/${dictname}_map.cpp )
  # set variable for install_source
  install_dictionary_source(${PROJECT_BINARY_DIR}/${subdir}/${dictname}_dict.cpp ${PROJECT_BINARY_DIR}/${subdir}/${dictname}_map.cpp )
endmacro (generate_dictionary)

function( _parse_dictionary_arguments )
  set(build_dictionary_usage "USAGE: build_dictionary( [dictionary_name] [local_subdir] [DICTIONARY_LIBRARIES <library list>] )")
  #message(STATUS "PARSE: called with ${ARGC} arguments: ${ARGV}")
  set(start_dict -1)
  if(${ARGC} EQUAL 0)
     message(SEND_ERROR "PARSE: No arguments. This should not happen.")
  elseif(${ARGC} EQUAL 1)
     if("${ARGV0}" STREQUAL "DICTIONARY_LIBRARIES")
       set(local_dictname "${PROJECT_NAME}" )
       set(local_subdir "dict" )
     else()
       set(local_dictname  "${ARGV0}")
       set(local_subdir "dict" )
     endif()
  elseif(${ARGC} EQUAL 2)
     if("${ARGV0}" STREQUAL "DICTIONARY_LIBRARIES")
       set(local_dictname "${PROJECT_NAME}" )
       set(local_subdir "dict" )
       set(start_dict 1)
     elseif("${ARGV1}" STREQUAL "DICTIONARY_LIBRARIES")
       set(local_dictname  "${ARGV0}")
       set(local_subdir "dict" )
     else()
       set(local_dictname  "${ARGV0}")
       set(local_subdir "${ARGV1}" )
     endif()
  else()
     if("${ARGV0}" STREQUAL "DICTIONARY_LIBRARIES")
       set(local_dictname "${PROJECT_NAME}" )
       set(local_subdir "dict" )
       set(start_dict 1)
     elseif("${ARGV1}" STREQUAL "DICTIONARY_LIBRARIES")
       set(local_dictname  "${ARGV0}")
       set(local_subdir "dict" )
       set(start_dict 2)
     elseif("${ARGV2}" STREQUAL "DICTIONARY_LIBRARIES")
       set(local_dictname  "${ARGV0}")
       set(local_subdir "${ARGV1}" )
       set(start_dict 3)
     else()
	message("BUILD_DICTIONARY: Too many arguments. ${ARGV}")
	message(SEND_ERROR  ${build_dictionary_usage})
     endif()
  endif()
  if( ${start_dict} GREATER 0)
     set(use_arg FALSE)
     foreach( lib ${ARGV} )
	if("${lib}" STREQUAL "DICTIONARY_LIBRARIES")
	   set(use_arg TRUE)
	elseif(use_arg)
	    list(APPEND local_dictionary_liblist ${lib})
	endif()
     endforeach( lib )
  endif()
  list(APPEND local_dictionary_liblist ${REFLEX} )
  set(dictname ${local_dictname} PARENT_SCOPE )
  set(subdir ${local_subdir} PARENT_SCOPE )
  set(dictionary_liblist ${local_dictionary_liblist} PARENT_SCOPE )
  #message(STATUS "PARSE: find dictionary source code for ${local_dictname} in ${local_subdir} ")
  #message(STATUS "PARSE: link dictionary ${local_dictname} with ${local_dictionary_liblist} ")
endfunction( _parse_dictionary_arguments )

# dictionaries are built in art with this
macro (build_dictionary )
  #message(STATUS "BUILD_DICTIONARY: calling build_dictionary with ${ARGC} arguments: ${ARGV}")
  if(${ARGC} EQUAL 0)
     set(dictname ${PROJECT_NAME} )
     set(subdir "dict" )
     set(dictionary_liblist ${REFLEX} )
  else()
     _parse_dictionary_arguments( ${ARGN} )
  endif()
  #set(dictionary_liblist "${ARGV}" ${REFLEX} )
  #message(STATUS "BUILD_DICTIONARY: find dictionary source code for ${dictname} in ${subdir} ")
  #message(STATUS "BUILD_DICTIONARY: link dictionary ${dictname} with ${dictionary_liblist} ")
  add_subdirectory(${subdir})
  add_library(${dictname}_dict SHARED ${PROJECT_BINARY_DIR}/${subdir}/${dictname}_dict.cpp )
  add_library(${dictname}_map  SHARED ${PROJECT_BINARY_DIR}/${subdir}/${dictname}_map.cpp )
  SET_SOURCE_FILES_PROPERTIES(${PROJECT_BINARY_DIR}/${subdir}/${dictname}_dict.cpp
                              ${PROJECT_BINARY_DIR}/${subdir}/${dictname}_map.cpp
                              PROPERTIES GENERATED 1)
  target_link_libraries( ${dictname}_dict ${dictionary_liblist} )
  target_link_libraries( ${dictname}_map  ${dictionary_liblist} )
  add_dependencies( ${dictname}_dict ${dictname}_generated )
  add_dependencies( ${dictname}_map  ${dictname}_generated )
  install ( TARGETS ${dictname}_dict DESTINATION ${flavorqual_dir}/lib )
  install ( TARGETS ${dictname}_map  DESTINATION ${flavorqual_dir}/lib )
endmacro (build_dictionary)

