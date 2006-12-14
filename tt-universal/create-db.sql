-- phpMyAdmin SQL Dump
-- version 2.8.1
-- http://www.phpmyadmin.net
--
-- Host: localhost
-- Erstellungszeit: 12. Dezember 2006 um 08:35
-- Server Version: 5.0.21
-- PHP-Version: 4.4.2-pl1
--
-- Datenbank: `s_stat`
--

-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `dhl_easylog1`
--

CREATE TABLE `dhl_easylog1` (
  `recordtype` varchar(25) NOT NULL default '',
  `rowpos` int(10) unsigned NOT NULL default '0',
  `parcelcount` int(10) unsigned NOT NULL default '0',
  `packing` varchar(25) default NULL,
  `weight` double NOT NULL default '0',
  `volume` double NOT NULL default '0',
  `length` double NOT NULL default '0',
  `width` double NOT NULL default '0',
  `height` double NOT NULL default '0',
  `lgmboxno` varchar(35) NOT NULL default '',
  `carrierboxno` varchar(35) NOT NULL default '',
  `routingcode` varchar(35) default NULL,
  `servicecode` varchar(35) default NULL,
  `shipmentno` int(11) NOT NULL default '0',
  `name1` varchar(60) NOT NULL default '',
  `name2` varchar(60) default NULL,
  `name3` varchar(60) default NULL,
  `street` varchar(60) NOT NULL default '',
  `street_number` varchar(10) default NULL,
  `city` varchar(60) NOT NULL default '',
  `zipcode` varchar(17) default NULL,
  `countrycode` char(3) default NULL,
  `contactperson1` varchar(35) default NULL,
  `contactperson2` varchar(35) default NULL,
  `credate` datetime NOT NULL default '0000-00-00 00:00:00',
  `stockno` int(10) unsigned NOT NULL default '0',
  PRIMARY KEY  (`stockno`,`credate`,`carrierboxno`,`lgmboxno`,`shipmentno`)
) TYPE=MyISAM;

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
  `partno` varchar(10) default NULL,
  `picklistno` int(10) unsigned default NULL,
  `shipmentno` int(10) unsigned default NULL,
  `shipmentrowpos` varchar(10) default NULL,
  `stocknosu` char(3) default NULL,
  `status` int(10) unsigned NOT NULL default '0',
  PRIMARY KEY  (`cono`,`custno`,`rowpos`,`rowsubpos`,`rowseq`,`status`)
) TYPE=MyISAM;

-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `gls_gepard1`
--

CREATE TABLE `gls_gepard1` (
  `date1` datetime NOT NULL default '0000-00-00 00:00:00',
  `date2` datetime NOT NULL default '0000-00-00 00:00:00',
  `custno` int(10) unsigned NOT NULL default '0',
  `carrierboxno` varchar(35) NOT NULL default '',
  `shipmentno` varchar(40) NOT NULL default '',
  `name1` varchar(60) NOT NULL default '',
  `name2` varchar(60) default NULL,
  `name3` varchar(60) default NULL,
  `street` varchar(60) NOT NULL default '',
  `city` varchar(60) NOT NULL default '',
  `city2` varchar(60) NOT NULL default '',
  `zipcode` varchar(17) NOT NULL default '',
  `zipcode2` varchar(17) NOT NULL default '',
  `countrycode` varchar(3) NOT NULL default '',
  `stockno` int(10) unsigned NOT NULL default '0',
  `unknown1` varchar(35) NOT NULL default '',
  `unknown2` varchar(35) NOT NULL default '',
  `unknown3` varchar(35) NOT NULL default '',
  `unknown4` varchar(35) NOT NULL default '',
  `unknown5` varchar(35) NOT NULL default '',
  `unknown6` varchar(35) NOT NULL default '',
  `unknown7` varchar(35) NOT NULL default '',
  `unknown8` varchar(35) NOT NULL default '',
  `unknown9` varchar(35) NOT NULL default '',
  `unknown10` varchar(35) NOT NULL default '',
  `unknown11` varchar(35) NOT NULL default '',
  `unknown12` varchar(35) NOT NULL default '',
  `unknown13` varchar(35) NOT NULL default '',
  PRIMARY KEY  (`stockno`,`date1`,`carrierboxno`,`custno`,`shipmentno`)
) TYPE=MyISAM;

