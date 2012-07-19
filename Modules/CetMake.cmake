# cet_make
#
# Identify the files in the current source directory and deal with them appropriately
# Users may opt to just include cet_make() in their CMakeLists.txt
# This implementation is intended to be called NO MORE THAN ONCE per subdirectory.
#
# cet_make( [LIBRARY_NAME <library name>]  
#           [LIBRARIES <library list>]  
#           [SUBDIRS <source subdirectory>] (e.g., detail)
#           [EXEC <exec source>]
#           [TEST <test source>]
#           [EXCLUDE <ignore these files>] )
#
# NOTE: if your code includes art plugins, you MUST use art_make instead of cet_make.
# cet_make will ignore all plugin code
#
# cet_make_exec( name liblist )
# -- build a regular executable
# -- used by art_make and cet_make
#
# cet_make_test_exec( name liblist )
# -- build a test executable
# -- used by art_make and cet_make

include(CetParseArgs)
include(InstallSource)

macro( cet_make_exec name liblist )
  #message(STATUS "debug: cet_make_exec called with ${name} ${liblist}")
  get_filename_component(name_ext ${name} EXT)
  STRING( REGEX REPLACE "(.*)${name_ext}" "\\1" base_name "${name}" )
  #message(STATUS "debug: cet_make_exec base name is ${base_name} ")
  add_executable( ${base_name} ${name} )
  target_link_libraries( ${base_name} ${liblist} )
  install( TARGETS ${base_name} DESTINATION ${flavorqual_dir}/bin )
endmacro( cet_make_exec )

macro( cet_make_test_exec name liblist )
  #message(STATUS "debug: _cet_test called with ${name} ${liblist}")
  get_filename_component(name_ext ${name} EXT)
  STRING( REGEX REPLACE "(.*)${name_ext}" "\\1" base_name "${name}" )
  #message(STATUS "debug: _cet_test base name is ${base_name} ")
  add_executable( ${base_name} ${name} )
  target_link_libraries( ${base_name} ${liblist} )
  ADD_TEST(${base_name} ${EXECUTABLE_OUTPUT_PATH}/${base_name})
endmacro( cet_make_test_exec )

macro( cet_make )
  set(cet_file_list "")
  set(cet_make_usage "USAGE: cet_make( [LIBRARIES <library list>] [EXEC <exec source>]  [TEST <test source>] [EXCLUDE <ignore these files>] )")
  #message(STATUS "cet_make debug: called with ${ARGN} from ${CMAKE_CURRENT_SOURCE_DIR}")
  cet_parse_args( CM "LIBRARY_NAME;LIBRARIES;EXEC;SUBDIRS;TEST;EXCLUDE" "" ${ARGN})
  # there are no default arguments
  if( CM_DEFAULT_ARGS )
     message("CET_MAKE: Incorrect arguments. ${ARGV}")
     message(SEND_ERROR  ${cet_make_usage})
  endif()
  # check for extra link libraries
  if(CM_LIBRARIES)
     set(cet_liblist ${CM_LIBRARIES})
  endif()
  # add executables to the list of known files 
  if(CM_EXEC)
     foreach( exec_file ${CM_EXEC} )
        set(cet_file_list ${cet_file_list} ${exec_file} )
     endforeach( exec_file )
  endif()
  if(CM_TEST)
     foreach( test_file ${CM_TEST} )
        set(cet_file_list ${cet_file_list} ${test_file} )
     endforeach( test_file )
  endif()
  # now look for other source files in this directory
  #message(STATUS "cet_make debug: listed files ${cet_file_list}")
  FILE( GLOB src_files *.c *.cc *.cpp *.C *.cxx )
  FILE( GLOB ignore_plugins  *_source.cc *_service.cc  *_module.cc )
  # also check subdirectories
  if( CM_SUBDIRS )
     foreach( sub ${CM_SUBDIRS} )
	FILE( GLOB subdir_src_files ${sub}/*.c ${sub}/*.cc ${sub}/*.cpp ${sub}/*.C ${sub}/*.cxx )
	FILE( GLOB subdir_ignore_plugins  ${sub}/*_source.cc ${sub}/*_service.cc  ${sub}/*_module.cc )
        if( subdir_src_files )
	  list(APPEND  src_files ${subdir_src_files})
        endif( subdir_src_files )
        if( subdir_ignore_plugins )
	  list(APPEND  ignore_plugins ${subdir_ignore_plugins})
        endif( subdir_ignore_plugins )
     endforeach(sub)
  endif( CM_SUBDIRS )
  if( ignore_plugins )
    LIST( REMOVE_ITEM src_files ${ignore_plugins} )
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
  #set(cet_make_name "${cetname2}_${name}_${type}")

  if( have_library )
    #message( STATUS "cet_make debug: building library for ${CMAKE_CURRENT_SOURCE_DIR}")
    if(CM_LIBRARY_NAME)
      set(cet_make_library_name ${CM_LIBRARY_NAME})
    else()
      set(cet_make_library_name ${cet_make_name})
    endif()
    if(CM_LIBRARIES) 
       link_libraries( ${cet_liblist} )
    endif(CM_LIBRARIES) 
    #message( STATUS "cet_make debug: calling add_library with ${cet_make_library_name}  ${cet_make_library_src}") 
    add_library( ${cet_make_library_name} SHARED ${cet_make_library_src} )
    install( TARGETS ${cet_make_library_name} DESTINATION ${flavorqual_dir}/lib )
  else( )
    message( STATUS "cet_make: no library for ${CMAKE_CURRENT_SOURCE_DIR}")
  endif( )

  # is there a dictionary?
  FILE(GLOB dictionary_header classes.h )
  FILE(GLOB dictionary_xml classes_def.xml )
  if( dictionary_header AND dictionary_xml )
     message( STATUS "cet_make: found dictionary in ${CMAKE_CURRENT_SOURCE_DIR}")
     set(cet_file_list ${cet_file_list} ${dictionary_xml} ${dictionary_header} )
     if(CM_LIBRARIES) 
        build_dictionary( DICTIONARY_LIBRARIES ${cet_liblist} )
     else()
        build_dictionary(  )
     endif()
  endif()

  # OK - now build the executables
  if(CM_EXEC)
     foreach( exec_file ${CM_EXEC} )
        cet_make_exec( ${exec_file} "${cet_liblist}" "${cet_make_library_name}" )
     endforeach( exec_file )
  endif()
  if(CM_TEST)
     foreach( test_file ${CM_TEST} )
        cet_make_test_exec( ${test_file} "${cet_liblist}" "${cet_make_library_name}" )
     endforeach( test_file )
  endif()

endmacro( cet_make )
