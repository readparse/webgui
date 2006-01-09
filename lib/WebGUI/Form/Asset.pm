package WebGUI::Form::Asset;

=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2006 Plain Black Corporation.
 -------------------------------------------------------------------
  Please read the legal notices (docs/legal.txt) and the license
  (docs/license.txt) that came with this distribution before using
  this software.
 -------------------------------------------------------------------
  http://www.plainblack.com                     info@plainblack.com
 -------------------------------------------------------------------

=cut

use strict;
use base 'WebGUI::Form::Control';
use WebGUI::Asset;
use WebGUI::Form::Button;
use WebGUI::Form::Hidden;
use WebGUI::Form::Text;
use WebGUI::International;
use WebGUI::Session;

=head1 NAME

Package WebGUI::Form::Asset

=head1 DESCRIPTION

Creates an asset selector field.

=head1 SEE ALSO

This is a subclass of WebGUI::Form::Control.

=head1 METHODS 

The following methods are specifically available from this class. Check the superclass for additional methods.

=cut

#-------------------------------------------------------------------

=head2 definition ( [ additionalTerms ] )

See the super class for additional details.

=head3 additionalTerms

The following additional parameters have been added via this sub class.

=head4 name

The name of the field. Defaults to "asset".

=head4 class

Limits the list of selectable assets to a specific class, such as "WebGUI::Asset::Wobject::Article", specified by this parameter.

=head4 label

A text label that will be displayed if toHtmlWithWrapper() is called. Defaults to getName().

=cut

sub definition {
	my $class = shift;
	my $definition = shift || [];
	push(@{$definition}, {
		formName=>{
			defaultValue=>WebGUI::International::get("asset","Asset")
			},
		label=>{
			defaultValue=>WebGUI::International::get("asset","Asset")
			},
		name=>{
			defaultValue=> "asset"
			},
		class=>{
			defaultValue=> undef
			},
		});
	return $class->SUPER::definition($definition);
}

#-------------------------------------------------------------------

=head2 toHtml ( )

Renders an asset selector.

=cut

sub toHtml {
	my $self = shift;
        my $asset = WebGUI::Asset->newByDynamicClass($self->{value}) || WebGUI::Asset->getRoot;
        return WebGUI::Form::Hidden->new(
                        name=>$self->{name},
                        extras=>$self->{extras},
                        value=>$asset->getId,
			id=>$self->{id}
                        )->toHtml
                .WebGUI::Form::Text->new(
                        name=>$self->{name}."_display",
                        extras=>' readonly="1" ',
                        value=>$asset->get("title"),
			id=>$self->{id}."_display"
                        )->toHtml
                .WebGUI::Form::Button->new(
                        value=>"...",
                        extras=>'onclick="window.open(\''.$asset->getUrl("op=formAssetTree;classLimiter=".$self->{class}.";formId=".$self->{id}).'\',\'assetPicker\',\'toolbar=no, location=no, status=no, directories=no, width=400, height=400\');"'
                        )->toHtml;
}

1;

