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

#der erste select wird ausgefürht und holt conos
#test2 custno 1606770

#my $select1 = "SELECT distinct cono, date_format(priodate,'%d.%m.%Y') as 'date' FROM focus_data
#where custno = '1603435' and status = '2' order by cono";

my $select1 = "SELECT distinct cono, date_format(priodate,'%d.%m.%Y') as 'date' FROM focus_data
where custno = '1606770' and status = '2' order by cono";

my $sth = $dbh->prepare($select1);
$sth->execute();

#die Ausgabe der Seite beginnt

my $q = CGI->new();
print $q->header();
print $q->start_html("Test1");
print $q->h1( "Test Überschrift" );

my @names = @{$sth->{NAME}};
my $count = 1;
my $var1;
my %hash;
my $name;

#Ausgabe der Tabelle mit den conos

print join(';',@names);       #debug
print "<br>\n";

print "<table border=1>\n".join("",map{'<th>'.$_.'</th>'}@names)."\n";
while(my $row = $sth->fetchrow_hashref()){

     $count++;
     $var1 = "<tr>".join("",map{'<td>'.$_.'</td>'}@{$row}{@names})."</tr>\n";
     $var1 =~ s!(.*)(<td>)(\d{6})(<\/td>)(.*)!$1$2<a href="http://www.domain.xy/script.pl?action=run;cono=$3" target="_blank">$3</a>$4$5!;
     print $var1;

# plus werte in array füllen
     for $name(@names){
          push @{$hash{$name}},$row->{$name};
     }
}
print "</table><br>\n";

#jetzt mit den ergebnissen der ersten abfrage (cono) die zweite abfrage starten und damit die
#shipmentno und lgmboxno zu den aufträgen holen
#und anzeigen

my $alle_conos = join(',',@{$hash{'cono'}});
print "<br>\n";

my $select2 = "
     SELECT distinct
	 `lm1_data`.`custno`,
     `lm1_data`.`shipmentno`,
	 `lm1_data`.`rec_date`,
	 `lm1_data`.`ack_date`,
	 `lm1_data`.`carrier`,
     `lm1_data`.`carrierboxno`,
	 `lm1_data`.`lgmboxno`,
	 `lm1_data`.`stockno`
     FROM
     `focus_data` `focus_data`
     INNER JOIN `lm1_data` `lm1_data`
     ON `focus_data`.`picklistno` = `lm1_data`.`picklistno`
     WHERE (`focus_data`.`cono` in ($alle_conos))";

my $sth2 = $dbh->prepare($select2);
$sth2->execute();

my @names2 = @{$sth2->{NAME}};
print "<table border=1>\n".join("",map{'<th>'.$_.'</th>'}@names2)."\n";
while(my $row = $sth2->fetchrow_hashref()){
     $count++;
     $var1 = "<tr>".join("",map{'<td>'.$_.'</td>'}@{$row}{@names2})."</tr>\n";
     print $var1;
     for $name(@names2){
          push @{$hash{$name}},$row->{$name};
     }
}
print "</table><br>\n";

#und mit diesen ergebnissen nun die anderen tabellen abfragen
#dazu nochmal entsprechende strings ezeugen

#doppelte werte entfernen
my %saw;
@saw{@{$hash{'shipmentno'}}} = ();
my @shipmentno_array = keys %saw;

my %saw2;
@saw2{@{$hash{'lgmboxno'}}} = ();
my @lgmboxno_array = keys %saw2;

#aus dem array einen string machen
my $liste_shipmentno = join(',',@shipmentno_array);
print "Shipmentno: ".$liste_shipmentno;
print "<br>\n";

my $liste_lgmboxno = join(',',@lgmboxno_array);
print "Lgmboxno: ".$liste_lgmboxno;
print "<br>\n";

#abfrage 1 gepard
print "<br>Ergebnisse aus GLS Gepard (manueller Versand):\n";
print "<br>\n";

