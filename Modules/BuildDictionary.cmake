# macro for building ROOT dictionaries
#
# USAGE:
# build_dictionary( [<dictionary_name>]
#                   [COMPILE_FLAGS <flags>]
#                   [DICT_NAME_VAR <var>]
#                   [DICTIONARY_LIBRARIES <library list>]
#                   [NO_INSTALL]
#                   [DICT_FUNCTIONS])
#
# * <dictionary_name> defaults to a name based on the current source
# code subdirectory.
#
# * ${REFLEX} is always appended to the library list (even if it is
# empty).
#
# * Specify NO_INSTALL when building a dictionary for tests.
#
# * The default behavior is to generate a dictionary for data only. Use
# the DICT_FUNCTIONS option to reactivate the generation of dictionary
# entries for functions.
#
# * If DICT_NAME_VAR is specified, <var> will be set to contain the
# dictionary name.
#
# * Any other macros or functions in this file are for internal use
# only.
#
########################################################################
include(CMakeParseArguments)

# define flags for genreflex
set( GENREFLEX_FLAGS
  --deep
  --iocomments
  --fail_on_warnings
  --capabilities=classes_ids.cc
  --gccxmlopt=--gccxml-compiler
  --gccxmlopt=$ENV{GCC_FQ_DIR}/bin/g++
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

function( _generate_dictionary )
  cmake_parse_arguments(GD "DICT_FUNCTIONS" "" "" ${ARGN})
  set(generate_dictionary_usage "_generate_dictionary( [DICT_FUNCTIONS] [dictionary_name] )")
  #message(STATUS "calling generate_dictionary with ${ARGC} arguments: ${ARGV}")
  if(NOT ${GD_UNPARSED_ARGUMENTS})
    _set_dictionary_name()
  else()
    list(LENGTH GD_UNPARSED_ARGUMENTS n_bad_args)
    if (n_bad_args GREATER 1)
      list(REMOVE_AT GD_UNPARSED_ARGUMENTS 0)
      message("_GENERATE_DICTIONARY: unwanted extra arguments: ${GD_UNPARSED_ARGUMENTS}")
      message(SEND_ERROR  ${generate_dictionary_usage})
    endif()
  endif()
  list(GET GD_UNPARSED_ARGUMENTS 0 dictname)
  if (NOT GD_DICT_FUNCTIONS)
    set(GENREFLEX_FLAGS ${GENREFLEX_FLAGS} --dataonly)
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
                         ${CMAKE_CURRENT_BINARY_DIR}/${dictname}_map.cpp PARENT_SCOPE)
endfunction( _generate_dictionary )

# dictionaries are built in art with this
function ( build_dictionary )
  #message(STATUS "BUILD_DICTIONARY: called with ${ARGC} arguments: ${ARGV}")
  set(build_dictionary_usage "USAGE: build_dictionary( [dictionary_name] [DICTIONARY_LIBRARIES <library list>] [COMPILE_FLAGS <flags>] [DICT_NAME_VAR <var>] [NO_INSTALL] )")
  cmake_parse_arguments( BD "NOINSTALL;NO_INSTALL;DICT_FUNCTIONS" "DICT_NAME_VAR" "DICTIONARY_LIBRARIES;COMPILE_FLAGS" ${ARGN})
  #message(STATUS "BUILD_DICTIONARY: unparsed arguments: ${BD_UNPARSED_ARGUMENTS}")
  #message(STATUS "BUILD_DICTIONARY: install flag is  ${BD_NO_INSTALL} ")
  #message(STATUS "BUILD_DICTIONARY: COMPILE_FLAGS: ${BD_COMPILE_FLAGS}")
  if( BD_NOINSTALL )
     message( SEND_ERROR "build_dictionary now requires NO_INSTALL, you have used the old NOINSTALL command")
  endif( BD_NOINSTALL )
  if( BD_UNPARSED_ARGUMENTS )
    list(LENGTH BD_UNPARSED_ARGUMENTS dlen)
    if(dlen GREATER 1 )
	    message("BUILD_DICTIONARY: Too many arguments. ${ARGV}")
	    message(SEND_ERROR  ${build_dictionary_usage})
    endif()
    list(GET BD_UNPARSED_ARGUMENTS 0 dictname)
    #message(STATUS "BUILD_DICTIONARY: have ${dlen} default arguments")
    #message(STATUS "BUILD_DICTIONARY: default arguments dictionary name: ${dictname}")
  else()
     #message(STATUS "BUILD_DICTIONARY: no default arguments, call _set_dictionary_name")
     _set_dictionary_name()
  endif()
  if (BD_DICT_NAME_VAR)
    set(${BD_DICT_NAME_VAR} ${dictname} PARENT_SCOPE)
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
  if( NOT BD_NO_INSTALL )
    if (cet_generated_code) # Local scope, set by _generate_dictionary.
      set(cet_generated_code ${cet_generated_code} PARENT_SCOPE)
    endif()
     #message( STATUS "BUILD_DICTIONARY: installing ${dictname}_dict and ${dictname}_map" )
     install ( TARGETS ${dictname}_dict DESTINATION ${flavorqual_dir}/lib )
     install ( TARGETS ${dictname}_map  DESTINATION ${flavorqual_dir}/lib )
     # add to library list for package configure file
     cet_add_to_library_list( ${dictname}_dict )
  endif()
endfunction ( build_dictionary )
