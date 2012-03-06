# Boost is a very special case
#
# find_ups_boost(  version [list of libraries] )
#  version - minimum version required

include(CheckUpsVersion)

# since variables are passed, this is implemented as a macro
macro( find_ups_boost version  )

  set(boost_liblist "${ARGN}")


# Check if the boost library has been set
# boost is a special case
SET ( BOOST_VERS $ENV{BOOST_VERSION} )
IF (NOT BOOST_VERS)
    MESSAGE (FATAL_ERROR "Boost library has not been setup")
ENDIF()

# convert vx_y_z to x.y.z
STRING( REGEX REPLACE "v(.*)_(.*)_(.*)" "\\1.\\2" MINVER "${version}" )
STRING( REGEX REPLACE "v(.*)_(.*)_(.*)" "\\1.\\2.\\3" THISVER "${BOOST_VERS}" )
#message(STATUS "find_ups_boost debug: Boost minimum version is ${MINVER} from ${version} " )
#message(STATUS "find_ups_boost debug: Boost  version is ${THISVER} from ${BOOST_VERS} " )
if(  ${THISVER} STRGREATER ${MINVER} )
  #message( STATUS "find_ups_boost debug: Boost ${THISVER} meets minimum required version ${MINVER}")
else()
  message( FATAL_ERROR "Boost ${THISVER} is less than minimum required version ${MINVER}")
endif()

SET ( BOOST_STRING $ENV{SETUP_BOOST} )
STRING( REGEX MATCH "[-][q]" has_qual "${BOOST_STRING}" )
STRING( REGEX MATCH "[-][j]" has_j "${BOOST_STRING}" )
if( has_qual )
  if( has_j )
     STRING( REGEX REPLACE ".*([-][q]+ )(.*)[ *]([-][-j])" "\\2" BOOST_QUAL "${BOOST_STRING}" )
  else( )
     STRING( REGEX REPLACE ".*([-][q]+ )(.*)" "\\2" BOOST_QUAL "${BOOST_STRING}" )
  endif( )
  #message(STATUS "find_ups_boost debug: Boost qualifier is ${BOOST_QUAL}")
  STRING( REGEX REPLACE ":" ";" BOOST_QUAL_LIST "${BOOST_QUAL}" )
  #message(STATUS "find_ups_boost debug: Boost qualifiers list: ${BOOST_QUAL_LIST}")
  list(REMOVE_ITEM BOOST_QUAL_LIST debug opt prof)
  #message(STATUS "find_ups_boost debug: Boost qualifiers are ${BOOST_QUAL_LIST}")
  STRING( REGEX REPLACE ";" ":" BOOST_BASE_QUAL "${BOOST_QUAL_LIST}" )
  #message(STATUS "find_ups_boost debug: Boost base qualifier is ${BOOST_BASE_QUAL}")
else( )
  message(STATUS "WARNING: Boost has no qualifier")
endif( )
message(STATUS "Boost version and qualifier are ${BOOST_VERS} ${BOOST_QUAL}" )
#message(STATUS "find_ups_boost debug: Boost base qualifier is ${BOOST_BASE_QUAL}" )

include_directories ( $ENV{BOOST_INC} )

# define the boost environment so we don't get system libraries
set(BOOST_ROOT $ENV{BOOST_DIR} )
set(BOOST_INCLUDEDIR $ENV{BOOST_INC} )
set(BOOST_LIBRARYDIR $ENV{BOOST_LIB} )
set(Boost_USE_MULTITHREADED ON)
set(Boost_ADDITIONAL_VERSIONS "1.48" "1.48.0" "1.49" "1.49.0")
set(Boost_NO_SYSTEM_PATHS ON)
# search for Boost ${MINVER} or better libraries
if( boost_liblist )
    find_package( Boost ${MINVER} COMPONENTS ${boost_liblist} )
    #message(STATUS "find_ups_boost debug: checking for Boost libraries: ${boost_liblist}" )
    #foreach( boostlib ${boost_liblist} )
    #   string( TOUPPER ${boostlib} BOOSTLIB_UC )
    #   message(STATUS "find_ups_boost debug: ${boostlib} is ${Boost_${BOOSTLIB_UC}_LIBRARY}")
    #endforeach( boostlib )
else ()
    find_package( Boost ${MINVER}  )
endif( boost_liblist )

#message(STATUS "find_ups_boost debug: Boost include directory is ${Boost_INCLUDE_DIR}" )
#message(STATUS "find_ups_boost debug: Boost library directory is ${BOOST_LIBRARYDIR}" )

endmacro( find_ups_boost )
