# macro for building ROOT dictionaries
#
# USAGE:
# build_dictionary( [<dictionary_name>]
#                   [COMPILE_FLAGS <flags>]
#                   [DICT_NAME_VAR <var>]
#                   [DICTIONARY_LIBRARIES <library list>]
#                   [USE_PRODUCT_NAME]
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
  --gccxmlopt=--gccxml-compiler
  --gccxmlopt=$ENV{GCC_FQ_DIR}/bin/g++
  -D_REENTRANT
  -DGNU_SOURCE
  -DGNU_GCC
  -DPROJECT_NAME="${PROJECT_NAME}"
  -DPROJECT_VERSION="${version}"
  -D__STRICT_ANSI__
)

check_ups_version(root ${ROOT_VERSION} v6_00_00
  PRODUCT_MATCHES_VAR BD_WANT_ROOTMAP
  PRODUCT_OLDER_VAR BD_WANT_CAP_FILE
  )

macro( _set_dictionary_name )
   if( PACKAGE_TOP_DIRECTORY )
      STRING( REGEX REPLACE "^${PACKAGE_TOP_DIRECTORY}/(.*)" "\\1" CURRENT_SUBDIR "${CMAKE_CURRENT_SOURCE_DIR}" )
   else()
      STRING( REGEX REPLACE "^${CMAKE_SOURCE_DIR}/(.*)" "\\1" CURRENT_SUBDIR "${CMAKE_CURRENT_SOURCE_DIR}" )
   endif()
   STRING( REGEX REPLACE "/" "_" dictname "${CURRENT_SUBDIR}" )
endmacro( _set_dictionary_name )

function( _generate_dictionary dictname )
  cmake_parse_arguments(GD "DICT_FUNCTIONS" "" "" ${ARGN})
  set(generate_dictionary_usage "_generate_dictionary( [DICT_FUNCTIONS] [dictionary_name] )")
  #message(STATUS "calling generate_dictionary with ${ARGC} arguments: ${ARGV}")
  if (NOT GD_DICT_FUNCTIONS AND NOT CET_DICT_FUNCTIONS)
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
  if (GENREFLEX_CLEANUP)
    set(CLEANUP_COMMAND  || { rm -f ${dictname}_dict.cpp ${dictname}_map.cpp "\;" /bin/false "\;" })
  endif()

  if (BD_WANT_ROOTMAP)
    set(ROOTMAP_OUTPUT ${LIBRARY_OUTPUT_PATH}/${CMAKE_SHARED_LIBRARY_PREFIX}${dictname}_dict.rootmap)
    list(APPEND GENREFLEX_FLAGS
      --rootmap-lib=${CMAKE_SHARED_LIBRARY_PREFIX}${dictname}_dict${CMAKE_SHARED_LIBRARY_SUFFIX}
      --rootmap=${ROOTMAP_OUTPUT}
      )
  endif()
  if (BD_WANT_CAP_FILE)
    set(SOURCE_OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/${dictname}_map.cpp)
    list(APPEND GENREFLEX_FLAGS
      --capabilities=${SOURCE_OUTPUT}
      )
  endif()
  add_custom_command(
    OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/${dictname}_dict.cpp
    ${SOURCE_OUTPUT} ${ROOTMAP_OUTPUT}
    COMMAND ${ROOT_GENREFLEX} ${CMAKE_CURRENT_SOURCE_DIR}/classes.h
    -s ${CMAKE_CURRENT_SOURCE_DIR}/classes_def.xml
		-I ${CMAKE_SOURCE_DIR}
		-I ${CMAKE_CURRENT_SOURCE_DIR}
		${GENREFLEX_INCLUDES} ${GENREFLEX_FLAGS}
    -o ${dictname}_dict.cpp
    ${CLEANUP_COMMAND}
    IMPLICIT_DEPENDS CXX ${CMAKE_CURRENT_SOURCE_DIR}/classes.h
    DEPENDS ${CMAKE_CURRENT_SOURCE_DIR}/classes_def.xml
    WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
    )
  # set variable for install_source
  set(cet_generated_code
    ${CMAKE_CURRENT_BINARY_DIR}/${dictname}_dict.cpp
    ${SOURCE_OUTPUT}
    PARENT_SCOPE)
endfunction( _generate_dictionary )

