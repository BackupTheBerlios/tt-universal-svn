#!/usr/bin/perl
###########################################
# get_nightstar_receive1.pl -- Import statistic from easylog into mysql tables
# Robert Krauss, 2006 (rk-hannover@gmx.de)
###########################################

my $debug = 1;              # set to 1 for debug print (for each .pl .pm separately)

# use strict;
use warnings;
use DBI;
use File::Copy;
use Tt_global ();           #our own module for all relevant subroutines
use Tt_parameters ();       #our own module for global vars


sub get_nightstar_receive1($);


$| = 1;                     # don't buffer STDOUT (for EPIC use)

#=============== MAIN =====================
if ($debug) {print get_timestamp()," ScriptStart!\n"};
get_nightstar_receive1('160');
# get_nightstar_receive1('210');
if ($debug) {print get_timestamp()," ScriptEnde!\n"};
#=============== END MAIN =================

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
             push @zeile, substr ($_,0,17);     #carrierrefno
             push @zeile, substr ($_,17,7);     #custno
             push @zeile, substr ($_,24,14);     #value1
             push @zeile, date_switch(substr ($_,38,8));     #date1-date
             push @zeile, substr ($_,46,8);     #date1-time
             $zeile[4] =~ tr/ /0/;              #leerzeichen in timestring zu 0 ersetzen
             $zeile[3] = $zeile[3]." ".$zeile[4]; #formatieren als timestring
             if ( $warehouse eq '160' ) {                        #pfad für stockno 160
                 $zeile[4] ='160';                               # wert 160 eintragen
             } elsif ( $warehouse eq '210' ) {                        #pfad für stockno 210
                 $zeile[4] ='210';                               # wert 210 eintragen
             }
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
              (`carrierrefno`,`custno`,`date1`,`value1`,`stockno`)
              VALUES
              ($zeile[0],$zeile[1],$zeile[2],$zeile[3],$zeile[4])";
#              $dbhandle->do($sql);
               print "SQL: ",$sql,"\n";
              $countvar++;
        }  # --- end while
        close ( INFILE ) or warn "$0 : failed to close input file $INFILE_filename : $!\n";
        #move file to save-dir
        if ( $warehouse eq '160' ) {                        #pfad für stockno 160
#             move2save("$STAT_STARTDIR/$NIGHT1_IN_IMPORTDIR","$STAT_STARTDIR/$STAT_SAVEDIR","$file");
        } elsif ( $warehouse eq '210' ) {                        #pfad für stockno 210
#             move2save("$STAT_STARTDIR/$NIGHT2_IN_IMPORTDIR","$STAT_STARTDIR/$STAT_SAVEDIR","$file");
        }
        write_log_entry("get_nightstar_receive1","INFO","FILENAME:$file","0");    #statusinfo zu jeder datei
     } # -----  end foreach  -----

     #create logfile entry
     write_log_entry("get_nightstar_receive1","INFO","READ END","$countvar");

     if ($debug) {print "Debug Ende get_nightstar_receive1\n"};
     return 1;
}

