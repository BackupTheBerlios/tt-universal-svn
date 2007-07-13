#!/usr/bin/perl
if ($debug) {print "Debug Global pm\n"};

###########################################
sub trim($) {                      #param: string
###########################################
  my $string = shift;
  $string =~ s/^\s+//;
  $string =~ s/\s+$//;
  return $string;
}

###########################################
# Left trim function to remove leading whitespace
sub ltrim($) {                     #param: string
###########################################
  my $string = shift;
  $string =~ s/^\s+//;
  return $string;
}

###########################################
# Right trim function to remove trailing whitespace
sub rtrim($) {                     #param: string
###########################################
  my $string = shift;
  $string =~ s/\s+$//;
  return $string;
}

###########################################
# Write entry in log db
sub write_log_entry($$$$) {        #param: quelle, kategorie, text, anzahl der bearbeiteten zeilen
###########################################

  my $log_source = $_[0];
  my $log_cat = $_[1];
  my $log_text = $_[2];
  my $itemcount = $_[3];
  $log_text =~ tr/'//d;             #hochkommas entfernen
  my $log_dbhandle = DBI->connect($DB_TYPE, $STAT_DB_USER, $STAT_DB_PASS, {RaiseError => 0}) or die "Database connection not made: $DBI::errstr";
  my $log_sql = "INSERT INTO import_log (`count` , `source` , `category` , `logtime` , `remark` , `lines_read` )
  VALUES (NULL ,\'$log_source\',\'$log_cat\', NOW(), \'$log_text\', \'$itemcount\')";
  $log_dbhandle->do($log_sql);
  $log_dbhandle->disconnect();
  return $log_sql;
}

###########################################
sub get_focus {
###########################################

     if ($debug) {print "Debug Start get_focus\n"};
     my $countvar = 0;

     #get filelist
     opendir (DIR,"$STAT_STARTDIR/$FOC_IMPORTDIR") || die "Opendir $STAT_STARTDIR/$FOC_IMPORTDIR not possible: $!";
     my @filelist = grep { -f "$STAT_STARTDIR/$FOC_IMPORTDIR/$_" } readdir(DIR);
     closedir DIR;

     #create logfile entry
     write_log_entry("get_focus","INFO","READ START","");

     if (@filelist lt 1 )
     {
	    # return early from subdir if dir empty and nothing to do
        write_log_entry("get_focus","INFO","READ STOP Nothing to do","0");
	    return;
     }

     #open connection to log and data db
     my $dbhandle = DBI->connect($DB_TYPE, $STAT_DB_USER, $STAT_DB_PASS, {RaiseError => 0}) or die "Database connection not made: $DBI::errstr";
# print "focus-pfad: $STAT_STARTDIR/$FOC_IMPORTDIR";
     #process each file found
     foreach my $file ( @filelist ) {
        my	$INFILE_filename = "$STAT_STARTDIR/$FOC_IMPORTDIR/$file"; # input file name
        open ( INFILE, '<', $INFILE_filename ) or die  "$0 : failed to open input file $INFILE_filename : $!\n";
        while (<INFILE>){
             next if m/^\s*$/;        # Leerzeilen ignorieren
             next if m/^trunc/;       # truncatingzeilen ignorieren
             chomp;                   # zeilenvorschub raus
             my @zeile = split (/;/); #am semikolon auftrennen
             if ($#zeile == 10){      #nur 11 spalten? dann fehlt eine
                  push @zeile,'';     # eine leere spalte hinzufuegen
             };
             for(my $i=0;$i<=$#zeile;$i++) {
                  $zeile[$i] = trim($zeile[$i]);
                  if ($zeile[$i] eq "") {    # Leerer Wert? Dann DEFAULT Befehl übergeben.
                    $zeile[$i] = 'DEFAULT';
                  } else { #was drin? dann verpacken
                    $zeile[$i] =~ tr/'//d;             #hochkommas entfernen
                    $zeile[$i] = "\'".$zeile[$i]."\'";
                  }
             }
             my $sql = "INSERT IGNORE INTO `$FOC_TABLENAME`
             ( `cono` , `custno` , `rowpos` , `rowsubpos` , `rowseq` , `priodate` , `partno` , `picklistno` , `shipmentno` , `shipmentrowpos` , `stocknosu` , `status` )
             VALUES
             ($zeile[0],$zeile[1],$zeile[2],$zeile[3],$zeile[4],$zeile[5],$zeile[6],$zeile[7],$zeile[8],$zeile[9],$zeile[10],$zeile[11])";
             $dbhandle->do($sql);
             $countvar++;
             }
        close ( INFILE ) or warn "$0 : failed to close input file $INFILE_filename : $!\n";
        #move file to save-dir
        move2save("$STAT_STARTDIR/$FOC_IMPORTDIR","$STAT_STARTDIR/$STAT_SAVEDIR","$file");
        write_log_entry("get_focus","INFO","FILENAME:$file","0");    #statusinfo zu jeder datei
     } # -----  end foreach  -----

     #create logfile entry
     write_log_entry("get_focus","INFO","READ END","$countvar");
  print "$file\n";
     if ($debug) {print "Debug Ende get_focus\n"};
}

###########################################
sub get_lm1 {
###########################################
     if ($debug) {print "Debug Start lm1\n"};

     my $countvar = 0;
     my $external_boxno = '';

     #get filelist
     opendir (DIR,"$STAT_STARTDIR/$LM1_IMPORTDIR") || die "Opendir $STAT_STARTDIR/$LM1_IMPORTDIR not possible: $!";
     my @filelist = grep { -f "$STAT_STARTDIR/$LM1_IMPORTDIR/$_" } readdir(DIR);
     closedir DIR;

     #create logfile entry
     write_log_entry("get_lm1","INFO","READ START","");

     if (@filelist lt 1 )
     {
	    # return early from subdir if dir empty and nothing to do
        write_log_entry("get_lm1","INFO","READ STOP Nothing to do","0");
	    return;
     }

     #open connection to log and data db
     my $dbhandle = DBI->connect($DB_TYPE, $STAT_DB_USER, $STAT_DB_PASS, {RaiseError => 0}) or die "Database connection not made: $DBI::errstr";

     #process each file found
     foreach my $file ( @filelist ) {
        my	$INFILE_filename = "$STAT_STARTDIR/$LM1_IMPORTDIR/$file"; # input file name
        open ( INFILE, '<', $INFILE_filename ) or die  "$0 : failed to open input file $INFILE_filename : $!\n";
        while (<INFILE>){
             next if m/^\s*$/;        # Leerzeilen ignorieren
             next if m/^trunc/;       # truncatingzeilen ignorieren
             chomp;                   # zeilenvorschub raus
             my @zeile = split (/;/); #am semikolon auftrennen
             if ($#zeile == 8){       #nur 9 spalten? dann fehlen zwei
                  push @zeile,'';     # zwei leere spalten hinzufuegen
                  push @zeile,'';
             };
             if ($#zeile == 9){       #nur 10 spalten? dann fehlen zwei
                  push @zeile,'';     # leere spalte hinzufuegen
             };

             for(my $i=0;$i<=$#zeile;$i++) {        #trimmen vor der ermittlung der ext_paketnummer
                  $zeile[$i] = trim($zeile[$i]);
             }
             # spalte7 = carrier
             # spalte8 = lgmboxno
             # spalte9 = carrierboxno
             # NEU spalte10 = zipcode

             $external_boxno = '';  #variable wieder leeren
             if (($zeile[7] eq 'GP' || $zeile[7] eq 'DP' ) && ($zeile[8] ne $zeile[9]) ) { #carrier GP oder DP und lgmboxno ungleich carrierboxno? dann externe paketnummer berechnen
                 $external_boxno = calc_carrierboxno($zeile[9], $zeile[7], $zeile[0]); # 1=carrierboxno 2=carrier 3=stockno
             }
             # spalte 10 jetzt erzeugen fuer ext_carrierboxno
             # NEU spalte 11 jetzt erzeugen fuer ext_carrierboxno
             push @zeile, $external_boxno;   # auf jeden fall zeile mit externalboxno anfuegen
             for(my $i=0;$i<=$#zeile;$i++) {
                  $zeile[$i] = trim($zeile[$i]);
                  if ($zeile[$i] eq "") {    # Leerer Wert? Dann DEFAULT Befehl übergeben.
                    $zeile[$i] = 'DEFAULT';
                  } else { #was drin? dann verpacken
                    $zeile[$i] =~ tr/'//d;             #hochkommas entfernen
                    $zeile[$i] = "\'".$zeile[$i]."\'";
                  }
             }
             my $sql = "INSERT IGNORE INTO `$LM1_TABLENAME` ( `stockno` , `custno` , `picklistno` , `shipmentno` , `picklistrowpos` , `rec_date` , `ack_date` , `carrier` , `lgmboxno` , `carrierboxno` , `zipcode` ,`ext_carrierboxno` )
VALUES ($zeile[0],$zeile[1],$zeile[2],$zeile[3],$zeile[4],$zeile[5],$zeile[6],$zeile[7],$zeile[8],$zeile[9],$zeile[10],$zeile[11])";
# print "\n$sql\n";
             $dbhandle->do($sql) or warn "do sql error:\n$sql\nDBI Error: $DBI::errstr";
             $countvar++;
             }
        close ( INFILE ) or warn "$0 : failed to close input file $INFILE_filename : $!\n";
        #move file to save-dir
        move2save("$STAT_STARTDIR/$LM1_IMPORTDIR","$STAT_STARTDIR/$STAT_SAVEDIR","$file");
        write_log_entry("get_lm1","INFO","FILENAME:$file","0");    #statusinfo zu jeder datei
     } # -----  end foreach  -----

     #create logfile entry
     write_log_entry("get_lm1","INFO","READ END","$countvar");

     if ($debug) {print "Debug Ende get_lm1\n"};
}

###########################################
sub move2save($$$;$) {             #param: woher, wohin, dateiname, (opt) warehouse
###########################################
     my $warehouse;
     my $from_dir = $_[0];
     my $to_dir = $_[1];
     my $file = $_[2];
     if (defined $_[3]) {
         $warehouse = $_[3];
     }
     else {
         $warehouse = '000';
     }

#print "\nfrom: $from_dir to: $to_dir file: $file\n";
     my $timestamp = get_timestamp();
     my $mon2 = substr($timestamp,4,2);
     my $year2 = substr($timestamp,0,4);

     unless (-d $to_dir)                #save dir vorhanden?
     {
     mkdir $to_dir, 0777 or die "mkdir $to_dir not possibe! $!\n";
     }

     unless (-d "$to_dir/$year2")        #jahr vorhanden?
     {
     mkdir "$to_dir/$year2", 0777 or die "mkdir $to_dir/$year2 not possibe! $!\n";
     }

     unless (-d "$to_dir/$year2/$mon2")   #monat vorhanden?
     {
     mkdir "$to_dir/$year2/$mon2", 0777 or die "mkdir $to_dir/$year2/$mon2 not possibe! $!\n";
     }

#print "Von: $from_dir \nNach: $to_dir/$year2/$mon2 \nFilename im SUB: $file \nMonat: $mon2 Jahr: $year2 Lager: $warehouse\n";
     move("$from_dir/$file","$to_dir/$year2/$mon2/$file\.$timestamp\.$warehouse\.done") or die "file $file: move not possible! $!\n";
}

###########################################
sub get_timestamp(;$) {            #param: (opt) timestampformat
###########################################

    my ($format) = @_;
    $format = 'CCYYMMDDhhmmss' if not defined $format;

    my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) =
        localtime(time);

    my %fields = (
        CC => int(($year + 1900) / 100),
        YY => $year % 100,
        MM => $mon + 1,
        DD => $mday,
        hh => $hour,
        mm => $min,
        ss => $sec
    );

    %fields = map {$_ => sprintf('%02u', $fields{$_})} keys %fields;

    foreach my $field (keys %fields) {
        $format =~ s/$field/$fields{$field}/g;
    }

    return $format;
}

