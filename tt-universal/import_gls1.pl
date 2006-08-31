use strict;
use warnings;

$|=1;

my $anz_fields;
my @gls_line_fields;
my $datensatz;
my $uvz = "G:/win_data/projekte/spicers/muster-csv-gls";

my	$OUTFILE_filename = $uvz."/alles-drin.txt"; # output file name

open ( OUTFILE, '>', $OUTFILE_filename ) or die  "$0 : failed to open  output file $OUTFILE_filename : $!\n";

opendir(DIR, $uvz);
my @Eintraege = readdir(DIR);
closedir(DIR);

foreach(@Eintraege) {
  if (/.csv/i){
     open (FILE,$uvz."/".$_) || die "File $_ nicht gefunden\n";
     my @gls_file = <FILE>;

     my @split_gls_file = split (/\/{5}GLS\/{5}/, $gls_file[0]);
     my $anz = @split_gls_file;

     print "Anzahl: $anz \n";

     close(FILE);

     for (my $i=0; $i < $anz; $i++)
     	{
     		my @gls_line_fields = split (/\|/,$split_gls_file[$i]);
     		$anz_fields = @gls_line_fields;
     			for (my $ii=0; $ii < $anz_fields; $ii++)
     			{
     			    $gls_line_fields[$ii] =~ s/T.*:(.*)/$1/;
                    $datensatz .= "\"" . $gls_line_fields[$ii] . "\"\,"
     			}
     		chop ($datensatz);
     		print OUTFILE $datensatz,"\n";
     		$datensatz = "";
     	}
  }
}
close ( OUTFILE ) or warn "$0 : failed to close output file $OUTFILE_filename : $!\n";
