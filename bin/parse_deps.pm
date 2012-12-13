# parse product_deps and qualifier_deps

# product_deps format:

#   parent this_product this_version
#   [incdir      product_dir	include]
#   [libdir      fq_dir	lib]
#   [bindir      fq_dir	bin]
#   product		version
#   dependent_product	dependent_product_version [optional]
#   dependent_product	dependent_product_version [optional]
#   qualifier dependent_product       dependent_product notes
#   this_qual dependent_product_qual  dependent_product_qual
#   this_qual dependent_product_qual  dependent_product_qual

# The indir, libdir, and bindir lines are optional
# Use them only if your product does not conform to the defaults
# Format: directory_type directory_path directory_name
# The only recognized values of the first field are incdir, libdir, and bindir
# The only recognized values of the second field are product_dir and fq_dir
# The third field is not constrained
#
# if dependent_product_version is a dash, the "current" version will be specified
# If a dependent product is optional, then add "optional" to the third field. 

#
# Use as many rows as you need for the qualifiers
# Use a separate column for each dependent product that must be explicitly setup
# Do not list products which will be setup by a dependent_product
#
# special qualifier options
# -	not installed for this parent qualifier
# -nq-	this dependent product has no qualifier
# -b-	this dependent product is only used for the build - it will not be in the table

sub parse_product_list {
  my @params = @_;
  open(PIN, "< $params[0]") or die "Couldn't open $params[0]";
  $get_phash="";
  $get_quals="";
  $get_fragment="";
  my $extra="none";
  while ( $line=<PIN> ) {
    chop $line;
    if ( index($line,"#") == 0 ) {
    } elsif ( $line !~ /\w+/ ) {
    } else {
      @words = split(/\s+/,$line);
      if( $words[0] eq "parent" ) {
	 $prod=$words[1];
	 $ver=$words[2];
	 if( $words[3] ) { $extra=$words[3]; }
	 $get_phash="";
         $get_quals="";
      } elsif( $words[0] eq "no_fq_dir" ) {
	 $get_phash="";
         $get_quals="";
      } elsif( $words[0] eq "incdir" ) {
	 $get_phash="";
         $get_quals="";
      } elsif( $words[0] eq "libdir" ) {
	 $get_phash="";
         $get_quals="";
      } elsif( $words[0] eq "bindir" ) {
	 $get_phash="";
         $get_quals="";
      } elsif( $words[0] eq "defaultqual" ) {
	 $get_phash="";
         $get_quals="";
	 $dq=@words[1];
      } elsif( $words[0] eq "only_for_build" ) {
	 $get_phash="";
         $get_quals="";
      } elsif( $words[0] eq "product" ) {
	 $get_phash="true";
         $get_quals="";
      } elsif( $words[0] eq "qualifier" ) {
	 $get_phash="";
         $get_quals="true";
      } elsif( $get_phash ) {
	if( $words[1] eq "-" ) {
          $phash{ $words[0] } = "";
	} else {
          $phash{ $words[0] } = $words[1];
	}
      } elsif( $words[0] eq "table_fragment_begin" ) {
         $get_fragment="true";
	 $get_phash="";
         $get_quals="";
      } elsif( $words[0] eq "table_fragment_end" ) {
         $get_fragment="";
	 $get_phash="";
         $get_quals="";
      } elsif( $get_quals ) {
      } elsif( $get_fragment ) {
      } else {
        print "parse_product_list: ignoring $line\n";
      }
    }
  }
  close(PIN);
  return ($prod, $ver, $extra, $dq, %phash);
}

