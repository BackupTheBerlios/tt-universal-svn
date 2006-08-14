use strict;
use warnings;

open (FILE,"d:\\down\\auftrag1.csv");
my @gls_file = <FILE>;
my $split_string = "\/{5}GLS\/{5}";
my @split_gls_file = split (/\/{5}GLS\/{5}/, $gls_file[0]);
my $anz = @split_gls_file;
my $anz_fields;
my $gls_import_line;
my @gls_line_fields;

print "Anzahl: $anz \n";

close(FILE);

for (my $i=0; $i < $anz; $i++)
	{
		my @gls_line_fields = split (/\|/,$split_gls_file[$i]);
		$anz_fields = @gls_line_fields;
			for (my $ii=0; $ii < $anz_fields; $ii++)
			{
				print "Feld $ii ==> $gls_line_fields[$ii]\n";
			}
	}

