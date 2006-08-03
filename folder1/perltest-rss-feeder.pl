use strict;
use warnings;
use XML::RSS;
use LWP::UserAgent;
my $ua = LWP::UserAgent->new();
my $feeds = { "MCslp" => 'http://www.mcslp.com/wp-rss2.php' };
foreach my $feed ( sort keys %{$feeds} ) {
	my ($rss) = parse_rss_fromurl( $feeds, $ua, $feed );
	parse_items_to_text($rss);
}

sub parse_rss_fromurl {
	my $feeds    = shift;
	my $ua       = shift;
	my $feed     = shift;
	my $response = $ua->get( $feeds->{$feed} );
	my $rss;
	if ( $response->is_success ) {
		$rss = XML::RSS->new();
		$rss->parse( $response->{_content} );
	}
	return ($rss);
}

sub parse_items_to_text {
	my ($feed) = @_;
	foreach my $i ( @{ $feed->{items} } ) {
		next unless defined($i);
		my $len = length( $i->{"title"} );
		print( $i->{"title"}, "\n", ( '=' x $len ),
			"\n", $i->{"description"}, "\n\n", $i->{"link"}, "\n\n" );
	}
}
