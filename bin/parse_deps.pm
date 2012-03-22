# parse product_deps and qualifier_deps


sub parse_product_list {
  my @params = @_;
  open(PIN, "< $params[0]") or die "Couldn't open $params[0]";
  while ( $line=<PIN> ) {
    chop $line;
    @words = split(/\s+/,$line);
    if( $words[0] eq "parent" ) {
       $prod=$words[1];
       $ver=$words[2];
    } elsif( $words[0] eq "product" ) {
    } else {
      $phash{ $words[0] } = $words[1];
    }
  }
  close(PIN);
  return ($prod, $ver, %phash);
}

sub parse_qualifier_list {
  my @params = @_;
  ##print "\n";
  ##print "reading $params[2]\n";
  $irow=0;
  open(QIN, "< $params[2]") or die "Couldn't open $params[2]";
  while ( $line=<QIN> ) {
    @words=split(/\s+/,$line);
    ##print "$line";
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
  close(QIN);
  ##print "found $irow qualifier rows\n";
  return ($qlen, @qlist);
}

1;

