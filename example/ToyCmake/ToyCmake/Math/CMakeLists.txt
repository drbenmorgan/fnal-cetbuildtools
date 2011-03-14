
set( ToyMath_sources DoMath.cc )

# how to link with boost and other system libraries
#link_libraries( ${Boost_FILESYSTEM_LIBRARY}
#                ${REFLEX}
#                dl )

# we only build a shared library
add_library(ToyMath SHARED ${ToyMath_sources} )

install ( TARGETS ToyMath DESTINATION ${flavorqual_dir}/lib )
install(FILES DoMath.h
        DESTINATION ${product}/${version}/include/ToyCmake/Math )

install_source()
