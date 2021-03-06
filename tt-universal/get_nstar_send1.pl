#!/usr/bin/perl
###########################################
# get_nightstar_send1.pl -- Import statistic from easylog into mysql tables
# Robert Krauss, 2006 (rk-hannover@gmx.de)
###########################################

my $debug = 1;              # set to 1 for debug print (for each .pl .pm separately)

use strict;
use warnings;
use DBI;
use File::Copy;
use Tt_global ();           #our own module for all relevant subroutines
use Tt_parameters ();       #our own module for global vars


sub get_nightstar_send1($);


$| = 1;                     # don't buffer STDOUT (for EPIC use)

#=============== MAIN =====================
if ($debug) {print get_timestamp()," ScriptStart!\n"};
get_nightstar_send1('160');
get_nightstar_send1('210');
if ($debug) {print get_timestamp()," ScriptEnde!\n"};
#=============== END MAIN =================

