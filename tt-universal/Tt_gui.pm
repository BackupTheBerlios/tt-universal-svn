#TODO alle direkt kodierten tabellen durch VARs ersetzen
sub init_search () {
}

###########################################
#show empty searchform and sub from here depending on query_variant
sub showsearchform_alt () {
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
                 label      => 'Kundennummer:',        # shown in front of <input>
                 required   => 0 ,          # must fill field in?
                 validate   => '/^\d{7}$/',      # validate user input
#                 comment    => 'zum Testen: 1603435',
         );
     $form->field(
                 name       => 'cono',          # name of field (required)
                 label      => 'Auftragsnummer:',        # shown in front of <input>
                 required   => 0 ,          # must fill field in?
                 validate   => '/^\d{6}$/',      # validate user input
         );
     $form->field(
                 name       => 'shipmentno',          # name of field (required)
                 label      => 'Lieferscheinnummer:',        # shown in front of <input>
                 required   => 0 ,          # must fill field in?
                 validate   => '/^\d{6}$/',      # validate user input
         );
     $form->field(
                 name       => 'partno',          # name of field (required)
                 label      => 'Artikelnummer:',        # shown in front of <input>
                 required   => 0 ,          # must fill field in?
                 validate   => '/^\d{5}(\d|x|X)$/',      # validate user input
                 comment    => 'Nach einer Artikelnummer kann nur ZUS�TZLICH gesucht werden.<br />',        # printed after field
         );
     if ($form->submitted && $form->validate) {
         # you would write code here to act on the form data
         $countvar = 0;                                #z�hlvar zur�cksetzen, bin�r benutzt
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
              print "<br>\n";
# print "Countvar: $countvar<br />\n";
              if ($countvar eq 2) {     #shipmentno
                    my ($liste_shipmentno, $liste_lgmboxno) = query_lm_main("","","$shipmentno","","02"); #reihenfolge: custno,cono,shipmentno,partno,abfragevariante (2-15)
                         if ($liste_shipmentno && $liste_lgmboxno) {
                              query_gls_gepard ($liste_shipmentno);
                              query_dhl_easylog ($liste_lgmboxno);
                              query_nightstar ($liste_lgmboxno);
                         }
              }
              if ($countvar eq 3) {     #shipmentno plus partno
                    my ($liste_shipmentno, $liste_lgmboxno) = query_lm_main("","","$shipmentno","$partno","03"); #reihenfolge: custno,cono,shipmentno,partno,abfragevariante (2-15)
                         if ($liste_shipmentno && $liste_lgmboxno) {
                              query_gls_gepard ($liste_shipmentno);
                              query_dhl_easylog ($liste_lgmboxno);
                              query_nightstar ($liste_lgmboxno);
                         }
              }
              if ($countvar eq 4) {     #cono
                    my ($liste_shipmentno, $liste_lgmboxno) = query_lm_main("","$cono","","","04"); #reihenfolge: custno,cono,shipmentno,partno,abfragevariante (2-15)
                         if ($liste_shipmentno && $liste_lgmboxno) {
                              query_gls_gepard ($liste_shipmentno);
                              query_dhl_easylog ($liste_lgmboxno);
                              query_nightstar ($liste_lgmboxno);
                         }
              }
              if ($countvar eq 5) {     #cono plus partno
                    my ($liste_shipmentno, $liste_lgmboxno) = query_lm_main("","$cono","","$partno","05"); #reihenfolge: custno,cono,shipmentno,partno,abfragevariante (2-15)
                         if ($liste_shipmentno && $liste_lgmboxno) {
                              query_gls_gepard ($liste_shipmentno);
                              query_dhl_easylog ($liste_lgmboxno);
                              query_nightstar ($liste_lgmboxno);
                         }
              }
              if ($countvar eq 6) {     #cono plus shipmentno
                    my ($liste_shipmentno, $liste_lgmboxno) = query_lm_main("","$cono","$shipmentno","","06"); #reihenfolge: custno,cono,shipmentno,partno,abfragevariante (2-15)
                         if ($liste_shipmentno && $liste_lgmboxno) {
                              query_gls_gepard ($liste_shipmentno);
                              query_dhl_easylog ($liste_lgmboxno);
                              query_nightstar ($liste_lgmboxno);
                         }
              }
              if ($countvar eq 7) {     #cono plus shipmentno plus partno
                    my ($liste_shipmentno, $liste_lgmboxno) = query_lm_main("","$cono","$shipmentno","$partno","07"); #reihenfolge: custno,cono,shipmentno,partno,abfragevariante (2-15)
                         if ($liste_shipmentno && $liste_lgmboxno) {
                              query_gls_gepard ($liste_shipmentno);
                              query_dhl_easylog ($liste_lgmboxno);
                              query_nightstar ($liste_lgmboxno);
                         }
              }
              if ($countvar eq 8 || $countvar eq 9) {  #custno or custno plus partno
                   show_cono_level1($custno,$partno);
              }
              if ($countvar eq 10) {     #custno plus shipmentno
                    my ($liste_shipmentno, $liste_lgmboxno) = query_lm_main("$custno","","$shipmentno","","10"); #reihenfolge: custno,cono,shipmentno,partno,abfragevariante (2-15)
                         if ($liste_shipmentno && $liste_lgmboxno) {
                              query_gls_gepard ($liste_shipmentno);
                              query_dhl_easylog ($liste_lgmboxno);
                              query_nightstar ($liste_lgmboxno);
                         }
              }
              if ($countvar eq 11) {     #custno plus shipmentno plus partno
                    my ($liste_shipmentno, $liste_lgmboxno) = query_lm_main("$custno","","$shipmentno","$partno","11"); #reihenfolge: custno,cono,shipmentno,partno,abfragevariante (2-15)
                         if ($liste_shipmentno && $liste_lgmboxno) {
                              query_gls_gepard ($liste_shipmentno);
                              query_dhl_easylog ($liste_lgmboxno);
                              query_nightstar ($liste_lgmboxno);
                         }
              }
              if ($countvar eq 12) {     #custno plus cono
                    my ($liste_shipmentno, $liste_lgmboxno) = query_lm_main("$custno","$cono","","","12"); #reihenfolge: custno,cono,shipmentno,partno,abfragevariante (2-15)
                         if ($liste_shipmentno && $liste_lgmboxno) {
                              query_gls_gepard ($liste_shipmentno);
                              query_dhl_easylog ($liste_lgmboxno);
                              query_nightstar ($liste_lgmboxno);
                         }
              }
              if ($countvar eq 13) {     #custno plus cono plus partno
                    my ($liste_shipmentno, $liste_lgmboxno) = query_lm_main("$custno","$cono","","$partno","13"); #reihenfolge: custno,cono,shipmentno,partno,abfragevariante (2-15)
                         if ($liste_shipmentno && $liste_lgmboxno) {
                              query_gls_gepard ($liste_shipmentno);
                              query_dhl_easylog ($liste_lgmboxno);
                              query_nightstar ($liste_lgmboxno);
                         }
              }
              if ($countvar eq 14) {     #custno plus cono plus shipmentno
                    my ($liste_shipmentno, $liste_lgmboxno) = query_lm_main("$custno","$cono","$shipmentno","","14"); #reihenfolge: custno,cono,shipmentno,partno,abfragevariante (2-15)
                         if ($liste_shipmentno && $liste_lgmboxno) {
                              query_gls_gepard ($liste_shipmentno);
                              query_dhl_easylog ($liste_lgmboxno);
                              query_nightstar ($liste_lgmboxno);
                         }
              }
              if ($countvar eq 15) {     #custno plus cono plus shipmentno plus partno
                    my ($liste_shipmentno, $liste_lgmboxno) = query_lm_main("$custno","$cono","$shipmentno","$partno","15"); #reihenfolge: custno,cono,shipmentno,partno,abfragevariante (2-15)
                         if ($liste_shipmentno && $liste_lgmboxno) {
                              query_gls_gepard ($liste_shipmentno);
                              query_dhl_easylog ($liste_lgmboxno);
                              query_nightstar ($liste_lgmboxno);
                         }
              }
         }
         elsif ($countvar eq 1) {                       #nur valid wenn alles ausser partno leer ist
              $form->field(name => 'partno', invalid => 1);
              print $form->render(header => 0, sticky => 1);
         }
         elsif ($countvar eq 0) {                       #alles leer? nochmal
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
#show empty searchform and sub from here depending on query_variant
sub showsearchform () {
##########################################
     my $countvar;
     my $filled_field_value = 0;

     @fields = qw(custno cono shipmentno lgmboxno partno);
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
                 label      => 'Kundennummer:',        # shown in front of <input>
                 required   => 0 ,          # must fill field in?
                 validate   => '/^\d{7}$/',      # validate user input
#                 comment    => 'zum Testen: 1603435',
         );
     $form->field(
                 name       => 'cono',          # name of field (required)
                 label      => 'Auftragsnummer:',        # shown in front of <input>
                 required   => 0 ,          # must fill field in?
                 validate   => '/^\d{4,6}$/',      # validate user input
         );
     $form->field(
                 name       => 'shipmentno',          # name of field (required)
                 label      => 'Lieferscheinnummer:',        # shown in front of <input>
                 required   => 0 ,          # must fill field in?
                 validate   => '/^\d{6}$/',      # validate user input
         );
	 $form->field(
                 name       => 'lgmboxno',          # name of field (required)
                 label      => 'LM-Paketnummer:',        # shown in front of <input>
                 required   => 0 ,          # must fill field in?
                 validate   => '/^\d{6,8}$/',      # validate user input
         );
     $form->field(
                 name       => 'partno',          # name of field (required)
                 label      => 'Artikelnummer:',        # shown in front of <input>
                 required   => 0 ,          # must fill field in?
                 validate   => '/^\d{5}(\d|x|X)$/',      # validate user input
                 comment    => 'Nach einer Artikelnummer kann nur ZUS&Auml;TZLICH gesucht werden.<br />',        # printed after field
         );
     if ($form->submitted && $form->validate) {
         # you would write code here to act on the form data
         $countvar = 0;                                #z�hvar zur�cksetzen, bin�r benutzt
                                                       #summe von countvar zeigt, welche felder gesetzt sind
                                                       #custno=50,partno=100, sonst einfach hochz�hlen
         my $custno = $form->field('custno');
         if (length($custno) > 1) {
               $countvar +=50;							#sonderfall nur custno beruecksichtigen
         }
         my $cono = $form->field('cono');              #dito
         if (length($cono) > 1) {
               $countvar ++;
         }
         my $shipmentno = $form->field('shipmentno');  #dito
         if (length($shipmentno) > 1) {
               $countvar ++;
         }
         my $lgmboxno = $form->field('lgmboxno');  #dito
         if (length($lgmboxno) > 1) {
               $countvar ++;
         }
         my $partno = $form->field('partno');          #wenn in partno was steht
         if (length($partno) > 1) {
               $countvar +=100;							#sonderfall nur partno beruecksichtigen
              $partno =~ tr/x/X/;                      #nur grosses X
         }
# print "<br>countvar = $countvar <br>\n";

         if ($countvar eq 100) {                       #nur valid wenn alles ausser partno leer ist
              $form->field(name => 'partno', invalid => 1);
              print $form->render(header => 0, sticky => 1);
         }
         elsif ($countvar eq 50 || $countvar eq 150) {  #custno or custno plus partno
              show_cono_level1($custno,$partno);
         }
         elsif ($countvar eq 0) {                       #alles leer? nochmal
              print "Keine Daten erhalten! Nochmal.<br />\n";
              $form->field(name => 'partno', invalid => 0);
              print $form->render(header => 0, sticky => 1);
         }
         elsif ($countvar ge 1 ) {                         #1 oder mehr als 1? alles gut
              print $form->confirm(header => 0);
              print "<br>\n";
              my ($liste_shipmentno, $liste_lgmboxno) = query_lm_main("$custno","$cono","$shipmentno","$partno","$lgmboxno","$countvar"); #reihenfolge: custno,cono,shipmentno,partno,lgmboxno,anzahl
              if ($liste_shipmentno && $liste_lgmboxno) {
					query_gls_gepard ($liste_shipmentno);
                    query_dhl_easylog ($liste_lgmboxno);
                    query_nightstar ($liste_lgmboxno);
              }
         }
         else {                                        #countvar nicht definiert? nochmal
              print "<br />ERROR<br />";
         }
	  }
     else {												# form noch nicht submittet oder nicht validiert
         print $form->render(header => 0);
     }
}

