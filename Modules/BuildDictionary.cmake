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
#        dictionary_name defaults to a name based on the source code subdirectory
#        subdir defaults to "dict"
#        ${REFLEX} is always appended to the library list (even if it is empty)
#
#  any other macros or functions in this file are for internal use only
#

include(CetParseArgs)

# define flags for genreflex
set( GENREFLEX_FLAGS --deep
                     --fail_on_warnings
		     --capabilities=classes_ids.cc
		     -D_REENTRANT
		     -DGNU_SOURCE
		     -DGNU_GCC
		     -DPROJECT_NAME="${PROJECT_NAME}"
		     -DPROJECT_VERSION="${version}" )

macro( _set_dictionary_name )
   #message( STATUS "source dir ${CMAKE_SOURCE_DIR}")
   #message( STATUS "current source dir ${CMAKE_CURRENT_SOURCE_DIR}")
   STRING( REGEX REPLACE "^${CMAKE_SOURCE_DIR}/(.*)" "\\1" CURRENT_SUBDIR "${CMAKE_CURRENT_SOURCE_DIR}" )
   STRING( REGEX REPLACE "/" "_" _dictname "${CURRENT_SUBDIR}" )
   #message( STATUS "dictionary name is ${_dictname}" )
endmacro( _set_dictionary_name )

# just the code generation step
macro (generate_dictionary  )
  set(generate_dictionary_usage "generate_dictionary( [dictionary_name] [subdir] )")
  #message(STATUS "calling generate_dictionary with ${ARGC} arguments: ${ARGV}")
  if(${ARGC} EQUAL 0)
     _set_dictionary_name()
     # remove extra subdirectory from name
     STRING( REGEX REPLACE "(.*)_dict" "\\1" dictname "${_dictname}" )
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
  #message(STATUS "GENERATE_DICTIONARY: using genreflex flags ${GENREFLEX_FLAGS} ")
  add_custom_command(
     OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/${dictname}_dict.cpp
            ${CMAKE_CURRENT_BINARY_DIR}/${dictname}_map.cpp
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
     WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
  )
  add_custom_target( ${dictname}_generated
                     DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/${dictname}_dict.cpp
                             ${CMAKE_CURRENT_BINARY_DIR}/${dictname}_map.cpp )
  # set variable for install_source
  set(cet_generated_code ${CMAKE_CURRENT_BINARY_DIR}/${dictname}_dict.cpp 
                         ${CMAKE_CURRENT_BINARY_DIR}/${dictname}_map.cpp )
endmacro (generate_dictionary)


# dictionaries are built in art with this
macro (build_dictionary )
  message(STATUS "BUILD_DICTIONARY: called with ${ARGC} arguments: ${ARGV}")

  set(build_dictionary_usage "USAGE: build_dictionary( [dictionary_name] [subdir] [DICTIONARY_LIBRARIES <library list>] [NOINSTALL] )")
  cet_parse_args( BD "DICTIONARY_LIBRARIES" "NOINSTALL" ${ARGN})
  message(STATUS "BUILD_DICTIONARY: default arguments: ${BD_DEFAULT_ARGS}")
  message(STATUS "BUILD_DICTIONARY: install flag is  ${BD_NOINSTALL} ")
  if( BD_DEFAULT_ARGS )
     list(LENGTH BD_DEFAULT_ARGS dlen)
     if(dlen GREATER 2 )
	message("BUILD_DICTIONARY: Too many arguments. ${ARGV}")
	message(SEND_ERROR  ${build_dictionary_usage})
     endif()
     list(GET BD_DEFAULT_ARGS 0 dictname)
     if( dlen GREATER 1 )
        list(GET BD_DEFAULT_ARGS 1 subdir)
     else()
        set(subdir "dict" )
     endif( )
     #message(STATUS "BUILD_DICTIONARY: have ${dlen} default arguments")
     #message(STATUS "BUILD_DICTIONARY: default arguments dictionary name: ${dictname}")
     #message(STATUS "BUILD_DICTIONARY: default arguments subdir: ${subdir}")
  else()
     #message(STATUS "BUILD_DICTIONARY: no default arguments, call _set_dictionary_name")
     _set_dictionary_name()
     set(dictname ${_dictname})
     set(subdir "dict" )
  endif()
  if(BD_DICTIONARY_LIBRARIES)
     message(STATUS "BUILD_DICTIONARY: found library list ${BD_DICTIONARY_LIBRARIES}")
     set(dictionary_liblist ${BD_DICTIONARY_LIBRARIES})
     #message(STATUS "BUILD_DICTIONARY: local library list is ${dictionary_liblist}")
  endif()
  list(APPEND dictionary_liblist ${REFLEX} )

  message(STATUS "BUILD_DICTIONARY: find dictionary source code for ${dictname} in ${subdir} ")
  message(STATUS "BUILD_DICTIONARY: link dictionary ${dictname} with ${dictionary_liblist} ")
  add_subdirectory(${subdir})
  add_library(${dictname}_dict SHARED ${CMAKE_CURRENT_BINARY_DIR}/${subdir}/${dictname}_dict.cpp )
  add_library(${dictname}_map  SHARED ${CMAKE_CURRENT_BINARY_DIR}/${subdir}/${dictname}_map.cpp )
  SET_SOURCE_FILES_PROPERTIES(${CMAKE_CURRENT_BINARY_DIR}/${subdir}/${dictname}_dict.cpp
                              ${CMAKE_CURRENT_BINARY_DIR}/${subdir}/${dictname}_map.cpp
                              PROPERTIES GENERATED 1)
  target_link_libraries( ${dictname}_dict ${dictionary_liblist} )
  target_link_libraries( ${dictname}_map  ${dictionary_liblist} )
  add_dependencies( ${dictname}_dict ${dictname}_generated )
  add_dependencies( ${dictname}_map  ${dictname}_generated )
  if( NOT BD_NOINSTALL )
     message( STATUS "BUILD_DICTIONARY: installing ${dictname}_dict and ${dictname}_map" )
     install ( TARGETS ${dictname}_dict DESTINATION ${flavorqual_dir}/lib )
     install ( TARGETS ${dictname}_map  DESTINATION ${flavorqual_dir}/lib )
  endif()
endmacro (build_dictionary)

