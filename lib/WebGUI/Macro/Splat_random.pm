package WebGUI::Macro::Splat_random;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2003 Plain Black LLC.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use strict;
use WebGUI::Macro;
use WebGUI::Utility;

#-------------------------------------------------------------------
sub process {
        my ($temp, @param);
        @param = WebGUI::Macro::getParams($_[0]);
        if ($param[0] ne "") {
        	$temp = round(rand()*$param[0]);
        } else {
        	$temp = round(rand()*1000000000);
        }
	return $temp;
}




1;
