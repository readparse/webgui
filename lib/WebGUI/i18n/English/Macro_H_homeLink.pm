package WebGUI::i18n::English::Macro_H_homeLink;

our $I18N = {

    'home link title' => {
        message => q|Home Link Macro|,
        lastUpdated => 1112466408,
    },

	'home link body' => {
		message => q|
<P><B>&#94;H; or &#94;H(); - Home Link</B><BR>A link to the home page of this site. In addition you can change the link text by creating a macro like this <B>&#94;H("Go Home");</B>. 
<P><B>NOTES:</B> You can also use the special case &#94;H(linkonly); to return only the URL to the home page and nothing more. Also, the .homeLink style sheet class is tied to this macro. And you can specify a second parameter that with the name of a template in the Macro/H_homeLink namespace that will override the default template. The following variables are available for use in the template:</P>
<p/>
<b>homeLink.url</b><br/>
The URL to the home page.
<p/>
<b>homeLink.text</b><br/>
The translated label for the link to the home page or the text that you supply to the macro.
<p/>

|,
		lastUpdated => 1112466919,
	},

	'47' => {
		message => q|Home|,
		lastUpdated => 1031514049
	},
};

1;