# dictionaries are built in art with this
function ( build_dictionary )
  #message(STATUS "BUILD_DICTIONARY: called with ${ARGC} arguments: ${ARGV}")
  set(build_dictionary_usage "USAGE: build_dictionary( [dictionary_name] [DICTIONARY_LIBRARIES <library list>] [COMPILE_FLAGS <flags>] [DICT_NAME_VAR <var>] [NO_INSTALL] )")
  cmake_parse_arguments( BD "NOINSTALL;NO_INSTALL;DICT_FUNCTIONS;USE_PRODUCT_NAME" "DICT_NAME_VAR" "DICTIONARY_LIBRARIES;COMPILE_FLAGS" ${ARGN})
  #message(STATUS "BUILD_DICTIONARY: unparsed arguments: ${BD_UNPARSED_ARGUMENTS}")
  #message(STATUS "BUILD_DICTIONARY: install flag is  ${BD_NO_INSTALL} ")
  #message(STATUS "BUILD_DICTIONARY: COMPILE_FLAGS: ${BD_COMPILE_FLAGS}")
  if( BD_NOINSTALL )
     message( FATAL_ERROR "build_dictionary now requires NO_INSTALL, you have used the old NOINSTALL command")
  endif( BD_NOINSTALL )
  if( BD_UNPARSED_ARGUMENTS )
    list(LENGTH BD_UNPARSED_ARGUMENTS dlen)
    if(dlen GREATER 1 )
	    message(FATAL_ERROR  "BUILD_DICTIONARY: Too many arguments. ${ARGV} \n ${build_dictionary_usage}")
    endif()
    list(GET BD_UNPARSED_ARGUMENTS 0 dictname)
    #message(STATUS "BUILD_DICTIONARY: have ${dlen} default arguments")
    #message(STATUS "BUILD_DICTIONARY: default arguments dictionary name: ${dictname}")
  else()
     #message(STATUS "BUILD_DICTIONARY: no default arguments, call _set_dictionary_name")
     _set_dictionary_name()
     if (BD_USE_PRODUCT_NAME)
       set( dictname ${product}_${dictname} )
     endif()
     #message(STATUS "BUILD_DICTIONARY debug: calculated dictionary name is ${dictname} for ${product}")
  endif()
  if (BD_DICT_NAME_VAR)
    set(${BD_DICT_NAME_VAR} ${dictname} PARENT_SCOPE)
  endif()
  if(BD_DICTIONARY_LIBRARIES)
     # check library names and translate where necessary
     set(dictionary_liblist "")
     foreach (lib ${BD_DICTIONARY_LIBRARIES})
       string(REGEX MATCH [/] has_path "${lib}")
       if( has_path )
	 list(APPEND dictionary_liblist ${lib})
       else()
	 string(TOUPPER  ${lib} ${lib}_UC )
	 #_cet_debug_message( "simple_plugin: check ${lib}" )
	 if( ${${lib}_UC} )
           _cet_debug_message( "changing ${lib} to ${${${lib}_UC}}")
           list(APPEND dictionary_liblist ${${${lib}_UC}})
	 else()
           list(APPEND dictionary_liblist ${lib})
	 endif()
       endif( has_path )
     endforeach()
  endif()
  list(APPEND dictionary_liblist ${ROOT_CORE} ${ROOT_REFLEX})
  #message(STATUS "BUILD_DICTIONARY: building dictionary ${dictname}")
  #message(STATUS "BUILD_DICTIONARY: link dictionary ${dictname} with ${dictionary_liblist} ")
  _generate_dictionary( ${dictname} )
  add_library(${dictname}_dict SHARED ${CMAKE_CURRENT_BINARY_DIR}/${dictname}_dict.cpp )
  SET_SOURCE_FILES_PROPERTIES(${CMAKE_CURRENT_BINARY_DIR}/${dictname}_dict.cpp
    ${SOURCE_OUTPUT}
    PROPERTIES GENERATED 1)
  if (BD_COMPILE_FLAGS)
    set_target_properties(${dictname}_dict
      PROPERTIES COMPILE_FLAGS ${BD_COMPILE_FLAGS})
    if (BD_WANT_CAP_FILE)
      set_target_properties(${dictname}_map
        PROPERTIES COMPILE_FLAGS ${BD_COMPILE_FLAGS})
    endif()
  endif()
  target_link_libraries( ${dictname}_dict ${dictionary_liblist} )
  if (BD_WANT_CAP_FILE)
    add_library(${dictname}_map SHARED ${CMAKE_CURRENT_BINARY_DIR}/${dictname}_map.cpp )
    target_link_libraries( ${dictname}_map ${dictionary_liblist} )
    add_dependencies(${dictname}_map ${dictname}_dict)
  endif()
  if( NOT BD_NO_INSTALL )
    if (cet_generated_code) # Local scope, set by _generate_dictionary.
      set(cet_generated_code ${cet_generated_code} PARENT_SCOPE)
    endif()
     #message( STATUS "BUILD_DICTIONARY: installing ${dictname}_dict" )
     install ( TARGETS ${dictname}_dict DESTINATION ${flavorqual_dir}/lib )
     # add to library list for package configure file
     cet_add_to_library_list( ${dictname}_dict )
     if (BD_WANT_CAP_FILE)
       install ( TARGETS ${dictname}_map DESTINATION ${flavorqual_dir}/lib )
     endif()
     if (BD_WANT_ROOTMAP)
       install ( FILES ${ROOTMAP_OUTPUT} DESTINATION ${flavorqual_dir}/lib )
     endif()
  endif()
endfunction ( build_dictionary )
