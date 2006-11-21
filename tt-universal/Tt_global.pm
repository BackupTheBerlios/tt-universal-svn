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
             ( `cono` , `custno` , `rowpos` , `rowsubpos` , `rowseq` , `priodate` , `partno` , `picklistno` , `shipmentno` , `field10` , `stocknosu` , `status` )
             VALUES
             ($zeile[0],$zeile[1],$zeile[2],$zeile[3],$zeile[4],$zeile[5],$zeile[6],$zeile[7],$zeile[8],$zeile[9],$zeile[10],$zeile[11])";
             $dbhandle->do($sql);
             $countvar++;
             }
        close ( INFILE ) or warn "$0 : failed to close input file $INFILE_filename : $!\n";
        #move file to save-dir
        move2save("$STAT_STARTDIR/$FOC_IMPORTDIR","$STAT_STARTDIR/$STAT_SAVEDIR","$file");
     } # -----  end foreach  -----

     #create logfile entry
     write_log_entry("get_focus","INFO","READ END","$countvar");

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
             for(my $i=0;$i<=$#zeile;$i++) {
                  $zeile[$i] = trim($zeile[$i]);
                  if ($zeile[$i] eq "") {    # Leerer Wert? Dann DEFAULT Befehl übergeben.
                    $zeile[$i] = 'DEFAULT';
                  } else { #was drin? dann verpacken
                    $zeile[$i] =~ tr/'//d;             #hochkommas entfernen
                    $zeile[$i] = "\'".$zeile[$i]."\'";
                  }
             }
             my $sql =
"INSERT IGNORE INTO `$LM1_TABLENAME` ( `stockno` , `custno` , `picklistno` , `shipmentno` , `picklistrowpos` , `rec_date` , `ack_date` , `carrier` , `lmboxno` , `carrierboxno` )
VALUES (
$zeile[0],$zeile[1],$zeile[2],$zeile[3],$zeile[4],$zeile[5],$zeile[6],$zeile[7],$zeile[8],$zeile[9]
)";
             $dbhandle->do($sql);
             $countvar++;
             }
        close ( INFILE ) or warn "$0 : failed to close input file $INFILE_filename : $!\n";
        #move file to save-dir
        move2save("$STAT_STARTDIR/$LM1_IMPORTDIR","$STAT_STARTDIR/$STAT_SAVEDIR","$file");
     } # -----  end foreach  -----

     #create logfile entry
     write_log_entry("get_lm1","INFO","READ END","$countvar");

     if ($debug) {print "Debug Ende get_lm1\n"};
}

###########################################
sub move2save($$$) {
###########################################
     my $from_dir = $_[0];
     my $to_dir = $_[1];
     my $file = $_[2];
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

#     print "Von: $from_dir \nNach: $to_dir/$year2/$mon2 \nFilename im SUB: $file \nMonat: $mon2 Jahr: $year2 \n";
     move("$from_dir/$file","$to_dir/$year2/$mon2/$file\.$timestamp\.done") or die "move not possible! $!\n";
}


1;

