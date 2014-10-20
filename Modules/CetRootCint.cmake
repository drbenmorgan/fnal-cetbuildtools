#
# cet_rootcint( <output_name> [NO_INSTALL] ) 
# runs rootcint against files in CMAKE_CURRENT_SOURCE_DIR and puts the result in CMAKE_CURRENT_BINARY_DIR

macro( cet_rootcint rc_output_name )

  set(cet_rootcint_usage "USAGE: cet_rootcint( <package name> [NO_INSTALL] )")
  cet_parse_args( RC "" "NO_INSTALL" ${ARGN})

  # there are no default arguments
  if( RC_DEFAULT_ARGS )
     message(FATAL_ERROR  "cet_rootcint: Incorrect arguments. ${ARGV} \n ${cet_rootcint_usage}")
  endif()
  ##message(STATUS "cet_rootcint debug: cet_rootcint called with ${rc_output_name}")
  ##get_filename_component(pkgname ${CMAKE_CURRENT_SOURCE_DIR} NAME )
  ##message(STATUS "cet_rootcint debug: pkgname is ${pkgname} - ${PACKAGE} - ${package}")
  set( SRT_FLAGS -D_POSIX_SOURCE
		 -D_SVID_SOURCE
		 -D_BSD_SOURCE
		 -D_POSIX_C_SOURCE=2
		 -DDEFECT_NO_IOSTREAM_NAMESPACES
		 -DDEFECT_NO_JZEXT
		 -DDEFECT_NO_INTHEX
		 -DDEFECT_NO_INTHOLLERITH
		 -DDEFECT_NO_READONLY
		 -DDEFECT_NO_DIRECT_FIXED
		 -DDEFECT_NO_STRUCTURE )

  # generate the list of headers to be parsed by cint
  FILE(GLOB CINT_CXX *.cxx )
  foreach( file ${CINT_CXX} )
     STRING( REGEX REPLACE ".cxx" ".h" header ${file} )
     get_filename_component( cint_file ${file} NAME_WE )
     set( CINT_HEADER_LIST ${cint_file}.h ${CINT_HEADER_LIST} )
     set( CINT_DEPENDS ${header} ${CINT_DEPENDS} )
  endforeach( file )
  ##message(STATUS "cint header list is now ${CINT_HEADER_LIST}" )

  ##message(STATUS "cet_rootcint: running ${ROOTCINT} and using headers in ${ROOTSYS}/include")
  get_property(inc_dirs DIRECTORY PROPERTY INCLUDE_DIRECTORIES)
  foreach( dir ${inc_dirs} )
     set( CINT_INCS -I${dir} ${CINT_INCS} )
  endforeach( dir )
  ##message(STATUS "cet_rootcint: include_directories ${CINT_INCS}")

  add_custom_command(
     OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/${rc_output_name}Cint.cc
            ${CMAKE_CURRENT_BINARY_DIR}/${rc_output_name}Cint.h
     COMMAND ${ROOTCINT} -f ${CMAKE_CURRENT_BINARY_DIR}/${rc_output_name}Cint.cc
                	 -c -p ${SRT_FLAGS}
			 -I. -I${CMAKE_SOURCE_DIR} ${CINT_INCS}
			 -DUSE_ROOT -I${ROOTSYS}/include
			 ${CINT_HEADER_LIST} LinkDef.h || { rm -f ${CMAKE_CURRENT_BINARY_DIR}/${rc_output_name}Cint.cc\; /bin/false\; }
     DEPENDS ${CINT_DEPENDS} LinkDef.h
     WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
  )

  # set variable for install_source
  if( NOT RC_NO_INSTALL )
    set(cet_generated_code ${CMAKE_CURRENT_BINARY_DIR}/${rc_output_name}Cint.cc
                	   ${CMAKE_CURRENT_BINARY_DIR}/${rc_output_name}Cint.h )
  endif( NOT RC_NO_INSTALL )

endmacro( cet_rootcint )
