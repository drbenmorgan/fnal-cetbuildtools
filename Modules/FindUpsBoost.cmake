# Boost is a very special case
#
# find_ups_boost(  version [list of libraries] )
#  version - minimum version required

# since variables are passed, this is implemented as a macro

macro( find_ups_boost version  )

  set(boost_liblist "${ARGN}")


# Check if the boost library has been set
# boost is a special case
SET ( BOOST_VERS $ENV{BOOST_VERSION} )
IF (NOT BOOST_VERS)
    MESSAGE (FATAL_ERROR "Boost library has not been setup")
ENDIF()
SET ( BOOST_STRING $ENV{SETUP_BOOST} )
STRING( REGEX REPLACE ".*([-][q]+ )(.*)([-][-j])" "-q \\2" BOOST_QUAL "${BOOST_STRING}" )
message(STATUS "Boost version and qualifier are ${BOOST_VERS} ${BOOST_QUAL}" )

include_directories ( $ENV{BOOST_INC} )

# define the boost environment so we don't get system libraries
set(BOOST_ROOT $ENV{BOOST_DIR} )
set(BOOST_INCLUDEDIR $ENV{BOOST_INC} )
set(BOOST_LIBRARYDIR $ENV{BOOST_LIB} )
set(Boost_USE_MULTITHREADED ON)
# search for Boost version 1.34 or better libraries
if( boost_liblist )
    find_package( Boost 1.34 COMPONENTS ${boost_liblist} )
    ##message(STATUS "checking for Boost libraries: ${boost_liblist}" )
else ()
    find_package( Boost 1.34  )
endif( boost_liblist )

##message(STATUS " Boost include directory is ${Boost_INCLUDE_DIR}" )

endmacro( find_ups_boost )