my $select3 = "
SELECT g.custno, g.shipmentno, g.name1, g.name2, g.name3,
g.street, g.city, g.city2, g.zipcode, g.zipcode2,
g.countrycode, g.stockno, g.date1, g.date2,
g.carrierboxno  FROM gls_gepard1 g
where g.shipmentno in ($liste_shipmentno)";

my $sth3 = $dbh->prepare($select3);
$sth3->execute();

my @names3 = @{$sth3->{NAME}};
print "<table border=1>\n".join("",map{'<th>'.$_.'</th>'}@names3)."\n";
while(my $row = $sth3->fetchrow_hashref()){
     $count++;
     $var1 = "<tr>".join("",map{'<td>'.$_.'</td>'}@{$row}{@names3})."</tr>\n";
     print $var1;
}
print "</table><br>\n";

#abfrage 2 dhl easylog

print "<br>Ergebnisse aus DHL Easylog (manueller Versand):\n";
print "<br>\n";

my $select4 = "
SELECT d.shipmentno, d.name1, d.name2, d.name3,
d.street, d.street_number, d.city, d.zipcode, d.countrycode,
d.stockno, d.lgmboxno, d.carrierboxno FROM dhl_easylog1 d
where d.lgmboxno in ($liste_lgmboxno)";

my $sth4 = $dbh->prepare($select4);
$sth4->execute();

my @names4 = @{$sth4->{NAME}};
print "<table border=1>\n".join("",map{'<th>'.$_.'</th>'}@names4)."\n";
while(my $row = $sth4->fetchrow_hashref()){
     $count++;
     $var1 = "<tr>".join("",map{'<td>'.$_.'</td>'}@{$row}{@names4})."</tr>\n";
     print $var1;
}
print "</table><br>\n";

#abfrage 3 nightplus

print "<br>Ergebnisse aus Nightplus Nachkurier (manueller Versand):\n";
print "<br>\n";

my $select5 = "
SELECT n.custno, n.shipmentno, n.lgmboxno, n.carrierboxno,
n.stockno, n.shipdate FROM nightstar1_out n
WHERE n.lgmboxno in ($liste_lgmboxno)";

my $sth5 = $dbh->prepare($select5);
$sth5->execute();

my @names5 = @{$sth5->{NAME}};
print "<table border=1>\n".join("",map{'<th>'.$_.'</th>'}@names5)."\n";
while(my $row = $sth5->fetchrow_hashref()){
     $count++;
     $var1 = "<tr>".join("",map{'<td>'.$_.'</td>'}@{$row}{@names5})."</tr>\n";
     print $var1;
}
print "</table><br>\n";

# hier folgen alle FEHLER bei Nightstar, nur was bei LM als NS geflaggt ist und NICHT in der NS
# tabelle steht, wird hier angezeigt

my $select6 = "
SELECT `lm1_data`.`lgmboxno`
FROM
 `lm1_data` `lm1_data`
  LEFT OUTER JOIN `nightstar1_out` `nightstar1_out`
  ON `lm1_data`.`lgmboxno` = `nightstar1_out`.`lgmboxno`
WHERE
 (`lm1_data`.`lgmboxno` IN ($liste_lgmboxno)) AND
 (`lm1_data`.`carrier` LIKE 'np%') AND
 (`nightstar1_out`.`lgmboxno` IS NULL)";

my $sth6 = $dbh->prepare($select6);
$sth6->execute();

if ($sth6->fetchrow_array ) {                 #wenn was gefunden wurde
     print "<font color=\"#FF0000\">\n";
     print "<br>FEHLER!<br>Für die folgenden cono's wurde kein Nighstar Ausgang gefunden, obwohl sie im LM entsprechend markiert sind:\n";
     print "<br>\n";


     my @names6 = @{$sth6->{NAME}};
     print "<table border=1>\n".join("",map{'<th>'.$_.'</th>'}@names6)."\n";
     while(my $row = $sth6->fetchrow_hashref()){
          $count++;
          $var1 = "<tr>".join("",map{'<td>'.$_.'</td>'}@{$row}{@names6})."</tr>\n";
          print $var1;
     }
     print "</table></font><br>\n";
}

#fertig

print $q->end_html();
