PRODUCTS := scd-ssi-build.pdf

TEXINPUTS := $(filter %DocumentTemplates/include, $(.INCLUDE_DIRS))//:
export TEXINPUTS

# Make sure make can find this by invoking make with correct -I<path>.
include latex.mk
