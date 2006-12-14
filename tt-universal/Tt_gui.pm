
sub init_search () {
}

sub showsearchform () {
     my $countvar;

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
         $countvar = 0;                                #zählvar zurücksetzen
         my $custno = $form->field('custno');
         if (length($custno) > 1) {
              $countvar += 2;                          #was drin? dann zähler um zwei erhöhen
         }
         my $cono = $form->field('cono');              #dito
         if (length($cono) > 1) {
              $countvar += 2;
         }
         my $shipmentno = $form->field('shipmentno');  #dito
         if (length($shipmentno) > 1) {
              $countvar += 2;
         }
         my $partno = $form->field('partno');          #wenn in partno was steht
         if (length($partno) > 1) {
              $countvar++;                             #dann nur um eins erhöhen
              $partno =~ tr/x/X/;                      #nur grosses X
         }
         if ($countvar gt 1 ) {                         #mehr als 1? alles gut
              print $form->confirm(header => 0);
              print "Und weiter gehts!<br />\n";
              #TODO run_search aufrufen, anzahl der übergabewerte einstellen
              run_search($custno,$cono,$shipmentno,$partno);
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

sub run_search($$$$) {      # TODO anpassen übergabeparameter sql run_search
     my $custno = $_[0];      #suchvars übergeben
     my $cono = $_[1];
     my $shipmentno = $_[2];
     my $partno = $_[3];
     my $dbh = DBI->connect($DB_TYPE, $STAT_DB_USER, $STAT_DB_PASS, {RaiseError => 0}) or die "Database connection not made: $DBI::errstr";
     my $countvar = 0;

#     my $select1 = "select distinct b.carrier, b.lmboxno, b.picklistno, b.shipmentno, b.custno
#     from lm1_data b where b.custno = $custno
#     order by b.picklistno ";
     my $select1 = "select distinct b.carrier, b.lmboxno, b.picklistno, b.shipmentno, b.custno
     from lm1_data b where b.picklistno in (SELECT distinct a.picklistno
     FROM focus_data a where ";
     if (length($custno) > 1) {
         $select1 .= "a\.custno = '$custno'";       #where klausel anhängen
         $countvar++;                             #dann zähler um eins erhöhen
     }
     if (length($cono) > 1) {
         if ($countvar ge 1 ) {
	         $select1 .= " and ";
         }
         $select1 .= "a\.cono = '$cono'";       #where klausel anhängen
         $countvar++;                             #dann zähler um eins erhöhen
     }
     if (length($shipmentno) > 1) {
         if ($countvar ge 1 ) {
	         $select1 .= " and ";
         }
         $select1 .= "a\.shipmentno = '$shipmentno'";       #where klausel anhängen
         $countvar++;                             #dann zähler um eins erhöhen
     }
     if (length($partno) > 1) {
         if ($countvar ge 1 ) {
	         $select1 .= " and ";
         }
         $select1 .= "a\.partno = '$partno'";       #where klausel anhängen
         $countvar++;                             #dann zähler um eins erhöhen
     }
     $select1 .= " and a.status=2) order by b.picklistno ";
     my $sth = $dbh->prepare($select1);
     $sth->execute();
# print "<br />SQL: $select1 <br />";
# TODO wenn im array was gefunden
     if ($sth->fetchrow_array ) {                 #wenn was gefunden wurde
          showtable_level1 ($sth);
          print "<a href='searchdata.pl?level=start>zur&uuml;ck</a>";
     }
     else {                                       #wenn die Abfrage ohne Ergebnis blieb
          print "<h2>keine Daten gefunden.</h2>" ;
          print "<a href='searchdata.pl?level=start>zur&uuml;ck</a>";
     }
     $dbh->disconnect();
}

sub get_by_carrier ($) {
     my $carrier = $_[0];
     print "<br> Get by carrier: $carrier!<br>";
}

sub showtable_level1 ($) {
     my $sth = $_[0];
     my (@shipmentno, @picklistno, @lmboxno, @carrier, @custno);
     my %temphash;
     my @out;
     print "<table border=1>\n".
     "  <th>carrier</th>\n".
     "  <th>lmboxno</th>\n".
     "  <th>picklistno</th>\n".
     "  <th>shipmentno</th>\n".
     "  <th>custno</th>\n";
     while (my $hash_ref = $sth->fetchrow_hashref) {
      print "  <tr>\n";
      print "    <td><a target='_blank' href='searchdata.pl?level=get_by_carrier;carrier=$hash_ref->{carrier}'>$hash_ref->{carrier}</a></td>\n";
      push @carrier,$hash_ref->{carrier};
      print "    <td><a target='_blank' href='searchdata.pl?level=get_by_lmboxno;lmboxno=$hash_ref->{lmboxno}'>$hash_ref->{lmboxno}</a></td>\n";
      push @lmboxno,$hash_ref->{lmboxno};
      print "    <td><a target='_blank' href='searchdata.pl?level=get_by_picklistno;picklistno=$hash_ref->{picklistno}'>$hash_ref->{picklistno}</a></td>\n";
      push @picklistno,$hash_ref->{picklistno};
      print "    <td><a target='_blank' href='searchdata.pl?level=get_by_shipmentno;shipmentno=$hash_ref->{shipmentno}'>$hash_ref->{shipmentno}</a></td>\n";
      push @shipmentno,$hash_ref->{shipmentno};
      print "    <td><a target='_blank' href='searchdata.pl?level=get_by_custno;custno=$hash_ref->{custno}'>$hash_ref->{custno}</a></td>\n";
      push @custno,$hash_ref->{custno};
      print "  </tr>\n";
     }
     print "</table>";

     undef %temphash;
     @out = grep(!$temphash{$_}++, @carrier);
     foreach my $hash_string ( @out ) {
     	print "Carrier Wert: $hash_string <br>\n";
     } # -----  end foreach  -----

     undef %temphash;
     @out = grep(!$temphash{$_}++, @lmboxno);
     foreach my $hash_string ( @out ) {
     	print "lmboxno Wert: $hash_string <br>\n";
     } # -----  end foreach  -----

     undef %temphash;
     @out = grep(!$temphash{$_}++, @picklistno);
     foreach my $hash_string ( @out ) {
     	print "picklistno Wert: $hash_string <br>\n";
     } # -----  end foreach  -----

     undef %temphash;
     @out = grep(!$temphash{$_}++, @shipmentno);
     foreach my $hash_string ( @out ) {
     	print "shipmentno Wert: $hash_string <br>\n";
     } # -----  end foreach  -----

     undef %temphash;
     @out = grep(!$temphash{$_}++, @custno);
     foreach my $hash_string ( @out ) {
     	print "custno Wert: $hash_string <br>\n";
     } # -----  end foreach  -----

}
1;