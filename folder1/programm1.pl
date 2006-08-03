$kekse = "";

print "Test.\n";

while ( $kekse ne "KEKSE") {
	print "ich will KEKSE: ";
	chomp($kekse = <STDIN>);
	}

print "Mmmm. KEKSE.\n";