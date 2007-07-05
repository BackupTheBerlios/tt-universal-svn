#!/usr/bin/perl
my $debug = 1;              # set to 1 for debug print (for each .pl .pm separately )

use strict;
use warnings;
use lib ('/spicers/scripts/perl');
use lib ('/Users/rk/workspace/tt-universal');
use lib ('D:/programme/EasyEclipse-LAMP102/workspace/tt-universal');
use lib ('C:/Programme/EasyEclipse-LAMP102/workspace/tt-universal');
use DBI;
use File::Copy;
use CGI qw(:all);
use Tt_parameters;       #our own module for global vars
use Tt_global;           #our own module for all relevant subroutines
use Tt_gui;              #our own module for browser gui stuff
use CGI::Carp qw(fatalsToBrowser);
use CGI::FormBuilder;
use CGI::FormBuilder::Messages;

# use DBIx::XHTML_Table;

$| = 1;                     # don't buffer STDOUT (for EPIC use)

#=============== MAIN =====================
my $q = CGI->new();
my $level = $q->param('level') || 'start';


print $q->header();
print $q->start_html("trackandtrace Suchseite");
print $q->h1( "trackandtrace Suchseite" );
print $q->a({-href=>"http://stat.spicers.de/wiki/index.php/Hilfeseite_trackandtrace",-target=>'_new'},"Hilfe zu diesem Formular ( &ouml;ffnet in neuem Fenster)");
print "<br><br>\n";

# Runmodes
if ($level eq 'start') {
    # Suchformular ausgeben
    showsearchform2 ();
#TODO showsearchform2 aufruf anpassen
}
elsif ($level eq 'scl') {                         #scd show cono level 1
    show_cono_level1( $q->param('custno'), $q->param('partno') );
}
elsif ($level eq 'scd') {                         #scd show cono detail
    show_cono_detail( $q->param('cono') );
}
else { # unbekannter Runmode
    print '<br>Runmode Fehler <br>';
}
# print "<br>Fertig.<br>";
print $q->end_html();

#=============== END MAIN =====================

