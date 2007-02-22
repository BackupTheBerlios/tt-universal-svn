use strict;
use warnings;

use DBI;

my $count;
my @zeile;
my $domain;
my $ergebnis;
my $sth;
my $sql_string;

$| = 1;                     # don't buffer STDOUT (for EPIC use)


# Datenbank-Verbindung aufbauen
my $dbh = DBI->connect( 'dbi:mysql:trackandtrace', 'root', '') || die "Kann keine Verbindung zum MySQL-Server aufbauen: $DBI::errstr\n";

$sql_string = "select * from lm1_data where lgmboxno != carrierboxno and (carrier = \'GP\' or carrier = \'DP\')";
# print $sql_string;
$sth = $dbh->prepare($sql_string) || die "Kann Statement nicht vorbereiten: $DBI::errstr\n";
$sth->execute() || die "Kann Abfrage nicht ausfuehren:  $DBI::errstr\n";
print ".";

while (my $ergebnis = $sth->fetchrow_hashref()) {

     $count ++;
     my $stock =  $ergebnis->{'stockno'} ;
     my $carrier =  $ergebnis->{'carrier'} ;
     my $boxno =  $ergebnis->{'lgmboxno'} ;
     my $cust = $ergebnis->{'custno'} ;
     my $picklist = $ergebnis->{'picklistno'} ;
     my $shipment = $ergebnis->{'shipmentno'} ;
     my $plrp = $ergebnis->{'picklistrowpos'} ;

     my $ext_boxno = calc_carrierboxno($boxno, $carrier, $stock);
#     print "box: $boxno | carrier: $carrier | stock: $stock | ext_box: $ext_boxno\n";

     my $update1 = "UPDATE `lm1_data` SET `ext_carrierboxno` = '$ext_boxno' WHERE `stockno` = $stock AND `custno` = $cust AND `picklistno` = $picklist AND `shipmentno` = $shipment AND `picklistrowpos` = $plrp";
     exit if $count == 2000;
     print "$update1 \n";
my $sth2 = $dbh->prepare($update1) || die "Kann Statement nicht vorbereiten: $DBI::errstr\n";
$sth2->execute() || die "Kann Abfrage nicht ausfuehren:  $DBI::errstr\n";
print "~";

}

print "\ncount: $count \n";


# Datenbank-Verbindung beenden
# $statement->finish();
# $dbh->disconnect;

###########################################
# calculate complete carrierboxno
sub calc_carrierboxno($$$) {        #param: carrierboxno, carrier (DP,GP), stockno (160,210)
###########################################
#        my ( $spcpaketnummer, $carrier, $lagernummer ) = @_;
        my $spcpaketnummer = $_[0];
        my $carrier = $_[1];
        my $lagernummer = $_[2];
        my $carpaketnummer;
        my $summe;
        my $checkdigit;
        my $lagercode;
        my $paketnummer;
        my $i;
        my $rest;
        my $wert;


        #ermitteln des Checkdigit
        if ( $carrier eq "DP" ) {    #Carrier Deutsche Post
                                     #ermitteln des Lagercodes
         if ( $lagernummer eq "160" ) {    #Lager Höver
          $lagercode = 30617;
         }
         elsif ( $lagernummer eq "210" )    #Lager Winkelhaid
         {
          $lagercode = 90655;
         }

         #ergänzen der Paketnummer um den Lagercode
         $paketnummer = $lagercode . $spcpaketnummer;

         #Anhand der Länge die Gültigkeit der Paketnummer prüfen
         if ( length($spcpaketnummer) == 6 )    #Paketnummer gültig
         {

          #Checksumme errechnen (1.,3. usw Stelle der Paketnummer mit 4,
          #                      2.,4. usw Stelle der Paketnummer mit 9
          #                      multiplizieren und die Ergebnisse addieren)
          for ( $i = 0 ; $i <= length($paketnummer) - 1 ; $i++ ) {
           $wert = substr( $paketnummer, $i, 1 );
           $summe = $summe + ( $wert * 4 );
           $i = $i + 1;
           if ( $i <= length($paketnummer) - 1 ) {
            $wert = substr( $paketnummer, $i, 1 );
            $summe = $summe + ( $wert * 9 );
           }
          }

     #errechnete Summe durch 10 teilen und den Divisionsrest von 10 subtrahieren
     #==> Checkdigit außer wenn der Rest 0 ist, dann ist das Checkdigit auch 0
          $rest = $summe % 10;
          if ( $rest != 0 ) {
           $checkdigit = 10 - $rest;
          }
          else {
           $checkdigit = 0;
          }
         }
         else    #Paketnummer ungültig
         {
          if ( length($spcpaketnummer) < 6 )    #Paketnummer zu kurz
          {
           $checkdigit = 55;
          }
          else                                  #Paketnummer zu lang
          {
           $checkdigit = 77;
          }
         }
        }
        elsif ( $carrier eq "GP" )              #Carrier German Parcel
        {

         #ermitteln des Lagercodes
         if ( $lagernummer eq "160" )           #Lager Höver
         {
          $lagercode = 30;
         }
         elsif ( $lagernummer eq "210" )        #Lager Winkelhaid
         {
          $lagercode = 85;
         }

         #ergänzen der Paketnummer um den Lagercode
         $paketnummer = $lagercode . $spcpaketnummer;

         #Anhand der Länge die Gültigkeit der Paketnummer prüfen
         if ( length($spcpaketnummer) == 9 )    #Paketnummer gültig
         {

          #Checksumme errechnen (1.,3. usw Stelle der Paketnummer mit 4,
          #                      2.,4. usw Stelle der Paketnummer mit 9
          #                      multiplizieren und die Ergebnisse addieren)
          for ( $i = 0 ; $i <= length($paketnummer) - 1 ; $i++ ) {
           $wert = substr( $paketnummer, $i, 1 );
           $summe = $summe + ( $wert * 3 );
           $i = $i + 1;
           if ( $i <= length($paketnummer) - 1 ) {
            $wert = substr( $paketnummer, $i, 1 );
            $summe = $summe + ( $wert * 1 );
           }
          }

          #Summe nochmal um 1 erhöhen
          $summe = $summe + 1;

     #errechnete Summe durch 10 teilen und den Divisionsrest von 10 subtrahieren
     #==> Checkdigit außer wenn der Rest 0 ist, dann ist das Checkdigit auch 0
          $rest = $summe % 10;
          if ( $rest != 0 ) {
           $checkdigit = 10 - $rest;
          }
          else {
           $checkdigit = 0;
          }
         }
         else    #Paketnummer ungültig
         {
          if ( length($spcpaketnummer) < 9 )    #Paketnummer zu kurz
          {
           $checkdigit = 55;
          }
          else                                  #Paketnummer zu lang
          {
           $checkdigit = 77;
          }
         }
        }
        else {
         $paketnummer = $spcpaketnummer;
        }
        $carpaketnummer = $paketnummer . $checkdigit;
        return ($carpaketnummer);
}