###########################################
# get all dhl easylog data
sub get_dhl1($) {                  #param: warehouse
###########################################
$debug = 1;
     if ($debug) {print "Debug Start get_dhl1\n"};
     my $warehouse = $_[0];        #erster parameter = warehouse / stockno
     if ($debug) {print "Debug $warehouse\n"};

     my $countvar = 0;
     my $filelist;
     my	$INFILE_filename;
     my @zeile;
     my $sapo_true;
     my $datadate;
     my $filecount;
     my $filetreatment;
     my @save_zeile;
     my $parcelno_save;


     #get filelist
     if ( $warehouse eq '160' ) {                        #pfad für stockno 160
          opendir (DIR,"$STAT_STARTDIR/$DHL_EASY1_IMPORTDIR") || die "Opendir $STAT_STARTDIR/$DHL_EASY1_IMPORTDIR not possible: $!";
          if ($debug) {print "$STAT_STARTDIR/$DHL_EASY1_IMPORTDIR\n"};
          @filelist = grep { -f "$STAT_STARTDIR/$DHL_EASY1_IMPORTDIR/$_" } readdir(DIR);
          if ($debug) {print @filelist,"\n"};
          closedir DIR;
     }
     if ( $warehouse eq '210' ) {                        #pfad für stockno 210
          opendir (DIR,"$STAT_STARTDIR/$DHL_EASY2_IMPORTDIR") || die "Opendir $STAT_STARTDIR/$DHL_EASY2_IMPORTDIR not possible: $!";
          if ($debug) {print "$STAT_STARTDIR/$DHL_EASY2_IMPORTDIR\n"};
          @filelist = grep { -f "$STAT_STARTDIR/$DHL_EASY2_IMPORTDIR/$_" } readdir(DIR);
          if ($debug) {print @filelist,"\n"};
          closedir DIR;
     }

     #create logfile entry
     write_log_entry("get_dhl1","INFO","READ START STOCKNO $warehouse","");

     if (@filelist lt 1 )
     {
	    # return early from subdir if dir empty and nothing to do
        write_log_entry("get_dhl1","INFO","READ STOP Nothing to do","0");
        if ($debug) {print @filelist,"\n"};
        if ($debug) {print "Debug NOTHING TO DO\n"};
	    return;
     }

     #open connection to log and data db
     my $dbhandle = DBI->connect($DB_TYPE, $STAT_DB_USER, $STAT_DB_PASS, {RaiseError => 0}) or die "Database connection not made: $DBI::errstr";

     #process each file found
     foreach my $file ( @filelist ) {
        if ( $warehouse eq '160' ) {                        #pfad für stockno 160
             $INFILE_filename = "$STAT_STARTDIR/$DHL_EASY1_IMPORTDIR/$file"; # input file name
        } elsif ( $warehouse eq '210' ) {                        #pfad für stockno 210
             $INFILE_filename = "$STAT_STARTDIR/$DHL_EASY2_IMPORTDIR/$file"; # input file name
        }
        open ( INFILE, '<', $INFILE_filename ) or die  "$0 : failed to open input file $INFILE_filename : $!\n";
        while (<INFILE>){
             next if m/^\s*$/;        # Leerzeilen ignorieren
             next if m/^trunc/;       # truncatingzeilen ignorieren
             next if m/^SAZO/;        # Zollsatzzeilen ignorieren
             next if m/^SANE/;        # Nachrichtenendezeilen ignorieren
             next if m/^SADE/;        # Dateiendezeilen ignorieren
             next if m/^SAPA/;        # Partnerrollenzeilen ignorieren
             chomp;                   # zeilenvorschub raus
             @zeile = split (/;/);    #am semikolon auftrennen
             $sapo_true = 0;          #kein Paketdatensatz
             for(my $i=0;$i<=$#zeile;$i++) {
                  $zeile[$i] = trim($zeile[$i]);             #werte trimmen
             }      #end for
             if ($zeile[0] =~ /SADK/) {
                  $datadate = substr($zeile[3],0,4)."-".substr($zeile[3],4,2)."-".substr($zeile[3],6,2); # Datum der Dateierstellung
                  $filecount = $zeile[2]; # Fortlaufende Nummerierung der Datei im Verfahren
             }
             elsif ($zeile[0] =~ /SANK/) {
                  $filetreatment = $zeile[4];       #Nummer des Verfahrens
             }
             elsif ($zeile[0] =~ /SAPO/) {
                  $sapo_true = 1;                   #Paketdatensatz erreicht
                  if ($zeile[2] > 1 ) {                #mehr als ein Packstück
                       @save_zeile = @zeile;        #Datensatz merken
                  }
                  else {                               #nur ein Packstück
                       undef(@save_zeile);             # dann gemerkten Datensatz vergessen
                  }
             }
             elsif ($zeile[0] =~ /SAZU/) {
                  if ($filetreatment == 72  && $zeile[1] eq 'ZI20') { #verfahren 72 und leistungskürzel gleich ZI20
                       $parcelno_save = $zeile[2];      #paketnummer aufheben
                       @zeile = @save_zeile;               #den gespeicherte sapo-datensatz zurückholen
                       $zeile[10] = $parcelno_save;        #die Paketnummer mit der gespeicherten überschreiben
                       $sapo_true = 1;                   #Paketdatensatz erreicht
                  }
             }
             if ($#zeile lt 25 ){                       #genug records anhängen um mindestns 25 elemente zu haben
                for(my $i=1;$i<=25;$i++) {
                     push @zeile,'';
                }
             }
             $zeile[24] = $datadate;                        #zeile[24] = datum
             $zeile[25] = $warehouse;                       #zeile[25] = stockno
             if ($sapo_true ) {                            #nur SAPO Sätze wegschreiben
                  for(my $i=0;$i<=$#zeile;$i++) {          #Nochmal durch alle Felder gehen und leere Werte anpassen
                       if ($zeile[$i] eq "") {             # Leerer Wert? Dann DEFAULT Befehl übergeben.
                         $zeile[$i] = 'DEFAULT';
                       } else { #was drin? dann verpacken
                         $zeile[$i] =~ tr/'//d;            #hochkommas entfernen
                         if ($i eq 9 ) {                   #bei feld lgmboxno die 4 letzten stellen abschneiden
	                         $zeile[$i] = substr($zeile[$i],0,length($zeile[$i])-4);
                         }
                         $zeile[$i] = "\'".$zeile[$i]."\'";
                       }
                  }
                  my $sql = "INSERT IGNORE INTO `$DHL_EASY1_TABLENAME`
                  ( `recordtype` , `rowpos` , `parcelcount` , `packing` , `weight` , `volume` , `length` , `width` , `height` , `lgmboxno` , `carrierboxno` , `routingcode` , `servicecode` , `shipmentno` , `name1` , `name2` , `name3` , `street` , `street_number` , `city` , `zipcode` , `countrycode` , `contactperson1` , `contactperson2` , `credate` , `stockno` )
                  VALUES
                  ($zeile[0],$zeile[1],$zeile[2],$zeile[3],$zeile[4],$zeile[5],$zeile[6],$zeile[7],$zeile[8],$zeile[9],$zeile[10],$zeile[11],$zeile[12],$zeile[13],$zeile[14],$zeile[15],$zeile[16],$zeile[17],$zeile[18],$zeile[19],$zeile[20],$zeile[21],$zeile[22],$zeile[23],$zeile[24],$zeile[25])";
                  $dbhandle->do($sql) or warn "\nERROR. SQL: $sql\nfile: $INFILE_filename\n";
#                  print $sql,"\n";
                  $countvar++;
             }  # --- end if
        }  # --- end while
        close ( INFILE ) or warn "$0 : failed to close input file $INFILE_filename : $!\n";
        #move file to save-dir
        if ( $warehouse eq '160' ) {                        #pfad für stockno 160
#             move2save("$STAT_STARTDIR/$DHL_EASY1_IMPORTDIR","$STAT_STARTDIR/$STAT_SAVEDIR","$file","$warehouse");
        } elsif ( $warehouse eq '210' ) {                        #pfad für stockno 210
#             move2save("$STAT_STARTDIR/$DHL_EASY2_IMPORTDIR","$STAT_STARTDIR/$STAT_SAVEDIR","$file","$warehouse");
# TODO move2save bei get_dhl1 wieder einschalten
        }
        write_log_entry("get_dhl1","INFO","FILENAME:$file VERFAHREN:$filetreatment LFD-NUMMER:$filecount","0");    #statusinfo zu jeder datei
     } # -----  end foreach  -----

     #create logfile entry
     write_log_entry("get_dhl1","INFO","READ END","$countvar");

     if ($debug) {print "Debug Ende get_dhl1\n"};
     return 1;
}

