# find and define information for users of art
#
# find_ups_art( minimum  [list of libraries] )
#  version - minimum version required

include(CheckUpsVersion)

macro( find_ups_art minimum  )

  find_ups_product( art ${minimum} )

endmacro( find_ups_art )
