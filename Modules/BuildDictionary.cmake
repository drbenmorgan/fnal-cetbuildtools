# macro for building ROOT dictionaries
#
# USAGE:
# build_dictionary( [dictionary_name]
#                   [DICTIONARY_LIBRARIES <library list>]
#                   [NOINSTALL])
#        dictionary_name defaults to a name based on the current source code subdirectory
#        ${REFLEX} is always appended to the library list (even if it is empty)
#        specify NOINSTALL when building a dictionary for the tests
#
#  any other macros or functions in this file are for internal use only
#

include(CetParseArgs)

# define flags for genreflex
set( GENREFLEX_FLAGS
  --deep
  --iocomments
  --fail_on_warnings
  --capabilities=classes_ids.cc
  -D_REENTRANT
  -DGNU_SOURCE
  -DGNU_GCC
  -DPROJECT_NAME="${PROJECT_NAME}"
  -DPROJECT_VERSION="${version}"
  -D__STRICT_ANSI__
)

macro( _set_dictionary_name )
   if( PACKAGE_TOP_DIRECTORY )
      STRING( REGEX REPLACE "^${PACKAGE_TOP_DIRECTORY}/(.*)" "\\1" CURRENT_SUBDIR "${CMAKE_CURRENT_SOURCE_DIR}" )
   else()
      STRING( REGEX REPLACE "^${CMAKE_SOURCE_DIR}/(.*)" "\\1" CURRENT_SUBDIR "${CMAKE_CURRENT_SOURCE_DIR}" )
   endif()
   STRING( REGEX REPLACE "/" "_" dictname "${CURRENT_SUBDIR}" )
endmacro( _set_dictionary_name )

macro( _generate_dictionary )
  set(generate_dictionary_usage "_generate_dictionary( [dictionary_name] )")
  #message(STATUS "calling generate_dictionary with ${ARGC} arguments: ${ARGV}")
  if(${ARGC} EQUAL 0)
     _set_dictionary_name()
  elseif(${ARGC} EQUAL 1)
     set(dictname  "${ARGV0}")
  else()
     message("_GENERATE_DICTIONARY: Too many arguments. ${ARGV}")
     message(SEND_ERROR  ${generate_dictionary_usage})
  endif()
  #message(STATUS "_GENERATE_DICTIONARY: generate dictionary source code for ${dictname}")
  get_directory_property( genpath INCLUDE_DIRECTORIES )
  foreach( inc ${genpath} )
      set( GENREFLEX_INCLUDES ${GENREFLEX_INCLUDES} -I ${inc} )
  endforeach(inc)
  # add any local compile definitions
  get_directory_property(compile_defs COMPILE_DEFINITIONS)
  foreach( def ${compile_defs} )
      set( GENREFLEX_FLAGS ${GENREFLEX_FLAGS} -D${def} )
  endforeach(def)
  #message(STATUS "_GENERATE_DICTIONARY: using genreflex flags ${GENREFLEX_FLAGS} ")
  #message(STATUS "_GENERATE_DICTIONARY: using genreflex cleanup ${GENREFLEX_CLEANUP} ")
  if( ${GENREFLEX_CLEANUP} MATCHES "TRUE" )
  add_custom_command(
     OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/${dictname}_dict.cpp
            ${CMAKE_CURRENT_BINARY_DIR}/${dictname}_map.cpp
     COMMAND ${ROOT_GENREFLEX} ${CMAKE_CURRENT_SOURCE_DIR}/classes.h
        	 -s ${CMAKE_CURRENT_SOURCE_DIR}/classes_def.xml
		 -I ${CMAKE_SOURCE_DIR}
		 -I ${CMAKE_CURRENT_SOURCE_DIR}
		 ${GENREFLEX_INCLUDES} ${GENREFLEX_FLAGS}
        	 -o ${dictname}_dict.cpp || { rm -f ${dictname}_dict.cpp\; /bin/false\; }
     COMMAND ${CMAKE_COMMAND} -E copy classes_ids.cc ${dictname}_map.cpp
     COMMAND ${CMAKE_COMMAND} -E remove -f classes_ids.cc
     IMPLICIT_DEPENDS CXX ${CMAKE_CURRENT_SOURCE_DIR}/classes.h
     DEPENDS ${CMAKE_CURRENT_SOURCE_DIR}/classes_def.xml
     WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
  )
  else()
  add_custom_command(
     OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/${dictname}_dict.cpp
            ${CMAKE_CURRENT_BINARY_DIR}/${dictname}_map.cpp
     COMMAND ${ROOT_GENREFLEX} ${CMAKE_CURRENT_SOURCE_DIR}/classes.h
        	 -s ${CMAKE_CURRENT_SOURCE_DIR}/classes_def.xml
		 -I ${CMAKE_SOURCE_DIR}
		 -I ${CMAKE_CURRENT_SOURCE_DIR}
		 ${GENREFLEX_INCLUDES} ${GENREFLEX_FLAGS}
        	 -o ${dictname}_dict.cpp 
     COMMAND ${CMAKE_COMMAND} -E copy classes_ids.cc ${dictname}_map.cpp
     COMMAND ${CMAKE_COMMAND} -E remove -f classes_ids.cc
     IMPLICIT_DEPENDS CXX ${CMAKE_CURRENT_SOURCE_DIR}/classes.h
     DEPENDS ${CMAKE_CURRENT_SOURCE_DIR}/classes_def.xml
     WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
  )
  endif()
  # set variable for install_source
  set(cet_generated_code ${CMAKE_CURRENT_BINARY_DIR}/${dictname}_dict.cpp 
                         ${CMAKE_CURRENT_BINARY_DIR}/${dictname}_map.cpp )