-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `import_log`
--

CREATE TABLE `import_log` (
  `count` bigint(20) unsigned NOT NULL auto_increment,
  `source` varchar(60) NOT NULL default '',
  `category` varchar(5) NOT NULL default '',
  `logtime` datetime NOT NULL default '0000-00-00 00:00:00',
  `remark` varchar(255) NOT NULL default '',
  `lines_read` bigint(20) unsigned NOT NULL default '0',
  PRIMARY KEY  (`count`)
) TYPE=MyISAM;

-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `lm1_data`
--

CREATE TABLE `lm1_data` (
  `stockno` int(10) unsigned NOT NULL default '0',
  `custno` int(10) unsigned NOT NULL default '0',
  `picklistno` int(10) unsigned NOT NULL default '0',
  `shipmentno` int(10) unsigned NOT NULL default '0',
  `picklistrowpos` int(10) unsigned NOT NULL default '0',
  `rec_date` datetime default NULL,
  `ack_date` datetime default NULL,
  `carrier` varchar(10) default NULL,
  `lmboxno` int(10) unsigned default NULL,
  `carrierboxno` int(10) unsigned default NULL,
  PRIMARY KEY  (`stockno`,`custno`,`picklistno`,`shipmentno`,`picklistrowpos`),
  KEY `lmboxno` (`lmboxno`),
  KEY `picklistno` (`picklistno`),
  KEY `shipmentno` (`shipmentno`),
  KEY `custno` (`custno`)
) TYPE=MyISAM;

-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `nightplus1_in`
--

CREATE TABLE `nightplus1_in` (
  `returncode` varchar(100) NOT NULL default '',
  `errorcode` varchar(4) NOT NULL default '',
  `date1` datetime NOT NULL default '0000-00-00 00:00:00',
  `stockno` int(10) unsigned NOT NULL default '0',
  PRIMARY KEY  (`returncode`,`date1`,`stockno`)
) TYPE=MyISAM;

-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `nightplus1_out`
--

CREATE TABLE `nightplus1_out` (
  `carrierboxno` varchar(30) NOT NULL default '',
  `lgmboxno` int(10) unsigned default NULL,
  `custno` int(10) unsigned NOT NULL default '0',
  `servicetime` varchar(30) NOT NULL default '',
  `shipdate` datetime NOT NULL default '0000-00-00 00:00:00',
  `rowpos` int(10) unsigned NOT NULL default '0',
  `parcelcount` int(10) unsigned NOT NULL default '0',
  `weight` double NOT NULL default '0',
  `shipmentno` int(11) unsigned NOT NULL default '0',
  `stockno` int(10) unsigned NOT NULL default '0',
  PRIMARY KEY  (`stockno`,`shipdate`,`carrierboxno`,`shipmentno`)
) TYPE=MyISAM;

-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `gls_parcel_out`
--

CREATE TABLE `gls_parcel_out` (
  `carrierboxno` varchar(12) NOT NULL default '0',
  `shipdate` date NOT NULL,
  `gls_custno` int(10) NOT NULL default '0',
  `weight` int(10) default NULL,
  `gls_product` varchar(50) NOT NULL default ' ',
  `gls_epl_number` varchar(5) NOT NULL,
  `tournumber` int(10) NOT NULL default '0',
  `checkdate` date NOT NULL,
  `country` varchar(3) NOT NULL,
  `zipcode` varchar(6) NOT NULL,
  `freight_terms` int(10) NOT NULL default '0',
  `gls_trunc` int(10) NOT NULL default '0',
  `custno` int(10) NOT NULL default '0',
  `name` varchar(40) NOT NULL,
  `street` varchar(40) NOT NULL,
  `city` varchar(40) NOT NULL,
  `shipmentno` int(10) NOT NULL default '0',
  `stockno` int(3) NOT NULL,
  `checkin_date` datetime default NULL,
  `checkout_date` datetime default NULL,
  `status` int(2) default NULL,
  PRIMARY KEY  (`carrierboxno`,`shipdate`,`stockno`)
) TYPE=MyISAM;
