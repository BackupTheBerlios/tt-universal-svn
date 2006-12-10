#!/usr/bin/perl
###########################################
# parameters.inc.pl -- Parameter Datei für Perl Scripte
# Robert Krauss, 2006 (rk-hannover@gmx.de )
###########################################
use strict;
use vars qw(
$STAT_DB
$DB_HOST
$DB_TYPE
$STAT_DB_USER
$STAT_DB_PASS
$LOG_TABLE
$STAT_STARTDIR
$STAT_SAVEDIR
$FOC_IMPORTDIR
$FOC_TABLENAME
$LM1_IMPORTDIR
$LM1_TABLENAME
$DHL_EASY1_IMPORTDIR
$DHL_EASY1_TABLENAME
$GLS_GEP1_IMPORTDIR
$GLS_GEP1_TABLENAME
$NIGHT1_IN_IMPORTDIR
$NIGHT1_IN_TABLENAME
$NIGHT1_OUT_IMPORTDIR
$NIGHT1_OUT_TABLENAME
);


$STAT_DB = 's_stat';        #Name der Stat Datenbank
$DB_HOST = 'localhost';		#Rechnername auf dem die MySQL DB liegt
$DB_TYPE = 'DBI:mysql:'.$STAT_DB.':'.$DB_HOST;	#DBI Zugriffsparameter für mysql

$STAT_DB_USER = 'root';    #Username für zugriff auf DB
$STAT_DB_PASS = '';        #passwort für zugriff auf DB

$LOG_TABLE = 'import_log'; #name der logging tabelle

$STAT_STARTDIR = 'e:/spicers';     #wo liegen die daten der anwendung
# $STAT_STARTDIR = '//gringots/netzdaten/win_data/projekte/spicers';     #wo liegen die daten der anwendung
$STAT_SAVEDIR = 'save';                              #wo werden die eingelesenen files abgelegt

$FOC_IMPORTDIR = 'daten-focus';                      #wo liegen die focus daten
$FOC_TABLENAME = 'focus_data';                       #in welche tabelle kommen die focus daten

$LM1_IMPORTDIR = 'lm1';                      #wo liegen die lm daten
$LM1_TABLENAME = 'lm1_data';                       #in welche tabelle kommen die lm daten

$DHL_EASY1_IMPORTDIR = 'dhl';                     #wo liegen die dhl easylog daten
$DHL_EASY1_TABLENAME = 'dhl_easylog1';

$GLS_GEP1_IMPORTDIR = 'gls';                      #wo liegen die gls gepard daten
$GLS_GEP1_TABLENAME = 'gls_gepard1';

$NIGHT1_IN_IMPORTDIR = 'nightstar/receive';       #wo liegen die nightstar daten
$NIGHT1_IN_TABLENAME = 'nightstar1_in';

$NIGHT1_OUT_IMPORTDIR = 'nightstar/send';         #wo liegen die nightstar daten
$NIGHT1_OUT_TABLENAME = 'nightstar1_out';


1;