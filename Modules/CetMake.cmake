# cet_make
#
# Identify the files in the current source directory and deal with them appropriately
# Users may opt to just include cet_make() in their CMakeLists.txt
# This implementation is intended to be called NO MORE THAN ONCE per subdirectory.
#
# NOTE: cet_make_exec and cet_make_test_exec are no longer part of 
# cet_make or art_make and must be called explicitly.
#
# cet_make( LIBRARY_NAME <library name> 
#           [LIBRARIES <library link list>]
#           [SUBDIRS <source subdirectory>] (e.g., detail)
#           [EXCLUDE <ignore these files>] )
#
#   NOTE: if your code includes art plugins, you MUST use art_make
#   instead of cet_make: cet_make will ignore all known plugin code.
#
# cet_make_library( [LIBRARY_NAME <library name>]  
#                   [SOURCE <source code list>] 
#                   [LIBRARIES <library list>] 
#                   [WITH_STATIC_LIBRARY]
#                   [NO_INSTALL] )
#
#   Make the named library.
#
# cet_make_exec( <executable name>  
#                [SOURCE <source code list>] 
#                [LIBRARIES <library link list>]
#                [USE_BOOST_UNIT]
#                [NO_INSTALL] )
#
#   Build a regular executable.
#
# cet_script( <script-names> ...
#             [DEPENDENCIES <deps>] 
#             [NO_INSTALL] 
#             [GENERATED]
#             [REMOVE_EXTENSIONS] )
#
#   Copy the named scripts to ${${product}_bin_dir} (usually bin/).
#
#   If the GENERATED option is used, the script will be copied from
#   ${CMAKE_CURRENT_BINARY_DIR} (after being made by a CONFIGURE
#   command, for example); otherwise it will be copied from
#   ${CMAKE_CURRENT_SOURCE_DIR}.
#
#   If REMOVE_EXTENSIONS is specified, extensions will be removed from script names 
#   when they are installed.
#
#   NOTE: If you wish to use one of these scripts in a CUSTOM_COMMAND,
#   list its name in the DEPENDS clause of the CUSTOM_COMMAND to ensure
#   it gets re-run if the script chagees.
#
########################################################################

include(CetParseArgs)
include(InstallSource)

macro( _cet_check_lib_directory )
  # find $CETBUILDTOOLS_DIR/bin/report_libdir
  if( ${${product}_lib_dir} MATCHES "NONE" )
      message(FATAL_ERROR "Please specify a lib directory in product_deps")
  elseif( ${${product}_lib_dir} MATCHES "ERROR" )
      message(FATAL_ERROR "Invalid lib directory in product_deps")
  endif()
endmacro( _cet_check_lib_directory )

macro( _cet_check_bin_directory )
  if( ${${product}_bin_dir} MATCHES "NONE" )
      message(FATAL_ERROR "Please specify a bin directory in product_deps")
  elseif( ${${product}_bin_dir} MATCHES "ERROR" )
      message(FATAL_ERROR "Invalid bin directory in product_deps")
  endif()
endmacro( _cet_check_bin_directory )

