#!/usr/bin/perl
if ($debug) {print "Debug Global pm\n"};

###########################################
sub trim($) {
###########################################
  my $string = shift;
  $string =~ s/^\s+//;
  $string =~ s/\s+$//;
  return $string;
}

###########################################
# Left trim function to remove leading whitespace
sub ltrim($) {
###########################################
  my $string = shift;
  $string =~ s/^\s+//;
  return $string;
}

###########################################
# Right trim function to remove trailing whitespace
sub rtrim($) {
###########################################
  my $string = shift;
  $string =~ s/\s+$//;
  return $string;
}

###########################################
# Write entry in log db
sub write_log_entry($$$$) {
###########################################

  my $log_source = $_[0];
  my $log_cat = $_[1];
  my $log_text = $_[2];
  my $itemcount = $_[3];
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
                  if ($zeile[$i] eq "") {    # Leerer Wert? Dann DEFAULT Befehl �bergeben.
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
             if ($#zeile == 8){       #nur 9 spalten? dann fehlt eine
                  push @zeile,'';     # eine leere spalte hinzufuegen
             };
             for(my $i=0;$i<=$#zeile;$i++) {
                  $zeile[$i] = trim($zeile[$i]);
                  if ($zeile[$i] eq "") {    # Leerer Wert? Dann DEFAULT Befehl �bergeben.
                    $zeile[$i] = 'DEFAULT';
                  } else { #was drin? dann verpacken
                    $zeile[$i] =~ tr/'//d;             #hochkommas entfernen
                    $zeile[$i] = "\'".$zeile[$i]."\'";
                  }
             }
             my $sql = "INSERT IGNORE INTO `$LM1_TABLENAME` ( `stockno` , `custno` , `picklistno` , `shipmentno` , `picklistrowpos` , `rec_date` , `ack_date` , `carrier` , `lmboxno` , `carrierboxno` )
VALUES ($zeile[0],$zeile[1],$zeile[2],$zeile[3],$zeile[4],$zeile[5],$zeile[6],$zeile[7],$zeile[8],$zeile[9])";
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
sub move2save($$$;$) {
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

#     print "Von: $from_dir \nNach: $to_dir/$year2/$mon2 \nFilename im SUB: $file \nMonat: $mon2 Jahr: $year2 Lager: $warehouse\n";
     move("$from_dir/$file","$to_dir/$year2/$mon2/$file\.$timestamp\.$warehouse\.done") or die "move not possible! $!\n";
}

###########################################
sub get_timestamp(;$) {
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
sub get_dhl1($) {
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
     if ( $warehouse eq '160' ) {                        #pfad f�r stockno 160
          opendir (DIR,"$STAT_STARTDIR/$DHL_EASY1_IMPORTDIR") || die "Opendir $STAT_STARTDIR/$DHL_EASY1_IMPORTDIR not possible: $!";
          if ($debug) {print "$STAT_STARTDIR/$DHL_EASY1_IMPORTDIR\n"};
          @filelist = grep { -f "$STAT_STARTDIR/$DHL_EASY1_IMPORTDIR/$_" } readdir(DIR);
          if ($debug) {print @filelist,"\n"};
          closedir DIR;
     }
     if ( $warehouse eq '210' ) {                        #pfad f�r stockno 210
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
        if ( $warehouse eq '160' ) {                        #pfad f�r stockno 160
             $INFILE_filename = "$STAT_STARTDIR/$DHL_EASY1_IMPORTDIR/$file"; # input file name
        } elsif ( $warehouse eq '210' ) {                        #pfad f�r stockno 210
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
                  if ($zeile[2] > 1 ) {                #mehr als ein Packst�ck
                       @save_zeile = @zeile;        #Datensatz merken
                  }
                  else {                               #nur ein Packst�ck
                       undef(@save_zeile);             # dann gemerkten Datensatz vergessen
                  }
             }
             elsif ($zeile[0] =~ /SAZU/) {
                  if ($filetreatment == 72  && $zeile[1] eq 'ZI20') { #verfahren 72 und leistungsk�rzel gleich ZI20
                       $parcelno_save = $zeile[2];      #paketnummer aufheben
                       @zeile = @save_zeile;               #den gespeicherte sapo-datensatz zur�ckholen
                       $zeile[10] = $parcelno_save;        #die Paketnummer mit der gespeicherten �berschreiben
                       $sapo_true = 1;                   #Paketdatensatz erreicht
                  }
             }
             if ($#zeile == 21 ) {                     #nur 22 spalten? Dann ansprechpartner hinzuf�gen
               	push @zeile,'';                        #zeile[22] = dummy
               	push @zeile,'';                        #zeile[23] = dummy
             }                #elsif f�r linux, da hier die letzte spalte mitgez�hlt wird
             elsif ($#zeile == 22 ) {                     #nur 23 spalten? Dann ansprechpartner hinzuf�gen
               	push @zeile,'';                        #zeile[22] = dummy
             }
             elsif ($#zeile == 24 ) {
               	pop @zeile;                        #24 spalten? dann eine wegnehmen
             }
             push @zeile,$datadate;                        #zeile[24] = datum
             push @zeile,$warehouse;                       #zeile[25] = stockno
             if ($sapo_true ) {                            #nur SAPO S�tze wegschreiben
                  for(my $i=0;$i<=$#zeile;$i++) {          #Nochmal durch alle Felder gehen und leere Werte anpassen
                       if ($zeile[$i] eq "") {             # Leerer Wert? Dann DEFAULT Befehl �bergeben.
                         $zeile[$i] = 'DEFAULT';
                       } else { #was drin? dann verpacken
                         $zeile[$i] =~ tr/'//d;             #hochkommas entfernen
                         $zeile[$i] = "\'".$zeile[$i]."\'";
                       }
                  }
                  my $sql = "INSERT IGNORE INTO `$DHL_EASY1_TABLENAME`
                  ( `recordtype` , `rowpos` , `parcelcount` , `packing` , `weight` , `volume` , `length` , `width` , `height` , `lgmboxno` , `carrierboxno` , `routingcode` , `servicecode` , `shipmentno` , `name1` , `name2` , `name3` , `street` , `street_number` , `city` , `zipcode` , `countrycode` , `contactperson1` , `contactperson2` , `credate` , `stockno` )
                  VALUES
                  ($zeile[0],$zeile[1],$zeile[2],$zeile[3],$zeile[4],$zeile[5],$zeile[6],$zeile[7],$zeile[8],$zeile[9],$zeile[10],$zeile[11],$zeile[12],$zeile[13],$zeile[14],$zeile[15],$zeile[16],$zeile[17],$zeile[18],$zeile[19],$zeile[20],$zeile[21],$zeile[22],$zeile[23],$zeile[24],$zeile[25])";
                  $dbhandle->do($sql);
#                  print $sql,"\n";
                  $countvar++;
             }  # --- end if
        }  # --- end while
        close ( INFILE ) or warn "$0 : failed to close input file $INFILE_filename : $!\n";
        #move file to save-dir
        if ( $warehouse eq '160' ) {                        #pfad f�r stockno 160
             move2save("$STAT_STARTDIR/$DHL_EASY1_IMPORTDIR","$STAT_STARTDIR/$STAT_SAVEDIR","$file","$warehouse");
        } elsif ( $warehouse eq '210' ) {                        #pfad f�r stockno 210
             move2save("$STAT_STARTDIR/$DHL_EASY2_IMPORTDIR","$STAT_STARTDIR/$STAT_SAVEDIR","$file","$warehouse");
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
sub get_gls1($) {
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
     if ( $warehouse eq '160' ) {                        #pfad f�r stockno 160
          opendir (DIR,"$STAT_STARTDIR/$GLS_GEP1_IMPORTDIR") || die "Opendir $STAT_STARTDIR/$GLS_GEP1_IMPORTDIR not possible: $!";
          if ($debug) {print "$STAT_STARTDIR/$GLS_GEP1_IMPORTDIR\n"};
          @filelist = grep { -f "$STAT_STARTDIR/$GLS_GEP1_IMPORTDIR/$_" } readdir(DIR);
          if ($debug) {print @filelist,"\n"};
          closedir DIR;
     }
     if ( $warehouse eq '210' ) {                        #pfad f�r stockno 210
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
        if ( $warehouse eq '160' ) {                        #pfad f�r stockno 160
             $INFILE_filename = "$STAT_STARTDIR/$GLS_GEP1_IMPORTDIR/$file"; # input file name
        } elsif ( $warehouse eq '210' ) {                        #pfad f�r stockno 210
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
               	( $temp, $temp, $city ) = &splitcountry($zeile[15]);  #ort herausl�sen aus string mit land und plz
               	push @zeile,$city;                                    #und an array dranh�ngen
               	if ($countcolumn == 15) {
                	push @zeile,'';            #shipmentno leer? dann leere spalte anf�gen
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
                push @zeile,$warehouse;                   #sonst letzte zeile anh�ngen
             }

             for(my $i=0;$i<=$#zeile;$i++) {          #Nochmal durch alle Felder gehen und leere Werte anpassen
                 if ($zeile[$i] eq "") {             # Leerer Wert? Dann DEFAULT Befehl �bergeben.
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
        if ( $warehouse eq '160' ) {                        #pfad f�r stockno 160
             move2save("$STAT_STARTDIR/$GLS_GEP1_IMPORTDIR","$STAT_STARTDIR/$STAT_SAVEDIR","$file","$warehouse");
        } elsif ( $warehouse eq '210' ) {                        #pfad f�r stockno 210
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
sub get_nightstar_send1($) {
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
     if ( $warehouse eq '160' ) {                        #pfad f�r stockno 160
          opendir (DIR,"$STAT_STARTDIR/$NIGHT1_OUT_IMPORTDIR") || die "Opendir $STAT_STARTDIR/$NIGHT1_OUT_IMPORTDIR not possible: $!";
          if ($debug) {print "$STAT_STARTDIR/$NIGHT1_OUT_IMPORTDIR\n"};
          @filelist = grep { -f "$STAT_STARTDIR/$NIGHT1_OUT_IMPORTDIR/$_" } readdir(DIR);
          if ($debug) {print @filelist,"\n"};
          closedir DIR;
     }
     if ( $warehouse eq '210' ) {                        #pfad f�r stockno 210
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
        if ( $warehouse eq '160' ) {                        #pfad f�r stockno 160
             $INFILE_filename = "$STAT_STARTDIR/$NIGHT1_OUT_IMPORTDIR/$file"; # input file name
        } elsif ( $warehouse eq '210' ) {                        #pfad f�r stockno 210
             $INFILE_filename = "$STAT_STARTDIR/$NIGHT2_OUT_IMPORTDIR/$file"; # input file name
        }
        open ( INFILE, '<', $INFILE_filename ) or die  "$0 : failed to open input file $INFILE_filename : $!\n";
        while (<INFILE>){
             next if m/^\s*$/;        # Leerzeilen ignorieren
             next if m/^trunc/;       # truncatingzeilen ignorieren
             chomp;                   # zeilenvorschub raus
             undef @zeile;            # var leeren f�r neuen durchgang
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

if ($debug) {$temp = $#zeile}; #   zu debugzwecken anzahl der arrayelemente aufheben
             for (my $i=0;$i<=$#zeile;$i++) {
                 $zeile[$i] = trim($zeile[$i]);             #werte trimmen
                 if ($zeile[$i] eq "") {             # Leerer Wert? Dann DEFAULT Befehl �bergeben.
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
        if ( $warehouse eq '160' ) {                        #pfad f�r stockno 160
             move2save("$STAT_STARTDIR/$NIGHT1_OUT_IMPORTDIR","$STAT_STARTDIR/$STAT_SAVEDIR","$file","$warehouse");
        } elsif ( $warehouse eq '210' ) {                        #pfad f�r stockno 210
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
sub date_switch($) {
###########################################
     my $date_in = $_[0];                         #das datum wie es �bergeben wurde
     my $date_return;

     if (length ($date_in) == 8 ) {               #Datumsformat 8 stellen? dd.mm.yy
          $date_return = "20".substr ($date_in,6,2)."-".substr ($date_in,3,2)."-".substr ($date_in,0,2);
     }
     elsif (length ($date_in) == 10 ) {           #Datumsformat 10 stellen? dd.mm.yy
          $date_return = substr ($date_in,6,4)."-".substr ($date_in,3,2)."-".substr ($date_in,0,2);
     }
     else {
          $date_return = "0000-00-00";            #null zur�ckgeben wenn �bergebene l�nge keinen sinn macht
     }
     return $date_return;
}

###########################################
# split string into country zipcode and city
# sample: ( $x, $y, $z ) = &splitcountry("9999 examplecity")
sub splitcountry($) {
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
sub get_nightstar_receive1($) {
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
     if ( $warehouse eq '160' ) {                        #pfad f�r stockno 160
          opendir (DIR,"$STAT_STARTDIR/$NIGHT1_IN_IMPORTDIR") || die "Opendir $STAT_STARTDIR/$NIGHT1_IN_IMPORTDIR not possible: $!";
          if ($debug) {print "$STAT_STARTDIR/$NIGHT1_IN_IMPORTDIR\n"};
          @filelist = grep { -f "$STAT_STARTDIR/$NIGHT1_IN_IMPORTDIR/$_" } readdir(DIR);
          if ($debug) {print @filelist,"\n"};
          closedir DIR;
     }
     if ( $warehouse eq '210' ) {                        #pfad f�r stockno 210
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
        if ( $warehouse eq '160' ) {                        #pfad f�r stockno 160
             $INFILE_filename = "$STAT_STARTDIR/$NIGHT1_IN_IMPORTDIR/$file"; # input file name
        } elsif ( $warehouse eq '210' ) {                        #pfad f�r stockno 210
             $INFILE_filename = "$STAT_STARTDIR/$NIGHT2_IN_IMPORTDIR/$file"; # input file name
        }
        open ( INFILE, '<', $INFILE_filename ) or die  "$0 : failed to open input file $INFILE_filename : $!\n";
        while (<INFILE>){
             next if m/^\s*$/;        # Leerzeilen ignorieren
             next if m/^trunc/;       # truncatingzeilen ignorieren
             chomp;                   # zeilenvorschub raus
             undef @zeile;            # var leeren f�r neuen durchgang
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
                 if ($zeile[$i] eq "") {             # Leerer Wert? Dann DEFAULT Befehl �bergeben.
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
        if ( $warehouse eq '160' ) {                        #pfad f�r stockno 160
             move2save("$STAT_STARTDIR/$NIGHT1_IN_IMPORTDIR","$STAT_STARTDIR/$STAT_SAVEDIR","$file");
        } elsif ( $warehouse eq '210' ) {                        #pfad f�r stockno 210
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
sub process_glsfile1($) {
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


     #get filelist
     if ( $warehouse eq '160' ) {                        #pfad f�r stockno 160
          opendir (DIR,"$STAT_STARTDIR/$GLS_PARCEL1_IMPORTDIR") || die "Opendir $STAT_STARTDIR/$GLS_PARCEL1_IMPORTDIR not possible: $!";
          if ($debug) {print "$STAT_STARTDIR/$GLS_PARCEL1_IMPORTDIR\n"};
          @filelist = grep { -f "$STAT_STARTDIR/$GLS_PARCEL1_IMPORTDIR/$_" } readdir(DIR);
          if ($debug) {print @filelist,"\n"};
          closedir DIR;
     }
     if ( $warehouse eq '210' ) {                        #pfad f�r stockno 210
          opendir (DIR,"$STAT_STARTDIR/$GLS_PARCEL2_IMPORTDIR") || die "Opendir $STAT_STARTDIR/$GLS_PARCEL2_IMPORTDIR not possible: $!";
          if ($debug) {print "$STAT_STARTDIR/$GLS_PARCEL2_IMPORTDIR\n"};
          @filelist = grep { -f "$STAT_STARTDIR/$GLS_PARCEL2_IMPORTDIR/$_" } readdir(DIR);
          if ($debug) {print @filelist,"\n"};
          closedir DIR;
     }

     #create logfile entry
     write_log_entry("process_glsfile1","INFO","READ START STOCKNO $warehouse","");

     if (@filelist lt 1 )
     {
	    # return early from subdir if dir empty and nothing to do
        write_log_entry("process_glsfile1","INFO","READ STOP Nothing to do","0");
        if ($debug) {print @filelist,"\n"};
        if ($debug) {print "Debug NOTHING TO DO\n"};
	    return;
     }

     #open connection to log and data db
     my $dbhandle = DBI->connect($DB_TYPE, $STAT_DB_USER, $STAT_DB_PASS, {RaiseError => 0}) or die "Database connection not made: $DBI::errstr";

     #process each file found
     foreach my $file ( @filelist ) {
        if ( $warehouse eq '160' ) {                        #pfad f�r stockno 160
             $INFILE_filename = "$STAT_STARTDIR/$GLS_PARCEL1_IMPORTDIR/$file"; # input file name
        } elsif ( $warehouse eq '210' ) {                        #pfad f�r stockno 210
             $INFILE_filename = "$STAT_STARTDIR/$GLS_PARCEL2_IMPORTDIR/$file"; # input file name
        }
        open ( INFILE, '<', $INFILE_filename ) or die  "$0 : failed to open input file $INFILE_filename : $!\n";
        while (<INFILE>){
             next if m/^\s*$/;        # Leerzeilen ignorieren
             next if m/^#/;       # truncatingzeilen ignorieren
             chomp;                   # zeilenvorschub raus
             undef @zeile;            # var leeren f�r neuen durchgang
             @zeile = split (/\|/);   # am pipe auftrennen
             $countcolumn = $#zeile;  # anzahl der arrayelemente aufheben

if ($debug) {$temp = $#zeile}; #   zu debugzwecken anzahl der arrayelemente aufheben
             for (my $i=0;$i<=$#zeile;$i++) {
                 $zeile[$i] = trim($zeile[$i]);             #werte trimmen
                 if ($zeile[$i] eq "") {             # Leerer Wert? Dann DEFAULT Befehl �bergeben.
                   $zeile[$i] = 'DEFAULT';
                 } else { #was drin? dann verpacken
                   $zeile[$i] =~ tr/'//d;             #hochkommas entfernen
                   $zeile[$i] = "\'".$zeile[$i]."\'";
                 }
             }
             if ($countcolumn == 16) {         #wenn 16 spalten dann letzte spalte = stockno
                 $zeile[17] = $warehouse;
             }
             elsif ($countcolumn == 15) {
               push @zeile,'';                           #sonst leere spalte anh�ngen
               push @zeile,$warehouse;                   #und dann stockno
             }
             elsif ($countcolumn == 17) {
               $temp = pop (@zeile);                           #sonst 1 spaltel�schen, ggf. linux
               push @zeile,$warehouse;                   #und dann stockno
             }
# TODO gls_parcel insert IGNORE ist richtig?
              $sql = "INSERT IGNORE INTO `gls_parcel_out` ( `carrierboxno` , `shipdate` , `gls_custno` , `weight` , `gls_product` , `gls_epl_number` , `tournumber` , `checkdate` , `country` , `zipcode` , `freight_terms` , `gls_trunc` , `custno` , `name` , `street` , `city` , `shipmentno` , `stockno`)
                       VALUES ($zeile[0],$zeile[1],$zeile[2],$zeile[3],$zeile[4],$zeile[5],$zeile[6],$zeile[7],$zeile[8],$zeile[9],$zeile[10],$zeile[11],$zeile[12],$zeile[13],$zeile[14],$zeile[15],$zeile[16],$zeile[17])";
# TODO aktivieren sql gls_parcel
              $dbhandle->do($sql);
#               print "SQL: ",$sql,"\n";
              $countvar++;
# if ($countvar == 3 ) {exit;}     #f�r debugzwecke
        }  # --- end while
        close ( INFILE ) or warn "$0 : failed to close input file $INFILE_filename : $!\n";
        #move file to save-dir
# TODO aktivieren move2save gls_parcel
        if ( $warehouse eq '160' ) {                        #pfad f�r stockno 160
#             move2save("$STAT_STARTDIR/$GLS_PARCEL1_IMPORTDIR","$STAT_STARTDIR/$STAT_SAVEDIR","$file","$warehouse");
        } elsif ( $warehouse eq '210' ) {                        #pfad f�r stockno 210
#             move2save("$STAT_STARTDIR/$GLS_PARCEL2_IMPORTDIR","$STAT_STARTDIR/$STAT_SAVEDIR","$file","$warehouse");
        }
        write_log_entry("process_glsfile1","INFO","FILENAME:$file","0");    #statusinfo zu jeder datei
     } # -----  end foreach  -----

     #create logfile entry
     write_log_entry("process_glsfile1","INFO","READ END","$countvar");

     if ($debug) {print "Debug Ende process_glsfile1\n"};
     return 1;
}


###########################################
# END of module
###########################################
1;
