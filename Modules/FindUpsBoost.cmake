# Boost is a very special case
#
# find_ups_boost(  [minimum] )
#  minimum - optional minimum version
#  we look for nearly all of the boost libraries
#      except math, prg_exec_monitor, test_exec_monitor

include(CheckUpsVersion)

# since variables are passed, this is implemented as a macro
macro(find_ups_boost)
  # Check if the boost library has been set
  # boost is a special case
  set(BOOST_VERS $ENV{BOOST_VERSION})
  if(NOT BOOST_VERS)
    messageFATAL_ERROR "Boost library has not been setup")
  endif()

  cmake_parse_arguments(FUB "" "" "" ${ARGN})
  set(minimum )
  if(FUB_UNPARSED_ARGUMENTS)
    list(GET FUB_UNPARSED_ARGUMENTS 0 minimum)
  endif()

  set(boost_liblist
    chrono
    date_time
    filesystem
    graph
    iostreams
    locale
    prg_exec_monitor
    program_options
    random
    regex
    serialization
    signals
    system
    thread
    timer
    unit_test_framework
    wave
    wserialization
    )

  # compare for recursion
  list(FIND cet_product_list boost found_product_match)
  if(${found_product_match} LESS 0)
    # add to product list
    set(CONFIG_FIND_UPS_COMMANDS "${CONFIG_FIND_UPS_COMMANDS}
    find_ups_boost( ${minimum} )")
    set(cet_product_list boost ${cet_product_list})

    # convert vx_y_z to x.y.z
    string(REGEX REPLACE "v(.*)_(.*)_(.*)" "\\1.\\2.\\3" THISVER "${BOOST_VERS}")
    # find_package chokes on our trailing characters such as 1.57.0a, so these must be stripped
    string(REGEX REPLACE "v(.*)_(.*)_([0-9]+).*" "\\1.\\2.\\3" MATCHVER "${BOOST_VERS}")

    if(minimum)
      string(REGEX REPLACE "v(.*)_(.*)_(.*)" "\\1.\\2" MINVER "${minimum}")

      if(${THISVER} STRGREATER ${MINVER})
        #message( STATUS "find_ups_boost debug: Boost ${THISVER} meets minimum required version ${MINVER}")
      else()
        message(FATAL_ERROR "Boost ${THISVER} is less than minimum required version ${MINVER}")
      endif()
    endif()

    set(BOOST_STRING $ENV{SETUP_BOOST})
    string(REGEX MATCH "[-][q]" has_qual "${BOOST_STRING}")
    string(REGEX MATCH "[-][j]" has_j "${BOOST_STRING}")

    if(has_qual)
      if(has_j)
        string(REGEX REPLACE ".*([-][q]+ )(.*)[ *]([-][-j])" "\\2" BOOST_QUAL "${BOOST_STRING}" )
      else()
        string(REGEX REPLACE ".*([-][q]+ )(.*)" "\\2" BOOST_QUAL "${BOOST_STRING}")
      endif()

      string(REGEX REPLACE ":" ";" BOOST_QUAL_LIST "${BOOST_QUAL}")
      list(REMOVE_ITEM BOOST_QUAL_LIST debug opt prof)
      string(REGEX REPLACE ";" ":" BOOST_BASE_QUAL "${BOOST_QUAL_LIST}")
    else()
      message(STATUS "WARNING: Boost has no qualifier")
    endif()
    _cet_debug_message("find_ups_boost: Boost version and qualifier are ${BOOST_VERS} ${BOOST_QUAL}" )

    include_directories($ENV{BOOST_INC})

    # define the boost environment so we don't get system libraries
    set(BOOST_ROOT $ENV{BOOST_DIR})
    set(BOOST_INCLUDEDIR $ENV{BOOST_INC})
    set(BOOST_LIBRARYDIR $ENV{BOOST_LIB})
    set(Boost_USE_MULTITHREADED ON)
    #set(Boost_ADDITIONAL_VERSIONS "1.48" "1.48.0" "1.49" "1.49.0")
    set(Boost_NO_SYSTEM_PATHS ON)
    # search for Boost ${MATCHVER} or better libraries
    find_package(Boost ${MATCHVER} COMPONENTS ${boost_liblist})
  endif()
endmacro()