macro( cet_make_exec cet_exec_name )
  set(cet_exec_file_list "")
  set(cet_make_exec_usage "USAGE: cet_make_exec( <executable name> [SOURCE <exec source>] [LIBRARIES <library list>] )")
  #message(STATUS "cet_make_exec debug: called with ${ARGN} from ${CMAKE_CURRENT_SOURCE_DIR}")
  cet_parse_args( CME "LIBRARIES;SOURCE" "USE_BOOST_UNIT;NO_INSTALL" ${ARGN})
  # there are no default arguments
  if( CME_DEFAULT_ARGS )
     message("CET_MAKE_EXEC: Incorrect arguments. ${ARGV}")
     message(SEND_ERROR  ${cet_make_exec_usage})
  endif()
  #message(STATUS "debug: cet_make_exec called with ${cet_exec_name} ${CME_LIBRARIES}")
  FILE( GLOB exec_src ${cet_exec_name}.c ${cet_exec_name}.cc ${cet_exec_name}.cpp ${cet_exec_name}.C ${cet_exec_name}.cxx )
  list(LENGTH exec_src n_sources)
  if (n_sources EQUAL 1) # If there's more than one, let the user specify explicitly.
    list(INSERT CME_SOURCE 0 ${exec_src})
  endif()
  add_executable( ${cet_exec_name} ${CME_SOURCE} )
  IF(CME_USE_BOOST_UNIT)
    # Make sure we have the correct library available.
    IF (NOT Boost_UNIT_TEST_FRAMEWORK_LIBRARY)
      MESSAGE(SEND_ERROR "cet_make_exec: target ${cet_exec_name} has USE_BOOST_UNIT "
        "option set but Boost Unit Test Framework Library cannot be found: is "
        "boost set up?")
    ENDIF()
    # Compile options (-Dxxx) for simple-format unit tests.
    SET_TARGET_PROPERTIES(${cet_exec_name} PROPERTIES
      COMPILE_DEFINITIONS BOOST_TEST_MAIN
      COMPILE_DEFINITIONS BOOST_TEST_DYN_LINK
      )
    target_link_libraries(${cet_exec_name} ${Boost_UNIT_TEST_FRAMEWORK_LIBRARY})
  ENDIF()
  if(CME_LIBRARIES)
     target_link_libraries( ${cet_exec_name} ${CME_LIBRARIES} )
  endif()
  if(CME_NO_INSTALL)
    #message(STATUS "${cet_exec_name} will not be installed")
  else()
    _cet_check_bin_directory()
    #message( STATUS "cet_make_exec: executables will be installed in ${${product}_bin_dir}")
    install( TARGETS ${cet_exec_name} DESTINATION ${${product}_bin_dir} )
  endif()
endmacro( cet_make_exec )

