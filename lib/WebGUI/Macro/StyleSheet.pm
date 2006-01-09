package WebGUI::Macro::StyleSheet;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2006 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use strict;
use WebGUI::Session;
use WebGUI::Style;

#-------------------------------------------------------------------
sub process {
	WebGUI::Style::setLink(shift,{
		type=>'text/css',
		rel=>'stylesheet'
		});
	return "";
}

1;


