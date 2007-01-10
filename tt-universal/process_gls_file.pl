#!/usr/bin/perl
###########################################
# process_gls_file.pl -- Process gls files kdpaket.dat
# Robert Krauss, 2006 (rk-hannover@gmx.de)
###########################################

my $debug = 1;              # set to 1 for debug print (for each .pl .pm separately)

use strict;
use warnings;
use lib ('/spicers/scripts/perl');
use lib ('D:/programme/EasyEclipse-LAMP102/workspace/tt-universal');
use lib ('C:/Programme/EasyEclipse-LAMP102/workspace/tt-universal');
use Tt_global;           #our own module for all relevant subroutines
use Tt_parameters;       #our own module for global vars
use DBI;
use File::Copy;
use Net::FTP;

# http://www.tekromancer.com/perl2/12_1.html
# http://www.schockwellenreiter.de/perl/ftp.html

my $STAT_DB = 's_stat';        #Name der Stat Datenbank
my $DB_HOST = 'localhost';		#Rechnername auf dem die MySQL DB liegt
my $DB_TYPE = 'DBI:mysql:'.$STAT_DB.':'.$DB_HOST;	#DBI Zugriffsparameter für mysql

my $STAT_DB_USER = 'root';    #Username für zugriff auf DB
my $STAT_DB_PASS = '';        #passwort für zugriff auf DB




$| = 1;                     # don't buffer STDOUT (for EPIC use)

#=============== MAIN =====================
if ($debug) {print get_timestamp()," ScriptStart!\n"};
process_glsfile1('160');
# process_glsfile1('210');
if ($debug) {print get_timestamp()," ScriptEnde!\n"};
#=============== END MAIN =================



