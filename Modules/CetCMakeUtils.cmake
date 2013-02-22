# cet_cmake_utils
#
# macros to help build the cmake config file
# intened for internal use - and also for use by art cmake modules
# 

macro(cet_init_config_var)
  # initialize cmake config file fragments
  set(CONFIG_FIND_UPS_COMMANDS "
## find_ups_product directives
## remember that these are minimum required versions" 
      CACHE STRING "UPS product directives for config" FORCE)
  set(CONFIG_FIND_LIBRARY_COMMANDS "
## find_library directives" 
      CACHE STRING "find_library directives for config" FORCE)
  set(CONFIG_LIBRARY_LIST "" CACHE INTERNAL "libraries created by this package" )
  set(library_list "" CACHE STRING "list of product librares" FORCE)
  set(product_list "" CACHE STRING "list of ups products" FORCE)
  set(find_library_list "" CACHE STRING "list of find_library calls" FORCE)
endmacro(cet_init_config_var)

macro(cet_add_to_library_list libname)
     # add to library list for package configure file
     set(CONFIG_LIBRARY_LIST ${CONFIG_LIBRARY_LIST} ${libname}
	 CACHE INTERNAL "libraries created by this package" )
endmacro(cet_add_to_library_list)