###########################################
# get all gls data
sub get_gls1($) {                  #param: warehouse
###########################################
$debug = 1;
     if ($debug) {print "Debug Start get_gls1\n"};
     my $warehouse = $_[0];        #erster parameter = warehouse / stockno
     if ($debug) {print "Debug $warehouse\n"};

     my $countvar = 0;
     my $filelist;
     my	$INFILE_filename;
     my @zeile;
     my $datadate;
     my $rec_format;
     my $countcolumn;
     my $temp;
     my $city;


     #get filelist
     if ( $warehouse eq '160' ) {                        #pfad für stockno 160
          opendir (DIR,"$STAT_STARTDIR/$GLS_GEP1_IMPORTDIR") || die "Opendir $STAT_STARTDIR/$GLS_GEP1_IMPORTDIR not possible: $!";
          if ($debug) {print "$STAT_STARTDIR/$GLS_GEP1_IMPORTDIR\n"};
          @filelist = grep { -f "$STAT_STARTDIR/$GLS_GEP1_IMPORTDIR/$_" } readdir(DIR);
          if ($debug) {print @filelist,"\n"};
          closedir DIR;
     }
     if ( $warehouse eq '210' ) {                        #pfad für stockno 210
          opendir (DIR,"$STAT_STARTDIR/$GLS_GEP2_IMPORTDIR") || die "Opendir $STAT_STARTDIR/$GLS_GEP2_IMPORTDIR not possible: $!";
          if ($debug) {print "$STAT_STARTDIR/$GLS_GEP2_IMPORTDIR\n"};
          @filelist = grep { -f "$STAT_STARTDIR/$GLS_GEP2_IMPORTDIR/$_" } readdir(DIR);
          if ($debug) {print @filelist,"\n"};
          closedir DIR;
     }

     #create logfile entry
     write_log_entry("get_gls1","INFO","READ START STOCKNO $warehouse","");

     if (@filelist lt 1 )
     {
	    # return early from subdir if dir empty and nothing to do
        write_log_entry("get_gls1","INFO","READ STOP Nothing to do","0");
        if ($debug) {print @filelist,"\n"};
        if ($debug) {print "Debug NOTHING TO DO\n"};
	    return;
     }

     #open connection to log and data db
     my $dbhandle = DBI->connect($DB_TYPE, $STAT_DB_USER, $STAT_DB_PASS, {RaiseError => 0}) or die "Database connection not made: $DBI::errstr";

     #process each file found
     foreach my $file ( @filelist ) {
        if ( $warehouse eq '160' ) {                        #pfad für stockno 160
             $INFILE_filename = "$STAT_STARTDIR/$GLS_GEP1_IMPORTDIR/$file"; # input file name
        } elsif ( $warehouse eq '210' ) {                        #pfad für stockno 210
             $INFILE_filename = "$STAT_STARTDIR/$GLS_GEP2_IMPORTDIR/$file"; # input file name
        }
        open ( INFILE, '<', $INFILE_filename ) or die  "$0 : failed to open input file $INFILE_filename : $!\n";
        while (<INFILE>){
             next if m/^\s*$/;        # Leerzeilen ignorieren
             next if m/^trunc/;       # truncatingzeilen ignorieren
             chomp;                   # zeilenvorschub raus
             @zeile = split (/\|/);   # am pipe auftrennen
             $countcolumn = $#zeile;  # anzahl der arrayelemente aufheben
             for (my $i=0;$i<=$#zeile;$i++) {
                  $zeile[$i] = trim($zeile[$i]);             #werte trimmen
             }      #end for
             # erkennen des recordformats
             if ($countcolumn == 21 || $countcolumn == 22) {         #format GP
              	$rec_format = 'GP';
             }
             elsif ($countcolumn == 16 || $countcolumn == 15) {      #format GPMON
               	$rec_format = 'GPMON';
               	( $temp, $temp, $city ) = &splitcountry($zeile[15]);  #ort herauslösen aus string mit land und plz
               	push @zeile,$city;                                    #und an array dranhängen
               	if ($countcolumn == 15) {
                	push @zeile,'';            #shipmentno leer? dann leere spalte anfügen
                }
             }
             else {      #not valid
                write_log_entry("get_gls1","ERROR","SKIP line in: $INFILE_filename Number of columns: $countcolumn Not defined.","0");
               	next;
             }
             if ($countcolumn == 22) {         #wenn 22 spalten dann letzte spalte = stockno
              	$zeile[22] = $warehouse;
             }
             else {
                push @zeile,$warehouse;                   #sonst letzte zeile anhängen
             }

             for(my $i=0;$i<=$#zeile;$i++) {          #Nochmal durch alle Felder gehen und leere Werte anpassen
                 if ($zeile[$i] eq "") {             # Leerer Wert? Dann DEFAULT Befehl übergeben.
                   $zeile[$i] = 'DEFAULT';
                 } else { #was drin? dann verpacken
                   $zeile[$i] =~ tr/'//d;             #hochkommas entfernen
                   $zeile[$i] = "\'".$zeile[$i]."\'";
                 }
              }
              if ($rec_format eq 'GP') {         #format GP
                    $sql = "INSERT IGNORE INTO `$GLS_GEP1_TABLENAME`
                    ( `carrierboxno` , `date1` , `unknown1` , `unknown2` , `unknown3` , `unknown4` , `unknown5` , `date2` , `countrycode` , `zipcode` , `unknown6` , `unknown7` , `shipmentno` , `name1` , `name2` , `name3` , `street` , `city` , `unknown8` , `zipcode2` , `unknown9` , `unknown10` , `stockno` )
                    VALUES
                    ($zeile[0],$zeile[1],$zeile[2],$zeile[3],$zeile[4],$zeile[5],$zeile[6],$zeile[7],$zeile[8],$zeile[9],$zeile[10],$zeile[11],$zeile[12],$zeile[13],$zeile[14],$zeile[15],$zeile[16],$zeile[17],$zeile[18],$zeile[19],$zeile[20],$zeile[21],$zeile[22])";
              }
              elsif ($rec_format eq 'GPMON') { #format GPMON
                    $sql = "INSERT IGNORE INTO `$GLS_GEP1_TABLENAME`
                    ( `carrierboxno` , `date1` , `unknown1` , `unknown12` , `unknown3` , `unknown4` , `unknown5` , `date2` , `countrycode` , `zipcode` , `unknown6` , `unknown7` , `unknown13` , `name1` , `street` , `city2` , `shipmentno` , `city`, `stockno` )
                    VALUES
                    ($zeile[0],$zeile[1],$zeile[2],$zeile[3],$zeile[4],$zeile[5],$zeile[6],$zeile[7],$zeile[8],$zeile[9],$zeile[10],$zeile[11],$zeile[12],$zeile[13],$zeile[14],$zeile[15],$zeile[16],$zeile[17],$zeile[18])";
              }
              $dbhandle->do($sql) or warn "\nERROR. SQL: $sql\nfile: $INFILE_filename\n";
#              print $sql,"\n";
              $countvar++;
        }  # --- end while
        close ( INFILE ) or warn "$0 : failed to close input file $INFILE_filename : $!\n";
        #move file to save-dir
        if ( $warehouse eq '160' ) {                        #pfad für stockno 160
             move2save("$STAT_STARTDIR/$GLS_GEP1_IMPORTDIR","$STAT_STARTDIR/$STAT_SAVEDIR","$file","$warehouse");
        } elsif ( $warehouse eq '210' ) {                        #pfad für stockno 210
             move2save("$STAT_STARTDIR/$GLS_GEP2_IMPORTDIR","$STAT_STARTDIR/$STAT_SAVEDIR","$file","$warehouse");
        }
        write_log_entry("get_gls1","INFO","FILENAME:$file","0");    #statusinfo zu jeder datei
     } # -----  end foreach  -----

     #create logfile entry
     write_log_entry("get_gls1","INFO","READ END","$countvar");

     if ($debug) {print "Debug Ende get_gls1\n"};
     return 1;
}