endmacro( _generate_dictionary )

# dictionaries are built in art with this
macro ( build_dictionary )
  #message(STATUS "BUILD_DICTIONARY: called with ${ARGC} arguments: ${ARGV}")
  set(build_dictionary_usage "USAGE: build_dictionary( [dictionary_name] [DICTIONARY_LIBRARIES <library list>] [NOINSTALL] )")
  cet_parse_args( BD "DICTIONARY_LIBRARIES;COMPILE_FLAGS" "NOINSTALL" ${ARGN})
  #message(STATUS "BUILD_DICTIONARY: default arguments: ${BD_DEFAULT_ARGS}")
  #message(STATUS "BUILD_DICTIONARY: install flag is  ${BD_NOINSTALL} ")
  #message(STATUS "BUILD_DICTIONARY: COMPILE_FLAGS: ${BD_COMPILE_FLAGS}")
  if( BD_DEFAULT_ARGS )
     list(LENGTH BD_DEFAULT_ARGS dlen)
     if(dlen GREATER 1 )
	message("BUILD_DICTIONARY: Too many arguments. ${ARGV}")
	message(SEND_ERROR  ${build_dictionary_usage})
     endif()
     list(GET BD_DEFAULT_ARGS 0 dictname)
     #message(STATUS "BUILD_DICTIONARY: have ${dlen} default arguments")
     #message(STATUS "BUILD_DICTIONARY: default arguments dictionary name: ${dictname}")
  else()
     #message(STATUS "BUILD_DICTIONARY: no default arguments, call _set_dictionary_name")
     _set_dictionary_name()
  endif()
  if(BD_DICTIONARY_LIBRARIES)
     set(dictionary_liblist ${BD_DICTIONARY_LIBRARIES})
  endif()
  list(APPEND dictionary_liblist ${ROOT_CORE} ${ROOT_REFLEX})
  #message(STATUS "BUILD_DICTIONARY: building dictionary ${dictname}")
  #message(STATUS "BUILD_DICTIONARY: link dictionary ${dictname} with ${dictionary_liblist} ")
   _generate_dictionary( ${dictname} )
  add_library(${dictname}_dict SHARED ${CMAKE_CURRENT_BINARY_DIR}/${dictname}_dict.cpp )
  add_library(${dictname}_map  SHARED ${CMAKE_CURRENT_BINARY_DIR}/${dictname}_map.cpp )
  SET_SOURCE_FILES_PROPERTIES(${CMAKE_CURRENT_BINARY_DIR}/${dictname}_dict.cpp
                              ${CMAKE_CURRENT_BINARY_DIR}/${dictname}_map.cpp
                              PROPERTIES GENERATED 1)
  if (BD_COMPILE_FLAGS)
    set_target_properties(${dictname}_dict ${dictname}_map
      PROPERTIES COMPILE_FLAGS ${BD_COMPILE_FLAGS})
  endif()
  target_link_libraries( ${dictname}_dict ${dictionary_liblist} )
  target_link_libraries( ${dictname}_map  ${dictionary_liblist} )
  add_dependencies( ${dictname}_map  ${dictname}_dict )
  if( NOT BD_NOINSTALL )
     #message( STATUS "BUILD_DICTIONARY: installing ${dictname}_dict and ${dictname}_map" )
     install ( TARGETS ${dictname}_dict DESTINATION ${flavorqual_dir}/lib )
     install ( TARGETS ${dictname}_map  DESTINATION ${flavorqual_dir}/lib )
  endif()
endmacro ( build_dictionary )