###########################################
sub get_timestamp() {
###########################################

     my ($sec,$min,$hour,$mday,$mon1,$year1,$wday,$ydat,$isdst)=localtime();         #aktuelle zeit holen
     my $mon = $mon1+1;
     my $year = $year1+1900;
     my $day = $mday;
     if (length($mon) == 1)
     {
         $mon="0$mon";                  #monate immer zweistellig
     }
     if (length($day) == 1)
     {
         $day="0$day";                  #tage immer zweistellig
     }
     if(length($hour) == 1)
     {
        $hour="0$hour";                 #stunden auch
     }
     if(length($min) == 1)
     {
        $min="0$min";                   #minuten auch
     }
     if(length($sec) == 1)
     {
        $sec="0$sec";                   #sekunden auch
     }
     my $timestamp = $year.$mon.$day.$hour.$min.$sec;       #zeitstempel bauen

     return $timestamp;
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
             if ($#zeile == 21 ) {                     #nur 22 spalten? Dann ansprechpartner hinzufügen
               	push @zeile,'';                        #zeile[22] = dummy
               	push @zeile,'';                        #zeile[23] = dummy
             }
             push @zeile,$datadate;                        #zeile[24] = datum
             push @zeile,$warehouse;                       #zeile[25] = stockno
             if ($sapo_true ) {                            #nur SAPO Sätze wegschreiben
                  for(my $i=0;$i<=$#zeile;$i++) {          #Nochmal durch alle Felder gehen und leere Werte anpassen
                       if ($zeile[$i] eq "") {             # Leerer Wert? Dann DEFAULT Befehl übergeben.
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
#                    print $sql,"\n";
                  $countvar++;
             }  # --- end if
        }  # --- end while
        close ( INFILE ) or warn "$0 : failed to close input file $INFILE_filename : $!\n";
        #move file to save-dir
        if ( $warehouse eq '160' ) {                        #pfad für stockno 160
             move2save("$STAT_STARTDIR/$DHL_EASY1_IMPORTDIR","$STAT_STARTDIR/$STAT_SAVEDIR","$file");
        } elsif ( $warehouse eq '210' ) {                        #pfad für stockno 210
             move2save("$STAT_STARTDIR/$DHL_EASY2_IMPORTDIR","$STAT_STARTDIR/$STAT_SAVEDIR","$file");
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
     my $temp;


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
             @zeile = split (/\|/);    #am pipe auftrennen
if ($debug) {$temp = $#zeile}; #   zu debugzwecken anzahl der arrayelemente aufheben
             for (my $i=0;$i<=$#zeile;$i++) {
                  $zeile[$i] = trim($zeile[$i]);             #werte trimmen
             }      #end for
             # erkennen des recordformats
             if ($zeile[20] =~ m/^\d{2}:\d{2}:\d{2}$/ ) { #format RMD
             	$rec_format = 'RMD';
             }
             elsif ($zeile[0] =~ m/^\d{12}$/ ) {         #format GP
              	$rec_format = 'GP';
             }
             elsif ($zeile[0] =~ m/^\d{2}.\d{2}.\d{4}$/ ) { #format GPMON
               	$rec_format = 'GPMON';
             }
# TODO Leere spalten am ende auffüllen
             push @zeile,$warehouse;                   #letzte $zeile = stockno
             for(my $i=0;$i<=$#zeile;$i++) {          #Nochmal durch alle Felder gehen und leere Werte anpassen
                 if ($zeile[$i] eq "") {             # Leerer Wert? Dann DEFAULT Befehl übergeben.
                   $zeile[$i] = 'DEFAULT';
                 } else { #was drin? dann verpacken
                   $zeile[$i] =~ tr/'//d;             #hochkommas entfernen
                   $zeile[$i] = "\'".$zeile[$i]."\'";
                 }
              }
              if ($rec_format eq 'RMD') { #format RMD
                    $sql = "INSERT IGNORE INTO `$GLS_GEP1_TABLENAME`
                    ( `carrierboxno` , `date1` , `unknown1` , `unknown2` , `unknown3` , `unknown11` , `unknown5` , `date2` , `countrycode` , `zipcode` , `unknown6` , `unknown7` , `custno` , `name1` , `name2` , `name3` , `street` , `city` , `unknown8` , `zipcode2` , `time` , `unknown10` , `stockno` )
                    VALUES
                    ($zeile[0],$zeile[1],$zeile[2],$zeile[3],$zeile[4],$zeile[5],$zeile[6],$zeile[7],$zeile[8],$zeile[9],$zeile[10],$zeile[11],$zeile[12],$zeile[13],$zeile[14],$zeile[15],$zeile[16],$zeile[17],$zeile[18],$zeile[19],$zeile[20],$zeile[21],$zeile[22])";
              }
              elsif ($rec_format eq 'GP') {         #format GP
                    $sql = "INSERT IGNORE INTO `$GLS_GEP1_TABLENAME`
                    ( `carrierboxno` , `date1` , `unknown1` , `unknown2` , `unknown3` , `unknown4` , `unknown5` , `date2` , `countrycode` , `zipcode` , `unknown6` , `unknown7` , `custno` , `name1` , `name2` , `name3` , `street` , `city` , `unknown8` , `zipcode2` , `unknown9` , `unknown10` , `stockno` )
                    VALUES
                    ($zeile[0],$zeile[1],$zeile[2],$zeile[3],$zeile[4],$zeile[5],$zeile[6],$zeile[7],$zeile[8],$zeile[9],$zeile[10],$zeile[11],$zeile[12],$zeile[13],$zeile[14],$zeile[15],$zeile[16],$zeile[17],$zeile[18],$zeile[19],$zeile[20],$zeile[21],$zeile[22])";
              }
              elsif ($rec_format eq 'GPMON') { #format GPMON
                    $sql = "INSERT IGNORE INTO `$GLS_GEP1_TABLENAME`
                    ( `carrierboxno` , `date1` , `unknown1` , `unknown12` , `unknown3` , `unknown4` , `unknown5` , `date2` , `countrycode` , `zipcode` , `unknown6` , `unknown7` , `unknown13` , `name1` , `street` , `city2` , `shipmentno` , `stockno` )
                    VALUES
                    ($zeile[1],$zeile[2],$zeile[3],$zeile[4],$zeile[5],$zeile[6],$zeile[7],$zeile[8],$zeile[9],$zeile[10],$zeile[11],$zeile[12],$zeile[13],$zeile[14],$zeile[15],$zeile[16],$zeile[17],$zeile[18])";
              }
#              $dbhandle->do($sql);
# TODO do sql aktivieren
if ($rec_format ne 'GPMON') { $sql=' ';}
              print "\nDatei: $file Format: $rec_format Spalten: $temp SQL: ",$sql,"\n";
              $countvar++;
        }  # --- end while
        close ( INFILE ) or warn "$0 : failed to close input file $INFILE_filename : $!\n";
        #move file to save-dir
# TODO move2save aktivieren
        if ( $warehouse eq '160' ) {                        #pfad für stockno 160
#             move2save("$STAT_STARTDIR/$GLS_GEP1_IMPORTDIR","$STAT_STARTDIR/$STAT_SAVEDIR","$file");
        } elsif ( $warehouse eq '210' ) {                        #pfad für stockno 210
#             move2save("$STAT_STARTDIR/$GLS_GEP2_IMPORTDIR","$STAT_STARTDIR/$STAT_SAVEDIR","$file");
        }
        write_log_entry("get_gls1","INFO","FILENAME:$file","0");    #statusinfo zu jeder datei
     } # -----  end foreach  -----

     #create logfile entry
     write_log_entry("get_gls1","INFO","READ END","$countvar");

     if ($debug) {print "Debug Ende get_gls1\n"};
     return 1;
}

###########################################
# END of module
###########################################
1;
