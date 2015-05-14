# ROOT is a special case
#
# find_ups_root(  minimum )
#  minimum - minimum version required

include(CheckUpsVersion)

function(_set_root_lib_vars)
  foreach (ROOTLIB ${ARGN})
    string(TOUPPER ${ROOTLIB} ROOTLIB_UC)
    set(ROOT_${ROOTLIB_UC} ${ROOTSYS}/lib/lib${ROOTLIB}.so PARENT_SCOPE)
  endforeach()
endfunction()

# since variables are passed, this is implemented as a macro
macro( find_ups_root minimum )

# require ROOTSYS
set( ROOTSYS $ENV{ROOTSYS} )
if ( NOT ROOTSYS )
  message(FATAL_ERROR "root has not been setup")
endif ()

# only execute if this macro has not already been called
if( NOT ROOT_VERSION )
  ##message( STATUS "find_ups_root debug: ROOT_VERSION is NOT defined" )

SET ( ROOT_STRING $ENV{SETUP_ROOT} )
set( ROOT_VERSION $ENV{ROOT_VERSION} )
if ( NOT ROOT_VERSION )
   #message( STATUS "find_ups_root: calculating root version" )
   STRING( REGEX REPLACE "^[r][o][o][t][ ]+([^ ]+).*" "\\1" ROOT_VERSION "${ROOT_STRING}" )
endif ()

#message( STATUS "find_ups_root: checking root ${ROOT_VERSION} against ${minimum}" )
_check_version( ROOT ${ROOT_VERSION} ${minimum} )
set( ROOT_DOT_VERSION ${dotver} )
# compare for recursion
list(FIND cet_product_list root found_product_match)
if( ${found_product_match} LESS 0 )
  # add to product list
  set(CONFIG_FIND_UPS_COMMANDS "${CONFIG_FIND_UPS_COMMANDS}
  find_ups_root( ${minimum} )")
  set(cet_product_list root ${cet_product_list} )
endif()

STRING( REGEX MATCH "[-][q]" has_qual  "${ROOT_STRING}" )
STRING( REGEX MATCH "[-][j]" has_j  "${ROOT_STRING}" )
if( has_qual )
  if( has_j )
     STRING( REGEX REPLACE ".*([-][q]+ )(.*)[ *]([-][-j])" "\\2" ROOT_QUAL "${ROOT_STRING}" )
  else( )
     STRING( REGEX REPLACE ".*([-][q]+ )(.*)" "\\2" ROOT_QUAL "${ROOT_STRING}" )
  endif( )
  STRING( REGEX REPLACE ":" ";" ROOT_QUAL_LIST "${ROOT_QUAL}" )
  list(REMOVE_ITEM ROOT_QUAL_LIST debug opt prof)
  STRING( REGEX REPLACE ";" ":" ROOT_BASE_QUAL "${ROOT_QUAL_LIST}" )
else( )
  message(STATUS "ROOT has no qualifier")
endif( )
if( ${found_product_match} LESS 0 )
  _cet_debug_message("find_ups_root: ROOT version and qualifier are ${ROOT_VERSION} ${ROOT_QUAL}" )
endif()
#message(STATUS "ROOT base qualifier is ${ROOT_BASE_QUAL}" )

# add include directory to include path if it exists
include_directories ( $ENV{ROOT_INC} )

# define ROOT libraries
_set_root_lib_vars(
  ASImage ASImageGui Cint Cintex Core EG EGPythia6 Eve FFTW FitPanel
  Foam FTGL Fumili Gdml Ged Genetic GenVector Geom GeomBuilder
  GeomPainter GLEW Gpad Graf Graf3d Gui GuiBld GuiHtml Gviz3d GX11
  GX11TTF Hbook Hist HistPainter Html Krb5Auth MathCore Matrix MemStat
  minicern Minuit Minuit2 MLP Net New Physics Postscript Proof
  ProofBench ProofDraw ProofPlayer PyROOT Quadp Recorder Reflex RGL Rint
  RIO RootAuth SessionViewer Smatrix Spectrum SpectrumPainter SPlot
  SQLIO SrvAuth Thread TMVA Tree TreePlayer TreeViewer VMC X3d XMLIO
  XMLParser
)

include_directories ( ${ROOTSYS}/include )

# define genreflex executable
set(ROOT_GENREFLEX ${ROOTSYS}/bin/genreflex)

# check for the need to cleanup after genreflex
check_ups_version(root ${ROOT_VERSION} v5_28_00d PRODUCT_OLDER_VAR GENREFLEX_CLEANUP)
#message(STATUS "genreflex cleanup status: ${GENREFLEX_CLEANUP}")

# define rootcint executable
set(ROOTCINT ${ROOTSYS}/bin/rootcint)

# define some useful library lists
set(ROOT_BASIC_LIB_LIST ${ROOT_CORE}
                        ${ROOT_CINT} 
                        ${ROOT_RIO}
                        ${ROOT_NET}
                        ${ROOT_HIST} 
                        ${ROOT_GRAF}
                        ${ROOT_GRAF3D}
                        ${ROOT_GPAD}
                        ${ROOT_TREE}
                        ${ROOT_RINT}
                        ${ROOT_POSTSCRIPT}
                        ${ROOT_MATRIX}
                        ${ROOT_PHYSICS}
                        ${ROOT_MATHCORE}
                        ${ROOT_THREAD}
)
set(ROOT_GUI_LIB_LIST   ${ROOT_GUI} ${ROOT_BASIC_LIB_LIST} )
set(ROOT_EVE_LIB_LIST   ${ROOT_EVE}
                        ${ROOT_EG}
                        ${ROOT_TREEPLAYER}
                        ${ROOT_GEOM}
                        ${ROOT_GED}
                        ${ROOT_RGL}
                        ${ROOT_GUI_LIB_LIST}
)
endif( NOT ROOT_VERSION )

endmacro( find_ups_root )
