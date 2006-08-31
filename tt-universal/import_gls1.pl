use strict;
use warnings;

open (FILE,"d:\\down\\auftrag1.csv");
my @gls_file = <FILE>;

my @split_gls_file = split (/\/{5}GLS\/{5}/, $gls_file[0]);
my $anz = @split_gls_file;

my $anz_fields;
my @gls_line_fields;
my $datensatz;

print "Anzahl: $anz \n";

close(FILE);

for (my $i=0; $i < $anz; $i++)
	{
		my @gls_line_fields = split (/\|/,$split_gls_file[$i]);
		$anz_fields = @gls_line_fields;
			for (my $ii=0; $ii < $anz_fields; $ii++)
			{
			    $gls_line_fields[$ii] =~ s/T.*:(.*)/$1/;
#				print "\"", $gls_line_fields[$ii], "\"\,";
                $datensatz .= "\"" . $gls_line_fields[$ii] . "\"\,"
			}
		chop ($datensatz);
		print $datensatz,"\n";
		$datensatz = "";
	}