sub parse_qualifier_list {
  my @params = @_;
  ##print "\n";
  ##print "reading $params[0]\n";
  my $efl = $params[1];
  $irow=0;
  $get_phash="";
  $get_quals="";
  $get_fragment="";
  open(QIN, "< $params[0]") or die "Couldn't open $params[0]";
  while ( $line=<QIN> ) {
    chop $line;
    if ( index($line,"#") == 0 ) {
    } elsif ( $line !~ /\w+/ ) {
    } else {
      ##print "$line\n";
      @words=split(/\s+/,$line);
      if( $words[0] eq "parent" ) {
	 $get_phash="";
         $get_quals="";
      } elsif( $words[0] eq "no_fq_dir" ) {
	 $get_phash="";
         $get_quals="";
      } elsif( $words[0] eq "incdir" ) {
	 $get_phash="";
         $get_quals="";
      } elsif( $words[0] eq "libdir" ) {
	 $get_phash="";
         $get_quals="";
      } elsif( $words[0] eq "bindir" ) {
	 $get_phash="";
         $get_quals="";
      } elsif( $words[0] eq "defaultqual" ) {
	 $get_phash="";
         $get_quals="";
      } elsif( $words[0] eq "only_for_build" ) {
	 $get_phash="";
         $get_quals="";
      } elsif( $words[0] eq "product" ) {
	 $get_phash="true";
         $get_quals="";
      } elsif( $words[0] eq "table_fragment_begin" ) {
         $get_fragment="true";
	 $get_phash="";
         $get_quals="";
      } elsif( $words[0] eq "table_fragment_end" ) {
         $get_fragment="";
	 $get_phash="";
         $get_quals="";
      } elsif( $words[0] eq "qualifier" ) {
	 $qlen = $#words;
	 $get_phash="";
         $get_quals="true";
	 for $i ( 0 .. $#words ) {
	      if( $words[$i] eq "notes" ) {
		 $qlen = $i - 1;
	      }
	 }
	 if( $irow != 0 ) {
            print $efl "echo ERROR: qualifier definition row must come before qualifier list\n";
            print $efl "return 2\n";
	    exit 2;
	 }
	 ##print "there are $qlen product entries out of $#words\n";
	 for $i ( 0 .. $qlen ) {
	   $qlist[$irow][$i] = $words[$i];
	 }
	 $irow++;
      } elsif( $get_phash ) {
      } elsif( $get_fragment ) {
      } elsif( $get_quals ) {
	 ##print "$params[0] qualifier $words[0]\n";
	 if( ! $qlen ) {
            print $efl "echo ERROR: qualifier definition row must come before qualifier list\n";
            print $efl "return 3\n";
	    exit 3;
	 }
	 if ( $#words < $qlen ) {
            print $efl "echo ERROR: only $#words qualifiers for $words[0] - need $qlen\n";
            print $efl "return 4\n";
	    exit 4;
	 }
	 for $i ( 0 .. $qlen ) {
	   $qlist[$irow][$i] = $words[$i];
	 }
	 $irow++;
      } elsif( $get_fragment ) {
	 print "$params[0] qualifier $words[0]\n";
      } else {
        print "parse_qualifier_list: ignoring $line\n";
      }
    }
  }
  close(QIN);
  ##print "found $irow qualifier rows\n";
  return ($qlen, @qlist);
}

sub find_optional_products {
  my @params = @_;
  open(PIN, "< $params[0]") or die "Couldn't open $params[0]";
  $get_phash="";
  $get_quals="";
  $get_fragment="";
  while ( $line=<PIN> ) {
    chop $line;
    if ( index($line,"#") == 0 ) {
    } elsif ( $line !~ /\w+/ ) {
    } else {
      @words = split(/\s+/,$line);
      if( $words[0] eq "parent" ) {
	 $get_phash="";
         $get_quals="";
      } elsif( $words[0] eq "no_fq_dir" ) {
	 $get_phash="";
         $get_quals="";
      } elsif( $words[0] eq "incdir" ) {
	 $get_phash="";
         $get_quals="";
      } elsif( $words[0] eq "libdir" ) {
	 $get_phash="";
         $get_quals="";
      } elsif( $words[0] eq "bindir" ) {
	 $get_phash="";
         $get_quals="";
      } elsif( $words[0] eq "defaultqual" ) {
	 $get_phash="";
         $get_quals="";
	 $dq=@words[1];
      } elsif( $words[0] eq "only_for_build" ) {
	 $get_phash="";
         $get_quals="";
      } elsif( $words[0] eq "product" ) {
	 $get_phash="true";
         $get_quals="";
      } elsif( $words[0] eq "table_fragment_begin" ) {
         $get_fragment="true";
	 $get_phash="";
         $get_quals="";
      } elsif( $words[0] eq "table_fragment_end" ) {
         $get_fragment="";
	 $get_phash="";
         $get_quals="";
      } elsif( $words[0] eq "qualifier" ) {
	 $get_phash="";
         $get_quals="true";
      } elsif( $get_phash ) {
	if ( $#words == 2 ) {
	   if(  $words[2] eq "optional" ) {
              $opthash{ $words[0] } = $words[2];
	   } else {
             $opthash{ $words[0] } = "";
	   }
	} else {
          $opthash{ $words[0] } = "";
	}
      } elsif( $get_fragment ) {
      } elsif( $get_quals ) {
      } else {
        print "find_optional_products: ignoring $line\n";
      }
    }
  }
  close(PIN);
  return (%opthash);
}

