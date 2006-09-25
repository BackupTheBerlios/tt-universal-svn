use strict;
use warnings;
use DBI;

sub trim($);
sub ltrim($);
sub rtrim($);
sub get_focus;

BEGIN {require "parameters.inc.pl"};

print $STAT_DB . "\n";
print $STAT_DB_USER . "\n";
print $STAT_DB_PASS . "\n";

print $LOG_TABLE . "\n";

print $STAT_STARTDIR . " x1 \n";
print $STAT_SAVEDIR . "\n";

print $FOC_IMPORTDIR . " x2 \n";
print $FOC_TABLENAME . "\n";

get_focus();

####################################################################

sub get_focus
{
print "Start\n";

opendir (DIR,"$STAT_STARTDIR/$FOC_IMPORTDIR") || die "Opendir not possible: $!";
my @filelist = grep { -f "$STAT_STARTDIR/$FOC_IMPORTDIR/$_" } readdir(DIR);
closedir DIR;
foreach my $file ( @filelist ) {
	 my	$INFILE_filename = "$STAT_STARTDIR/$FOC_IMPORTDIR/$file"; # input file name
     open ( INFILE, '<', $INFILE_filename ) or die  "$0 : failed to open input file $INFILE_filename : $!\n";
          while (<INFILE>){
               next if m/^\s*$/;        # Leerzeilen ignorieren
               next if m/^trunc/;       # truncatingzeilen ignorieren
               chomp;                   # zeilenvorschub raus
               my @zeile = split (/;/); #am semikolon auftrennen
               print "$.->";
               for(my $i=0;$i<=$#zeile;$i++) {
                    $i > 0 ? print "\;" : print "";
                    print trim($zeile[$i]);
               }
               print "\n";
          }
     close ( INFILE ) or warn "$0 : failed to close input file $INFILE_filename : $!\n";
} # -----  end foreach  -----
print "Ende\n";
}

sub trim($)
{
	my $string = shift;
	$string =~ s/^\s+//;
	$string =~ s/\s+$//;
	return $string;
}
# Left trim function to remove leading whitespace
sub ltrim($)
{
	my $string = shift;
	$string =~ s/^\s+//;
	return $string;
}
# Right trim function to remove trailing whitespace
sub rtrim($)
{
	my $string = shift;
	$string =~ s/\s+$//;
	return $string;
}
