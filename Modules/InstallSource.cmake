# use to install source code
#
# install_source()
# install_source( SUBDIRS dir1 )
# install_source( SUBDIRS dir1 dir2 )

include(CetParseArgs)

macro( install_source   )
  cet_parse_args( ISRC "SUBDIRS" "" ${ARGN})
  
  STRING( REGEX REPLACE "^${CMAKE_SOURCE_DIR}(.*)" "\\1" CURRENT_SUBDIR "${CMAKE_CURRENT_SOURCE_DIR}" )
  set(source_install_dir ${product}/${version}/source/${product}${CURRENT_SUBDIR} )
  FILE(GLOB src_files *.cc *.h *.cpp *.icc *.xml )
  INSTALL( FILES ${src_files} 
           DESTINATION ${source_install_dir} )
  message( STATUS "source code will be installed in is ${source_install_dir}" )
  if( ISRC_SUBDIRS )
     foreach( sub ${ISRC_SUBDIRS} )
	FILE(GLOB src_files ${sub}/*.cc ${sub}/*.h ${sub}/*.cpp ${sub}/*.icc ${sub}/*.xml )
	INSTALL( FILES ${src_files} 
        	 DESTINATION ${source_install_dir}/${sub} )
     endforeach(sub)
     message( STATUS "also installing in subdirs: ${ISRC_SUBDIRS}")
  endif( ISRC_SUBDIRS )

endmacro( install_source )
