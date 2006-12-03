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
-- Tabellenstruktur für Tabelle `focus_data`
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
  `shipmentrowpos` varchar(10) collate latin1_general_ci default NULL,
  `stocknosu` varchar(3) collate latin1_general_ci default NULL,
  `status` int(10) unsigned NOT NULL default '0',
  PRIMARY KEY  (`cono`,`custno`,`rowpos`,`rowsubpos`,`rowseq`,`status`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COLLATE=latin1_general_ci;

-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `import_log`
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
-- Tabellenstruktur für Tabelle `lm1_data`
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

-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `dhl_easylog1`
--

CREATE TABLE `dhl_easylog1` (
  `recordtype` varchar(25) collate latin1_general_ci NOT NULL default '',
  `rowpos` int(10) unsigned NOT NULL default '0',
  `parcelcount` int(10) unsigned NOT NULL default '0',
  `packing` varchar(25) collate latin1_general_ci default NULL,
  `weight` double NOT NULL,
  `volume` double NOT NULL,
  `length` double NOT NULL,
  `width` double NOT NULL,
  `height` double NOT NULL,
  `lgmboxno` varchar(35) collate latin1_general_ci NOT NULL default '',
  `carrierboxno` varchar(35) collate latin1_general_ci NOT NULL default '',
  `routingcode` varchar(35) collate latin1_general_ci default NULL,
  `servicecode` varchar(35) collate latin1_general_ci default NULL,
  `shipmentno` varchar(40) collate latin1_general_ci default NULL,
  `name1` varchar(60) collate latin1_general_ci NOT NULL default '',
  `name2` varchar(60) collate latin1_general_ci default NULL,
  `name3` varchar(60) collate latin1_general_ci default NULL,
  `street` varchar(60) collate latin1_general_ci NOT NULL default '',
  `street_number` varchar(10) collate latin1_general_ci default NULL,
  `city` varchar(60) collate latin1_general_ci NOT NULL default '',
  `zipcode` varchar(17) collate latin1_general_ci default NULL,
  `countrycode` varchar(3) collate latin1_general_ci default NULL,
  `contactperson1` varchar(35) collate latin1_general_ci default NULL,
  `contactperson2` varchar(35) collate latin1_general_ci default NULL,
  `credate` datetime NOT NULL default '0000-00-00 00:00:00',
  `stockno` int(10) unsigned NOT NULL default '0',
  PRIMARY KEY  (`stockno`,`credate`,`carrierboxno`,`lgmboxno`,`shipmentno`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COLLATE=latin1_general_ci;

-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `gls_gepard1`
--

CREATE TABLE `gls_gepard1` (
  `date1` datetime NOT NULL default '0000-00-00 00:00:00',
  `date2` datetime NOT NULL default '0000-00-00 00:00:00',
  `custno` int(10) unsigned NOT NULL,
  `carrierboxno` varchar(35) collate latin1_general_ci NOT NULL default '',
  `shipmentno` varchar(40) collate latin1_general_ci NOT NULL default '',
  `name1` varchar(60) collate latin1_general_ci NOT NULL default '',
  `name2` varchar(60) collate latin1_general_ci default NULL,
  `name3` varchar(60) collate latin1_general_ci default NULL,
  `street` varchar(60) collate latin1_general_ci NOT NULL default '',
  `city` varchar(60) collate latin1_general_ci NOT NULL default '',
  `city2` varchar(60) collate latin1_general_ci NOT NULL default '',
  `zipcode` varchar(17) collate latin1_general_ci NOT NULL default '',
  `zipcode2` varchar(17) collate latin1_general_ci NOT NULL default '',
  `countrycode` varchar(3) collate latin1_general_ci NOT NULL default '',
  `stockno` int(10) unsigned NOT NULL default '0',
  `unknown1` varchar(35) collate latin1_general_ci NOT NULL default '',
  `unknown2` varchar(35) collate latin1_general_ci NOT NULL default '',
  `unknown3` varchar(35) collate latin1_general_ci NOT NULL default '',
  `unknown4` varchar(35) collate latin1_general_ci NOT NULL default '',
  `unknown5` varchar(35) collate latin1_general_ci NOT NULL default '',
  `unknown6` varchar(35) collate latin1_general_ci NOT NULL default '',
  `unknown7` varchar(35) collate latin1_general_ci NOT NULL default '',
  `unknown8` varchar(35) collate latin1_general_ci NOT NULL default '',
  `unknown9` varchar(35) collate latin1_general_ci NOT NULL default '',
  `unknown10` varchar(35) collate latin1_general_ci NOT NULL default '',
  `unknown11` varchar(35) collate latin1_general_ci NOT NULL default '',
  `unknown12` varchar(35) collate latin1_general_ci NOT NULL default '',
  `unknown13` varchar(35) collate latin1_general_ci NOT NULL default '',
  PRIMARY KEY  (`stockno`,`date1`,`carrierboxno`,`custno`,`shipmentno`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COLLATE=latin1_general_ci;

-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `nightstar1_out`
--

CREATE TABLE `nightstar1_out` (
  `carrierrefno` varchar(30) collate latin1_general_ci NOT NULL default '',
  `carrierboxno` varchar(30) collate latin1_general_ci NOT NULL default '',
  `custno` int(10) unsigned NOT NULL default '0',
  `name1` varchar(30) collate latin1_general_ci NOT NULL default '',
  `name2` varchar(30) collate latin1_general_ci NOT NULL default '',
  `street` varchar(30) collate latin1_general_ci NOT NULL default '',
  `zipcode` varchar(10) collate latin1_general_ci NOT NULL default '',
  `city` varchar(30) collate latin1_general_ci NOT NULL default '',
  `deliver_until` varchar(30) collate latin1_general_ci NOT NULL default '',
  `shipdate` datetime NOT NULL default '0000-00-00 00:00:00',
  `parcelcount1` int(10) unsigned NOT NULL default '0',
  `parcelcount2` int(10) unsigned NOT NULL default '0',
  `weight` double NOT NULL default '0',
  `shipmentno` int(10) unsigned NOT NULL default '0',
  `sender1` varchar(30) collate latin1_general_ci NOT NULL default '',
  `sender2` varchar(30) collate latin1_general_ci NOT NULL default '',
  `sender3` varchar(30) collate latin1_general_ci NOT NULL default '',
  `content` varchar(30) collate latin1_general_ci NOT NULL default '',
  `atg` varchar(30) collate latin1_general_ci NOT NULL default '',
  `ast` varchar(30) collate latin1_general_ci NOT NULL default '',
  `shipment` varchar(30) collate latin1_general_ci NOT NULL default '',
  `dispatch` varchar(30) collate latin1_general_ci NOT NULL default '',
  `labeltext` varchar(30) collate latin1_general_ci NOT NULL default '',
  `freight_terms` varchar(30) collate latin1_general_ci NOT NULL default '',
  `end_customer1` varchar(30) collate latin1_general_ci NOT NULL default '',
  `end_customer2` varchar(30) collate latin1_general_ci NOT NULL default '',
  `end_customer3` varchar(30) collate latin1_general_ci NOT NULL default '',
  `end_customer4` varchar(30) collate latin1_general_ci NOT NULL default '',
  `end_customer5` varchar(30) collate latin1_general_ci NOT NULL default '',
  `stockno` int(10) unsigned NOT NULL default '0',
  PRIMARY KEY  (`stockno`,`shipdate`,`carrierboxno`,`shipmentno`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COLLATE=latin1_general_ci;

-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `nightstar1_in`
--

CREATE TABLE `nightstar1_in` (
  `carrierrefno` varchar(30) collate latin1_general_ci NOT NULL default '',
  `custno` int(10) unsigned NOT NULL default '0',
  `date1` datetime NOT NULL default '0000-00-00 00:00:00',
  `value1` varchar(14) collate latin1_general_ci NOT NULL default '',
  `stockno` int(10) unsigned NOT NULL default '0',
  PRIMARY KEY  (`carrierrefno`,`date1`,`stockno`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COLLATE=latin1_general_ci;

