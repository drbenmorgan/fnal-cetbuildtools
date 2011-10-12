# ROOT is a special case
#
# find_ups_root(  minimum )
#  minimum - minimum version required

include(CheckUpsVersion)

# since variables are passed, this is implemented as a macro
macro( find_ups_root minimum )

# require ROOTSYS
set( ROOTSYS $ENV{ROOTSYS} )
if ( NOT ROOTSYS )
  message(FATAL_ERROR "root has not been setup")
endif ()
set( ROOT_VERSION $ENV{ROOT_VERSION} )
if ( NOT ROOT_VERSION )
   message( STATUS "find_ups_root: calculating root version" )
   SET ( ROOT_STRING $ENV{SETUP_ROOT} )
   STRING( REGEX REPLACE "^[r][o][o][t][ ]+([^ ]+).*" "\\1" ROOT_VERSION "${ROOT_STRING}" )
endif ()

#message( STATUS "find_ups_root: checking root ${ROOT_VERSION} against ${minimum}" )
_check_version( ROOT ${ROOT_VERSION} ${minimum} )
set( ROOT_DOT_VERSION ${dotver} )

STRING( REGEX MATCH "[-][q]" has_qual  "${ROOT_STRING}" )
STRING( REGEX MATCH "[-][j]" has_j  "${ROOT_STRING}" )
if( has_qual )
  if( has_j )
     STRING( REGEX REPLACE ".*([-][q]+ )(.*)([-][-j])" "-q \\2" ROOT_QUAL "${ROOT_STRING}" )
  else( )
     STRING( REGEX REPLACE ".*([-][q]+ )(.*)" "-q \\2" ROOT_QUAL "${ROOT_STRING}" )
  endif( )
else( )
  message(STATUS "ROOT has no qualifier")
endif( )
message(STATUS "ROOT version and qualifier are ${ROOT_VERSION} ${ROOT_QUAL}" )

# add include directory to include path if it exists
include_directories ( $ENV{ROOT_INC} )

# define ROOT libraries
find_library( ROOT_REFLEX   NAMES Reflex PATHS $ENV{ROOTSYS}/lib )
find_library( ROOT_CINT     NAMES Cint   PATHS $ENV{ROOTSYS}/lib )
find_library( ROOT_CINTEX   NAMES Cintex PATHS $ENV{ROOTSYS}/lib )
find_library( ROOT_CORE     NAMES Core   PATHS $ENV{ROOTSYS}/lib )
find_library( ROOT_MATHCORE NAMES MathCore PATHS $ENV{ROOTSYS}/lib )
find_library( ROOT_HIST     NAMES Hist   PATHS $ENV{ROOTSYS}/lib )
find_library( ROOT_TREE     NAMES Tree   PATHS $ENV{ROOTSYS}/lib )
find_library( ROOT_PHYSICS  NAMES Physics PATHS $ENV{ROOTSYS}/lib )
find_library( ROOT_GRAF     NAMES Graf   PATHS $ENV{ROOTSYS}/lib )
find_library( ROOT_RIO      NAMES RIO    PATHS $ENV{ROOTSYS}/lib )
find_library( ROOT_NET      NAMES Net    PATHS $ENV{ROOTSYS}/lib )
find_library( ROOT_MATRIX   NAMES Matrix PATHS $ENV{ROOTSYS}/lib )
find_library( ROOT_THREAD   NAMES Thread PATHS $ENV{ROOTSYS}/lib )
# define genreflex executable
find_program( ROOT_GENREFLEX NAMES genreflex PATHS $ENV{ROOTSYS}/bin )
# check for the need to cleanup after genreflex
_check_if_version_greater( ROOT ${ROOT_VERSION} v5_28_00d )
   if ( ${product_version_less} MATCHES "TRUE" )
      set ( GENREFLEX_CLEANUP TRUE )
   else()
      set ( GENREFLEX_CLEANUP FALSE )
   endif()
   message(STATUS "cleanup status: ${GENREFLEX_CLEANUP}")

endmacro( find_ups_root )
