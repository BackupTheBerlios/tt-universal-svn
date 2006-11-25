$x11 = "H002200616030012902300129021606045BFW Zoo-fachhandel WesterstedeGmbH                          Lange Str. 41                 26655   Westerstede                   08:0027.10.06 1 3 20,21951433Sssssss Abc Deutschland       30161   Hannover-Zoo                  Handelsware                                            Nacht Express       Acht Uhr       Frei Haus";
$x111 = "H002200616030013100300131001605028Büro 2000 K.A.H. GmbH                                       Papenreye 18                  22453   Hamburg                       08:0027.10.06 1 1  3,57951569Sssssss Abc Deutschland       30161   Hannover-Zoo                  Handelsware                                            Nacht Express       Acht Uhr       Frei Haus";
$x1 = "H002200616030013061300130611605028Büro 2000 K.A.H. GmbH                                       Papenreye 18                  22453   Hamburg                       08:0027.10.06 1 1  9,31951570Sssssss Abc Deutschland       30161   Hannover-Zoo                  Handelsware                                            Nacht Express       Acht Uhr       Frei Haus";

print "$x1\n";
print "$x2\n";
print "$x3\n";

my $Paketnummer = substr ($x1,0,19);
my $Paketreferenznummer = substr ($x1,19,8);
my $Empfaenger1 = substr ($x1,27,7);
my $Empfaenger2 = substr ($x1,34,30);
my $Empfaenger3 = substr ($x1,64,30);
my $Empfaenger4 = substr ($x1,94,30);
my $Empfaenger5 = substr ($x1,124,8);
my $Empfaenger6 = substr ($x1,132,30);
my $Zustellung_bis = substr ($x1,162,5);
my $Datum = substr ($x1,167,8);
my $Paket_x_von_Y1 = substr ($x1,175,2);
my $Paket_x_von_Y2 = substr ($x1,177,2);
my $Gewicht = substr ($x1,179,6);
my $Lieferscheinnr = substr ($x1,185,6);
my $Absender1 = substr ($x1,191,30);
my $Absender2 = substr ($x1,221,8);
my $Absender3 = substr ($x1,229,30);
my $Inhalt = substr ($x1,259,20);
my $ATG = substr ($x1,279,10);
my $AST = substr ($x1,289,10);
my $Sendung = substr ($x1,299,15);
my $Versandart = substr ($x1,314,20);
my $Label = substr ($x1,334,15);
my $Frankatur = substr ($x1,349,20);
my $Enkundename1 = substr ($x1,369,30);
my $Enkundename2 = substr ($x1,399,30);
my $Enkundename3 = substr ($x1,429,30);
my $Enkundename4 = substr ($x1,459,8);
my $Enkundename5 = substr ($x1,467,30);
my $stockno = substr ($x1,8,3);

push @zeile, substr ($x1,0,19);     #carrierrefno
push @zeile, substr ($x1,19,8);     #carrierboxno
push @zeile, substr ($x1,27,7);     #custno
push @zeile, substr ($x1,34,30);     #name1
push @zeile, substr ($x1,64,30);     #name2
push @zeile, substr ($x1,94,30);     #street
push @zeile, substr ($x1,124,8);     #zipcode
push @zeile, substr ($x1,132,30);     #city
push @zeile, substr ($x1,162,5);     #deliver_until
push @zeile, substr ($x1,167,8);     #shipdate
push @zeile, substr ($x1,175,2);     #parcelcount1
push @zeile, substr ($x1,177,2);     #parcelcount2
push @zeile, substr ($x1,179,6);     #weight
push @zeile, substr ($x1,185,6);     #shipmentno
push @zeile, substr ($x1,191,30);     #sender1
push @zeile, substr ($x1,221,8);     #sender2
push @zeile, substr ($x1,229,30);     #sender3
push @zeile, substr ($x1,259,20);     #content
push @zeile, substr ($x1,279,10);     #atg
push @zeile, substr ($x1,289,10);     #ast
push @zeile, substr ($x1,299,15);     #shipment
push @zeile, substr ($x1,314,20);     #dispatch
push @zeile, substr ($x1,334,15);     #labeltext
push @zeile, substr ($x1,349,20);     #freight_terms
push @zeile, substr ($x1,369,30);     #end_customer1
push @zeile, substr ($x1,399,30);     #end_customer2
push @zeile, substr ($x1,429,30);     #end_customer3
push @zeile, substr ($x1,459,8);     #end_customer4
push @zeile, substr ($x1,467,30);     #end_customer5
push @zeile, substr ($x1,8,3);       #stockno

for(my $i=0;$i<=$#zeile;$i++) {
     $zeile[$i] = trim($zeile[$i]);
     if ($zeile[$i] eq "") {    # Leerer Wert? Dann DEFAULT Befehl übergeben.
       $zeile[$i] = 'DEFAULT';
     } else { #was drin? dann verpacken
       $zeile[$i] =~ tr/'//d;             #hochkommas entfernen
       $zeile[$i] = "\'".$zeile[$i]."\'";
     }
}

print "carrierrefno:=>$carrierrefno<= ->$zeile[0]<-\n";
print "carrierboxno:=>$carrierboxno<= ->$zeile[1]<-\n";
print "custno:=>$custno<= ->$zeile[2]<-\n";
print "name1:=>$name1<= ->$zeile[3]<-\n";
print "name2:=>$name2<= ->$zeile[4]<-\n";
print "street:=>$street<= ->$zeile[5]<-\n";
print "zipcode:=>$zipcode<= ->$zeile[6]<-\n";
print "city:=>$city<= ->$zeile[7]<-\n";
print "deliver_until:=>$deliver_until<= ->$zeile[8]<-\n";
print "date:=>$date<= ->$zeile[9]<-\n";
print "parcelcount1:=>$parcelcount1<= ->$zeile[10]<-\n";
print "parcelcount2:=>$parcelcount2<= ->$zeile[11]<-\n";
print "weight:=>$weight<= ->$zeile[12]<-\n";
print "shipmentno:=>$shipmentno<= ->$zeile[13]<-\n";
print "sender1:=>$sender1<= ->$zeile[14]<-\n";
print "sender2:=>$sender2<= ->$zeile[15]<-\n";
print "sender3:=>$sender3<= ->$zeile[16]<-\n";
print "content:=>$content<= ->$zeile[17]<-\n";
print "atg:=>$atg<= ->$zeile[18]<-\n";
print "ast:=>$ast<= ->$zeile[19]<-\n";
print "shipment:=>$shipment<= ->$zeile[20]<-\n";
print "dispatch:=>$dispatch<= ->$zeile[21]<-\n";
print "labeltext:=>$labeltext<= ->$zeile[22]<-\n";
print "freight_terms:=>$freight_terms<= ->$zeile[23]<-\n";
print "end_customer1:=>$end_customer1<= ->$zeile[24]<-\n";
print "end_customer2:=>$end_customer2<= ->$zeile[25]<-\n";
print "end_customer3:=>$end_customer3<= ->$zeile[26]<-\n";
print "end_customer4:=>$end_customer4<= ->$zeile[27]<-\n";
print "end_customer5:=>$end_customer5<= ->$zeile[28]<-\n";


print "Stockno:=>$stockno<= ->$zeile[29]<-\n";

sub trim($) {
  my $string = shift;
  $string =~ s/^\s+//;
  $string =~ s/\s+$//;
  return $string;
}