macro( cet_make )
  set(cet_file_list "")
  set(cet_make_usage "USAGE: cet_make( LIBRARY_NAME <library name> [LIBRARIES <library list>] [SUBDIRS <source subdirectory>] [EXCLUDE <ignore these files>] )")
  #message(STATUS "cet_make debug: called with ${ARGN} from ${CMAKE_CURRENT_SOURCE_DIR}")
  cet_parse_args( CM "LIBRARY_NAME;LIBRARIES;SUBDIRS;EXCLUDE" "WITH_STATIC_LIBRARY" ${ARGN})
  # there are no default arguments
  if( CM_DEFAULT_ARGS )
     message("CET_MAKE: Incorrect arguments. ${ARGV}")
     message(SEND_ERROR  ${cet_make_usage})
  endif()
  # check for extra link libraries
  if(CM_LIBRARIES)
     set(cet_liblist ${CM_LIBRARIES})
  endif()
  # now look for other source files in this directory
  #message(STATUS "cet_make debug: listed files ${cet_file_list}")
  FILE( GLOB src_files *.c *.cc *.cpp *.C *.cxx )
  FILE( GLOB ignore_dot_files  .*.c .*.cc .*.cpp .*.C .*.cxx )
  FILE( GLOB ignore_plugins  *_dict.cpp
                             *_map.cpp
			     *_generator.cc
			     *_source.cc
			     *_service.cc
			     *_module.cc )
  # check subdirectories and also CMAKE_CURRENT_BINARY_DIR for generated code
  LIST(APPEND CM_SUBDIRS ${CMAKE_CURRENT_BINARY_DIR})
  foreach( sub ${CM_SUBDIRS} )
     FILE( GLOB subdir_src_files ${sub}/*.c ${sub}/*.cc ${sub}/*.cpp ${sub}/*.C ${sub}/*.cxx )
     FILE( GLOB subdir_ignore_dot_files ${sub}/.*.c ${sub}/.*.cc ${sub}/.*.cpp ${sub}/.*.C ${sub}/.*.cxx )
     FILE( GLOB subdir_ignore_plugins  ${sub}/*_dict.cpp
                        	       ${sub}/*_map.cpp
				       ${sub}/*_generator.cc
                                       ${sub}/*_source.cc
				       ${sub}/*_service.cc
				       ${sub}/*_module.cc )
     if( subdir_src_files )
       list(APPEND  src_files ${subdir_src_files})
     endif( subdir_src_files )
     if( subdir_ignore_plugins )
       list(APPEND  ignore_plugins ${subdir_ignore_plugins})
     endif( subdir_ignore_plugins )
     if( subdir_ignore_dot_files )
       list(APPEND  ignore_dot_files ${subdir_ignore_dot_files})
     endif( subdir_ignore_dot_files )
  endforeach(sub)
  #message(STATUS "cet_make ignore list: ${ignore_dot_files}")
  if( ignore_plugins )
    LIST( REMOVE_ITEM src_files ${ignore_plugins} )
  endif()
  if( ignore_dot_files )
    LIST( REMOVE_ITEM src_files ${ignore_dot_files} )
  endif()
  #message(STATUS "cet_make debug: exclude files ${CM_EXCLUDE}")
  if(CM_EXCLUDE)
     foreach( exclude_file ${CM_EXCLUDE} )
         LIST( REMOVE_ITEM src_files ${CMAKE_CURRENT_SOURCE_DIR}/${exclude_file} )
     endforeach( exclude_file )
  endif()
  #message(STATUS "cet_make debug: other files ${src_files}")
  set(have_library FALSE)
  foreach( file ${src_files} )
      #message(STATUS "cet_make debug: checking ${file}")
      set(have_file FALSE)
      foreach( known_file ${cet_file_list} )
         if( "${file}" MATCHES "${known_file}" )
	    set(have_file TRUE)
	 endif()
      endforeach( known_file )
      if( NOT have_file )
         #message(STATUS "cet_make debug: found new file ${file}")
         set(cet_file_list ${cet_file_list} ${file} )
         set(cet_make_library_src ${cet_make_library_src} ${file} )
         set(have_library TRUE)
      endif()
  endforeach(file)
  #message(STATUS "cet_make debug: known files ${cet_file_list}")

  # calculate base name
  STRING( REGEX REPLACE "^${CMAKE_SOURCE_DIR}/(.*)" "\\1" CURRENT_SUBDIR "${CMAKE_CURRENT_SOURCE_DIR}" )
  STRING( REGEX REPLACE "/" "_" cet_make_name "${CURRENT_SUBDIR}" )

  if( have_library )
    if(CM_LIBRARY_NAME)
      set(cet_make_library_name ${CM_LIBRARY_NAME})
    else()
      set(cet_make_library_name ${cet_make_name})
    endif()
    _cet_debug_message("cet_make: building library ${cet_make_library_name} for ${CMAKE_CURRENT_SOURCE_DIR}")
    if(CM_LIBRARIES) 
       cet_make_library( LIBRARY_NAME ${cet_make_library_name}
                	 SOURCE ${cet_make_library_src}
			 LIBRARIES  ${cet_liblist} )
    else() 
       cet_make_library( LIBRARY_NAME ${cet_make_library_name}
                	 SOURCE ${cet_make_library_src} )
    endif() 
    #message( STATUS "cet_make debug: library ${cet_make_library_name} will be installed in ${${product}_lib_dir}")
  else( )
    _cet_debug_message("cet_make: no library for ${CMAKE_CURRENT_SOURCE_DIR}")
  endif( )

  # is there a dictionary?
  FILE(GLOB dictionary_header classes.h )
  FILE(GLOB dictionary_xml classes_def.xml )
  if( dictionary_header AND dictionary_xml )
     _cet_debug_message("cet_make: found dictionary in ${CMAKE_CURRENT_SOURCE_DIR}")
     set(cet_file_list ${cet_file_list} ${dictionary_xml} ${dictionary_header} )
     if(CM_LIBRARIES) 
        build_dictionary( DICTIONARY_LIBRARIES ${cet_liblist} )
     else()
        build_dictionary(  )
     endif()
  endif()

endmacro( cet_make )

macro( cet_make_library )
  set(cet_file_list "")
  set(cet_make_library_usage "USAGE: cet_make_library( LIBRARY_NAME <library name> SOURCE <source code list> [LIBRARIES <library link list>] )")
  #message(STATUS "cet_make_library debug: called with ${ARGN} from ${CMAKE_CURRENT_SOURCE_DIR}")
  cet_parse_args( CML "LIBRARY_NAME;LIBRARIES;SOURCE" "WITH_STATIC_LIBRARY;NO_INSTALL" ${ARGN})
  # there are no default arguments
  if( CML_DEFAULT_ARGS )
     message("CET_MAKE_LIBRARY: Incorrect arguments. ${ARGV}")
     message(SEND_ERROR  ${cet_make_library_usage})
  endif()
  # check for a source code list
  if(CML_SOURCE)
     set(cet_src_list ${CML_SOURCE})
  else()
     message("CET_MAKE_LIBRARY: Incorrect arguments. ${ARGV}")
     message(SEND_ERROR  ${cet_make_library_usage})
  endif()
  add_library( ${CML_LIBRARY_NAME} SHARED ${cet_src_list} )
  if(CML_LIBRARIES)
     target_link_libraries( ${CML_LIBRARY_NAME} ${CML_LIBRARIES} )
  endif()
  #message( STATUS "cet_make_library debug: CML_NO_INSTALL is ${CML_NO_INSTALL}")
  #message( STATUS "cet_make_library debug: CML_WITH_STATIC_LIBRARY is ${CML_WITH_STATIC_LIBRARY}")
  if( CML_NO_INSTALL )
    #message(STATUS "cet_make_library debug: ${CML_LIBRARY_NAME} will not be installed")
  else()
    _cet_check_lib_directory()
    cet_add_to_library_list( ${CML_LIBRARY_NAME})
    _cet_debug_message( "cet_make_library: ${CML_LIBRARY_NAME} will be installed in ${${product}_lib_dir}")
    install( TARGETS  ${CML_LIBRARY_NAME} 
	     RUNTIME DESTINATION ${${product}_bin_dir}
	     LIBRARY DESTINATION ${${product}_lib_dir}
	     ARCHIVE DESTINATION ${${product}_lib_dir}
             )
  endif()
  if( CML_WITH_STATIC_LIBRARY )
    add_library( ${CML_LIBRARY_NAME}S STATIC ${cet_src_list} )
    if(CML_LIBRARIES)
       target_link_libraries( ${CML_LIBRARY_NAME}S ${CML_LIBRARIES} )
    endif()
    set_target_properties( ${CML_LIBRARY_NAME}S PROPERTIES OUTPUT_NAME ${CML_LIBRARY_NAME} )
    set_target_properties( ${CML_LIBRARY_NAME}  PROPERTIES OUTPUT_NAME ${CML_LIBRARY_NAME} )
    set_target_properties( ${CML_LIBRARY_NAME}S PROPERTIES CLEAN_DIRECT_OUTPUT 1 )
    set_target_properties( ${CML_LIBRARY_NAME}  PROPERTIES CLEAN_DIRECT_OUTPUT 1 )
    if( CML_NO_INSTALL )
      #message(STATUS "cet_make_library debug: ${CML_LIBRARY_NAME}S will not be installed")
    else()
      install( TARGETS  ${CML_LIBRARY_NAME}S 
	       RUNTIME DESTINATION ${${product}_bin_dir}
	       LIBRARY DESTINATION ${${product}_lib_dir}
	       ARCHIVE DESTINATION ${${product}_lib_dir}
               )
    endif()
  endif( CML_WITH_STATIC_LIBRARY )
endmacro( cet_make_library )

macro (cet_script)
  cet_parse_args(CS "DEPENDENCIES" "GENERATED;NO_INSTALL;REMOVE_EXTENSIONS" ${ARGN})
  if (CS_GENERATED)
    set(CS_SOURCE_DIR ${CMAKE_CURRENT_BINARY_DIR})
  else()
    set(CS_SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR})
  endif()
  foreach(target_name ${CS_DEFAULT_ARGS})
    if(CS_REMOVE_EXTENSIONS)
       get_filename_component(target ${target_name} NAME_WE )
    else()
       set(target ${target_name})
    endif()
    add_custom_target(!${target} ALL
      ${CMAKE_COMMAND} -E make_directory "${EXECUTABLE_OUTPUT_PATH}/"
      COMMAND ${CMAKE_COMMAND} -E
      copy "${CS_SOURCE_DIR}/${target_name}"
      "${EXECUTABLE_OUTPUT_PATH}/${target}"
      COMMAND chmod +x "${EXECUTABLE_OUTPUT_PATH}/${target}"
      DEPENDS "${CS_SOURCE_DIR}/${target_name}"
      )
    if (CS_DEPENDENCIES)
      add_dependencies(!${target} ${CS_DEPENDENCIES})
    endif()
    # Allow CUSTOM_COMMANDs using these scripts to be updated when the
    # script changes: just list the script in the DEPENDS of the
    # CUSTOM_COMMAND.
    add_executable(${target} IMPORTED GLOBAL)
    set_target_properties(${target}
      PROPERTIES IMPORTED_LOCATION "${CS_SOURCE_DIR}/${target_name}"
      )

    # Install in product if desired.
    if (NOT CS_NO_INSTALL)
      install(PROGRAMS "${EXECUTABLE_OUTPUT_PATH}/${target}"
        DESTINATION "${${product}_bin_dir}")
    endif()
  endforeach()
endmacro()
