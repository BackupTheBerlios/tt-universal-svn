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


$| = 1;                     # don't buffer STDOUT (for EPIC use)

#=============== MAIN =====================
if ($debug) {print get_timestamp()," ScriptStart!\n"};
# $timestamp = process_glsfile1_read('160');        # kdpaket.dat für lager 160 einlesen
# if ($timestamp gt 0 ) {                           # wenn was eingelesen wurde, auf doppelte aussendung prüfen
# $timestamp = '20070121132619'; #  20070120222752
$timestamp = '20070120222752';
	comp_p_out_gepart($timestamp);
	comp_p_out_dhl_easylog($timestamp);
	comp_p_out_nightstar($timestamp);
	writefile_p_out($timestamp,'160');
# }
#$timestamp = process_glsfile1_read('210');        # kdpaket.dat für lager 210 einlesen
#if ($timestamp gt 0 ) {                           # wenn was eingelesen wurde, auf doppelte aussendung prüfen
#	comp_p_out_gepart($timestamp);
#	comp_p_out_dhl_easylog($timestamp);
#	comp_p_out_nightstar($timestamp);
#}

# process_glsfile1_read('210');
#if (send_ftp2server ("d:/down/kdpaket.dat","$GLS_FTPUSER160","$GLS_FTPPASS160","$GLS_FTPHOST160","$GLS_FTPPATH160")) {
#     print "FTP hat geklappt\n";
#}
#else {
#     print "FTP FEHLGESCHLAGEN!\n";
#}
#if (get_fromftpserver ("kdpaket.dat","$GLS_FTPUSER160","$GLS_FTPPASS160","$GLS_FTPHOST160","$GLS_FTPPATH160","d:/down")) {
#     print "FTP holen hat geklappt\n";
#}
#else {
#     print "FTP holen FEHLGESCHLAGEN!\n";
#}

if ($debug) {print get_timestamp()," ScriptEnde!\n"};
#=============== END MAIN =================

