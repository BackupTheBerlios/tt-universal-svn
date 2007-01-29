#!/usr/bin/perl
###########################################
# get_focus_lm.pl -- Import statistic data into mysql tables
# Robert Krauss, 2006 (rk-hannover@gmx.de)
###########################################

my $debug = 1;              # set to 1 for debug print (for each .pl .pm separately)

use strict;
use warnings;
use DBI;
use File::Copy;
use Tt_global;           #our own module for all relevant subroutines
use Tt_parameters;       #our own module for global vars



$| = 1;                     # don't buffer STDOUT (for EPIC use)

#=============== MAIN =====================
if ($debug) {print get_timestamp()," ScriptStart!\n"};
get_focus();
get_lm1();
if ($debug) {print get_timestamp()," ScriptEnde!\n"};
#=============== END MAIN =================
# ALTER TABLE `focus_data` ADD INDEX ( `custno` ) ;
# ALTER TABLE `focus_data` ADD INDEX ( `partno` ) ;
# ALTER TABLE `focus_data` ADD INDEX ( `picklistno` ) ;
# ALTER TABLE `focus_data` ADD INDEX ( `shipmentno` ) ;
# ALTER TABLE `focus_data` ADD INDEX ( `stocknosu` ) ;
# ALTER TABLE `focus_data` ADD INDEX ( `status` ) ;
# ALTER TABLE `lm1_data` ADD INDEX ( `lmboxno` ) ;
# ALTER TABLE `lm1_data` ADD INDEX ( `picklistno` ) ;
# ALTER TABLE `lm1_data` ADD INDEX ( `shipmentno` ) ;
# ALTER TABLE `lm1_data` ADD INDEX ( `custno` ) ;