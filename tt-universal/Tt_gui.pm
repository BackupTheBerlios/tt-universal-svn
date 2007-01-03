
sub init_search () {
}

###########################################
#show empty searchform and sub from here depending on query_variant
sub showsearchform () {
##########################################
     my $countvar;
     my $filled_field_value = 0;

#     print "Content-type:text/html\n\n";
     @fields = qw(custno cono shipmentno partno);
     $form = CGI::FormBuilder->new(
                  fields => \@fields,
                  messages => ':de_DE',
                  method => 'post',
                  reset => 'Suchfelder leeren',
                  keepextras => 1,
                  javascript => 0
             );
     $form->field(
                 name       => 'custno',          # name of field (required)
                 label      => 'Kundennummer',        # shown in front of <input>
                 required   => 0 ,          # must fill field in?
                 validate   => '/^\d{7}$/',      # validate user input
                 comment    => 'zum Testen: 1603435',
         );
     $form->field(
                 name       => 'cono',          # name of field (required)
                 label      => 'Auftragsnummer',        # shown in front of <input>
                 required   => 0 ,          # must fill field in?
                 validate   => '/^\d{6}$/',      # validate user input
         );
     $form->field(
                 name       => 'shipmentno',          # name of field (required)
                 label      => 'Lieferscheinnummer',        # shown in front of <input>
                 required   => 0 ,          # must fill field in?
                 validate   => '/^\d{6}$/',      # validate user input
         );
     $form->field(
                 name       => 'partno',          # name of field (required)
                 label      => 'Artikelnummer',        # shown in front of <input>
                 required   => 0 ,          # must fill field in?
                 validate   => '/^\d{5}(\d|x|X)$/',      # validate user input
                 comment    => 'Nach einer Artikelnummer kann nur ZUSÄTZLICH gesucht werden.<br />',        # printed after field
         );
     if ($form->submitted && $form->validate) {
         # you would write code here to act on the form data
         $countvar = 0;                                #zählvar zurücksetzen, binär benutzt
                                                       #summe von countvar zeigt, welche felder gesetzt sind
                                                       #custno=8,cono=4,shipmentno=2,partno=1
         my $custno = $form->field('custno');
         if (length($custno) > 1) {
               $countvar += 8;                          #spalte 4 wert=8
         }
         my $cono = $form->field('cono');              #dito
         if (length($cono) > 1) {
               $countvar += 4;                          #spalte 3 wert=4
         }
         my $shipmentno = $form->field('shipmentno');  #dito
         if (length($shipmentno) > 1) {
               $countvar += 2;                          #spalte 2 wert=2
         }
         my $partno = $form->field('partno');          #wenn in partno was steht
         if (length($partno) > 1) {
               $countvar += 1;                          #spalte 1 wert=1
              $partno =~ tr/x/X/;                      #nur grosses X
         }
         if ($countvar gt 1 ) {                         #mehr als 1? alles gut
              print $form->confirm(header => 0);
              print "Und weiter gehts!<br />\n";
              #TODO select bauen für jede wertekombination eine funktion bauen
              #TODO auswahl funktion gemäß der eingegebenen daten
              print "Countvar: $countvar<br />\n";
              if ($countvar == 8 || $countvar == 9) {
                   show_cono_level1($custno,$partno);
              }
         }
         elsif ($countvar == 1) {                       #nur valid wenn alles ausser partno leer ist
              $form->field(name => 'partno', invalid => 1);
              print $form->render(header => 0, sticky => 1);
         }
         elsif ($countvar == 0) {                       #alles leer? nochmal
              print "Keine Daten erhalten! Nochmal.<br />\n";
              $form->field(name => 'partno', invalid => 0);
              print $form->render(header => 0, sticky => 1);
         }
         else {                                        #alles leer? nochmal
              print "<br />ERROR<br />";
         }
     } else {
         print $form->render(header => 0);
     }
}

