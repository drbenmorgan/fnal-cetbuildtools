########################################################################
# cet_regex_escape(<val> <var> [<num>])
#
#   Escape the provided string to prevent interpretation by the CMake
#   regex engine.
#
# The optional <num> argument indicates the expected interpolation level
# for the resulting string. The default is 1. Every time the string is
# expected to be passed to a function or macro, increase <num> to ensure
# that "\" are correctly handled.
#
########################################################################
function(cet_regex_escape val var)    
  string(REGEX REPLACE "(\\.|\\||\\^|\\$|\\*|\\(|\\)|\\[|\\]|\\+)" "\\\\\\1" tmp "${val}")
  string(REGEX REPLACE "/+" "/" tmp "${tmp}")
  if (${ARGN})
    set(count ${ARGN})
    while (count GREATER 1) # Extra escapes for passing to macros.
      string(REPLACE "\\" "\\\\" tmp "${tmp}")
      math(EXPR count "${count} - 1")
    endwhile()
  endif()
  set(${var} "${tmp}" PARENT_SCOPE)
endfunction()
