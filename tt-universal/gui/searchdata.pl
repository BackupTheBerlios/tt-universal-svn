#!/usr/bin/perl
my $debug = 1;              # set to 1 for debug print (for each .pl .pm separately)

use strict;
use warnings;
use lib ('/spicers/scripts/perl');
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

# Runmodes
if ($level eq 'start') {
    # Suchformular ausgeben
    showsearchform ();
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
print "<br>Fertig.<br>";
print $q->end_html();

#=============== END MAIN =====================


#my $table = DBIx::XHTML_Table->new($dbhandle1);
#
#$table->exec_query(' select distinct b.custno, b.shipmentno, b.picklistno, b.lmboxno, b.carrier
#from lm1_data b where b.custno = ? order by b.picklistno ',[$custno]);
#
#$table->modify(table => { border => 1 });
#$table->set_group('custno',1);
## $table->set_group('shipmentno',1);
## $table->set_group('picklistno',1);
## $table->set_group('lmboxno',1);
#$table->set_row_colors(['#d0d0d0','#f0f0f0']);
#
#print $table->output();
#
#my @hash_ref = $dbhandle1->fetchall_hashref('shipmentno');
#foreach my $hash_string ( @hash_ref ) {
#	print "Wert: $hash_string </br>\n";
#} # -----  end foreach  -----

#my $select1 = "select distinct b.carrier, b.lmboxno, b.picklistno, b.shipmentno, b.custno
#from lm1_data b where b.picklistno in (
#SELECT distinct a.picklistno
#FROM focus_data a
#where a.custno = 1605528
#and a.status=2
#)
#order by b.picklistno ";