sub find_only_for_build_products {
  my @params = @_;
  my $count = 0;
  open(PIN, "< $params[0]") or die "Couldn't open $params[0]";
  while ( $line=<PIN> ) {
    chop $line;
    if ( index($line,"#") == 0 ) {
    } elsif ( $line !~ /\w+/ ) {
    } else {
      @words = split(/\s+/,$line);
      if( $words[0] eq "only_for_build" ) {
        ++$count;
	$ephash[$count][0] = $words[1];  
	if( $words[2] eq "-" ) {
	  $ephash[$count][1] = "";
	} else {
          $ephash[$count][1] = $words[2];
	}
      }
    }
  }
  close(PIN);
  return ($count,@ephash);
}

sub get_include_directory {
  my @params = @_;
  $incdir = "default";
  open(PIN, "< $params[0]") or die "Couldn't open $params[0]";
  while ( $line=<PIN> ) {
    chop $line;
    if ( index($line,"#") == 0 ) {
    } elsif ( $line !~ /\w+/ ) {
    } else {
      @words = split(/\s+/,$line);
      if( $words[0] eq "incdir" ) {
         if( $words[1] eq "product_dir" ) {
	    $incdir = "\${UPS_PROD_DIR}/".$words[2];
         } elsif( $words[1] eq "fq_dir" ) {
	    $incdir = "\${\${UPS_PROD_NAME_UC}_FQ_DIR}/".$words[2];
         } elsif( $words[1] eq "-" ) {
	    $incdir = "none";
	 } else {
	    print "ERROR: $words[1] is an invalid directory path\n";
	    print "ERROR: directory path must be specified as either \"product_dir\" or \"fq_dir\"\n";
	    print "ERROR: using the default include directory path\n";
	 }
      }
    }
  }
  close(PIN);
  ##print "defining include directory $incdir\n";
  return ($incdir);
}

sub get_bin_directory {
  my @params = @_;
  $bindir = "default";
  open(PIN, "< $params[0]") or die "Couldn't open $params[0]";
  while ( $line=<PIN> ) {
    chop $line;
    if ( index($line,"#") == 0 ) {
    } elsif ( $line !~ /\w+/ ) {
    } else {
      @words = split(/\s+/,$line);
      if( $words[0] eq "bindir" ) {
         if( $words[1] eq "product_dir" ) {
	    $bindir = "\${UPS_PROD_DIR}/".$words[2];
         } elsif( $words[1] eq "fq_dir" ) {
	    $bindir = "\${\${UPS_PROD_NAME_UC}_FQ_DIR}/".$words[2];
         } elsif( $words[1] eq "-" ) {
	    $bindir = "none";
	 } else {
	    print "ERROR: $words[1] is an invalid directory path\n";
	    print "ERROR: directory path must be specified as either \"product_dir\" or \"fq_dir\"\n";
	    print "ERROR: using the default bin directory path\n";
	 }
      }
    }
  }
  close(PIN);
  ##print "defining executable directory $bindir\n";
  return ($bindir);
}

sub get_lib_directory {
  my @params = @_;
  $libdir = "default";
  open(PIN, "< $params[0]") or die "Couldn't open $params[0]";
  while ( $line=<PIN> ) {
    chop $line;
    if ( index($line,"#") == 0 ) {
    } elsif ( $line !~ /\w+/ ) {
    } else {
      @words = split(/\s+/,$line);
      if( $words[0] eq "libdir" ) {
         if( $words[1] eq "product_dir" ) {
	    $libdir = "\${UPS_PROD_DIR}/".$words[2];
         } elsif( $words[1] eq "fq_dir" ) {
	    $libdir = "\${\${UPS_PROD_NAME_UC}_FQ_DIR}/".$words[2];
         } elsif( $words[1] eq "-" ) {
	    $libdir = "none";
	 } else {
	    print "ERROR: $words[1] is an invalid directory path\n";
	    print "ERROR: directory path must be specified as either \"product_dir\" or \"fq_dir\"\n";
	    print "ERROR: using the default include directory path\n";
	 }
      }
    }
  }
  close(PIN);
  ##print "defining library directory $libdir\n";
  return ($libdir);
}

