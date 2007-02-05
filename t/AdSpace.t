#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2006 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use FindBin;
use strict;
use lib "$FindBin::Bin/lib";
use WebGUI::Test;
use WebGUI::Session;

use Test::More;
use Test::Deep;

my $numTests = 11; # increment this value for each test you create
++$numTests; ##For conditional testing on module load

plan tests => $numTests;

my $loaded = use_ok('WebGUI::AdSpace');

my $session = WebGUI::Test->session;
my ($adSpace, $alfred, $alfred2, $bruce, $catWoman, $defaultAdSpace );

SKIP: {

	skip "Unable to load WebGUI::AdSpace", $numTests-1 unless $loaded;

	$adSpace = WebGUI::AdSpace->create($session, {name=>"Alfred"});

	isa_ok($adSpace, 'WebGUI::AdSpace');

	my $data = $session->db->quickHashRef("select adSpaceId, name from adSpace where adSpaceId=?",[$adSpace->getId]);

	ok(exists $data->{adSpaceId}, "create()");
	is($data->{name}, $adSpace->get("name"), "get()");
	is($data->{adSpaceId}, $adSpace->getId, "getId()");

    $alfred = WebGUI::AdSpace->newByName($session, 'Alfred');

    cmp_deeply($adSpace, $alfred, 'newByName returns identical object if name exists');

    $bruce = WebGUI::AdSpace->newByName($session, 'Bruce');
    is($bruce, undef, 'newByName returns undef if the name does not exist');
    
    $alfred2 = WebGUI::AdSpace->create($session);
    is($alfred2, undef, 'create returns undef unless you pass it a name');
    
    $alfred2 = WebGUI::AdSpace->create($session, {name => 'Alfred'});
    is($alfred2, undef, 'create returns undef if the name already exists');

	isa_ok($alfred->session, 'WebGUI::Session');

    undef $alfred2;

    $alfred->set({title => "Alfred's Ad"});
    is($alfred->get('title'), "Alfred's Ad", "get, set work on title");

    $bruce = WebGUI::AdSpace->create($session, {name => 'Bruce'});
    $bruce->set({title => "Bruce's Ad"});

    $catWoman = WebGUI::AdSpace->create($session, {name => 'CatWoman'});
    $catWoman->set({title => "CatWoman's Ad"});

    my $adSpaces = WebGUI::AdSpace->getAdSpaces($session);

    cmp_deeply($adSpaces, [$alfred, $bruce, $catWoman], 'getAdSpaces returns all AdSpaces in alphabetical order by title');
}

END {
    foreach my $ad_space ($adSpace, $bruce, $alfred, $alfred2, $catWoman, $defaultAdSpace ) {
        if (defined $ad_space and ref $ad_space eq 'WebGUI::AdSpace') {
            $ad_space->delete;
        }
    }
}
