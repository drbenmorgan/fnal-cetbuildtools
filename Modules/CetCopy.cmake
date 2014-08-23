########################################################################
# cet_copy
#
# Simple internal copy target to (hopefully) avoid triggering a CMake
# whenfiles have changed.
#
# Usage: cet_copy(<sources>... DESTINATION <dir> [options])
#
####################################
# Options:
#
# DEPENDENCIES <deps>...
#
#   If any <deps> change, the file shall be re-copied (the source file
#   itself is always a dependency).
#
# NAME
#
#   New name for the file in its final destination.
#
# PROGRAMS
#
#   Copied files should be made executable.
#
# WORKING_DIRECTORY <dir>
#
#   Paths are relative to the specified directory (default
#   CMAKE_CURRENT_BINARY_DIR).
#
####################################
# Notes
#
# For PROGRAMS, custom commands using them will be updated when the
# program changes if one lists the script in the DEPENDS list of the
# custom command.
########################################################################
include (CMakeParseArguments)
function (cet_copy)
  cmake_parse_arguments(CETC "PROGRAMS"
    "DESTINATION;NAME;WORKING_DIRECTORY"
    "DEPENDENCIES"
    ${ARGN})
  if (NOT CETC_DESTINATION)
    message(FATAL_ERROR "Missing required option argument DESTINATION")
  endif()
  if (NOT CETC_WORKING_DIRECTORY)
    set(CETC_WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR})
  endif()
  foreach (source ${CETC_UNPARSED_ARGUMENTS})
    if (CETC_NAME)
      set(dest_path "${CETC_DESTINATION}/${CETC_NAME}")
    else()
      get_filename_component(source_base "${source}" NAME)
      set(dest_path "${CETC_DESTINATION}/${source_base}")
    endif()
    string(REPLACE "/" "+" target "${dest_path}")
    add_custom_command(OUTPUT "${dest_path}"
      WORKING_DIRECTORY "${CETC_WORKING_DIRECTORY}"
      COMMAND ${CMAKE_COMMAND} -E copy "${source}" "${dest_path}"
      DEPENDS "${source}" ${CETC_DEPENDENCIES}
      )
    if (CETC_PROGRAMS)
      add_custom_command(OUTPUT "${dest_path}"
        COMMAND chmod +x "${dest_path}"
        APPEND
        )
    endif()
    add_custom_target(${target} ALL DEPENDS "${dest_path}")
  endforeach()
endfunction()
