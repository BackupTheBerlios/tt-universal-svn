#!D:/programme/xampp/perl/bin/perl.exe

# print "Hello World\n";
# print "again.\n";

use strict;
use cgi;


my $s = "Hello";
my $t = "$s World";
print "Content-type: text/plain; charset=iso-8859-1\n\n";

print $t;


