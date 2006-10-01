use strict;
use warnings;
use DBI;
use File::Copy;

sub trim($);
sub ltrim($);
sub rtrim($);
sub get_focus;
sub move2save($$$);

BEGIN {require "parameters.inc.pl"};

#print $STAT_DB . "\n";
#print $STAT_DB_USER . "\n";
#print $STAT_DB_PASS . "\n";
#
#print $LOG_TABLE . "\n";
#
#print $STAT_STARTDIR . " x1 \n";
#print $STAT_SAVEDIR . "\n";
#
#print $FOC_IMPORTDIR . " x2 \n";
#print $FOC_TABLENAME . "\n";

get_focus();
my $filename1 = "file1.file";
my $filename2 = "file2.file";
# move2save("$STAT_STARTDIR/$FOC_IMPORTDIR","$STAT_STARTDIR/$STAT_SAVEDIR","$filename2");
####################################################################

sub move2save($$$)
{
     my $from_dir = $_[0];
     my $to_dir = $_[1];
     my $file = $_[2];

     my ($sec,$min,$hour,$mday,$mon1,$year1,$wday,$ydat,$isdst)=localtime();         #aktuelle zeit holen
     my $mon = $mon1+1;
     my $year = $year1+1900;
     my $day = $mday;
     if (length($mon) == 1)
     {
         $mon="0$mon";                  #monate immer zweistellig
     }
     if (length($day) == 1)
     {
         $day="0$day";                  #tage immer zweistellig
     }
     if(length($hour) == 1)
     {
        $hour="0$hour";                 #stunden auch
     }
     if(length($min) == 1)
     {
        $min="0$min";                   #minuten auch
     }
     if(length($sec) == 1)
     {
        $sec="0$sec";                   #sekunden auch
     }
     my $timestamp = $year.$mon.$day.$hour.$min.$sec;       #zeitstempel bauen

     unless (-d $to_dir)                #save dir vorhanden?
     {
     mkdir $to_dir, 0777 or die "mkdir $to_dir not possibe! $!\n";
     }

     unless (-d "$to_dir/$year")        #jahr vorhanden?
     {
     mkdir "$to_dir/$year", 0777 or die "mkdir $to_dir/$year not possibe! $!\n";
     }

     unless (-d "$to_dir/$year/$mon")   #monat vorhanden?
     {
     mkdir "$to_dir/$year/$mon", 0777 or die "mkdir $to_dir/$year/$mon not possibe! $!\n";
     }

     print "Von: $from_dir \nNach: $to_dir/$year/$mon \nFilename im SUB: $file \nMonat: $mon Jahr: $year \n";
     move("$from_dir/$file","$to_dir/$year/$mon/$file\.$timestamp\.done") or die "move not possible! $!\n";
}

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
