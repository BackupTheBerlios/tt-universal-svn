use strict;
# use warnings;
use DBI;


my $STAT_DB = 's_stat';        #Name der Stat Datenbank
my $DB_HOST = 'localhost';		#Rechnername auf dem die MySQL DB liegt
my $DB_TYPE = 'DBI:mysql:'.$STAT_DB.':'.$DB_HOST;	#DBI Zugriffsparameter für mysql
my $STAT_DB_USER = 'root';    #Username für zugriff auf DB
my $STAT_DB_PASS = '';        #passwort für zugriff auf DB

my $dbh = DBI->connect($DB_TYPE, $STAT_DB_USER, $STAT_DB_PASS, {RaiseError => 0}) or die "Database connection not made: $DBI::errstr";

my $select1 = "select * from dhl_easylog1";
my $sth = $dbh->prepare($select1);
$sth->execute();

my @names = @{$sth->{NAME}};
my $count = 1;
print "<table border=1>\n".join("",map{'<th>'.$_.'</th>'}@names)."\n";
while(my $row = $sth->fetchrow_hashref()){
 $count++;
  print "<tr>".join("~",map{'<td>'." bla".$_.'</td>'}@{$row}{@names})."</tr>\n";
  if ($count == 5 ) {exit;}
#  for my $name(@names){
#      push @{$hash{$name}},$row->{$name};
#  }
}
