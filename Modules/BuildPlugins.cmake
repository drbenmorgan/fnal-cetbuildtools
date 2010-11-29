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
macro (build_dictionary maindir subdir)
  add_library(${maindir}${subdir}_dict SHARED ${maindir}${subdir}_dict.cpp )
  add_library(${maindir}${subdir}_map SHARED ${maindir}${subdir}_map.cpp )
  set(dictionary_liblist "${ARGN}")
  if( dictionary_liblist )
    target_link_libraries( ${maindir}${subdir}_dict ${dictionary_liblist} )
    target_link_libraries( ${maindir}${subdir}_map ${dictionary_liblist} )
  endif( dictionary_liblist )
  add_custom_command(
     OUTPUT ${maindir}${subdir}_dict.cpp
     COMMAND ${GENREFLEX} ${CMAKE_SOURCE_DIR}/art/${maindir}/${subdir}/classes.h
        	 -s ${CMAKE_SOURCE_DIR}/art/${maindir}/${subdir}/classes_def.xml
		 -I ${CMAKE_SOURCE_DIR}
		 -I ${CMAKE_SOURCE_DIR}/art/${maindir}/${subdir}
		 ${GENREFLEX_INCLUDES}
        	 -o ${maindir}${subdir}_dict.cpp
		 ${GENREFLEX_FLAGS} || { rm -f ${maindir}${subdir}_dict.cpp\; /bin/false\; }
     DEPENDS ${CMAKE_SOURCE_DIR}/art/${maindir}/${subdir}/classes.h
             ${CMAKE_SOURCE_DIR}/art/${maindir}/${subdir}/classes_def.xml
  )
  add_custom_command(
     OUTPUT ${maindir}${subdir}_map.cpp
     DEPENDS ${maindir}${subdir}_dict.cpp
     COMMAND mv classes_ids.cc ${maindir}${subdir}_map.cpp
  )
  install ( TARGETS ${maindir}${subdir}_dict DESTINATION ${flavorqual_dir}/lib )
  install ( TARGETS ${maindir}${subdir}_map  DESTINATION ${flavorqual_dir}/lib )
endmacro (build_dictionary maindir subdir)

macro (build_art_dictionary maindir subdir)
  add_library(${maindir}${subdir}_dict SHARED ${maindir}${subdir}_dict.cpp )
  add_library(${maindir}${subdir}_map SHARED ${maindir}${subdir}_map.cpp )
  set(dictionary_liblist "${ARGN}")
  if( dictionary_liblist )
    target_link_libraries( ${maindir}${subdir}_dict ${dictionary_liblist} )
    target_link_libraries( ${maindir}${subdir}_map ${dictionary_liblist} )
  endif( dictionary_liblist )
  add_custom_command(
     OUTPUT ${maindir}${subdir}_dict.cpp
     COMMAND ${GENREFLEX} ${CMAKE_SOURCE_DIR}/art/${maindir}/${subdir}/classes.h
        	 -s ${CMAKE_SOURCE_DIR}/art/${maindir}/${subdir}/classes_def.xml
		 -I ${CMAKE_SOURCE_DIR}
		 -I ${CMAKE_SOURCE_DIR}/art/${maindir}/${subdir}
		 ${GENREFLEX_INCLUDES}
        	 -o ${maindir}${subdir}_dict.cpp
		 ${GENREFLEX_FLAGS} || { rm -f ${maindir}${subdir}_dict.cpp\; /bin/false\; }
     DEPENDS ${CMAKE_SOURCE_DIR}/art/${maindir}/${subdir}/classes.h
             ${CMAKE_SOURCE_DIR}/art/${maindir}/${subdir}/classes_def.xml
  )
  add_custom_command(
     OUTPUT ${maindir}${subdir}_map.cpp
     DEPENDS ${maindir}${subdir}_dict.cpp
     COMMAND mv classes_ids.cc ${maindir}${subdir}_map.cpp
  )
  install ( TARGETS ${maindir}${subdir}_dict DESTINATION ${flavorqual_dir}/lib )
  install ( TARGETS ${maindir}${subdir}_map  DESTINATION ${flavorqual_dir}/lib )
endmacro (build_dictionary maindir subdir)

# simple plugin libraries
macro (simple_plugin name)
  add_library(${name} SHARED ${name}.cc )
  set(simple_plugin_liblist "${ARGN}")
  if( simple_plugin_liblist )
    target_link_libraries( ${name} ${simple_plugin_liblist} )
  endif( simple_plugin_liblist )
  install( TARGETS ${name}  DESTINATION ${flavorqual_dir}/lib )
endmacro (simple_plugin name)
