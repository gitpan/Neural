use Math::DVector;

print "1..1\n";

$v = new Math::DVector(3);

$v->setlist(3,4,5);

$v2 = new Math::DVector(3);

$v2->setlist(4,5,6);

$v->add_vec($v2,2);

@l = $v->aslist;

if($l[0] == 11) { print "ok 1\n"; } else {print "not ok 1\n";}