###########################################

# funktion f�r auswahl cono nach �bergabe custno und ggf. partno
sub show_cono_level1($;$) {
###########################################
     my $custno_var = $_[0];
     my $partno_var = $_[1];
     my $count = 1;
     my $var1;

     #jetzt select bauen mit oder ohne partno
     my $select1 = "SELECT distinct cono, date_format(priodate,'%d.%m.%Y') as 'date' FROM $FOC_TABLENAME
     where custno = '$custno_var'";
     if ($partno_var) {
          $select1 .= " and partno = '$partno_var'";
     }
     $select1 .= " and status = '2' order by cono";
#print "<br>Select: $select1 <br>\n";

     my $dbh = DBI->connect($DB_TYPE, $STAT_DB_USER, $STAT_DB_PASS, {RaiseError => 0}) or die "Database connection not made: $DBI::errstr";
     my $sth = $dbh->prepare($select1);
     $sth->execute();         #select ausf�hren
     $dbh->disconnect();      #database handle schliessen

     if ($sth->rows gt 0 ) {                 #wenn was gefunden wurde
          my @names = @{$sth->{NAME}};
          print "<h1>custno: $custno_var partno: $partno_var</h1>";

          print "<table border=1>\n".join("",map{'<th>'.$_.'</th>'}@names)."\n";
          while(my $row = $sth->fetchrow_hashref()){
               $count++;
               $var1 = "<tr>".join("",map{'<td>'.$_.'</td>'}@{$row}{@names})."</tr>\n";
               $var1 =~ s!(.*)(<td>)(\d{4,6})(<\/td>)(.*)!$1$2<a href="$SERVER_MAIN_FILENAME?level=scd;cono=$3" target="_blank">$3</a>$4$5!;  #relative URL!
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
     my ($liste_shipmentno, $liste_lgmboxno) = query_lm_main ("",$cono_var,"","","","08"); #reihenfolge: custno,cono,shipmentno,partno,lgmboxno abfragevariante (2-15)
     if ($liste_shipmentno && $liste_lgmboxno) {
          query_gls_gepard ($liste_shipmentno);
          query_dhl_easylog ($liste_lgmboxno);
          query_nightstar ($liste_lgmboxno);
     }
}

###########################################
#hauptabfrage lm
sub query_lm_main_alt ($$$$$){          #reihenfolge: custno,cono,shipmentno,partno,abfragevariante (02-15)
###########################################
     my $var_custno = $_[0];
     my $var_cono = $_[1];
     my $var_shipmentno = $_[2];
     my $var_partno = $_[3];
     my $query_variant = $_[4];
     my @names2;              #array f�r spaltennamen
     my $name;                #string f�r temp-var
     my $liste_shipmentno;    #var f�r r�ckgabeliste1
     my $liste_lgmboxno;      #var f�r r�ckgabeliste2

#if ($var_custno ) {print"<br>var custno def: $var_custno"};
#if ($var_cono ) {print"<br>var cono def: $var_cono "};
#if ($var_shipmentno  ) {print"<br>var shipmentno def: $var_shipmentno "};
#if ($var_partno  ) {print"<br>var partno def: $var_partno "};
#if ($query_variant  ) {print"<br>var query variant def: $query_variant <br>"};

     print "<br>Ergebnisse aus LM:<br>\n";

     #hier beginnt der query-string
     my $select2 = "
          SELECT distinct
     	 `lm1_data`.`custno`,
          `lm1_data`.`shipmentno`,
     	 date_format(`lm1_data`.`rec_date`,'%d.%m.%Y') as 'rec_date',
     	 date_format(`lm1_data`.`ack_date`,'%d.%m.%Y') as 'ack_date',
     	 `lm1_data`.`carrier`,
          `lm1_data`.`carrierboxno`,
     	 `lm1_data`.`lgmboxno`,
     	 `lm1_data`.`stockno`,
     	 `lm1_data`.`ext_carrierboxno` as 'Paketnummer'
          FROM
          `focus_data` `focus_data`
          INNER JOIN `lm1_data` `lm1_data`
          ON `focus_data`.`picklistno` = `lm1_data`.`picklistno`
          AND `focus_data`.`shipmentrowpos` = `lm1_data`.`picklistrowpos` ";    #die letzte zeile evtl nur bei partno gesetzt

     for ($query_variant) {   #die abfragevariante entscheidet, wie der querystring weitergeht
         if (/02/)      { $select2 .= " WHERE `focus_data`.`shipmentno` in ($var_shipmentno)";}     # do something else
         elsif (/03/)   { $select2 .= " WHERE `focus_data`.`shipmentno` in ($var_shipmentno) AND `focus_data`.`partno` IN ($var_partno)";}     # do something else
         elsif (/04/)   { $select2 .= " WHERE `focus_data`.`cono` in ($var_cono)";}     # do something else
         elsif (/05/)   { $select2 .= " WHERE `focus_data`.`cono` in ($var_cono) AND `focus_data`.`partno` IN ($var_partno)"; }     # do something else
         elsif (/06/)   { $select2 .= " WHERE `focus_data`.`cono` IN ($var_cono) AND `focus_data`.`shipmentno` IN ($var_shipmentno)"; }     # do something else
         elsif (/07/)   { $select2 .= " WHERE `focus_data`.`cono` IN ($var_cono) AND `focus_data`.`shipmentno` IN ($var_shipmentno) AND `focus_data`.`partno` IN ($var_partno)"; }     # do something else
         elsif (/08/)   { $select2 .= " WHERE `focus_data`.`cono` in ($var_cono)"; }     # do something else
         elsif (/09/)   { $select2 .= " WHERE `focus_data`.`cono` in ($var_cono) AND `focus_data`.`partno` IN ($var_partno)"; }     # do something else
         elsif (/10/)  { $select2 .= " WHERE `focus_data`.`custno` IN ($var_custno) AND `focus_data`.`shipmentno` IN ($var_shipmentno)";}     # do something else
         elsif (/11/)  { $select2 .= " WHERE `focus_data`.`custno` IN ($var_custno) AND `focus_data`.`shipmentno` IN ($var_shipmentno) AND `focus_data`.`partno` IN ($var_partno)";}     # do something else
         elsif (/12/)  { $select2 .= " WHERE `focus_data`.`cono` IN ($var_cono) AND `focus_data`.`custno` IN ($var_custno)";}     # do something else
         elsif (/13/)  { $select2 .= " WHERE `focus_data`.`cono` IN ($var_cono) AND `focus_data`.`custno` IN ($var_custno) AND `focus_data`.`partno` IN ($var_partno)";}     # do something else
         elsif (/14/)  { $select2 .= " WHERE `focus_data`.`cono` IN ($var_cono) AND `focus_data`.`custno` IN ($var_custno) AND `focus_data`.`shipmentno` IN ($var_shipmentno)";}     # do something else
        else           { $select2 .= " WHERE `focus_data`.`cono` IN ($var_cono) AND `focus_data`.`custno` IN ($var_custno) AND `focus_data`.`shipmentno` IN ($var_shipmentno) AND `focus_data`.`partno` IN ($var_partno)";}     # default
     }

     $select2 .= " ORDER by `lm1_data`.`ack_date`";         #die sortierreihenfolge
# print "<br>Select2: $select2<br><br>\n";
     my $dbh2 = DBI->connect($DB_TYPE, $STAT_DB_USER, $STAT_DB_PASS, {RaiseError => 0}) or die "Database connection not made: $DBI::errstr";
     my $sth2 = $dbh2->prepare($select2);
     $sth2->execute();
     $dbh2->disconnect();

     if ($sth2->rows gt 0 ) {                 #wenn was gefunden wurde
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
          $liste_shipmentno = join(',',@{$hash{'shipmentno'}});    #strings erzeugen f�r die r�ckgabe
          $liste_lgmboxno = join(',',@{$hash{'lgmboxno'}});

     }
     else {
          print "<b>Keine Daten gefunden!</b><br>\n";
          $liste_shipmentno = "";    #leere strings erzeugen f�r die r�ckgabe
          $liste_lgmboxno = "";

     }
# print "<br>liste shipment: $liste_shipmentno <br> liste boxno: $liste_lgmboxno<br><br>\n";
     return ($liste_shipmentno, $liste_lgmboxno);      #es werden ZWEI werte zur�ckgegeben
}

###########################################
#hauptabfrage lm
sub query_lm_main ($$$$$$){          #reihenfolge: custno,cono,shipmentno,partno,lgmboxno,abfragevariante
###########################################
     my $var_custno = $_[0];
     my $var_cono = $_[1];
     my $var_shipmentno = $_[2];
     my $var_partno = $_[3];
     my $var_lgmboxno = $_[4];
     my $query_variant = $_[5];
     my @names2;              #array f�r spaltennamen
     my $name;                #string f�r temp-var
     my $liste_shipmentno;    #var f�r r�ckgabeliste1
     my $liste_lgmboxno;      #var f�r r�ckgabeliste2
     my $countvar = 0;
     my $tmp_boxno;
     my $tmp_zipcode;

     print "<br>Ergebnisse aus LM:<br>\n";

     #hier beginnt der query-string
     my $select2 = "
          SELECT distinct
     	 `$LM1_TABLENAME`.`custno`,
         `$LM1_TABLENAME`.`shipmentno`,
     	 date_format(`$LM1_TABLENAME`.`rec_date`,'%d.%m.%Y') as 'rec_date',
     	 date_format(`$LM1_TABLENAME`.`ack_date`,'%d.%m.%Y') as 'ack_date',
     	 `$LM1_TABLENAME`.`zipcode`,
     	 `$LM1_TABLENAME`.`carrier`,
         `$LM1_TABLENAME`.`carrierboxno`,
     	 `$LM1_TABLENAME`.`lgmboxno`,
     	 `$LM1_TABLENAME`.`stockno`,
     	 `$LM1_TABLENAME`.`ext_carrierboxno` as 'Paketnummer'
         FROM
         `$FOC_TABLENAME` `focus_data`
         INNER JOIN `$LM1_TABLENAME` `lm1_data`
         ON `$FOC_TABLENAME`.`picklistno` = `$LM1_TABLENAME`.`picklistno`
         AND `$FOC_TABLENAME`.`shipmentrowpos` = `$LM1_TABLENAME`.`picklistrowpos`
         WHERE ";    #die letzte zeile evtl nur bei partno gesetzt

     if ($var_custno) {
     	$select2 .= "`$FOC_TABLENAME`.`custno` IN ($var_custno) ";
     	$countvar ++;
     	}

     if ($var_cono) {
     	if ($countvar ge 1) {
     		$select2 .= "AND ";
     	}
     	$select2 .= "`$FOC_TABLENAME`.`cono` in ($var_cono) ";
     	$countvar ++;
     }

     if ($var_shipmentno) {
     	if ($countvar ge 1) {
     		$select2 .= "AND ";
     	}
     	$select2 .= "`$FOC_TABLENAME`.`shipmentno` in ($var_shipmentno) ";
     	$countvar ++;
     }
     if ($var_lgmboxno) {
     	if ($countvar ge 1) {
     		$select2 .= "AND ";
     	}
     	$select2 .= "`$LM1_TABLENAME`.`lgmboxno` in ($var_lgmboxno) ";
     	$countvar ++;
     }
     if ($var_partno) {
     	if ($countvar ge 1) {
     		$select2 .= "AND ";
     	}
     	$select2 .= "`$FOC_TABLENAME`.`partno` IN ('$var_partno') ";
     	$countvar ++;
     }

#if ($query_variant) {print"<br>var query variant def: $query_variant <br>"};

     $select2 .= "ORDER by `$LM1_TABLENAME`.`ack_date`";         #die sortierreihenfolge
# print "<br>Select2: $select2<br><br>\n";
     my $dbh2 = DBI->connect($DB_TYPE, $STAT_DB_USER, $STAT_DB_PASS, {RaiseError => 0}) or die "Database connection not made: $DBI::errstr";
     my $sth2 = $dbh2->prepare($select2);
     $sth2->execute();
     $dbh2->disconnect();

     if ($sth2->rows gt 0 ) {                 #wenn was gefunden wurde
          @names2 = @{$sth2->{NAME}};
          print "<table border=1>\n".join("",map{'<th>'.$_.'</th>'}@names2)."\n";
          while(my $row = $sth2->fetchrow_hashref()){
               $count++;
               if (($row->{'carrier'} eq 'GP') && (length($row->{'Paketnummer'}) eq '12')) {
               		$tmp_boxno = $row->{'Paketnummer'};
               		$row->{'Paketnummer'} = "<a href=\"$TTO_SERVER_URL_GLS$tmp_boxno\" target=\"_blank\">$tmp_boxno</a>";
               }

               if (($row->{'carrier'} eq 'DP') && (length($row->{'Paketnummer'}) eq '12') && (length($row->{'zipcode'}) eq '5')) {
               		$tmp_boxno = $row->{'Paketnummer'};
               		$tmp_zipcode = $row->{'zipcode'};
               		$row->{'Paketnummer'} = "<a href=\"$TTO_SERVER_URL_DHL$tmp_zipcode&idc=$tmp_boxno\" target=\"_blank\">$tmp_boxno</a>";
               }
               $var1 = "<tr>".join("",map{'<td>'.$_.'</td>'}@{$row}{@names2})."</tr>\n";
#			   $var1 =~ s!((?:<td>.*?</td>){8})<td>(.*?)</td>!$1<td><a href="$SERVER_MAIN_FILENAME?level=scd;cono=$2" target="_blank">$2</a></td>!;
               print $var1;
               for $name(@names2){
                    push @{$hash{$name}},$row->{$name};
               }
          }
          print "</table><br>\n";
          $liste_shipmentno = join(',',@{$hash{'shipmentno'}});    #strings erzeugen f�r die r�ckgabe
          $liste_lgmboxno = join(',',@{$hash{'lgmboxno'}});

     }
     else {
          print "<b>Keine Daten gefunden!</b><br>\n";
          $liste_shipmentno = "";    #leere strings erzeugen f�r die r�ckgabe
          $liste_lgmboxno = "";

     }
# print "<br>liste shipment: $liste_shipmentno <br> liste boxno: $liste_lgmboxno<br><br>\n";
     return ($liste_shipmentno, $liste_lgmboxno);      #es werden ZWEI werte zur�ckgegeben
}


###########################################
#abfrage 1 gepard
sub query_gls_gepard($){
###########################################

     my $liste_shipmentno = $_[0];        #�bergabe der shipmentnos als string
     my $tmp_boxno;

     print "<br>Ergebnisse aus GLS Gepard (manueller Versand):\n";
     print "<br>\n";

     my $select3 = "
     SELECT g.shipmentno, g.name1, g.name2,
     g.street, g.zipcode, g.city, g.unknown8 as 'lgmboxno',
     g.stockno, date_format(g.date1,'%d.%m.%Y') as 'date1',
     g.carrierboxno  FROM $GLS_GEP1_TABLENAME g
     where g.shipmentno in ($liste_shipmentno)";
#print "\n$select3\n";
     my $dbh3 = DBI->connect($DB_TYPE, $STAT_DB_USER, $STAT_DB_PASS, {RaiseError => 0}) or die "Database connection not made: $DBI::errstr";
     my $sth3 = $dbh3->prepare($select3);
     $sth3->execute();
     $dbh3->disconnect();

     if ($sth3->rows gt 0 ) {                 #wenn was gefunden wurde
          my @names3 = @{$sth3->{NAME}};
          print "<table border=1>\n".join("",map{'<th>'.$_.'</th>'}@names3)."\n";
          while(my $row = $sth3->fetchrow_hashref()){
               $count++;
               if (length($row->{'carrierboxno'}) eq '12') {
               		$tmp_boxno = $row->{'carrierboxno'};
               		$row->{'carrierboxno'} = "<a href=\"$TTO_SERVER_URL_GLS$tmp_boxno\" target=\"_blank\">$tmp_boxno</a>";
               }

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
     SELECT
     d.shipmentno,
     date_format(`d`.`credate`,'%d.%m.%Y') as 'date',
     d.name1,
     d.name2,
     d.street,
     d.street_number,
     d.zipcode,
     d.city,
     d.countrycode,
     d.stockno,
     d.lgmboxno,
     d.carrierboxno
     FROM $DHL_EASY1_TABLENAME d
     where d.lgmboxno in ($liste_lgmboxno)";

     my $dbh4 = DBI->connect($DB_TYPE, $STAT_DB_USER, $STAT_DB_PASS, {RaiseError => 0}) or die "Database connection not made: $DBI::errstr";
     my $sth4 = $dbh4->prepare($select4);
     $sth4->execute();
     $dbh4->disconnect();

     if ($sth4->rows gt 0 ) {                 #wenn was gefunden wurde
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
     n.stockno, date_format(n.shipdate,'%d.%m.%Y') as 'shipdate' FROM nightstar1_out n
     WHERE n.lgmboxno in ($liste_lgmboxno)";

     my $dbh5 = DBI->connect($DB_TYPE, $STAT_DB_USER, $STAT_DB_PASS, {RaiseError => 0}) or die "Database connection not made: $DBI::errstr";
     my $sth5 = $dbh5->prepare($select5);
     $sth5->execute();

     if ($sth5->rows gt 0 ) {                 #wenn was gefunden wurde
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

     if ($sth6->rows gt 0 ) {                 #wenn was gefunden wurde
          print "<font color=\"#FF0000\">\n";
          print "<br>FEHLER!<br>F�r die folgenden cono's wurde kein Nighstar Ausgang gefunden, obwohl sie im LM entsprechend markiert sind:\n";
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