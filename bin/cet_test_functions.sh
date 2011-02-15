#!/bin/bash
########################################################################
# cet_test_functions.sh
################################
#
# Provide some functions used commonly by shell-script tests of CET
# code. This script must be sourced, not executed.
#
#
# Providing an option (see usage) will alter the behavior of the test
# functions on failure: return control to the souring function or exit
# the shell (the default).
#
#
# In addition, the variable ART_EXEC may be injected into the
# environment to influence the behavior of the run_art function to run a
# different Art exec than the default, "art."
#
# Available functions:

# check_command
#   Basic function to echo the command and execute it. This will rarely
# be called from user script directly but is used by other functions.
#
# check_exit
#   Run the provided command and check the exit code against $1 if it is
# numeric. If the first argument is not numeric the desired exit code
# is assumed to be 0.
#
# check_fail
#   Run the provided command and expect it to give a non-zero exit code.
#
# check_files
#   Ensure the provided arguments exist as files and are readable.
#
# run_art
#   Run the art executable (configurable via the environment variable
# ART_EXEC) with the second argument being the configuration file and
# all others passed verbatim. A numeric first argument will be swallowed
# by check_exit and treated as the desired exit value.
#
# fail_art
#   As run_art, but with an expected non-zero exit value and no
# permitted numeric first argument.
#
# Note that sourcing this script leaves the variable "cet_tf_leave" in
#  shell-local variable space: it should not be disturbed.
#
# 2011/02/15 CG.
########################################################################

cet_tf_leave=exit # Default behavior on check failure.

###################################
# cet_tf_usage
function cet_tf_usage() {
    cat 1>&2 <<EOF
usage: . cet_test_functions.sh [--exit-on-fail|--exit|-e|--return-on-fail|--return|-r]
       . cet_test_functions.sh --help|-h|-?
EOF
    return 1;
}

####################################
# Parse arguments.
cet_tf_temp=`getopt -o :erh\? -n "cet_test_functions.sh" --long --return-on-fail --long return --long exit-on-fail --long exit --long help -- "$@"`
eval set -- "$cet_tf_temp"
unset cet_tf_temp
while true; do
    case $1 in
        --exit-on-fail|--exit|-e)
        cet_tf_leave=exit;
        shift
        ;;
        --help|-h|-\?)
        cet_tf_usage
        return 1
        ;;
        --return-on-fail|--return|-r)
        cet_tf_leave=return;
        shift
        ;;
        --)
        shift
        break
        ;;
        *)
        cet_tf_usage
        return 1
        ;;
    esac
done
# Clear argument list
eval set --
# Variable / function pollution
unset cet_tf_usage

####################################
# check_command
function check_command() {
    echo "Invoking $@" 1>&2
    "$@"
    return $?
}

####################################
# check_exit
function check_exit() {
    local exit_code
    local status
    [[ -n "$1" ]] && [[ "$1" == [0-9]* ]] && { (( exit_code = $1 )); shift; }
    check_command "$@"
    (( status = $? ))
    (( status == ${exit_code:-0} )) || \
        { echo "${1} failed check: expected code ${exit_code}, got code ${status}." 1>&2; ${cet_tf_leave} ${status}; }
}

####################################
# check_fail
function check_fail() {
    check_command "$@"
    (( $? == 0 )) && \
        { echo "${1} failed check: expected non-zero exit code; got 0." 1>&2; ${cet_tf_leave} 1; }
    return 0
}

####################################
# check_files
function check_files() {
    local result
    local file
    (( result = 0 ))
    for file in "$@"; do
        [[ -r "$file" ]] || \
            { echo "Failed to find expected file \"$file\"" 1>&2;
            (( ++result )); }
    done
    if (( $result == 0 )); then
        return
    else
        echo "Failed to find $result files." 1>&2
        ${cet_tf_leave} 1
    fi
}

####################################
# run_art
function run_art() {
    check_exit ${ART_EXEC:-art} -c "$@" || $cet_tf_leave $?
}

####################################
# fail_art
function fail_art() {
    check_fail ${ART_EXEC:-art} -c "$@" || $cet_tf_leave $?
}
