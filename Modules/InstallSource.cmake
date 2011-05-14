# install_source() 
# install_headers()
#
# Use the install_source macro to install source code for debugging
# The default implementation will pick up the following file extensions:
#      .cc .c .cpp .C .cxx .h .hh .H .hpp .icc .xml
# For other files, use the EXTRAS option
#
# The SUBDIRS option allows you to search subdirectories (e.g. a detail subdirectory)
# The EXTRAS option is intended to allow you to pick up extra files not otherwise found.
# You cannot pick up files in subdirectories with EXTRAS.
# The LIST option allows you to install from a list.  
# When LIST is used, we do not search for other files to install.
# Note that the LIST and SUBDIRS options are mutually exclusive
# Subdirectories will NOT be searched for files in the EXTRAS list.
# If you need that level of complexity, then subdirectory should have 
# its own CMakeLists.txt file.
#
# Recommended use:
# install_source( [SUBDIRS subdirectory_list] [EXTRAS extra_file_list] )
# install_source( LIST file_list )
#
# install_headers( [SUBDIRS subdirectory_list] [EXTRAS extra_file_list] )
# install_headers( LIST file_list )
#
# set_install_root() defines PACKAGE_TOP_DIRECTORY 

include(CetParseArgs)

macro( set_install_root )
  set( PACKAGE_TOP_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR})
  message( STATUS "set_install_root: PACKAGE_TOP_DIRECTORY is ${PACKAGE_TOP_DIRECTORY}")
endmacro( set_install_root )

macro( _cet_install_generated_code )
  # search for .in files
  FILE(GLOB config_source_files *.in  )
  if( config_source_files )
     foreach( input_file ${config_source_files} )
	STRING( REGEX REPLACE "^(${CMAKE_CURRENT_SOURCE_DIR})(.*)[.][i][n]$"  "${CMAKE_CURRENT_BINARY_DIR}\\2" output_file "${input_file}")
	INSTALL( FILES ${output_file} 
        	 DESTINATION ${source_install_dir} )
     endforeach(input_file)
  endif( config_source_files )
endmacro( _cet_install_generated_code )

macro( _cet_install_generated_dictionary_code )
  # check for dictionary code
  if( cet_generated_code )
     foreach( dict ${cet_generated_code} )
	 STRING( REGEX REPLACE "^${CMAKE_CURRENT_BINARY_DIR}/(.*)$"  "\\1" dictname "${dict}")
         # OK, this is hokey, but it works
	 set( dummy dummy_${dictname} )
	 add_custom_command( 
	    OUTPUT ${dummy}
	    COMMAND ${CMAKE_COMMAND} -E copy ${dict} ${dummy}
	    DEPENDS ${dict}
	 )
	 INSTALL( FILES ${dict} 
        	  DESTINATION ${source_install_dir} )
     endforeach(dict)
  endif( cet_generated_code )
endmacro( _cet_install_generated_dictionary_code )

