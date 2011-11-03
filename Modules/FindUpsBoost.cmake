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
#message(STATUS "Boost minimum version is ${MINVER} from ${version} " )
#message(STATUS "Boost  version is ${THISVER} from ${BOOST_VERS} " )
if(  ${THISVER} STRGREATER ${MINVER} )
  message( STATUS "Boost ${THISVER} meets minimum required version ${MINVER}")
else()
  message( FATAL_ERROR "Boost ${THISVER} is less than minimum required version ${MINVER}")
endif()

SET ( BOOST_STRING $ENV{SETUP_BOOST} )
STRING( REGEX MATCH "[-][q]" has_qual "${BOOST_STRING}" )
STRING( REGEX MATCH "[-][j]" has_j "${BOOST_STRING}" )
if( has_qual )
  if( has_j )
     STRING( REGEX REPLACE ".*([-][q]+ )(.*)([-][-j])" "-q \\2" BOOST_QUAL "${BOOST_STRING}" )
  else( )
     STRING( REGEX REPLACE ".*([-][q]+ )(.*)" "-q \\2" BOOST_QUAL "${BOOST_STRING}" )
  endif( )
  STRING( REGEX REPLACE "(.*)[:](.*)" "\\1" BOOST_BASE_QUAL "${BOOST_QUAL}" )
  #message(STATUS "Boost qualifier is ${BOOST_QUAL}")
else( )
  message(STATUS "WARNING: Boost has no qualifier")
endif( )
message(STATUS "Boost version and qualifier are ${BOOST_VERS} ${BOOST_QUAL}" )
message(STATUS "Boost base qualifier is ${BOOST_BASE_QUAL}" )

include_directories ( $ENV{BOOST_INC} )

# define the boost environment so we don't get system libraries
set(BOOST_ROOT $ENV{BOOST_DIR} )
set(BOOST_INCLUDEDIR $ENV{BOOST_INC} )
set(BOOST_LIBRARYDIR $ENV{BOOST_LIB} )
set(Boost_USE_MULTITHREADED ON)
# search for Boost ${MINVER} or better libraries
if( boost_liblist )
    find_package( Boost ${MINVER} COMPONENTS ${boost_liblist} )
    ##message(STATUS "checking for Boost libraries: ${boost_liblist}" )
else ()
    find_package( Boost ${MINVER}  )
endif( boost_liblist )

##message(STATUS " Boost include directory is ${Boost_INCLUDE_DIR}" )

endmacro( find_ups_boost )
