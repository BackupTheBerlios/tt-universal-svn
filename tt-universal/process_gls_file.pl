#!/usr/bin/perl
###########################################
# process_gls_file.pl -- Process gls files kdpaket.dat
# Robert Krauss, 2006 (rk-hannover@gmx.de)
###########################################

my $debug = 1;              # set to 1 for debug print (for each .pl .pm separately)

use strict;
use warnings;
use lib ('D:/EasyEclipseLAMP102/workspace/tt');
use Tt_global;           #our own module for all relevant subroutines
use Tt_parameters;       #our own module for global vars
use DBI;
use File::Copy;
use Net::FTP;

# http://www.tekromancer.com/perl2/12_1.html


$| = 1;                     # don't buffer STDOUT (for EPIC use)

#=============== MAIN =====================
if ($debug) {print get_timestamp()," ScriptStart!\n"};
process_glsfile1('160');
# process_glsfile1('210');
if ($debug) {print get_timestamp()," ScriptEnde!\n"};
#=============== END MAIN =================



