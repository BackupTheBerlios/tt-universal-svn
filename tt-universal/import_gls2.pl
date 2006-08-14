#!/usr/bin/perl

use strict;
use warnings;

use Data::Dumper;

open (FILE,"d:\\down\\auftrag1.csv");
{
   local $/ = '/////GLS/////'; #/
   while (<FILE>) {
       s/^\\+\w+\\+//g;
       s/\/+\w+\/+$//g;
       print Dumper [split /\|/, $_];
   }
}
