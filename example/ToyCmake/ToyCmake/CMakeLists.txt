
set( ToyCmake_sources DoMath.cc )

#link_libraries( ${Boost_FILESYSTEM_LIBRARY}
#                ${REFLEX}
#                dl )

add_library(ToyCmake SHARED ${ToyCmake_sources} )

add_executable( SquareIt   SquareIt.cpp   )
target_link_libraries( SquareIt ToyCmake )

install ( TARGETS ToyCmake DESTINATION ${flavorqual_dir}/lib )
install(FILES DoMath.h
        DESTINATION ${version}/include/ToyCmake )
install ( TARGETS SquareIt   DESTINATION ${flavorqual_dir}/bin )


