<?php
require_once("DB.php");

function get_user_id( $name )
{
  $dsn = 'mysql://root@localhost/mysql';
  $db =& DB::Connect( $dsn, array() );
  if (PEAR::isError($db)) { die($db->getMessage()); }

  $res = $db->query( 'SELECT host FROM user WHERE user=?',
  array( $name ) );
  $id = null;
  while( $res->fetchInto( $row ) ) { $id = $row[0]; }

  return $id;
}

var_dump( get_user_id( 'jack' ) );
?>