###########################################
# funktion für auswahl cono nach übergabe custno und ggf. partno
sub show_cono_level1($;$) {
###########################################
     my $custno_var = $_[0];
     my $partno_var = $_[1];
     my $count = 1;
     my $var1;

     #jetzt select bauen mit oder ohne partno
     my $select1 = "SELECT distinct cono, date_format(priodate,'%d.%m.%Y') as 'date' FROM focus_data
     where custno = '$custno_var'";
     if ($partno_var) {
          $select1 .= " and partno = '$partno_var'";
     }
     $select1 .= " and status = '2' order by cono";
     print "<br>Select: $select1 <br>\n";

     my $dbh = DBI->connect($DB_TYPE, $STAT_DB_USER, $STAT_DB_PASS, {RaiseError => 0}) or die "Database connection not made: $DBI::errstr";
     my $sth = $dbh->prepare($select1);
     $sth->execute();         #select ausführen
     $dbh->disconnect();      #database handle schliessen

     if ($sth->fetchrow_array ) {                 #wenn was gefunden wurde
          my @names = @{$sth->{NAME}};
          print "<h1>Test Überschrift custno: $custno_var partno: $partno_var</h1>";
          print "<table border=1>\n".join("",map{'<th>'.$_.'</th>'}@names)."\n";
          while(my $row = $sth->fetchrow_hashref()){
               $count++;
               $var1 = "<tr>".join("",map{'<td>'.$_.'</td>'}@{$row}{@names})."</tr>\n";
               $var1 =~ s!(.*)(<td>)(\d{6})(<\/td>)(.*)!$1$2<a href="$SERVER_MAIN_FILENAME?level=scd;cono=$3" target="_blank">$3</a>$4$5!;  #relative URL!
               print $var1;
          }
          print "</table><br>\n";
     }
     else {                                       #wenn die Abfrage ohne Ergebnis blieb
          print "<h2>keine Daten gefunden.</h2>" ;
          print "<a href='searchdata.pl?level=start>zur&uuml;ck</a>";
     }
}

###########################################
#show cono detail funktion wenn nur cono oder cono plus partno
sub show_cono_detail ($) {
###########################################

     my $cono_var = $_[0];
     my ($liste_shipmentno, $liste_lgmboxno) = query_lm_main ("",$cono_var,"","","8"); #reihenfolge: custno,cono,shipmentno,partno,abfragevariante (2-15)
     if ($liste_shipmentno && $liste_lgmboxno) {
          query_gls_gepard ($liste_shipmentno);
          query_dhl_easylog ($liste_lgmboxno);
          query_nightstar ($liste_lgmboxno);
     }
}

###########################################
#hauptabfrage lm
sub query_lm_main ($$$$$){          #reihenfolge: custno,cono,shipmentno,partno,abfragevariante (2-15)
###########################################
     my $var_custno = $_[0];
     my $var_cono = $_[1];
     my $var_shipmentno = $_[2];
     my $var_partno = $_[3];
     my $query_variant = $_[4];
     my @names2;              #array für spaltennamen
     my $name;                #string für temp-var
     my $liste_shipmentno;    #var für rückgabeliste1
     my $liste_lgmboxno;      #var für rückgabeliste2

if ($var_custno ) {print"<br>var custno def: $var_custno"};
if ($var_cono ) {print"<br>var cono def: $var_cono "};
if ($var_shipmentno  ) {print"<br>var shipmentno def: $var_shipmentno "};
if ($var_partno  ) {print"<br>var partno def: $var_partno "};
if ($query_variant  ) {print"<br>var query variant def: $query_variant <br>"};

     print "<br>Ergebnisse aus LM:<br>\n";

     #hier beginnt der query-string
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
          ON `focus_data`.`picklistno` = `lm1_data`.`picklistno`";

     for ($query_variant) {   #die abfragevariante entscheidet, wie der querystring weitergeht
         if (/2/)  { }     # do something else
         elsif (/3/)  { }     # do something else
         elsif (/4/)  { }     # do something else
         elsif (/5/)  { }     # do something else
         elsif (/6/)  { }     # do something else
         elsif (/7/)  { }     # do something else
         elsif (/8/)  {$select2 .= " WHERE (`focus_data`.`cono` in ($var_cono))"; }     # do something else
         elsif (/9/)  {$select2 .= " WHERE (`focus_data`.`cono` in ($var_cono))"; }     # do something else
         elsif (/10/)  { }     # do something else
         elsif (/11/)  { }     # do something else
         elsif (/12/)  { }     # do something else
         elsif (/13/)  { }     # do something else
         elsif (/14/)  { }     # do something else
        else            { }     # default
     }

     $select2 .= " ORDER by `lm1_data`.`ack_date`";         #die sortierreihenfolge

     my $dbh2 = DBI->connect($DB_TYPE, $STAT_DB_USER, $STAT_DB_PASS, {RaiseError => 0}) or die "Database connection not made: $DBI::errstr";
     my $sth2 = $dbh2->prepare($select2);
     $sth2->execute();
     $dbh2->disconnect();

     if ($sth2->fetchrow_array ) {                 #wenn was gefunden wurde
          @names2 = @{$sth2->{NAME}};
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
          $liste_shipmentno = join(',',@{$hash{'shipmentno'}});    #strings erzeugen für die rückgabe
          $liste_lgmboxno = join(',',@{$hash{'lgmboxno'}});

     }
     else {
          print "<b>Keine Daten gefunden!</b><br>\n";
          $liste_shipmentno = "";    #leere strings erzeugen für die rückgabe
          $liste_lgmboxno = "";

     }

     return ($liste_shipmentno, $liste_lgmboxno);      #es werden ZWEI werte zurückgegeben
}

