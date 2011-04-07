# Use this macro to install source code for debugging
# The default implementation will pick up the following file extensions:
#         .c .cc .cpp .C .cxx .h .icc .hh .H .xml
# For other files, use the LIST option
# Note that the LIST and SUBDIRS options are mutually exclusive
# The LIST option is intended to allow you to pick up extra files not otherwise found.
# You cannot pick up files in subdirectories with LIST.
#
# Recommended use:
# install_source( [SUBDIRS subdirectory_list ] )
# install_source( LIST extra_file_list )
#
# install_source()
# install_source( SUBDIRS subdirectory_list )
# install_source( LIST extra_file_list )

include(CetParseArgs)

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
            *.c *.cc *.h *.cpp *.icc *.xml *.C *.cxx *.hh *.H )
  INSTALL( FILES ${src_files} 
           DESTINATION ${source_install_dir} )
  # check for generated files
  _cet_install_generated_code()
  _cet_install_generated_dictionary_code()
  # now check subdirectories
  if( ISRC_SUBDIRS )
     foreach( sub ${ISRC_SUBDIRS} )
	FILE(GLOB subdir_src_files 
	         ${sub}/*.cc ${sub}/*.c ${sub}/*.cpp ${sub}/*.C ${sub}/*.cxx
		 ${sub}/*.h ${sub}/*.icc  ${sub}/*.hh ${sub}/*.H
		 ${sub}/*.xml  )
	INSTALL( FILES ${subdir_src_files} 
        	 DESTINATION ${source_install_dir}/${sub} )
     endforeach(sub)
     #message( STATUS "also installing in subdirs: ${ISRC_SUBDIRS}")
  endif( ISRC_SUBDIRS )
endmacro( _cet_install_without_list )

macro( _cet_install_from_list   )
   #message( STATUS "source code will be installed in ${source_install_dir}" )
   INSTALL( FILES ${ISRC_LIST} 
            DESTINATION ${source_install_dir} )
endmacro( _cet_install_from_list )

macro( install_source   )
  cet_parse_args( ISRC "SUBDIRS;LIST" "" ${ARGN})
  STRING( REGEX REPLACE "^${CMAKE_SOURCE_DIR}(.*)" "\\1" CURRENT_SUBDIR "${CMAKE_CURRENT_SOURCE_DIR}" )
  set(source_install_dir ${product}/${version}/source/${product}${CURRENT_SUBDIR} )
  if( ISRC_LIST )
     if( ISRC_SUBDIRS )
        message( FATAL_ERROR 
	         "ERROR: call install_source with EITHER LIST or SUBDIRS but not both")
     endif( ISRC_SUBDIRS )
     _cet_install_from_list()
  else()
      _cet_install_without_list()
  endif()
endmacro( install_source )

macro( install_headers   )
  STRING( REGEX REPLACE "^${CMAKE_SOURCE_DIR}(.*)" "\\1" CURRENT_SUBDIR "${CMAKE_CURRENT_SOURCE_DIR}" )
  set(header_install_dir ${product}/${version}/include${CURRENT_SUBDIR} )
  message( STATUS "headers will be installed in ${header_install_dir}" )
  FILE(GLOB headers *.h *.icc *.hh *.H )
  INSTALL( FILES ${headers} 
           DESTINATION ${header_install_dir} )
endmacro( install_headers )