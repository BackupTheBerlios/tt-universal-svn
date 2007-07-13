#!/usr/bin/perl

if ($debug) {print "Debug tt_paratemers\n"};

# $STAT_DB = 's_stat';        #Name der Stat Datenbank
$STAT_DB = 'trackandtrace';        #Name der Stat Datenbank
$DB_HOST = 'localhost';		#Rechnername auf dem die MySQL DB liegt
$DB_TYPE = 'DBI:mysql:'.$STAT_DB.':'.$DB_HOST;	#DBI Zugriffsparameter f�r mysql

$STAT_DB_USER = 'root';    #Username f�r zugriff auf DB
$STAT_DB_PASS = '';        #passwort f�r zugriff auf DB

$LOG_TABLE = 'import_log';                   #name der logging tabelle
$SERVER_NAME = 'http://localhost';           #name des servers f�r url
# $SERVER_NAME = 'http://stat.spicers.de';           #name des servers f�r url
$SERVER_HELP_URL = 'http://stat.spicers.de/wiki/index.php/Hilfeseite_trackandtrace';		#URL der internen Hilfeseite
$TTO_SERVER_URL_DHL = 'http://nolp.dhl.de/nextt-online-public/set_identcodes.do?lang=de&zip=';			#URL f�r Track and trace online bei DHL, nach der plz folgt noch &idc=
$TTO_SERVER_URL_GLS = 'http://www.gls-germany.com/online/paketstatus.php3?mode=&hasdata=1&filter=all&datatype=paketnr&paketnr=&search.x=51&search.y=10&search=search&paketliste%5B0%5D=';			#URL f�r Track and trace online bei GLS
$SERVER_PATH = 'trackandtrace/';                           #subdir des servers f�r url ACHTUNG! MIT abschliessendem Slash!
$SERVER_MAIN_FILENAME = 'searchdata.pl';     #name des hauptscripts

# $STAT_STARTDIR = 'C:/down/spicers';                                      #wo liegen die daten der anwendung
# $STAT_STARTDIR = 'C:/Down/gls';
# $STAT_STARTDIR = '//gringots/netzdaten/win_data/projekte/spicers';    #wo liegen die daten der anwendung
# $STAT_STARTDIR = '/spicers/trackandtrace';
# $STAT_STARTDIR = 'D:\down\spicers-down';
$STAT_STARTDIR = '/Users/rk/spicers';
$STAT_SAVEDIR = 'save';                                               #wo werden die eingelesenen files abgelegt

$FOC_IMPORTDIR = 'daten-focus';                                       #wo liegen die focus daten
$FOC_TABLENAME = 'focus_data';                                        #in welche tabelle kommen die focus daten

$LM1_IMPORTDIR = 'lm1';                                               #wo liegen die lm daten
$LM1_TABLENAME = 'lm1_data';                                          #in welche tabelle kommen die lm daten

$DHL_EASY1_IMPORTDIR = 'dhl160';                                      #wo liegen die dhl easylog daten f�r stockno 160
$DHL_EASY2_IMPORTDIR = 'dhl210';                                      #wo liegen die dhl easylog daten f�r stockno 210
$DHL_EASY1_TABLENAME = 'dhl_easylog1';

$GLS_GEP1_IMPORTDIR = 'gls160';                                       #wo liegen die gls gepard daten f�r stockno 160
$GLS_GEP2_IMPORTDIR = 'gls210';                                       #wo liegen die gls gepard daten f�r stockno 210
$GLS_GEP1_TABLENAME = 'gls_gepard1';

$NIGHT1_IN_IMPORTDIR = 'nightstar160/receive';                        #wo liegen die nightstar daten 160
$NIGHT2_IN_IMPORTDIR = 'nightstar210/receive';                        #wo liegen die nightstar daten 210
$NIGHT1_IN_TABLENAME = 'nightstar1_in';

$NIGHT1_OUT_IMPORTDIR = 'nightstar160/send';                          #wo liegen die nightstar daten 160
$NIGHT2_OUT_IMPORTDIR = 'nightstar210/send';                          #wo liegen die nightstar daten
$NIGHT1_OUT_TABLENAME = 'nightstar1_out';

$GLS_PARCEL1_IMPORTDIR = 'glsparcel160';                              #wo liegen die kdpaket.dat files f�r stockno 160
$GLS_PARCEL2_IMPORTDIR = 'glsparcel210';                              #wo liegen die kdpaket.dat files f�r stockno 210
$GLS_PARCEL1_EXPORTDIR = 'glsparcel160/out';                          #wo liegen die kdpaket.dat files von stockno 160
$GLS_PARCEL2_EXPORTDIR = 'glsparcel210/out';                          #wo liegen die kdpaket.dat files von stockno 210
$GLS_OUT1_TABLENAME = 'gls_parcel_out';
$GLS_FTPUSER160 = 'test1';                                                 #name des ftp users auf dem gls server
$GLS_FTPPASS160 = 'test1';                                                 #name des ftp passwd auf dem gls server
$GLS_FTPHOST160 = 'localhost';                                                 #name des ftp servers auf dem gls server
$GLS_FTPPATH160 = '/l160';                                                 #speicherpfad auf dem gls server
$GLS_FTPUSER210 = 'test22';                                                 #name des ftp users auf dem gls server
$GLS_FTPPASS210 = 'test2';                                                 #name des ftp passwd auf dem gls server
$GLS_FTPHOST210 = 'localhost';                                                 #name des ftp servers auf dem gls server
$GLS_FTPPATH210 = '/l210';                                                 #speicherpfad auf dem gls server

###########################################
# END of module
###########################################
1;
