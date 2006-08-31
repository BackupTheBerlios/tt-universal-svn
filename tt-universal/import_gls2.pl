#!/usr/bin/perl

use strict;
use warnings;

use Data::Dumper;
# $Data::Dumper::Indent = 0;
$Data::Dumper::Terse = 1;

open (FILE,"d:\\down\\auftrag1.csv");
{
   local $/ = '/////GLS/////'; #/
   while (<FILE>) {
       s/^\\+\w+\\+//g;
       s/\/+\w+\/+$//g;
       print Dumper [split /\|/, $_];
   }
}
