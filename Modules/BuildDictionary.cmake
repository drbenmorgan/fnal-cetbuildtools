# macros for building plugin libraries
#
# this is how we do the genreflex step
# define some variables for genreflex
set( GENREFLEX_FLAGS --deep
                     --fail_on_warnings
		     --capabilities=classes_ids.cc
                     -DCMS_DICT_IMPL
		     -D_REENTRANT
		     -DGNU_SOURCE
		     -DGNU_GCC
		     -DPROJECT_NAME="CMSSW"
		     -DPROJECT_VERSION="CMSSW_3_0_0_pre2" )
set( GENREFLEX_INCLUDES -I ${CPPUNIT_INC}
			-I $ENV{CLHEP_DIR}/include
			-I $ENV{ROOT_DIR}/include
			-I $ENV{ROOT_DIR}/cintex/inc
			-I $ENV{BOOST_INC}
			-I $ENV{CPP0X_INC}
			-I $ENV{CETLIB_INC}
			-I $ENV{FHICLCPP_INC}
			-I $ENV{MESSAGEFACILITY_INC}
			-I $ENV{LIBSIGCPP_DIR}/include/sigc++-2.0
			-I $ENV{LIBSIGCPP_DIR}/lib/sigc++-2.0/include )
macro (build_dictionary dictname )
  add_library(${dictname}_dict SHARED ${dictname}_dict.cpp )
  add_library(${dictname}_map SHARED ${dictname}_map.cpp )
  set(dictionary_liblist "${ARGN}")
  if( dictionary_liblist )
    target_link_libraries( ${dictname}_dict ${dictionary_liblist} )
    target_link_libraries( ${dictname}_map ${dictionary_liblist} )
  endif( dictionary_liblist )
  add_custom_command(
     OUTPUT ${dictname}_dict.cpp
     COMMAND ${GENREFLEX}  ${CMAKE_CURRENT_SOURCE_DIR}/classes.h
        	 -s  ${CMAKE_CURRENT_SOURCE_DIR}/classes_def.xml
		 -I ${CMAKE_SOURCE_DIR}
		 -I ${CMAKE_SOURCE_DIR}/art/${maindir}/${subdir}
		 ${GENREFLEX_INCLUDES}
        	 -o ${dictname}_dict.cpp
		 ${GENREFLEX_FLAGS} || { rm -f ${dictname}_dict.cpp\; /bin/false\; }
     DEPENDS  ${CMAKE_CURRENT_SOURCE_DIR}/classes.h
              ${CMAKE_CURRENT_SOURCE_DIR}/classes_def.xml
  )
  add_custom_command(
     OUTPUT ${dictname}_map.cpp
     DEPENDS ${dictname}_dict.cpp
     COMMAND mv classes_ids.cc ${dictname}_map.cpp
  )
  install ( TARGETS ${dictname}_dict DESTINATION ${flavorqual_dir}/lib )
  install ( TARGETS ${dictname}_map  DESTINATION ${flavorqual_dir}/lib )
endmacro (build_dictionary maindir subdir)