macro( _cet_install_without_list   )
  #message( STATUS "source code will be installed in ${source_install_dir}" )
  FILE(GLOB src_files 
            *.cc *.c *.cpp *.C *.cxx *.h *.hh *.H *.hpp *.icc *.xml )
  if( src_files )
    INSTALL( FILES ${src_files} 
             DESTINATION ${source_install_dir} )
  endif( src_files )
  # check for generated files
  _cet_install_generated_code()
  _cet_install_generated_dictionary_code()
  # now check subdirectories
  if( ISRC_SUBDIRS )
     foreach( sub ${ISRC_SUBDIRS} )
	FILE(GLOB subdir_src_files 
	         ${sub}/*.cc ${sub}/*.c ${sub}/*.cpp ${sub}/*.C ${sub}/*.cxx
		 ${sub}/*.h ${sub}/*.hh ${sub}/*.H ${sub}/*.hpp ${sub}/*.icc
		 ${sub}/*.xml  )
        if( subdir_src_files )
	  INSTALL( FILES ${subdir_src_files} 
        	   DESTINATION ${source_install_dir}/${sub} )
        endif( subdir_src_files )
     endforeach(sub)
     #message( STATUS "also installing in subdirs: ${ISRC_SUBDIRS}")
  endif( ISRC_SUBDIRS )
endmacro( _cet_install_without_list )

macro( _cet_install_from_list  source_files  )
   #message( STATUS "_cet_install_from_list debug: source code list will be installed in ${source_install_dir}" )
   #message( STATUS "_cet_install_from_list debug: install list is ${source_files}")
   INSTALL( FILES ${source_files} 
            DESTINATION ${source_install_dir} )
endmacro( _cet_install_from_list )

macro( _cet_install_header_without_list   )
  #message( STATUS "headers will be installed in ${header_install_dir}" )
  FILE(GLOB headers *.h *.hh *.H *.hpp *.icc )
  FILE(GLOB dict_headers classes.h )
  if( dict_headers )
    #message(STATUS "install_headers debug: removing ${dict_headers} from header list")
    LIST(REMOVE_ITEM headers ${dict_headers} )
  endif( dict_headers)
  if( headers )
    INSTALL( FILES ${headers} 
             DESTINATION ${header_install_dir} )
  endif( headers )
  # now check subdirectories
  if( IHDR_SUBDIRS )
     foreach( sub ${IHDR_SUBDIRS} )
	FILE(GLOB subdir_headers 
		 ${sub}/*.h ${sub}/*.hh ${sub}/*.H ${sub}/*.hpp ${sub}/*.icc  )
        if( subdir_headers )
	  INSTALL( FILES ${subdir_headers} 
        	   DESTINATION ${header_install_dir}/${sub} )
        endif( subdir_headers )
     endforeach(sub)
     #message( STATUS "also installing in subdirs: ${IHDR_SUBDIRS}")
  endif( IHDR_SUBDIRS )
endmacro( _cet_install_header_without_list )

macro( _cet_install_header_from_list header_list  )
   #message( STATUS "headers will be installed in ${header_install_dir}" )
   INSTALL( FILES ${header_list} 
            DESTINATION ${header_install_dir} )
endmacro( _cet_install_header_from_list )

macro( install_source   )
  cet_parse_args( ISRC "SUBDIRS;LIST;EXTRAS" "" ${ARGN})
  #message( STATUS "install_source: PACKAGE_TOP_DIRECTORY is ${PACKAGE_TOP_DIRECTORY}")
  if( PACKAGE_TOP_DIRECTORY )
     STRING( REGEX REPLACE "^${PACKAGE_TOP_DIRECTORY}(.*)" "\\1" CURRENT_SUBDIR "${CMAKE_CURRENT_SOURCE_DIR}" )
  else()
     STRING( REGEX REPLACE "^${CMAKE_SOURCE_DIR}(.*)" "\\1" CURRENT_SUBDIR "${CMAKE_CURRENT_SOURCE_DIR}" )
  endif()
  set(source_install_dir ${product}/${version}/source/${product}${CURRENT_SUBDIR} )
  message( STATUS "install_source: source code will be installed in ${source_install_dir}" )
  if( ISRC_LIST )
     if( ISRC_SUBDIRS )
        message( FATAL_ERROR 
	         "ERROR: call install_source with EITHER LIST or SUBDIRS but not both")
     endif( ISRC_SUBDIRS )
     _cet_install_from_list("${ISRC_LIST}")
  else()
     if( ISRC_EXTRAS )
        _cet_install_from_list("${ISRC_EXTRAS}")
     endif( ISRC_EXTRAS )
     _cet_install_without_list()
  endif()
endmacro( install_source )

macro( install_headers   )
  cet_parse_args( IHDR "SUBDIRS;LIST;EXTRAS" "" ${ARGN})
  if( PACKAGE_TOP_DIRECTORY )
     STRING( REGEX REPLACE "^${PACKAGE_TOP_DIRECTORY}(.*)" "\\1" CURRENT_SUBDIR "${CMAKE_CURRENT_SOURCE_DIR}" )
  else()
     STRING( REGEX REPLACE "^${CMAKE_SOURCE_DIR}(.*)" "\\1" CURRENT_SUBDIR "${CMAKE_CURRENT_SOURCE_DIR}" )
  endif()
  set(header_install_dir ${product}/${version}/include${CURRENT_SUBDIR} )
  message( STATUS "install_headers: headers will be installed in ${header_install_dir}" )
  if( IHDR_LIST )
     if( IHDR_SUBDIRS )
        message( FATAL_ERROR 
	         "ERROR: call install_headers with EITHER LIST or SUBDIRS but not both")
     endif( IHDR_SUBDIRS )
     _cet_install_header_from_list("${IHDR_LIST}")
  else()
     if( IHDR_EXTRAS )
        _cet_install_header_from_list("${IHDR_EXTRAS}")
     endif( IHDR_EXTRAS )
     _cet_install_header_without_list()
  endif()
endmacro( install_headers )
