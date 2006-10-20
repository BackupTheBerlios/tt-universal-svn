-- phpMyAdmin SQL Dump
-- version 2.8.1
-- http://www.phpmyadmin.net
--
-- Host: localhost
-- Erstellungszeit: 20. Oktober 2006 um 14:49
-- Server Version: 5.0.21
-- PHP-Version: 4.4.2-pl1
--
-- Datenbank: `s_stat`
--

-- --------------------------------------------------------

--
-- Tabellenstruktur f�r Tabelle `focus_data`
--

CREATE TABLE `focus_data` (
  `cono` int(10) unsigned NOT NULL default '0',
  `custno` int(10) unsigned NOT NULL default '0',
  `rowpos` int(10) unsigned NOT NULL default '0',
  `rowsubpos` int(10) unsigned NOT NULL default '0',
  `rowseq` int(10) unsigned NOT NULL default '0',
  `priodate` datetime default NULL,
  `partno` varchar(10) collate latin1_general_ci default NULL,
  `picklistno` int(10) unsigned default NULL,
  `shipmentno` int(10) unsigned default NULL,
  `field10` varchar(10) collate latin1_general_ci default NULL,
  `stocknosu` varchar(3) collate latin1_general_ci default NULL,
  `status` int(10) unsigned NOT NULL default '0',
  PRIMARY KEY  (`cono`,`custno`,`rowpos`,`rowsubpos`,`rowseq`,`status`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COLLATE=latin1_general_ci;

-- --------------------------------------------------------

--
-- Tabellenstruktur f�r Tabelle `import_log`
--

CREATE TABLE `import_log` (
  `count` bigint(20) unsigned NOT NULL auto_increment,
  `source` varchar(60) collate latin1_general_ci NOT NULL,
  `category` varchar(5) collate latin1_general_ci NOT NULL,
  `logtime` datetime NOT NULL,
  `remark` varchar(100) collate latin1_general_ci NOT NULL,
  `lines_read` bigint(20) unsigned NOT NULL default '0',
  PRIMARY KEY  (`count`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COLLATE=latin1_general_ci;

-- --------------------------------------------------------

--
-- Tabellenstruktur f�r Tabelle `lm1_data`
--

CREATE TABLE `lm1_data` (
  `stockno` int(10) unsigned NOT NULL,
  `custno` int(10) unsigned NOT NULL,
  `picklistno` int(10) unsigned NOT NULL,
  `shipmentno` int(10) unsigned NOT NULL,
  `picklistrowpos` int(10) unsigned NOT NULL,
  `rec_date` datetime default NULL,
  `ack_date` datetime default NULL,
  `carrier` varchar(10) collate latin1_general_ci default NULL,
  `lmboxno` int(10) unsigned default NULL,
  `carrierboxno` int(10) unsigned default NULL,
  PRIMARY KEY  (`stockno`,`custno`,`picklistno`,`shipmentno`,`picklistrowpos`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COLLATE=latin1_general_ci;
