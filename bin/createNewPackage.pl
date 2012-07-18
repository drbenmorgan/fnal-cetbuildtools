#!/bin/env perl
#
#  createNewPackage.pl
#
# this script assumes that you have a $BTEV/package-nameList/package-name.list file
# lines should be "packagename package-nametag"
# 
#  Usage:  createNewPackage.pl package-name working-directory

if( $#ARGV < 1 ) {
    print "Usage: createNewPackage.pl package-name working-directory \n";
    exit;
} else {
    $package = $ARGV[0];
    $workdir = $ARGV[1];
}

if( ! -d $workdir ) {
    print "cannot find $workdir\n";
    print "please \"mkdir -p $workdir\"\n";
    exit;
}

print "will create package skeleton for $package in $workdir\n";


