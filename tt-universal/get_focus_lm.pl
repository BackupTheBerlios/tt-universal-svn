#!/usr/bin/perl
###########################################
# get_focus_lm.pl -- Import statistic data into mysql tables
# Robert Krauss, 2006 (rk-hannover@gmx.de)
###########################################

use strict;
use warnings;
use DBI;
use File::Copy;
use Tt_global ();           #our own module for all relevant subroutines
use Tt_parameters ();       #our own module for global vars

$| = 1;                     # don't buffer STDOUT

#=============== MAIN =====================
print get_timestamp()," ScriptStart!\n";
get_focus();
get_lm1();
print get_timestamp()," Scriptende!\n";
#=============== END MAIN =================