###########################################
# get all data from nightstar that are sent
sub get_nightstar_send1($) {       #param: warehouse
###########################################
$debug = 1;
     if ($debug) {print "Debug Start get_nightstar_send1\n"};
     my $warehouse = $_[0];        #erster parameter = warehouse / stockno
     if ($debug) {print "Debug $warehouse\n"};

     my $countvar = 0;
     my $filelist;
     my	$INFILE_filename;
     my @zeile;
     my $datadate;
     my $rec_format;
     my $temp;
     my $countcolumn;


     #get filelist
     if ( $warehouse eq '160' ) {                        #pfad für stockno 160
          opendir (DIR,"$STAT_STARTDIR/$NIGHT1_OUT_IMPORTDIR") || die "Opendir $STAT_STARTDIR/$NIGHT1_OUT_IMPORTDIR not possible: $!";
          if ($debug) {print "$STAT_STARTDIR/$NIGHT1_OUT_IMPORTDIR\n"};
          @filelist = grep { -f "$STAT_STARTDIR/$NIGHT1_OUT_IMPORTDIR/$_" } readdir(DIR);
          if ($debug) {print @filelist,"\n"};
          closedir DIR;
     }
     if ( $warehouse eq '210' ) {                        #pfad für stockno 210
          opendir (DIR,"$STAT_STARTDIR/$NIGHT2_OUT_IMPORTDIR") || die "Opendir $STAT_STARTDIR/$NIGHT2_OUT_IMPORTDIR not possible: $!";
          if ($debug) {print "$STAT_STARTDIR/$NIGHT2_OUT_IMPORTDIR\n"};
          @filelist = grep { -f "$STAT_STARTDIR/$NIGHT2_OUT_IMPORTDIR/$_" } readdir(DIR);
          if ($debug) {print @filelist,"\n"};
          closedir DIR;
     }

     #create logfile entry
     write_log_entry("get_nightstar_send1","INFO","READ START STOCKNO $warehouse","");

     if (@filelist lt 1 )
     {
	    # return early from subdir if dir empty and nothing to do
        write_log_entry("get_nightstar_send1","INFO","READ STOP Nothing to do","0");
        if ($debug) {print @filelist,"\n"};
        if ($debug) {print "Debug NOTHING TO DO\n"};
	    return;
     }

     #open connection to log and data db
     my $dbhandle = DBI->connect($DB_TYPE, $STAT_DB_USER, $STAT_DB_PASS, {RaiseError => 0}) or die "Database connection not made: $DBI::errstr";

     #process each file found
     foreach my $file ( @filelist ) {
        if ( $warehouse eq '160' ) {                        #pfad für stockno 160
             $INFILE_filename = "$STAT_STARTDIR/$NIGHT1_OUT_IMPORTDIR/$file"; # input file name
        } elsif ( $warehouse eq '210' ) {                        #pfad für stockno 210
             $INFILE_filename = "$STAT_STARTDIR/$NIGHT2_OUT_IMPORTDIR/$file"; # input file name
        }
        open ( INFILE, '<', $INFILE_filename ) or die  "$0 : failed to open input file $INFILE_filename : $!\n";
        while (<INFILE>){
             next if m/^\s*$/;        # Leerzeilen ignorieren
             next if m/^trunc/;       # truncatingzeilen ignorieren
             chomp;                   # zeilenvorschub raus
             undef @zeile;            # var leeren für neuen durchgang
#             push @zeile, substr ($_,0,19);     #carrierrefno
#             push @zeile, substr ($_,19,8);     #carrierboxno
#             push @zeile, substr ($_,27,7);     #custno
#             push @zeile, substr ($_,34,30);     #name1
#             push @zeile, substr ($_,64,30);     #name2
#             push @zeile, substr ($_,94,30);     #street
#             push @zeile, substr ($_,124,8);     #zipcode
#             push @zeile, substr ($_,132,30);     #city
#             push @zeile, substr ($_,162,5);     #deliver_until
#             push @zeile, date_switch(substr ($_,167,8));     #shipdate gewandelt nach iso
#             push @zeile, substr ($_,175,2);     #parcelcount1
#             push @zeile, substr ($_,177,2);     #parcelcount2
#             push @zeile, substr ($_,179,6);     #weight
#             push @zeile, substr ($_,185,6);     #shipmentno
#             push @zeile, substr ($_,191,30);     #sender1
#             push @zeile, substr ($_,221,8);     #sender2
#             push @zeile, substr ($_,229,30);     #sender3
#             push @zeile, substr ($_,259,20);     #content
#             push @zeile, substr ($_,279,10);     #atg
#             push @zeile, substr ($_,289,10);     #ast
#             push @zeile, substr ($_,299,15);     #shipment
#             push @zeile, substr ($_,314,20);     #dispatch
#             push @zeile, substr ($_,334,15);     #labeltext
#             push @zeile, substr ($_,349,20);     #freight_terms
#             push @zeile, substr ($_,369,30);     #end_customer1
#             push @zeile, substr ($_,399,30);     #end_customer2
#             push @zeile, substr ($_,429,30);     #end_customer3
#             push @zeile, substr ($_,459,8);     #end_customer4
#             push @zeile, substr ($_,467,30);     #end_customer5
#             push @zeile, substr ($_,8,3);       #stockno
             @zeile = split (/;/);   # am semikolon auftrennen
             $countcolumn = $#zeile;  # anzahl der arrayelemente aufheben
#print "count: $countcolumn\n";
             if ($countcolumn eq 8 ) {            #eine spalte zu wenig? dann leere stockno hinzufügen
	             push(@zeile,'');
             }

if ($debug) {$temp = $#zeile}; #   zu debugzwecken anzahl der arrayelemente aufheben
             for (my $i=0;$i<=$#zeile;$i++) {
                 $zeile[$i] = trim($zeile[$i]);             #werte trimmen
                 if ($zeile[$i] eq "") {             # Leerer Wert? Dann DEFAULT Befehl übergeben.
                   $zeile[$i] = 'DEFAULT';
                 } else { #was drin? dann verpacken
                   $zeile[$i] =~ tr/'//d;             #hochkommas entfernen
                   $zeile[$i] = "\'".$zeile[$i]."\'";
                 }
              }
              $sql = "INSERT IGNORE INTO `$NIGHT1_OUT_TABLENAME`
              (`carrierboxno` , `lgmboxno` , `custno` , `servicetime` , `shipdate` , `rowpos` , `parcelcount` , `weight` , `shipmentno` , `stockno`)
              VALUES
              ($zeile[0],$zeile[1],$zeile[2],$zeile[3],$zeile[4],$zeile[5],$zeile[6],$zeile[7],$zeile[8],$zeile[9])";

#              $sql = "INSERT IGNORE INTO `$NIGHT1_OUT_TABLENAME`
#              (`carrierrefno`,`carrierboxno`,`custno`,`name1`,`name2`,`street`,`zipcode`,`city`,`deliver_until`,`shipdate`,`parcelcount1`,`parcelcount2`,`weight`,`shipmentno`,`sender1`,`sender2`,`sender3`,`content`,`atg`,`ast`,`shipment`,`dispatch`,`labeltext`,`freight_terms`,`end_customer1`,`end_customer2`,`end_customer3`,`end_customer4`,`end_customer5`,`stockno`)
#              VALUES
#              ($zeile[0],$zeile[1],$zeile[2],$zeile[3],$zeile[4],$zeile[5],$zeile[6],$zeile[7],$zeile[8],$zeile[9],$zeile[10],$zeile[11],$zeile[12],$zeile[13],$zeile[14],$zeile[15],$zeile[16],$zeile[17],$zeile[18],$zeile[19],$zeile[20],$zeile[21],$zeile[22],$zeile[23],$zeile[24],$zeile[25],$zeile[26],$zeile[27],$zeile[28],$zeile[29])";
               $dbhandle->do($sql);
#               print "SQL: ",$sql,"\n";
              $countvar++;
        }  # --- end while
        close ( INFILE ) or warn "$0 : failed to close input file $INFILE_filename : $!\n";
        #move file to save-dir
        if ( $warehouse eq '160' ) {                        #pfad für stockno 160
             move2save("$STAT_STARTDIR/$NIGHT1_OUT_IMPORTDIR","$STAT_STARTDIR/$STAT_SAVEDIR","$file","$warehouse");
        } elsif ( $warehouse eq '210' ) {                        #pfad für stockno 210
             move2save("$STAT_STARTDIR/$NIGHT2_OUT_IMPORTDIR","$STAT_STARTDIR/$STAT_SAVEDIR","$file","$warehouse");
        }
        write_log_entry("get_nightstar_send1","INFO","FILENAME:$file","0");    #statusinfo zu jeder datei
     } # -----  end foreach  -----

     #create logfile entry
     write_log_entry("get_nightstar_send1","INFO","READ END","$countvar");

     if ($debug) {print "Debug Ende get_nightstar_send1\n"};
     return 1;
}

###########################################
# reformat date from german to iso
sub date_switch($) {               #param: datumformat mit 8 stellen (dd.mm.yy) oder 10 stellen (dd.mm.yyyy)
###########################################
     my $date_in = $_[0];                         #das datum wie es übergeben wurde
     my $date_return;

     if (length ($date_in) == 8 ) {               #Datumsformat 8 stellen? dd.mm.yy
          $date_return = "20".substr ($date_in,6,2)."-".substr ($date_in,3,2)."-".substr ($date_in,0,2);
     }
     elsif (length ($date_in) == 10 ) {           #Datumsformat 10 stellen? dd.mm.yyyy
          $date_return = substr ($date_in,6,4)."-".substr ($date_in,3,2)."-".substr ($date_in,0,2);
     }
     else {
          $date_return = "0000-00-00";            #null zurückgeben wenn übergebene länge keinen sinn macht
     }
     return $date_return;
}

###########################################
# split string into country zipcode and city
# sample: ( $x, $y, $z ) = &splitcountry("9999 examplecity")
sub splitcountry($) {              #param: string mit plz ort
###########################################
my $splitstring = $_[0];
     if ( $splitstring =~ m/^[A-Z]+-/ ) {    # Landeskennzeichen vorhanden
          $splitstring =~ m/^([A-Z]+)-(\d*)\s*(.*)$/;
          return $1, $2, $3;
     } else {                         # kein Landeskennzeichen
          $splitstring =~ m/^(\d*)\s*(.*)$/;
          return "", $1, $2;
     }
}

###########################################
# get all data from nightstar that are sent
sub get_nightstar_receive1($) {    #param: warehouse
###########################################
$debug = 1;
     if ($debug) {print "Debug Start get_nightstar_receive1\n"};
     my $warehouse = $_[0];        #erster parameter = warehouse / stockno
     if ($debug) {print "Debug $warehouse\n"};

     my $countvar = 0;
     my $filelist;
     my	$INFILE_filename;
     my @zeile;
     my $datadate;
     my $rec_format;
     my $temp;

#TODO format anpassen wg. lieferscheinnummer?
     #get filelist
     if ( $warehouse eq '160' ) {                        #pfad für stockno 160
          opendir (DIR,"$STAT_STARTDIR/$NIGHT1_IN_IMPORTDIR") || die "Opendir $STAT_STARTDIR/$NIGHT1_IN_IMPORTDIR not possible: $!";
          if ($debug) {print "$STAT_STARTDIR/$NIGHT1_IN_IMPORTDIR\n"};
          @filelist = grep { -f "$STAT_STARTDIR/$NIGHT1_IN_IMPORTDIR/$_" } readdir(DIR);
          if ($debug) {print @filelist,"\n"};
          closedir DIR;
     }
     if ( $warehouse eq '210' ) {                        #pfad für stockno 210
          opendir (DIR,"$STAT_STARTDIR/$NIGHT2_IN_IMPORTDIR") || die "Opendir $STAT_STARTDIR/$NIGHT2_IN_IMPORTDIR not possible: $!";
          if ($debug) {print "$STAT_STARTDIR/$NIGHT2_IN_IMPORTDIR\n"};
          @filelist = grep { -f "$STAT_STARTDIR/$NIGHT2_IN_IMPORTDIR/$_" } readdir(DIR);
          if ($debug) {print @filelist,"\n"};
          closedir DIR;
     }

     #create logfile entry
     write_log_entry("get_nightstar_receive1","INFO","READ START STOCKNO $warehouse","");

     if (@filelist lt 1 )
     {
	    # return early from subdir if dir empty and nothing to do
        write_log_entry("get_nightstar_receive1","INFO","READ STOP Nothing to do","0");
        if ($debug) {print @filelist,"\n"};
        if ($debug) {print "Debug NOTHING TO DO\n"};
	    return;
     }

     #open connection to log and data db
     my $dbhandle = DBI->connect($DB_TYPE, $STAT_DB_USER, $STAT_DB_PASS, {RaiseError => 0}) or die "Database connection not made: $DBI::errstr";

     #process each file found
     foreach my $file ( @filelist ) {
        if ( $warehouse eq '160' ) {                        #pfad für stockno 160
             $INFILE_filename = "$STAT_STARTDIR/$NIGHT1_IN_IMPORTDIR/$file"; # input file name
        } elsif ( $warehouse eq '210' ) {                        #pfad für stockno 210
             $INFILE_filename = "$STAT_STARTDIR/$NIGHT2_IN_IMPORTDIR/$file"; # input file name
        }
        open ( INFILE, '<', $INFILE_filename ) or die  "$0 : failed to open input file $INFILE_filename : $!\n";
        while (<INFILE>){
             next if m/^\s*$/;        # Leerzeilen ignorieren
             next if m/^trunc/;       # truncatingzeilen ignorieren
             chomp;                   # zeilenvorschub raus
             undef @zeile;            # var leeren für neuen durchgang
             push @zeile, substr ($_,0,35);     #returncode
             push @zeile, substr ($_,35,3);     #errorcode
             push @zeile, date_switch(substr ($_,38,8));     #date1-date
             push @zeile, substr ($_,46,8);     #date1-time
             $zeile[3] =~ s/   /00:/;       #von mitternacht bis 1 fehlen die stunden
             $zeile[2] =~ tr/ /0/;          #leerzeichen in datestring zu 0 ersetzen
             $zeile[3] =~ tr/ /0/;          #leerzeichen in timestring zu 0 ersetzen
             $zeile[2] = $zeile[2]." ".$zeile[3]; #formatieren als timestring
             $zeile[3] = substr ($_,6,3);       #lager aus der paketnummer extrahieren
             for (my $i=0;$i<=$#zeile;$i++) {
                 $zeile[$i] = trim($zeile[$i]);             #werte trimmen
                 if ($zeile[$i] eq "") {             # Leerer Wert? Dann DEFAULT Befehl übergeben.
                   $zeile[$i] = 'DEFAULT';
                 } else { #was drin? dann verpacken
                   $zeile[$i] =~ tr/'//d;             #hochkommas entfernen
                   $zeile[$i] = "\'".$zeile[$i]."\'";
                 }
              }
              $sql = "INSERT IGNORE INTO `$NIGHT1_IN_TABLENAME`
              (`returncode`,`errorcode`,`date1`,`stockno`)
              VALUES
              ($zeile[0],$zeile[1],$zeile[2],$zeile[3])";
              $dbhandle->do($sql);
#               print "SQL: ",$sql,"\n";
              $countvar++;
        }  # --- end while
        close ( INFILE ) or warn "$0 : failed to close input file $INFILE_filename : $!\n";
        #move file to save-dir
        if ( $warehouse eq '160' ) {                        #pfad für stockno 160
             move2save("$STAT_STARTDIR/$NIGHT1_IN_IMPORTDIR","$STAT_STARTDIR/$STAT_SAVEDIR","$file");
        } elsif ( $warehouse eq '210' ) {                        #pfad für stockno 210
             move2save("$STAT_STARTDIR/$NIGHT2_IN_IMPORTDIR","$STAT_STARTDIR/$STAT_SAVEDIR","$file");
        }
        write_log_entry("get_nightstar_receive1","INFO","FILENAME:$file","0");    #statusinfo zu jeder datei
     } # -----  end foreach  -----

     #create logfile entry
     write_log_entry("get_nightstar_receive1","INFO","READ END","$countvar");

     if ($debug) {print "Debug Ende get_nightstar_receive1\n"};
     return 1;
}

###########################################
# get all data from gls kdpaket.dat file
sub process_glsfile1_read($) {          #param: warehouse
###########################################
$debug = 1;
     if ($debug) {print "Debug process_glsfile1\n"};
     my $warehouse = $_[0];        #erster parameter = warehouse / stockno
     if ($debug) {print "Debug $warehouse\n"};

     my $countvar = 0;
     my $filelist;
     my	$INFILE_filename;
     my @zeile;
     my $datadate;
     my $rec_format;
     my $temp;
     my $countcolumn;
     my $timestamp = get_timestamp();   #ein timestamp für alle zeilen


     #get filelist
     if ( $warehouse eq '160' ) {                        #pfad für stockno 160
          opendir (DIR,"$STAT_STARTDIR/$GLS_PARCEL1_IMPORTDIR") || die "Opendir $STAT_STARTDIR/$GLS_PARCEL1_IMPORTDIR not possible: $!";
          if ($debug) {print "$STAT_STARTDIR/$GLS_PARCEL1_IMPORTDIR\n"};
          @filelist = grep { -f "$STAT_STARTDIR/$GLS_PARCEL1_IMPORTDIR/$_" } readdir(DIR);
          if ($debug) {print @filelist,"\n"};
          closedir DIR;
     }
     if ( $warehouse eq '210' ) {                        #pfad für stockno 210
          opendir (DIR,"$STAT_STARTDIR/$GLS_PARCEL2_IMPORTDIR") || die "Opendir $STAT_STARTDIR/$GLS_PARCEL2_IMPORTDIR not possible: $!";
          if ($debug) {print "$STAT_STARTDIR/$GLS_PARCEL2_IMPORTDIR\n"};
          @filelist = grep { -f "$STAT_STARTDIR/$GLS_PARCEL2_IMPORTDIR/$_" } readdir(DIR);
          if ($debug) {print @filelist,"\n"};
          closedir DIR;
     }

     #create logfile entry
     write_log_entry("process_glsfile1_read","INFO","READ START STOCKNO $warehouse","");

     if (@filelist lt 1 )
     {
	    # return early from subdir if dir empty and nothing to do
        write_log_entry("process_glsfile1_read","INFO","READ STOP Nothing to do $warehouse","0");
        if ($debug) {print @filelist,"\n"};
        if ($debug) {print "Debug NOTHING TO DO\n"};
	    return;
     }

     #open connection to log and data db
     my $dbhandle = DBI->connect($DB_TYPE, $STAT_DB_USER, $STAT_DB_PASS, {RaiseError => 0}) or die "Database connection not made: $DBI::errstr";

     #process each file found
     foreach my $file ( @filelist ) {
        if ( $warehouse eq '160' ) {                        #pfad für stockno 160
             $INFILE_filename = "$STAT_STARTDIR/$GLS_PARCEL1_IMPORTDIR/$file"; # input file name
        } elsif ( $warehouse eq '210' ) {                        #pfad für stockno 210
             $INFILE_filename = "$STAT_STARTDIR/$GLS_PARCEL2_IMPORTDIR/$file"; # input file name
        }
        open ( INFILE, '<', $INFILE_filename ) or die  "$0 : failed to open input file $INFILE_filename : $!\n";
        while (<INFILE>){
             next if m/^\s*$/;        # Leerzeilen ignorieren
             next if m/^#/;       # truncatingzeilen ignorieren
             chomp;                   # zeilenvorschub raus
             undef @zeile;            # var leeren für neuen durchgang
             @zeile = split (/\|/);   # am pipe auftrennen
             $countcolumn = $#zeile;  # anzahl der arrayelemente aufheben

if ($debug) {$temp = $#zeile}; #   zu debugzwecken anzahl der arrayelemente aufheben
             for (my $i=0;$i<=$#zeile;$i++) {
                 $zeile[$i] = trim($zeile[$i]);             #werte trimmen
                 if ($zeile[$i] eq "") {             # Leerer Wert? Dann DEFAULT Befehl übergeben.
                   $zeile[$i] = 'NULL';
                 } else { #was drin? dann verpacken
                   $zeile[$i] =~ tr/'//d;             #hochkommas entfernen
                   $zeile[$i] = "\'".$zeile[$i]."\'";
                 }
             }
             if ($countcolumn == 16) {         #wenn 16 spalten dann letzte spalte = stockno
                 $zeile[17] = $warehouse;
             }
             elsif ($countcolumn == 15) {
               push @zeile,'';                           #sonst leere spalte anhängen
               push @zeile,$warehouse;                   #und dann stockno
             }
             elsif ($countcolumn == 17) {
               $temp = pop (@zeile);                           #sonst 1 spaltelöschen, ggf. linux
               push @zeile,$warehouse;                   #und dann stockno
             }
#             if (not(search_db("dhl_easylog1","$warehouse","shipmentno","$zeile[17]")) && not(search_db("dhl_nightplus1_out","$warehouse","shipmentno","$zeile[17]")) ) {  #lieferschein nicht gefunden in dhl oder nightplus
             push @zeile,$timestamp;              #checkin_date = jetzt
             push @zeile, 'NULL';                     #checkout_date = nix
             push @zeile, '1';                    #status = 1 (true)
              $sql = "INSERT IGNORE INTO `$GLS_OUT1_TABLENAME` ( `carrierboxno` , `shipdate` , `gls_custno` , `weight` , `gls_product` , `gls_epl_number` , `tournumber` , `checkdate` , `country` , `zipcode` , `freight_terms` , `gls_trunc` , `custno` , `name` , `street` , `city` , `shipmentno` , `stockno`, `checkin_date`, `checkout_date`, `status`)
                       VALUES ($zeile[0],$zeile[1],$zeile[2],$zeile[3],$zeile[4],$zeile[5],$zeile[6],$zeile[7],$zeile[8],$zeile[9],$zeile[10],$zeile[11],$zeile[12],$zeile[13],$zeile[14],$zeile[15],$zeile[16],$zeile[17],$zeile[18],$zeile[19],$zeile[20])";
               $dbhandle->do($sql);
#               print "SQL: ",$sql,"\n";
              $countvar++;
        }  # --- end while
        close ( INFILE ) or warn "$0 : failed to close input file $INFILE_filename : $!\n";
        #move file to save-dir
        if ( $warehouse eq '160' ) {                        #pfad für stockno 160
             rename ("$STAT_STARTDIR/$GLS_PARCEL1_IMPORTDIR/$file","$STAT_STARTDIR/$GLS_PARCEL1_IMPORTDIR/$file.$timestamp.INFILE") or warn "rename not working: $!";  #rename to avoid backup conflicts
             move2save("$STAT_STARTDIR/$GLS_PARCEL1_IMPORTDIR","$STAT_STARTDIR/$STAT_SAVEDIR","$file.$timestamp.INFILE","$warehouse");
        } elsif ( $warehouse eq '210' ) {                        #pfad für stockno 210
             rename ("$STAT_STARTDIR/$GLS_PARCEL2_IMPORTDIR/$file","$STAT_STARTDIR/$GLS_PARCEL2_IMPORTDIR/$file.$timestamp.INFILE") or warn "rename not working: $!";
             move2save("$STAT_STARTDIR/$GLS_PARCEL2_IMPORTDIR","$STAT_STARTDIR/$STAT_SAVEDIR","$file.$timestamp.INFILE","$warehouse");
        }
        write_log_entry("process_glsfile1_read","INFO","FILENAME:$file","0");    #statusinfo zu jeder datei
     } # -----  end foreach  -----

     #create logfile entry
     write_log_entry("process_glsfile1_read","INFO","READ END","$countvar");
     if ($debug) {print "Debug Ende process_glsfile1\n"};
     return $timestamp;  #timestamp zu weiteren verwendung zurückliefern.
}

###########################################
# find any data in given db and row
sub search_db($$$$) {              #param: tabelle, warehouse, suchfeld, suchwert
###########################################
    my $table = $_[0];
    my $warehouse = $_[1];
    my $search_field = $_[2];
    my $search_value = $_[3];
    my $retval;
    my $search_dbhandle = DBI->connect($DB_TYPE, $STAT_DB_USER, $STAT_DB_PASS, {RaiseError => 0}) or die "Database connection in search_db not made: $DBI::errstr";

    my $select1 = "select * from $table where `stockno` = $warehouse and `$search_field` = '$search_value'";
    my $sth = $search_dbhandle->prepare($select1);
# print "Select1: $select1\n";
    $sth->execute();
     if ($sth->rows gt 0 ) {                 #wenn was gefunden wurde
          $retval = "1";
# print "Select1: if erfuellt\n";
     }
     else {                                       #wenn die Abfrage ohne Ergebnis blieb
          $retval = "0";
# print "Select1: else erfuellt\n";
     }
     $search_dbhandle->disconnect();
     return $retval;
}

###########################################
# put file on server via ftp
sub send_ftp2server ($$$$$) {      #params; file, user, pass, host, path
###########################################
     my $file2send = $_[0];
     my $ftpuser = $_[1];
     my $ftppass = $_[2];
     my $ftphost = $_[3];
     my $ftppath = $_[4];
     my $retstr = 0;               #rückgabestring 0=fehler, 1=OK

     my $ftp=Net::FTP->new($ftphost, Debug=>0);
     if ($ftp->login($ftpuser, $ftppass)) {
          if ($ftp->cwd("$ftppath")){
               $ftp->ascii();                # wechselt in ASCII Modus
               if ($ftp->put("$file2send")) {
                    $retstr = '1';
               }
               else {
                    $retstr = "Can't upload file $file2send on Server $ftphost: ". $ftp->message. "\n";
               }
          }
          else {    #chdir hat nicht funktioniert
               $retstr = "Can't change FTP Path to $ftppath on Server $ftphost: ". $ftp->message. "\n";
          }
          $ftp->quit;
     }
     else {         #login hat nicht funktioniert
           $retstr = "Can't logon to $ftphost: ". $ftp->message. "\n";
     }
     return $retstr;
}

###########################################
# get file from ftp server and store locally
sub get_fromftpserver ($$$$$$) {   #params; file, user, pass, host, path, local directory
###########################################
     my $file2get = $_[0];
     my $ftpuser = $_[1];
     my $ftppass = $_[2];
     my $ftphost = $_[3];
     my $ftppath = $_[4];
     my $localdir = $_[5];
     my $retstr = '0';               #rückgabestring

     my $ftp=Net::FTP->new($ftphost, Debug=>0);
     if ($ftp->login($ftpuser, $ftppass)) {
          if ($ftp->cwd("$ftppath")){
               $ftp->ascii();                # wechselt in ASCII Modus
               if ($ftp->get("$file2get","$localdir/$file2get")) {    #datei holen
                    $retstr = '1';
               }
               else {
                    $retstr = "Can't download file $file2get from Server $ftphost: ". $ftp->message. "\n";
               }
          }
          else {    #chdir hat nicht funktioniert
               $retstr = "Can't change FTP Path to $ftppath on Server $ftphost: ". $ftp->message. "\n";
          }
          $ftp->quit;
     }
     else {         #login hat nicht funktioniert
           $retstr = "Can't logon to $ftphost: ". $ftp->message. "\n";
     }
     return $retstr;
}

###########################################
# compare gls_parcel_out with gepart
sub comp_p_out_gepart($) {        #param: checkin_date timestamp
###########################################

  my $timestamp = $_[0];
  my $sth;                              #statement handle sql
  my $update_dbhandle = DBI->connect($DB_TYPE, $STAT_DB_USER, $STAT_DB_PASS, {RaiseError => 0}) or die "Database connection not made: $DBI::errstr";
  my $update_sql = "update `$GLS_OUT1_TABLENAME` `a`"
        . " INNER JOIN `$GLS_GEP1_TABLENAME` `b` "
        . " ON `a`.`shipmentno` = `b`.`shipmentno` AND "
        . " `a`.`custno` = `b`.`custno` AND "
        . " `a`.`stockno` = `b`.`stockno` "
        . " set `a`.`status` = \'2\' "
        . " WHERE (`a`.`status` = \'1\') AND "
        . " (`a`.`checkin_date` = \'$timestamp\')";
  $sth = $update_dbhandle->prepare($update_sql);                 #query vorbereiten
  $sth->execute;                                                 #query ausführen
  $num_aff_row = $sth->rows;                                     #wieviele zeilen hat es getroffen
  write_log_entry("comp_p_out_dhl_gepart","INFO","No. of records found: $num_aff_row","0");    #statusinfo
  return $num_aff_row;
}

###########################################
# compare gls_parcel_out with dhl easylog
sub comp_p_out_dhl_easylog($) {        #param: checkin_date timestamp; TEST: 20070120222752
###########################################

  my $timestamp = $_[0];
  my $sth;                              #statement handle sql
  my $update_dbhandle = DBI->connect($DB_TYPE, $STAT_DB_USER, $STAT_DB_PASS, {RaiseError => 0}) or die "Database connection not made: $DBI::errstr";
  my $update_sql = "UPDATE `$GLS_OUT1_TABLENAME` `a` "
        . " INNER JOIN `$LM1_TABLENAME` `c` "
        . " ON `a`.`custno` = `c`.`custno` "
        . " INNER JOIN `$DHL_EASY1_TABLENAME` `b` "
        . " ON `a`.`shipmentno` = `b`.`shipmentno` AND"
        . " `a`.`stockno` = `b`.`stockno` AND"
        . " `c`.`lgmboxno` = `b`.`lgmboxno` "
        . " SET `a`.`status` = \'3\'"
        . " WHERE"
        . " (`a`.`status` = \'1\') AND"
        . " (`a`.`checkin_date` = \'$timestamp\')";
  $sth = $update_dbhandle->prepare($update_sql);                 #query vorbereiten
  $sth->execute;                                                 #query ausführen
  $num_aff_row = $sth->rows;                                     #wieviele zeilen hat es getroffen
  write_log_entry("comp_p_out_dhl_easylog","INFO","No. of records found: $num_aff_row","0");    #statusinfo
  return $num_aff_row;
}

###########################################
# compare gls_parcel_out with nightstar
sub comp_p_out_nightstar($) {        #param: checkin_date timestamp; TEST: 20070120222752
###########################################

  my $timestamp = $_[0];
  my $sth;                              #statement handle sql
  my $num_aff_row;
  my $update_dbhandle = DBI->connect($DB_TYPE, $STAT_DB_USER, $STAT_DB_PASS, {RaiseError => 0}) or die "Database connection not made: $DBI::errstr";
  my $update_sql = "update `$GLS_OUT1_TABLENAME` `a`"
        . " INNER JOIN `$NIGHT1_OUT_TABLENAME` `b` "
        . " ON `a`.`shipmentno` = `b`.`shipmentno` AND "
        . " `a`.`custno` = `b`.`custno` AND "
        . " `a`.`stockno` = `b`.`stockno` "
        . " set `a`.`status` = \'2\' "
        . " WHERE (`a`.`status` = \'1\') AND "
        . " (`a`.`checkin_date` = \'$timestamp\')";
  $sth = $update_dbhandle->prepare($update_sql);                 #query vorbereiten
  $sth->execute;                                                 #query ausführen
  $num_aff_row = $sth->rows;                                     #wieviele zeilen hat es getroffen
  write_log_entry("comp_p_out_nightstar","INFO","No. of records found: $num_aff_row","0");    #statusinfo
  $update_dbhandle->disconnect();
  return $num_aff_row;
}

###########################################
# update gls_parcel_out for all items sent back to gls
sub update_p_out_sent_ok($$) {        #param: checkin_date timestamp, stockno; TEST: 20070120222752
###########################################

  my $timestamp = $_[0];
  my $stockno = $_[1];
  my $sth;                              #statement handle sql
  my $num_aff_row;
  my $timestamp_out = get_timestamp();
  my $ftp_return;
  my $update_dbhandle = DBI->connect($DB_TYPE, $STAT_DB_USER, $STAT_DB_PASS, {RaiseError => 0}) or die "Database connection not made: $DBI::errstr";
  my $update_sql = "update `$GLS_OUT1_TABLENAME` "
        . " set `status` = \'90\',"
        . " `checkout_date` = \'$timestamp_out\'"
        . " WHERE "
        . " `checkin_date` = \'$timestamp\' and"
        . " `stockno` = \'$stockno\' and"
        . " `status` = \'1\'";
#print "\nupdate_sql: $update_sql\n";
  $sth = $update_dbhandle->prepare($update_sql);                 #query vorbereiten
  $sth->execute;                                                 #query ausführen
  $num_aff_row = $sth->rows;                                     #wieviele zeilen hat es getroffen
#print "update_p_out_sent_ok: $num_aff_row Zeilen\n";
  $update_dbhandle->disconnect();
  return $num_aff_row;
}

###########################################
# write gls_parcel_out data to csv file for sending to gls
sub writefile_p_out($$) {        #param: checkin_date, stockno (timestamp; TEST: 20070120222752)
###########################################

  my $timestamp = $_[0];
  my $stockno = $_[1];
  my $count = 0;
  my $var1;
  my $OUTFILE_filename = "kdpaket.dat.$timestamp"; # output file name
  my $pathstr;                                     # path to the file to write
  my $retval;
  my $gls_headerline;

  $gls_headerline = "#GPK#|0001|0|SPICERS|1|".get_timestamp('CCYYMMDD')."|50026|";
#print "PFAD: $STAT_STARTDIR/$GLS_PARCEL1_EXPORTDIR/$OUTFILE_filename\n";

  if ( $stockno eq '160' ) {                        #pfad für stockno 160
     open ( OUTFILE, '>', "$STAT_STARTDIR/$GLS_PARCEL1_EXPORTDIR/$OUTFILE_filename" ) or die "$0 : failed to open  output file $OUTFILE_filename : $!\n";
     $pathstr = "$STAT_STARTDIR/$GLS_PARCEL1_EXPORTDIR/$OUTFILE_filename";
  }

  if ( $stockno eq '210' ) {                        #pfad für stockno 160
     open ( OUTFILE, '>', "$STAT_STARTDIR/$GLS_PARCEL2_EXPORTDIR/$OUTFILE_filename" ) or die "$0 : failed to open  output file $OUTFILE_filename : $!\n";
     $pathstr = "$STAT_STARTDIR/$GLS_PARCEL2_EXPORTDIR/$OUTFILE_filename";
  }

  my $dbhandle = DBI->connect($DB_TYPE, $STAT_DB_USER, $STAT_DB_PASS, {RaiseError => 0}) or die "Database connection not made: $DBI::errstr";
  my $sql = "SELECT g . carrierboxno , date_format(g . shipdate,'%Y%m%d') , g . gls_custno , "
        . " g . weight , g . gls_product , g . gls_epl_number , "
        . " g . tournumber , date_format(g . checkdate,'%Y%m%d') , g . country , g . zipcode , "
        . " g . freight_terms , g . gls_trunc , g . custno , g . name , "
        . " g . street , g . city , g . shipmentno "
        . " FROM gls_parcel_out g "
        . " WHERE g . checkin_date = \'$timestamp\' AND g.stockno = \'$stockno\' AND g.status = \'1\'";
#test        . " WHERE g.stockno = \'$stockno\' AND g.status = \'1\'";
  my $sth = $dbhandle->prepare($sql);
  $sth->execute();
  print OUTFILE "$gls_headerline\n";              #first line must be GLS headerline
  while (@row=$sth->fetchrow_array()) {
        $count++;
        $var1 = join("|",@row);
        print OUTFILE "$var1|\n";            # | at the end due to gls file rules
  }
  print ".FERTIG $count Zeilen.\n";
  write_log_entry("writefile_p_out","INFO","Stockno: $stockno FILENAME:$OUTFILE_filename","$count");    #statusinfo zu jeder datei
  close ( OUTFILE ) or warn "$0 : failed to close output file $OUTFILE_filename : $!\n";
  $dbhandle->disconnect();
  $retval = 0;              #return value
  if (-e $pathstr && -s $pathstr)  {      #existiert die gerade erstellte datei und hat sie mehr als 0 byte?
       if ( $stockno eq '160' ) {                        #sent file to gls
#          $ftp_return = send_ftp2server ("$pathstr","$GLS_FTPUSER160","$GLS_FTPPASS160","$GLS_FTPHOST160","$GLS_FTPPATH160");
# TODO FTP Transfer für GLS einschalten
           $ftp_return = 1;
          if ($ftp_return eq '1') {
              print "FTP hat geklappt\n";
              rename ($pathstr,"$pathstr.OK");
              write_log_entry("writefile_p_out","INFO","FTP OK FILENAME:$OUTFILE_filename","0");    #statusinfo zu jeder datei
              move2save("$STAT_STARTDIR/$GLS_PARCEL1_EXPORTDIR","$STAT_STARTDIR/$STAT_SAVEDIR","$OUTFILE_filename.OK","$stockno");
              $retval += 1;              #return value plus 1
          }
          else {
              print "FTP FEHLGESCHLAGEN: $ftp_return\n";
              rename ($pathstr,"$pathstr.ERROR");
              write_log_entry("writefile_p_out","ERROR","FTP ERROR: $ftp_return FILENAME:$OUTFILE_filename","0");    #statusinfo zu jeder datei
              move2save("$STAT_STARTDIR/$GLS_PARCEL1_EXPORTDIR","$STAT_STARTDIR/$STAT_SAVEDIR","$OUTFILE_filename.ERROR","$stockno");
          }
       }
       if ( $stockno eq '210' ) {                        #sent file to gls
#          $ftp_return = send_ftp2server ("$pathstr","$GLS_FTPUSER210","$GLS_FTPPASS210","$GLS_FTPHOST210","$GLS_FTPPATH210");
           $ftp_return = 1;
          if ($ftp_return eq '1') {
              print "FTP hat geklappt\n";
              rename ($pathstr,"$pathstr.OK");
              write_log_entry("writefile_p_out","INFO","FTP OK FILENAME:$OUTFILE_filename","0");    #statusinfo zu jeder datei
              move2save("$STAT_STARTDIR/$GLS_PARCEL2_EXPORTDIR","$STAT_STARTDIR/$STAT_SAVEDIR","$OUTFILE_filename.OK","$stockno");
              $retval += 2;              #return value plus 2
          }
          else {
              print "FTP FEHLGESCHLAGEN: $ftp_return\n";
              rename ($pathstr,"$pathstr.ERROR");
              write_log_entry("writefile_p_out","ERROR","FTP ERROR: $ftp_return FILENAME:$OUTFILE_filename","0");    #statusinfo zu jeder datei
              move2save("$STAT_STARTDIR/$GLS_PARCEL2_EXPORTDIR","$STAT_STARTDIR/$STAT_SAVEDIR","$OUTFILE_filename.ERROR","$stockno");
          }
       }
  }
  else {
    $retval += 0;              #return value plus zero
  }
  return $retval;
}

###########################################
# write gls_parcel_out data to csv file for sending to gls
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

###########################################
# END of module
###########################################
1;
