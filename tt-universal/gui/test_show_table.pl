use strict;
use warnings;
use DBI;
use CGI qw(:all);


my $STAT_DB = 's_stat';        #Name der Stat Datenbank
my $DB_HOST = 'localhost';		#Rechnername auf dem die MySQL DB liegt
my $DB_TYPE = 'DBI:mysql:'.$STAT_DB.':'.$DB_HOST;	#DBI Zugriffsparameter für mysql
my $STAT_DB_USER = 'root';    #Username für zugriff auf DB
my $STAT_DB_PASS = '';        #passwort für zugriff auf DB

my $dbh = DBI->connect($DB_TYPE, $STAT_DB_USER, $STAT_DB_PASS, {RaiseError => 0}) or die "Database connection not made: $DBI::errstr";

my $select1 = "SELECT distinct cono, date_format(priodate,'%d.%m.%Y') as 'date' FROM focus_data
where custno = '1603435' and status = '2' order by cono";
my $sth = $dbh->prepare($select1);
$sth->execute();

my $q = CGI->new();
print $q->header();
print $q->start_html("Test1");
print $q->h1( "Test Überschrift" );

my @names = @{$sth->{NAME}};
my $count = 1;
my $var1;


print "<table border=1>\n".join("",map{'<th>'.$_.'</th>'}@names)."\n";
while(my $row = $sth->fetchrow_hashref()){
     $count++;
     $var1 = "<tr>".join("",map{'<td>'.$_.'</td>'}@{$row}{@names})."</tr>\n";
     $var1 =~ s!(.*)(<td>)(\d{6})(<\/td>)(.*)!$1$2<a href="http://www.domain.xy/script.pl?action=run;cono=$3" target="_blank">$3</a>$4$5!;
     print $var1;
#  for my $name(@names){
#      push @{$hash{$name}},$row->{$name};
#  }
}


print $q->end_html();
print $q->redirect('http://1somewhere.else/in/movie.pl?x=1;y=2');