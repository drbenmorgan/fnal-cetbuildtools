# parse product_deps and qualifier_deps

# product_deps format:
#   parent this_product this_version
#   [incdir      product_dir	include]
#   [libdir      fq_dir	lib]
#   [bindir      fq_dir	bin]
#   product		version
#   dependent_product	dependent_product_version
#   dependent_product	dependent_product_version
#
# The indir, libdir, and bindir lines are optional
# Use them only if your product does not conform to the defaults
# Format: directory_type directory_path directory_name
# The only recognized values of the first field are incdir, libdir, and bindir
# The only recognized values of the second field are product_dir and fq_dir
# The third field is not constrained
#
# if dependent_product_version is a dash, the "current" version will be specified

sub parse_product_list {
  my @params = @_;
  open(PIN, "< $params[0]") or die "Couldn't open $params[0]";
  while ( $line=<PIN> ) {
    chop $line;
    if ( index($line,"#") == 0 ) {
    } else {
      @words = split(/\s+/,$line);
      if( $words[0] eq "parent" ) {
	 $prod=$words[1];
	 $ver=$words[2];
      } elsif( $words[0] eq "product" ) {
      } elsif( $words[0] eq "incdir" ) {
      } elsif( $words[0] eq "libdir" ) {
      } elsif( $words[0] eq "bindir" ) {
      } else {
	if( $words[1] eq "-" ) {
          $phash{ $words[0] } = "";
	} else {
          $phash{ $words[0] } = $words[1];
	}
      }
    }
  }
  close(PIN);
  return ($prod, $ver, %phash);
}

# qualifier_deps format:
#   parent this_product this_version
#   qualifier dependent_product       dependent_product notes
#   this_qual dependent_product_qual  dependent_product_qual
#   this_qual dependent_product_qual  dependent_product_qual
#
# Use as many rows as you need for the qualifiers
# Use a separate column for each dependent product that must be explicitly setup
# Do not list products which will be setup by a dependent_product

sub parse_qualifier_list {
  my @params = @_;
  ##print "\n";
  ##print "reading $params[2]\n";
  $irow=0;
  open(QIN, "< $params[2]") or die "Couldn't open $params[2]";
  while ( $line=<QIN> ) {
    chop $line;
    if ( index($line,"#") == 0 ) {
    } else {
      ##print "$line";
      @words=split(/\s+/,$line);
      if( $words[0] eq "parent" ) {
	 ##print "found parent\n";
	 if(( $words[1] ne $params[0] ) || ( $words[2] ne $params[1] )){
            print "ERROR: inconsistent lists\n";
	    print "       product_deps is for $params[0] $params[1]\n";
	    print "       but qualifier_deps is for $words[1] $words[2]\n";
	    exit 1;
	 }
      } elsif( $words[0] eq "qualifier" ) {
	 $qlen = $#words;
	 for $i ( 0 .. $#words ) {
	      if( $words[$i] eq "notes" ) {
		 $qlen = $i - 1;
	      }
	 }
	 if( $irow != 0 ) {
            print "ERROR: qualifier definition row must come before qualifier list\n";
	    exit 2;
	 }
	 ##print "there are $qlen product entries out of $#words\n";
	 for $i ( 0 .. $qlen ) {
	   $qlist[$irow][$i] = $words[$i];
	 }
	 $irow++;
      } else {
	 ##print "$params[0] qualifier $words[0]\n";
	 if( ! $qlen ) {
            print "ERROR: qualifier definition row must come before qualifier list\n";
	    exit 3;
	 }
	 if ( $#words < $qlen ) {
            print "ERROR: only $#words qualifiers for $words[0] - need $qlen\n";
	    exit 4;
	 }
	 for $i ( 0 .. $qlen ) {
	   $qlist[$irow][$i] = $words[$i];
	 }
	 $irow++;
      }
    }
  }
  close(QIN);
  ##print "found $irow qualifier rows\n";
  return ($qlen, @qlist);
}

sub get_include_directory {
  my @params = @_;
  $incdir = "default";
  open(PIN, "< $params[0]") or die "Couldn't open $params[0]";
  while ( $line=<PIN> ) {
    chop $line;
    if ( index($line,"#") == 0 ) {
    } else {
      @words = split(/\s+/,$line);
      if( $words[0] eq "incdir" ) {
         if( $words[1] eq "product_dir" ) {
	    $incdir = "\${UPS_PROD_DIR}/".$words[2];
         } elsif( $words[1] eq "fq_dir" ) {
	    $incdir = "\${\${UPS_PROD_NAME_UC}_FQ_DIR}/".$words[2];
	 } else {
	    print "ERROR: $words[1] is an invalid directory path\n";
	    print "ERROR: directory path must be specified as either \"product_dir\" or \"fq_dir\"\n";
	    print "ERROR: using the default include directory path\n";
	 }
      }
    }
  }
  close(PIN);
  print "defining include directory $incdir\n";
  return ($incdir);
}

sub get_bin_directory {
  my @params = @_;
  $bindir = "default";
  open(PIN, "< $params[0]") or die "Couldn't open $params[0]";
  while ( $line=<PIN> ) {
    chop $line;
    if ( index($line,"#") == 0 ) {
    } else {
      @words = split(/\s+/,$line);
      if( $words[0] eq "bindir" ) {
         if( $words[1] eq "product_dir" ) {
	    $bindir = "\${UPS_PROD_DIR}/".$words[2];
         } elsif( $words[1] eq "fq_dir" ) {
	    $bindir = "\${\${UPS_PROD_NAME_UC}_FQ_DIR}/".$words[2];
	 } else {
	    print "ERROR: $words[1] is an invalid directory path\n";
	    print "ERROR: directory path must be specified as either \"product_dir\" or \"fq_dir\"\n";
	    print "ERROR: using the default bin directory path\n";
	 }
      }
    }
  }
  close(PIN);
  print "defining executable directory $bindir\n";
  return ($bindir);
}

sub get_lib_directory {
  my @params = @_;
  $libdir = "default";
  open(PIN, "< $params[0]") or die "Couldn't open $params[0]";
  while ( $line=<PIN> ) {
    chop $line;
    if ( index($line,"#") == 0 ) {
    } else {
      @words = split(/\s+/,$line);
      if( $words[0] eq "libdir" ) {
         if( $words[1] eq "product_dir" ) {
	    $libdir = "\${UPS_PROD_DIR}/".$words[2];
         } elsif( $words[1] eq "fq_dir" ) {
	    $libdir = "\${\${UPS_PROD_NAME_UC}_FQ_DIR}/".$words[2];
	 } else {
	    print "ERROR: $words[1] is an invalid directory path\n";
	    print "ERROR: directory path must be specified as either \"product_dir\" or \"fq_dir\"\n";
	    print "ERROR: using the default include directory path\n";
	 }
      }
    }
  }
  close(PIN);
  print "defining library directory $libdir\n";
  return ($libdir);
}

1;
