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
sub get_dhl1() {
###########################################

     if ($debug) {print "Debug Start get_dhl1\n"};
     my $countvar = 0;

     #get filelist
     opendir (DIR,"$STAT_STARTDIR/$DHL_EASY1_IMPORTDIR") || die "Opendir $STAT_STARTDIR/$DHL_EASY1_IMPORTDIR not possible: $!";
     my @filelist = grep { -f "$STAT_STARTDIR/$DHL_EASY1_IMPORTDIR/$_" } readdir(DIR);
     closedir DIR;

     #create logfile entry
     write_log_entry("get_dhl1","INFO","READ START","");

     if (@filelist lt 1 )
     {
	    # return early from subdir if dir empty and nothing to do
        write_log_entry("get_dhl1","INFO","READ STOP Nothing to do","0");
	    return;
     }

     #open connection to log and data db
     my $dbhandle = DBI->connect($DB_TYPE, $STAT_DB_USER, $STAT_DB_PASS, {RaiseError => 0}) or die "Database connection not made: $DBI::errstr";

     #process each file found
     foreach my $file ( @filelist ) {
        my	$INFILE_filename = "$STAT_STARTDIR/$DHL_EASY1_IMPORTDIR/$file"; # input file name
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
                    $zeile[$i] = "\'".$zeile[$i]."\'";
                  }
             }
             my $sql = "INSERT IGNORE INTO `$DHL_EASY1_TABLENAME`
             ( `cono` , `custno` , `rowpos` , `rowsubpos` , `rowseq` , `priodate` , `partno` , `picklistno` , `shipmentno` , `field10` , `stocknosu` , `status` )
             VALUES
             ($zeile[0],$zeile[1],$zeile[2],$zeile[3],$zeile[4],$zeile[5],$zeile[6],$zeile[7],$zeile[8],$zeile[9],$zeile[10],$zeile[11])";
#             $dbhandle->do($sql);
          print $sql,"\n";
             $countvar++;
             }
        close ( INFILE ) or warn "$0 : failed to close input file $INFILE_filename : $!\n";
        #move file to save-dir
#        move2save("$STAT_STARTDIR/$DHL_EASY1_IMPORTDIR","$STAT_STARTDIR/$STAT_SAVEDIR","$file");
     } # -----  end foreach  -----

     #create logfile entry
     write_log_entry("get_dhl1","INFO","READ END","$countvar");

     if ($debug) {print "Debug Ende get_dhl1\n"};
}

###########################################
# END of module
###########################################
1;