###########################################
#abfrage 1 gepard
sub query_gls_gepard($){
###########################################

     my $liste_shipmentno = $_[0];        #übergabe der shipmentnos als string
     print "<br>Ergebnisse aus GLS Gepard (manueller Versand):\n";
     print "<br>\n";

     my $select3 = "
     SELECT g.custno, g.shipmentno, g.name1, g.name2, g.name3,
     g.street, g.city, g.city2, g.zipcode, g.zipcode2,
     g.countrycode, g.stockno, g.date1, g.date2,
     g.carrierboxno  FROM gls_gepard1 g
     where g.shipmentno in ($liste_shipmentno)";

     my $dbh3 = DBI->connect($DB_TYPE, $STAT_DB_USER, $STAT_DB_PASS, {RaiseError => 0}) or die "Database connection not made: $DBI::errstr";
     my $sth3 = $dbh3->prepare($select3);
     $sth3->execute();
     $dbh3->disconnect();

     if ($sth3->fetchrow_array ) {                 #wenn was gefunden wurde
          my @names3 = @{$sth3->{NAME}};
          print "<table border=1>\n".join("",map{'<th>'.$_.'</th>'}@names3)."\n";
          while(my $row = $sth3->fetchrow_hashref()){
               $count++;
               $var1 = "<tr>".join("",map{'<td>'.$_.'</td>'}@{$row}{@names3})."</tr>\n";
               print $var1;
          }
          print "</table><br>\n";
     }
     else {
          print "<b>Keine Daten gefunden!</b><br>\n";
     }

}

###########################################
#abfrage 2 dhl easylog
sub query_dhl_easylog($){
###########################################
     my $liste_lgmboxno = $_[0];
     print "<br>Ergebnisse aus DHL Easylog (manueller Versand):\n";
     print "<br>\n";

     my $select4 = "
     SELECT d.shipmentno, d.name1, d.name2, d.name3,
     d.street, d.street_number, d.city, d.zipcode, d.countrycode,
     d.stockno, d.lgmboxno, d.carrierboxno FROM dhl_easylog1 d
     where d.lgmboxno in ($liste_lgmboxno)";

     my $dbh4 = DBI->connect($DB_TYPE, $STAT_DB_USER, $STAT_DB_PASS, {RaiseError => 0}) or die "Database connection not made: $DBI::errstr";
     my $sth4 = $dbh4->prepare($select4);
     $sth4->execute();
     $dbh4->disconnect();

     if ($sth4->fetchrow_array ) {                 #wenn was gefunden wurde
          my @names4 = @{$sth4->{NAME}};
          print "<table border=1>\n".join("",map{'<th>'.$_.'</th>'}@names4)."\n";
          while(my $row = $sth4->fetchrow_hashref()){
               $count++;
               $var1 = "<tr>".join("",map{'<td>'.$_.'</td>'}@{$row}{@names4})."</tr>\n";
               print $var1;
          }
          print "</table><br>\n";
     }
     else {
          print "<b>Keine Daten gefunden!</b><br>\n";
     }

}

###########################################
#abfrage 3 nightstar
sub query_nightstar($){
###########################################
     my $liste_lgmboxno = $_[0];
     print "<br>Ergebnisse aus Nightplus Nachkurier (manueller Versand):\n";
     print "<br>\n";

     my $select5 = "
     SELECT n.custno, n.shipmentno, n.lgmboxno, n.carrierboxno,
     n.stockno, n.shipdate FROM nightstar1_out n
     WHERE n.lgmboxno in ($liste_lgmboxno)";

     my $dbh5 = DBI->connect($DB_TYPE, $STAT_DB_USER, $STAT_DB_PASS, {RaiseError => 0}) or die "Database connection not made: $DBI::errstr";
     my $sth5 = $dbh5->prepare($select5);
     $sth5->execute();

     if ($sth5->fetchrow_array ) {                 #wenn was gefunden wurde
          my @names5 = @{$sth5->{NAME}};
          print "<table border=1>\n".join("",map{'<th>'.$_.'</th>'}@names5)."\n";
          while(my $row = $sth5->fetchrow_hashref()){
               $count++;
               $var1 = "<tr>".join("",map{'<td>'.$_.'</td>'}@{$row}{@names5})."</tr>\n";
               print $var1;
          }
          print "</table><br>\n";
     }
     else {
          print "<b>Keine Daten gefunden!</b><br>\n";
     }

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

     my $sth6 = $dbh5->prepare($select6);
     $sth6->execute();
     $dbh5->disconnect();

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
}


1;