package WebGUI::Macro::a_account;

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
use WebGUI::International;
use WebGUI::Session;
use WebGUI::Asset::Template;
use WebGUI::URL;

=head1 NAME

Package WebGUI::Macro::a_account

=head1 DESCRIPTION

Macro for displaying a url to the current User's account page.

=head2 process ( [text,template ] )

process takes two optional parameters for customizing the content and layout
of the account link.

=head3 text

The text of the link.  If no text is displayed an internationalized default will be used.

=head3 template

A template to use for formatting the link.

=cut

#-------------------------------------------------------------------
sub process {
       my %var;
         my  @param = @_;
	return WebGUI::URL::page("op=auth;method=init") if ($param[0] eq "linkonly");
       $var{'account.url'} = WebGUI::URL::page('op=auth;method=init');
       $var{'account.text'} = $param[0] || WebGUI::International::get(46,'Macro_a_account');
	if ($param[1]) {
		return  WebGUI::Asset::Template->newByUrl($param[1])->process(\%var);
	} else {
		return  WebGUI::Asset::Template->new("PBtmpl0000000000000037")->process(\%var);
	}
}


1;


