<?php
/*
 * Created on 01.08.2006
 *
 * To change the template for this generated file go to
 * Window - Preferences - PHPeclipse - PHP - Code Templates
 * phpinfo();
*/


$food = array('Obst' => array('Orange', 'Banane', 'Apfel'),
              'Gem�se' => array('Karrotte', 'Kohl', 'Erbse'));

// rekursiv z�hlen
print count($food, COUNT_RECURSIVE); // gibt 8 aus
print "Test";
// normales z�hlen
print count($food); // gibt 2 aus

 ?>