sub check_fq_dir {
  my @params = @_;
  $fq = "true";
  open(PIN, "< $params[0]") or die "Couldn't open $params[0]";
  while ( $line=<PIN> ) {
    chop $line;
    if ( index($line,"#") == 0 ) {
    } elsif ( $line !~ /\w+/ ) {
      } elsif( $words[0] eq "table_fragment_begin" ) {
         $get_fragment="true";
	 $get_phash="";
         $get_quals="";
      } elsif( $words[0] eq "table_fragment_end" ) {
         $get_fragment="";
	 $get_phash="";
         $get_quals="";
    } else {
      @words = split(/\s+/,$line);
      if( $words[0] eq "no_fq_dir" ) {
         $fq = "";
      }
    }
  }
  close(PIN);
  ##print "defining library directory $libdir\n";
  return ($fq);
}

sub check_for_fragment {
  my @params = @_;
  $frag = "";
  $get_fragment="";
  $nfrag=0;
  open(PIN, "< $params[0]") or die "Couldn't open $params[0]";
  while ( $line=<PIN> ) {
    chop $line;
    if ( index($line,"#") == 0 ) {
      # comments might be part of a table fragment
      if ( $get_fragment ) {
	#print "found fragment $line\n";
	$fraglines[$nfrag] = $line;
	++$nfrag;
      }
    } elsif ( $line !~ /\w+/ ) {
      # empty lines might be part of a table fragment
      if ( $get_fragment ) {
	#print "found fragment $line\n";
	$fraglines[$nfrag] = $line;
	++$nfrag;
      }
    } else {
      @words = split(/\s+/,$line);
      if( $words[0] eq "table_fragment_begin" ) {
         $get_fragment="true";
         $frag = "true";
      } elsif( $words[0] eq "table_fragment_end" ) {
         $get_fragment="";
      } elsif( $get_fragment ) {
	#print "found fragment $line\n";
	$fraglines[$nfrag] = $line;
	++$nfrag;
      } else {
      }
    }
  }
  close(PIN);
  #print "found $nfrag table fragment lines\n";
  return ($frag,@fraglines);
}

sub find_default_qual {
  my @params = @_;
  $defq = "";
  open(PIN, "< $params[0]") or die "Couldn't open $params[0]";
  while ( $line=<PIN> ) {
    chop $line;
    if ( index($line,"#") == 0 ) {
    } elsif ( $line !~ /\w+/ ) {
    } else {
      @words = split(/\s+/,$line);
      if( $words[0] eq "defaultqual" ) {
         $defq = $words[1];
      }
    }
  }
  close(PIN);
  ##print "defining library directory $libdir\n";
  return ($defq);
}

sub cetpkg_info_file {
  ## write a file to be processed by CetCMakeEnv
  my @params = @_;
  $cetpkgfile = "cetpkg_variable_report";
  open(CPG, "> $cetpkgfile") or die "Couldn't open $cetpkgfile";
  print CPG "\n";
  print CPG "CETPKG_NAME     $params[0]\n";
  print CPG "CETPKG_VERSION  $params[1]\n";
  print CPG "CETPKG_DEFAULT_VERSION  $params[2]\n";
  print CPG "CETPKG_QUAL     $params[3]\n";
  print CPG "CETPKG_TYPE     $params[4]\n";
  close(CPG);
  return($cetpkgfile);  
}

sub print_setup_noqual {
  my @params = @_;
  my $efl = $params[3];
  if( $params[2] eq "optional" ) { 
  print $efl "# setup of $params[0] is optional\n"; 
  print $efl "unset have_prod\n"; 
  print $efl "ups exist $params[0] $params[1]\n"; 
  print $efl "test \"\$?\" = 0 && set_ have_prod=\"true\"\n"; 
  print $efl "test \"\$have_prod\" = \"true\" || echo \"will not setup $params[0] $params[1]\"\n"; 
  print $efl "test \"\$have_prod\" = \"true\" && setup -B $params[0] $params[1] \n";
  print $efl "unset have_prod\n"; 
  } else {
  print $efl "setup -B $params[0] $params[1] \n";
  }
  return 0;
}

sub print_setup_qual {
  my @params = @_;
  my $efl = $params[4];
  if( $params[3] eq "optional" ) { 
  print $efl "# setup of $params[0] is optional\n"; 
  print $efl "unset have_prod\n"; 
  print $efl "ups exist $params[0] $params[1] -q $params[2]\n"; 
  print $efl "test \"\$?\" = 0 && set_ have_prod=\"true\"\n"; 
  print $efl "test \"\$have_prod\" = \"true\" || echo \"will not setup $params[0] $params[1] -q $params[2]\"\n"; 
  print $efl "test \"\$have_prod\" = \"true\" && setup -B $params[0] $params[1] -q $params[2] \n";
  print $efl "unset have_prod\n"; 
  } else {
  print $efl "setup -B $params[0] $params[1] -q $params[2]\n";
	#print TSET "setup -B $qlist[0][$j] $phash{$qlist[0][$j]} -q $ql \n";
  }
  return 0;
}

