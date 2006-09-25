use strict;
use vars qw(
$STAT_DB
$STAT_DB_USER
$STAT_DB_PASS
$LOG_TABLE
$STAT_STARTDIR
$STAT_SAVEDIR
$FOC_IMPORTDIR
$FOC_TABLENAME
);

$STAT_DB = 'spicers_stat'; #Name der Stat Datenbank
$STAT_DB_USER = 'root';    #Username für zugriff auf DB
$STAT_DB_PASS = '';        #passwort für zugriff auf DB

$LOG_TABLE = 'import_log'; #name der logging tabelle

$STAT_STARTDIR = 'G:/win_data/projekte/spicers';     #wo liegen die daten der anwendung
$STAT_SAVEDIR = 'save';                              #wo werden die eingelesenen files abgelegt

$FOC_IMPORTDIR = 'daten-focus';                      #wo liegen die focus daten
$FOC_TABLENAME = 'focus_data';                       #in welche tabelle kommen die focus daten


1;