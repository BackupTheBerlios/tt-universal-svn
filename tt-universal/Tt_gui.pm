
sub init_search () {
}

sub showsearchform () {
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

sub show_cono_level1($;$) {
                              # funktion für auswahl cono nach übergabe custno und ggf. partno
     my $custno_var = $_[0];
     my $partno_var = $_[1];
     my $dbh = DBI->connect($DB_TYPE, $STAT_DB_USER, $STAT_DB_PASS, {RaiseError => 0}) or die "Database connection not made: $DBI::errstr";

     #jetzt select bauen mit oder ohne partno
     my $select1 = "SELECT distinct cono, date_format(priodate,'%d.%m.%Y') as 'date' FROM focus_data
     where custno = '$custno_var'";
     if ($partno_var) {
          $select1 .= " and partno = '$partno_var'";
     }
     $select1 .= " and status = '2' order by cono";
     print "<br>Select: $select1 <br>\n";
     my $sth = $dbh->prepare($select1);
     $sth->execute();         #select ausführen
     $dbh->disconnect();      #database handle schliessen

     my @names = @{$sth->{NAME}};
     my $count = 1;
     my $var1;
     if ($sth->fetchrow_array ) {                 #wenn was gefunden wurde
          print "<h1>Test Überschrift custno: $custno_var partno: $partno_var</h1>";
          print "<table border=1>\n".join("",map{'<th>'.$_.'</th>'}@names)."\n";
          while(my $row = $sth->fetchrow_hashref()){
               $count++;
               $var1 = "<tr>".join("",map{'<td>'.$_.'</td>'}@{$row}{@names})."</tr>\n";
               $var1 =~ s!(.*)(<td>)(\d{6})(<\/td>)(.*)!$1$2<a href="$SERVER_MAIN_FILENAME?level=scd;cono=$3" target="_blank">$3</a>$4$5!;  #relative URL!
               print $var1;
          }
     }
     else {                                       #wenn die Abfrage ohne Ergebnis blieb
          print "<h2>keine Daten gefunden.</h2>" ;
          print "<a href='searchdata.pl?level=start>zur&uuml;ck</a>";
     }
}

sub show_cono_detail ($) {
                              # show cono detail funktion select alle db wenn cono vorhanden
     my $cono_var = $_[0];
     print "<h1>Test Show cono detail Überschrift</h1>";
     print "<br> Show cono detail: $cono_var!<br>";
}

1;