sub compare_qual {
  my @params = @_;
  my @ql1 = split(/:/,$params[0]);
  my @ql2 = split(/:/,$params[1]);
  my $retval = 0;
  if( $#ql1 != $#ql2 ) { return $retval; }
  my $size = $#ql2 + 1;
  $qmatch = 0;
  foreach $i ( 0 .. $#ql1 ) {
    foreach $j ( 0 .. $#ql2 ) {
      if( $ql1[$i] eq $ql2[$j] )  { $qmatch++; }
    }
  }
  if( $qmatch == $size ) { $retval = 1; }
  return $retval;
}

sub check_flags {
  my @params = @_;
  my $type = uc $params[1];
  my $cxxflg = "";
  my $cflg = "";
  open(PIN, "< $params[0]") or die "Couldn't open $params[0]";
  while ( $line=<PIN> ) {
    chop $line;
    @words = split(/\s+/,$line);
    if ( $words[0] eq "CET_BASE_CXX_FLAG_${type}:" ) {
       $cxxflg = $words[1];
    } elsif ( $words[0] eq "CET_BASE_C_FLAG_${type}:" ) {
       $cflg = $words[1];
    }
  }
  close(PIN);
  return ($cxxflg,$cflg);
}

sub get_cmake_inc_directory {
  my @params = @_;
  $incdir = "DEFAULT";
  open(PIN, "< $params[0]") or die "Couldn't open $params[0]";
  while ( $line=<PIN> ) {
    chop $line;
    if ( index($line,"#") == 0 ) {
    } elsif ( $line !~ /\w+/ ) {
    } else {
      @words = split(/\s+/,$line);
      if( $words[0] eq "incdir" ) {
	 if( $#words < 2 ) {
	   $incsubdir = "include";
	 } else {
	   $incsubdir = $words[2];
	 }
         if( $words[1] eq "product_dir" ) {
	    $incdir = "\${product}/\${version}/$incsubdir";
         } elsif( $words[1] eq "fq_dir" ) {
	    $incdir = "\${flavorqual_dir}/$incsubdir";
         } elsif( $words[1] eq "-" ) {
	    $incdir = "NONE";
	 } else {
	    $incdir = "ERROR";
	 }
      }
    }
  }
  close(PIN);
  return ($incdir);
}

sub get_cmake_lib_directory {
  my @params = @_;
  $libdir = "DEFAULT";
  open(PIN, "< $params[0]") or die "Couldn't open $params[0]";
  while ( $line=<PIN> ) {
    chop $line;
    if ( index($line,"#") == 0 ) {
    } elsif ( $line !~ /\w+/ ) {
    } else {
      @words = split(/\s+/,$line);
      if( $words[0] eq "libdir" ) {
	 if( $#words < 2 ) {
	   $libsubdir = "lib";
	 } else {
	   $libsubdir = $words[2];
	 }
         if( $words[1] eq "product_dir" ) {
	    $libdir = "\${product}/\${version}/$libsubdir";
         } elsif( $words[1] eq "fq_dir" ) {
	    $libdir = "\${flavorqual_dir}/$libsubdir";
         } elsif( $words[1] eq "-" ) {
	    $libdir = "NONE";
	 } else {
	    $libdir = "ERROR";
	 }
      }
    }
  }
  close(PIN);
  return ($libdir);
}

sub get_cmake_bin_directory {
  my @params = @_;
  $bindir = "DEFAULT";
  open(PIN, "< $params[0]") or die "Couldn't open $params[0]";
  while ( $line=<PIN> ) {
    chop $line;
    if ( index($line,"#") == 0 ) {
    } elsif ( $line !~ /\w+/ ) {
    } else {
      @words = split(/\s+/,$line);
      if( $words[0] eq "bindir" ) {
	 if( $#words < 2 ) {
	   $binsubdir = "bin";
	 } else {
	   $binsubdir = $words[2];
	 }
         if( $words[1] eq "product_dir" ) {
	    $bindir = "\${product}/\${version}/$binsubdir";
         } elsif( $words[1] eq "fq_dir" ) {
	    $bindir = "\${flavorqual_dir}/$binsubdir";
         } elsif( $words[1] eq "-" ) {
	    $bindir = "NONE";
	 } else {
	    $bindir = "ERROR";
	 }
      }
    }
  }
  close(PIN);
  return ($bindir);
}

1;
