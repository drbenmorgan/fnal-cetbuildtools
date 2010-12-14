# ROOT is a special case
#
# find_ups_root(  version )
#  version - minimum version required

# since variables are passed, this is implemented as a macro

macro( find_ups_root version )

# require ROOTSYS
set( ROOTSYS $ENV{ROOTSYS} )
if ( NOT ROOTSYS )
  message(FATAL_ERROR "root has not been setup")
endif ()
SET ( ROOT_STRING $ENV{SETUP_ROOT} )
STRING( REGEX REPLACE "^[r][o][o][t][ ]+([^ ]+).*" "\\1" ROOT_VERSION "${ROOT_STRING}" )

# convert vx_y_z to x.y.z
STRING( REGEX REPLACE "v(.*)_(.*)_(.*)" "\\1.\\2" MINVER "${version}" )
STRING( REGEX REPLACE "v(.*)_(.*)_(.*)" "\\1.\\2.\\3" THISVER "${ROOT_VERSION}" )
#message(STATUS "ROOT minimum version is ${MINVER} from ${version} " )
#message(STATUS "ROOT  version is ${THISVER} from ${ROOT_VERSION} " )
if(  ${THISVER} STRGREATER ${MINVER} )
  message( STATUS "ROOT ${THISVER} meets minimum required version ${MINVER}")
else()
  message( FATAL_ERROR "ROOT ${THISVER} is less than minimum required version ${MINVER}")
endif()

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
find_library( REFLEX NAMES Reflex PATHS $ENV{ROOTSYS}/lib )
find_library( CINT   NAMES Cint   PATHS $ENV{ROOTSYS}/lib )
find_library( CINTEX NAMES Cintex PATHS $ENV{ROOTSYS}/lib )
find_library( CORE   NAMES Core   PATHS $ENV{ROOTSYS}/lib )
find_library( MATHCORE NAMES MathCore PATHS $ENV{ROOTSYS}/lib )
find_library( HIST   NAMES Hist   PATHS $ENV{ROOTSYS}/lib )
find_library( TREE   NAMES Tree   PATHS $ENV{ROOTSYS}/lib )
find_library( GRAF   NAMES Graf   PATHS $ENV{ROOTSYS}/lib )
find_library( RIO    NAMES RIO    PATHS $ENV{ROOTSYS}/lib )
find_library( NET    NAMES Net    PATHS $ENV{ROOTSYS}/lib )
find_library( MATRIX NAMES Matrix PATHS $ENV{ROOTSYS}/lib )
# define genreflex executable
find_program( GENREFLEX NAMES genreflex PATHS $ENV{ROOTSYS}/bin )

endmacro( find_ups_root )
