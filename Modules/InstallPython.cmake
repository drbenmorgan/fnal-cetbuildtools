include(CMakeParseArguments)

function (_to_python_list OUTPUT_VAR PYTHON_VAR)
  if (PYTHON_VAR)
    set(tmp "${PYTHON_VAR}=[ ")
  else()
    set(tmp "[ ")
  endif()
  foreach (item ${ARGN})
    if (NOT item OR item MATCHES "[^-\\+0-9\\.]*([eE][-0-9]+)?")
      set(item "'${item}'")
    endif()
    set(tmp "${tmp}" "${item},")
  endforeach()
  string(REGEX REPLACE "(,| )$" " ]" tmp "${tmp}")
  set(${OUTPUT_VAR} "${tmp}" PARENT_SCOPE)
endfunction()

function (_nested_dependencies OUTPUT_VAR PACKAGE_SPEC)
  string(FIND "${PACKAGE_SPEC}" "." index)
  while (index GREATER -1)
    string(SUBSTRING "${PACAKGE_SPEC}" 0 index tmp)
    string(FIND "${PACKAGE_SPEC}" "." index)
  endwhile()
endfunction()

function(install_python)
  cmake_parse_arguments(IP
    "NO_INSTALL"
    "SETUP;NAME;VERSION"
    "SETUP_ARGS;SETUP_PREAMBLE;SCRIPTS;MODULES;PACKAGES;PACKAGE_DATA;DATA_FILES;EXTRA_DEPENDS"
    ${ARGN})
  if (NOT IP_SCRIPTS AND NOT IP_MODULES AND NOT IP_SETUP AND NOT PACKAGES)
    message(FATAL_ERROR "install_python called with no defined "
      "SCRIPTS, MODULES, PACKAGES or SETUP.")
  endif()
  if ((IP_SETUP AND IP_SETUP_ARGS) OR (IP_SETUP AND IP_SETUP_PREAMBLE))
    message(FATAL_ERROR "install_python: simultaneous specification of SETUP and SETUP_ARGS or SETUP and SETUP_PREAMBLE makes no sense.")
  endif()
  if (IP_PACKAGE_DATA AND NOT IP_PACKAGES)
    message(FATAL_ERROR "install_python: PACKAGE_DATA makes no sense without PACKAGES.")
  endif()
  if (NOT IP_NAME)
    set(IP_NAME ${product})
  endif()
  if (NOT IP_VERSION)
    set(IP_VERSION ${cet_dot_version})
  endif()
  if (IP_PACKAGES)
    set(packages "packages=[")
    foreach (package ${IP_PACKAGES})
      set(packages "${packages} '${package}',")
      _nested_dependencies(depends "${package}")
    endforeach()
  endif()
  if (IP_PACKAGE_DATA)
    cmake_parse_arguments(PD "" "ROOT" "PKG" ${IP_PACKAGE_DATA})
    if (PD_ROOT or PD_PKG)
      set(package_data "package_data={ ")
      if (PD_ROOT)
        set(package_data "${package_data} '': ")
        _to_python_list (package_data "" ${PD_ROOT})
        set(package_data "${package_data}, ")
      endif()
      foreach (this_pkg PD_PKG)
        list(GET this_pkg 0 tmp)
        set(package_data "${package_data} '${tmp}' : ")
        list(REMOVE_AT this_pkg 0) 
        _to_python_list (package_data "" ${this_pkg})
        set(package_data "${package_data}, ")
      endforeach()
      string(REGEX REPLACE "(, | )$" " }" tmp "${tmp}")
    endif()
  endif()
  if (IP_SCRIPTS)
    string(REGEX REPLACE "^(.*)" "${CMAKE_CURRENT_SOURCE_DIR}/\\1" IP_SCRIPTS ${IP_SCRIPTS})
    _to_python_list(scripts scripts ${IP_SCRIPTS})
    file(GLOB gscripts ${IP_SCRIPTS})
    list(APPEND depends ${gscripts})
    set(scripts "${scripts},")
  endif()
  if (IP_MODULES)
    _to_python_list(modules py_modules ${IP_MODULES})
    file(GLOB gmodules ${IP_MODULES})
    foreach (module ${IP_MODULES})
      set(modules "${modules} '${module}',")
      if (module MATCHES "([^\\.]+)\\.")
        list(APPEND depends "${CMAKE_MATCH_0}/__init__.py")
      else()
        list(APPEND depends "${CMAKE_CURRENT_SOURCE_DIR}/${module}.py")
      endif()
    endforeach()
    string(REGEX REPLACE ",$" " ]" modules "${modules}")
  endif()
  message(STATUS "depends = ${depends}")
  if (NOT IP_SETUP)
    SET(IP_SETUP "${CMAKE_CURRENT_BINARY_DIR}/setup.py")
    if (IP_SETUP_PREAMBLE)
      file(WRITE "${CMAKE_CURRENT_BINARY_DIR}/setup.py"
        ${IP_SETUP_PREAMBLE}
        )
    else()
      file(WRITE "${CMAKE_CURRENT_BINARY_DIR}/setup.py"
        "from distutils.core import setup, Extension\n"
        )
    endif()
    file(APPEND "${CMAKE_CURRENT_BINARY_DIR}/setup.py"
      "\n\n"
      "if __name__ == '__main__':\n"
      "  setup(name='${IP_NAME}',\n"
      "        version='${IP_VERSION}',\n"
      "        package_dir = {'': '${CMAKE_CURRENT_SOURCE_DIR}'},\n"
      "        ${scripts}\n"
      "        ${modules}"
      )
    if (IP_SETUP_ARGS)
      foreach(setup_arg ${IP_SETUP_ARGS})
        file(APPEND "${CMAKE_CURRENT_BINARY_DIR}/setup.py"
          ",\n"
          "        ${setup_arg}")
      endforeach()
    endif()
    file(APPEND "${CMAKE_CURRENT_BINARY_DIR}/setup.py" ")\n")
  endif()
  if (IP_EXTRA_DEPENDS)
    list(APPEND depends ${IP_EXTRA_DEPENDS})
  endif()
  list(REMOVE_DUPLICATES depends)
  add_custom_command(OUTPUT python_${IP_NAME}_timestamp
    COMMAND python "${IP_SETUP}" build
    COMMAND ${CMAKE_COMMAND} -E touch python_${IP_NAME}_timestamp
    DEPENDS "${IP_SETUP}" ${depends}
    )
  add_custom_target(python_${IP_NAME}_build
    ALL DEPENDS python_${IP_NAME}_timestamp
    )
  if (NOT IP_NO_INSTALL)
    install(CODE "execute_process(COMMAND python \"${IP_SETUP}\" install --prefix=${CMAKE_INSTALL_PREFIX}/${flavorqual_dir})")
  endif()
endfunction()
