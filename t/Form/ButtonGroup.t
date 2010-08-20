# vim:syntax=perl
#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2009 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#------------------------------------------------------------------

# Test the ButtonGroup form element
# 
#

use FindBin;
use strict;
use lib "$FindBin::Bin/../lib";
use Test::More;
use Test::Deep;
use WebGUI::Test; # Must use this before any other WebGUI modules
use WebGUI::Session;

#----------------------------------------------------------------------------
# Init
my $session         = WebGUI::Test->session;


#----------------------------------------------------------------------------
# Tests

plan tests => 6;        # Increment this number for each test you create

#----------------------------------------------------------------------------
# put your tests here

use_ok( 'WebGUI::Form::ButtonGroup' );

#----------------------------------------------------------------------------
# buttons as params

my $bOne = WebGUI::Form::TestButton->new( $session, { name => "one" } );
my $bTwo = WebGUI::Form::TestButton->new( $session, { name => "two" } );
my $bg  = WebGUI::Form::ButtonGroup->new( $session, { 
    buttons     => [ $bOne, $bTwo ],
} );

cmp_deeply(
    $bg->get('buttons'),
    [ $bOne, $bTwo ],
    "buttons is arrayref of objects",
);

#----------------------------------------------------------------------------
# addButton

my $bThree = $bg->addButton( "TestButton", { name => "three" } );
isa_ok( $bThree, 'WebGUI::Form::TestButton', 'addButton returns object' );
is( $bThree->get('name'), "three", 'addButton passes params to constructor' );
cmp_deeply(
    $bg->get('buttons'),
    [ $bOne, $bTwo, $bThree ],
    "addButton adds button to list",
);

#----------------------------------------------------------------------------
# toHtml

my $html = $bg->toHtml;
like( $html, qr/onetwothree/, 'buttons rendered without extras between or around' );


#----------------------------------------------------------------------------
# Test collateral

package WebGUI::Form::TestButton;
# Fool WebGUI::Pluggable to prevent complaints
BEGIN { $INC{'WebGUI/Form/TestButton.pm'} = __FILE__ }

use base 'WebGUI::Form::Control';

sub toHtml  {
    return $_[0]->get('name');
}

#vim:ft=perl