#!/usr/bin/perl
###########################################
# gui1.pl -- query mysql tables for parcel data
# Robert Krauss, 2006 (rk-hannover@gmx.de)
###########################################

my $debug = 1;              # set to 1 for debug print (for each .pl .pm separately)

use strict;
use warnings;
use DBI;
use File::Copy;
use lib ('../', './tt-gui/');
use CGI;
use Tt_global;           #our own module for all relevant subroutines
use Tt_parameters;       #our own module for global vars




$| = 1;                     # don't buffer STDOUT (for EPIC use)

#=============== MAIN =====================
print "Content-type:text/html\n\n";

if ($debug) {print get_timestamp()," ScriptStart!\n"};

my $STAT_DB = 's_stat';        #Name der Stat Datenbank
my $DB_HOST = 'localhost';		#Rechnername auf dem die MySQL DB liegt
my $DB_TYPE = 'DBI:mysql:'.$STAT_DB.':'.$DB_HOST;	#DBI Zugriffsparameter für mysql

my $STAT_DB_USER = 'root';    #Username für zugriff auf DB
my $STAT_DB_PASS = '';        #passwort für zugriff auf DB
my $dbh = DBI->connect($DB_TYPE, $STAT_DB_USER, $STAT_DB_PASS, {RaiseError => 0}) or die "Database connection not made: $DBI::errstr";



sub suchformular_ausgeben {
    print '<form action="gui1.pl" method="post">';
    print '<input type="hidden" name="level" value="run_search" />';
    print 'Kundennummer<input type="text" name="custno" /><br />';
    print '<input type="submit" name="Suche starten" />'
}

sub suche_starten {
 my $custno = shift;
     my $sql = "SELECT * FROM `lm1_data` WHERE custno =$custno";

     # my  $hash_ref = $dbh->selectall_hashref($sql);
     my $sth = $dbh->prepare($sql);
     $sth->execute();
     tabelle_ausgeben( $sth );
}

sub tabelle_ausgeben {
    my $sth = shift;
    print "\n<table border='1'>";
    print "\n<tr><th>stockno</th><th>custno</th><th>picklistno</th><th>shipmentno</th></tr>";
    while (my  $hash_ref = $sth->fetchrow_hashref) {
        print "<tr>";
        print "<td>$hash_ref->{stockno}</td\n>";
        print "<td>$hash_ref->{custno}</td>\n";
        print "<td>$hash_ref->{picklistno}</td>\n";
        print "<td><a target='_blank' href='gui1.pl?level=get_by_sno;sno=$hash_ref->{shipmentno}'>$hash_ref->{shipmentno}</a></td>\n";
        print "</tr>";
    }
    print "</table>\n";
}

sub get_by_shipmentno {
    my $shipmentno = shift;
    print "foo";
}

my $q = CGI->new();
my $level = $q->param('level') || 'start';

print $q->header();
print '<html><head><title>foo!</title></head><body>';

# Runmodes
if ($level eq 'start') {
    # Suchformular ausgeben
    suchformular_ausgeben();
}
elsif ($level eq 'run_search') {
    suche_starten( $q->param('custno') );
}
elsif ($level eq 'get_by_sno') {
    get_by_shipmentno( $q->param('sno') );
}
else { # unbekannter Runmode
    print 'Fehler';
}

print '</body></html>';
if ($debug) {print get_timestamp()," ScriptEnde!\n"};
#=============== END MAIN =================