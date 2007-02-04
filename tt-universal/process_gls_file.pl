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
use lib ('D:/EasyEclipseLAMP102/workspace/tt');
use Tt_global;           #our own module for all relevant subroutines
use Tt_parameters;       #our own module for global vars
use DBI;
use File::Copy;
use Net::FTP;

my $timestamp;
my $transfer_ok = 0;
my $transferfile;             #file with path to send


$| = 1;                     # don't buffer STDOUT (for EPIC use)

#=============== MAIN =====================
if ($debug) {print get_timestamp()," ScriptStart!\n"};
$timestamp = process_glsfile1_read('160');        # kdpaket.dat für lager 160 einlesen
if ($timestamp gt 0 ) {                           # wenn was eingelesen wurde, auf doppelte aussendung prüfen
	comp_p_out_gepart($timestamp);                #mit gepart vergleichen
	comp_p_out_dhl_easylog($timestamp);           #mit easylog vergleichen
	comp_p_out_nightstar($timestamp);             #mit nightstar vergleichen
	$transfer_ok = writefile_p_out($timestamp,'160');
	if ($transfer_ok eq '1') {                 # wenn ein gültiger wert zurückgegeben wird...
         print "Transfer OK. Retvalue = $transfer_ok\n";
         update_p_out_sent_ok($timestamp,'160');  #versand der kdpaket.dat in der tabelle vermerken
    }
    else {
         print "Transfer 160 NOT OK? Retvalue = $transfer_ok\n";
    }
}
else {
    print "160. Kein Timestamp. Nichts eingelesen.\n";

}

$timestamp = process_glsfile1_read('210');        # kdpaket.dat für lager 210 einlesen
if ($timestamp gt 0 ) {                           # wenn was eingelesen wurde, auf doppelte aussendung prüfen
	comp_p_out_gepart($timestamp);
	comp_p_out_dhl_easylog($timestamp);
	comp_p_out_nightstar($timestamp);
	$transfer_ok = writefile_p_out($timestamp,'210');
	if ($transfer_ok eq '2') {                 # wenn ein gültiger wert zurückgegeben wird...
         print "Transfer OK. Retvalue = $transfer_ok\n";
         update_p_out_sent_ok($timestamp,'210');
    }
    else {
         print "Transfer 210 NOT OK? Retvalue = $transfer_ok\n";
    }
}
else {
    print "210. Kein Timestamp. Nichts eingelesen.\n";
}

if ($debug) {print get_timestamp()," ScriptEnde!\n"};
#=============== END MAIN =================

