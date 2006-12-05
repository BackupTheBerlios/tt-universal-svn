#!/usr/bin/perl
###########################################
# get_gls1.pl -- Import statistic from easylog into mysql tables
# Robert Krauss, 2006 (rk-hannover@gmx.de)
###########################################

my $debug = 1;              # set to 1 for debug print (for each .pl .pm separately)

use strict;
use warnings;
use DBI;
use File::Copy;
use Tt_global ();           #our own module for all relevant subroutines
use Tt_parameters ();       #our own module for global vars

sub get_gls1($);


$| = 1;                     # don't buffer STDOUT (for EPIC use)

#=============== MAIN =====================
if ($debug) {print get_timestamp()," ScriptStart!\n"};
get_gls1('160');
get_gls1('210');
if ($debug) {print get_timestamp()," ScriptEnde!\n"};
#=============== END MAIN =================


#GP27.10:
#302544502811|20061027|1417    |5,00    |        |680      |4597    |20061023|D          |68647  |0       |0       |1603752|Gemeinder Biblis|Frau Schmitt|     |Darmstädter Str. 25|Biblis|        |68647   |        |0        |
#carrierboxno|date1   |unknown1|unknown2|unknown3|unknown4 |unknown5|date2   |countrycode|zipcode|unknown6|unknown7|custno |name1           |name2       |name3|street             |city  |unknown8|zipcode2|unknown9|unknown10|
#
#Rmd27.10:
#302544502811|27.10.06|1417    |5       |        |4597     |4597    |23.10.06|D          |68647  |0       |0       |1603752|Gemeinder Biblis|Frau Schmitt|     |Darmstädter Str. 25|Biblis|        |        |11:59:54|         |
#carrierboxno|date1   |unknown1|unknown2|unknown3|unknown11|unknown5|date2   |countrycode|zipcode|unknown6|unknown7|custno |name1           |name2       |name3|street             |city  |unknown8|zipcode2|time    |unknown10|
#
#GPMON.10:
#23.10.2006|302544502446|20061023|1417    |50       |        |120     |3032    |20061020|D          |14776  |0       |0       |0        |BE Büromaschinen Etzien|Geschwister-Scholl-Str. 36|14776 Brandenburg|0943018   |
#date1     |carrierboxno|date1   |unknown1|unknown12|unknown3|unknown4|unknown5|date2   |countrycode|zipcode|unknown6|unknown7|unknown13|name1                  |street                    |city2            |shipmentno|
