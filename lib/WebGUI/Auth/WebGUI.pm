package WebGUI::Auth::WebGUI;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2006 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com			info@plainblack.com
#-------------------------------------------------------------------

use Digest::MD5;
use strict;
use URI;
use WebGUI::Asset::Template;
use WebGUI::Auth;
use WebGUI::DateTime;
use WebGUI::HTMLForm;
use WebGUI::Macro;
use WebGUI::Mail;
use WebGUI::Storage::Image;
use WebGUI::User;
use WebGUI::Utility;

our @ISA = qw(WebGUI::Auth);


#-------------------------------------------------------------------

=head2 _isValidPassword (  )

  Validates the password.

=cut

sub _isValidPassword {
   my $self = shift;
   my $password = shift;
	 WebGUI::Macro::negate(\$password);
   my $confirm = shift;
	WebGUI::Macro::negate(\$confirm);
   my $error = "";

   if ($password ne $confirm) {
      $error .= '<li>'.WebGUI::International::get(3,'AuthWebGUI').'</li>';
   }
   if ($password eq "") {
      $error .= '<li>'.WebGUI::International::get(4,'AuthWebGUI').'</li>';
   }

   if ($self->getSetting("passwordLength") && length($password) < $self->getSetting("passwordLength")){
      $error .= '<li>'.WebGUI::International::get(7,'AuthWebGUI')." ".$self->getSetting("passwordLength").'</li>';
   }

   $self->error($error);
   return $error eq "";
}

#-------------------------------------------------------------------

=head2 addUserForm ( )

  Creates user form elements specific to this Auth Method.

=cut

sub _logSecurityMessage {
    $self->session->errorHandler->security("change password.  Password changed successfully");
}

#-------------------------------------------------------------------

=head2 addUserForm ( )

  Creates user form elements specific to this Auth Method.

=cut

sub addUserForm {
   my $self = shift;
   my $userData = $self->getParams;
   my $f = WebGUI::HTMLForm->new;
   $f->password(
	name=>"authWebGUI.identifier",
	label=>WebGUI::International::get(51),
	value=>"password"
	);
   $f->interval(
	-name=>"authWebGUI.passwordTimeout",
	-label=>WebGUI::International::get(16,'AuthWebGUI'),
	-value=>$userData->{passwordTimeout},
	-defaultValue=>$self->session->setting->get("webguiPasswordTimeout")
	);
   my $userChange = $self->session->setting->get("webguiChangeUsername");
   if($userChange || $userChange eq "0"){
      $userChange = $userData->{changeUsername};
   }
   $f->yesNo(
                -name=>"authWebGUI.changeUsername",
                -value=>$userChange,
                -label=>WebGUI::International::get(21,'AuthWebGUI')
             );
   my $passwordChange = $self->session->setting->get("webguiChangePassword");
   if($passwordChange || $passwordChange eq "0"){
      $passwordChange = $userData->{changePassword};
   }
   $f->yesNo(
                -name=>"authWebGUI.changePassword",
                -value=>$passwordChange,
                -label=>WebGUI::International::get(20,'AuthWebGUI')
             );
   return $f->printRowsOnly;
}

#-------------------------------------------------------------------

=head2 addUserFormSave ( )

  Saves user elements unique to this authentication method

=cut

sub addUserFormSave {
   my $self = shift;
   my $properties;
   unless ($self->session->form->get('authWebGUI.identifier') eq "password") {
      $properties->{identifier} = Digest::MD5::md5_base64($self->session->form->get('authWebGUI.identifier'));
   }
   $properties->{changeUsername} = $self->session->form->get('authWebGUI.changeUsername');
   $properties->{changePassword} = $self->session->form->get('authWebGUI.changePassword');
   $properties->{passwordTimeout} =  $self->session->form->interval('authWebGUI.passwordTimeout');
   $properties->{passwordLastUpdated} =$self->session->datetime->time();
   if($self->session->setting->get("webguiExpirePasswordOnCreation")){
      $properties->{passwordLastUpdated} =$self->session->datetime->time() - $properties->{passwordTimeout};   
   }
   $self->SUPER::addUserFormSave($properties);
}

#-------------------------------------------------------------------
sub authenticate {
    my $self = shift;
	my ($identifier, $userData, $auth);
	
	$auth = $self->SUPER::authenticate($_[0]);
	return 0 if !$auth;
	
	$identifier = $_[1];
	$userData = $self->getParams;
	if ((Digest::MD5::md5_base64($identifier) eq $$userData{identifier}) && ($identifier ne "")) {
		return 1;
	} 
	$self->user(WebGUI::User->new($self->session,1));
	$self->error(WebGUI::International::get(68));
	return 0;
}

#-------------------------------------------------------------------
sub createAccount {
   my $self = shift;
   my $vars;
   if ($self->session->user->profileField("userId") ne "1") {
      return $self->displayAccount;
   } elsif (!$self->session->setting->get("anonymousRegistration")) {
 	  return $self->displayLogin;
   } 
   $vars->{'create.message'} = $_[0] if ($_[0]);
	my $storage = WebGUI::Storage::Image->createTemp;
	my ($filename, $challenge) = $storage->addFileFromCaptcha;
	$vars->{useCaptcha} = $self->session->setting->get("webguiUseCaptcha");
	if ($vars->{useCaptcha}) {
   		$vars->{'create.form.captcha'} = WebGUI::Form::text({"name"=>"authWebGUI.captcha", size=>6, maxlength=>6})
			.WebGUI::Form::hidden({name=>"authWebGUI.captcha.validation", value=>Digest::MD5::md5_base64(lc($challenge))})
			.'<img src="'.$storage->getUrl($filename).'" border="0" alt="captcha" align="middle" />';
   		$vars->{'create.form.captcha.label'} = WebGUI::International::get("captcha label","AuthWebGUI");
	}
   $vars->{'create.form.username'} = WebGUI::Form::text({"name"=>"authWebGUI.username","value"=>$session{form}{"authWebGUI.username"}});
   $vars->{'create.form.username.label'} = WebGUI::International::get(50);
   $vars->{'create.form.password'} = WebGUI::Form::password({"name"=>"authWebGUI.identifier"});
   $vars->{'create.form.password.label'} = WebGUI::International::get(51);
   $vars->{'create.form.passwordConfirm'} = WebGUI::Form::password({"name"=>"authWebGUI.identifierConfirm"});
   $vars->{'create.form.passwordConfirm.label'} = WebGUI::International::get(2,'AuthWebGUI');
   $vars->{'create.form.hidden'} = WebGUI::Form::hidden({"name"=>"confirm","value"=>$self->session->form->process("confirm")});
 	$vars->{'recoverPassword.isAllowed'} = $self->getSetting("passwordRecovery");
	   $vars->{'recoverPassword.url'} = $self->session->url->page('op=auth;method=recoverPassword');
	   $vars->{'recoverPassword.label'} = WebGUI::International::get(59);
   return $self->SUPER::createAccount("createAccountSave",$vars);
}

#-------------------------------------------------------------------
sub createAccountSave {
   my $self = shift;
   
   return $self->displayAccount if ($self->session->user->profileField("userId") ne "1");
   
   my $username = $self->session->form->get('authWebGUI.username');
   my $password = $self->session->form->get('authWebGUI.identifier');
   my $passConfirm = $self->session->form->get('authWebGUI.identifierConfirm');
   
   my $error;
   $error = $self->error unless($self->validUsername($username));
	if ($self->session->setting->get("webguiUseCaptcha")) {
		unless ($self->session->form->get('authWebGUI.captcha.validation') eq Digest::MD5::md5_base64(lc($self->session->form->get('authWebGUI.captcha')))) {
			$error .= WebGUI::International::get("captcha failure","AuthWebGUI");
		}
	}
   $error .= $self->error unless($self->_isValidPassword($password,$passConfirm));
   my ($profile, $temp, $warning) = WebGUI::Operation::Profile::validateProfileData();
   $error .= $temp;
   
   return $self->createAccount($error) unless ($error eq "");
   
   #If Email address is not unique, a warning is displayed
   if($warning ne "" && !$self->session->form->process("confirm")){
      $self->session->form->process("confirm") = 1;
      return $self->createAccount('<li>'.WebGUI::International::get(1078).'</li>');
   }

   my $properties;
   $properties->{changeUsername} = $self->session->setting->get("webguiChangeUsername");
   $properties->{changePassword} = $self->session->setting->get("webguiChangePassword");   
   $properties->{identifier} = Digest::MD5::md5_base64($password);
   $properties->{passwordLastUpdated} =$self->session->datetime->time();
   $properties->{passwordTimeout} = $self->session->setting->get("webguiPasswordTimeout");
   $properties->{status} = 'Deactivated' if ($self->session->setting->get("webguiValidateEmail"));
   $self->SUPER::createAccountSave($username,$properties,$password,$profile);
   	if ($self->session->setting->get("webguiValidateEmail")) {
		my $key = WebGUI::Id::generate();
		$self->saveParams($self->userId,"WebGUI",{emailValidationKey=>$key});
   		WebGUI::Mail::send(
			$profile->{email},
			WebGUI::International::get('email address validation email subject','AuthWebGUI'),
			WebGUI::International::get('email address validation email body','AuthWebGUI')."\n\n".$self->session->url->getSiteURL().$self->session->url->page("op=auth;method=validateEmail;key=".$key),
			);
		$self->user->status("Deactivated");
		$self->session->var->end($self->session->var->get("sessionId"));
		$self->session->var->start(1);
		my $u = WebGUI::User->new($self->session,1);
		$self->{user} = $u;
		$self->logout;
		return $self->displayLogin(WebGUI::International::get('check email for validation','AuthWebGUI'));
	}
	return "";
}

#-------------------------------------------------------------------
sub deactivateAccount {
   my $self = shift;
   return $self->displayLogin if($self->userId eq '1');
   return $self->SUPER::deactivateAccount("deactivateAccountConfirm");
}

#-------------------------------------------------------------------
sub deactivateAccountConfirm {
   my $self = shift;
   return $self->displayLogin unless ($self->session->setting->get("selfDeactivation"));
   return $self->SUPER::deactivateAccountConfirm;
}

#-------------------------------------------------------------------
sub displayAccount {
   my $self = shift;
   my $vars;
   return $self->displayLogin($_[0]) if ($self->userId eq '1');
   my $userData = $self->getParams;
   $vars->{'account.message'} = $_[0] if ($_[0]);
   $vars->{'account.noform'} = 1;
   if($userData->{changeUsername}  || (!defined $userData->{changeUsername} && $self->session->setting->get("webguiChangeUsername"))){
      $vars->{'account.form.username'} = WebGUI::Form::text({"name"=>"authWebGUI.username","value"=>$self->username});
      $vars->{'account.form.username.label'} = WebGUI::International::get(50);
      $vars->{'account.noform'} = 0;
   }
   if($userData->{changePassword} || (!defined $userData->{changePassword} && $self->session->setting->get("webguiChangePassword"))){
      $vars->{'account.form.password'} = WebGUI::Form::password({"name"=>"authWebGUI.identifier","value"=>"password"});
      $vars->{'account.form.password.label'} = WebGUI::International::get(51);
      $vars->{'account.form.passwordConfirm'} = WebGUI::Form::password({"name"=>"authWebGUI.identifierConfirm","value"=>"password"});
      $vars->{'account.form.passwordConfirm.label'} = WebGUI::International::get(2,'AuthWebGUI');
      $vars->{'account.noform'} = 0;
   }
   $vars->{'account.nofields'} = WebGUI::International::get(22,'AuthWebGUI');
   return $self->SUPER::displayAccount("updateAccount",$vars);
}

#-------------------------------------------------------------------

=head2 displayLogin ( )

   The initial login screen an unauthenticated user sees

=cut

sub displayLogin {
   	my $self = shift;
   	my $vars;
   	return $self->displayAccount($_[0]) if ($self->userId ne "1");
   	$vars->{'login.message'} = $_[0] if ($_[0]);
   	$vars->{'recoverPassword.isAllowed'} = $self->getSetting("passwordRecovery");
   	$vars->{'recoverPassword.url'} = $self->session->url->page('op=auth;method=recoverPassword');
   	$vars->{'recoverPassword.label'} = WebGUI::International::get(59);
   	return $self->SUPER::displayLogin("login",$vars);
}

#-------------------------------------------------------------------

=head2 editUserForm ( )

  Creates user form elements specific to this Auth Method.

=cut

sub editUserForm {
   my $self = shift;
   return $self->addUserForm;
}

#-------------------------------------------------------------------

=head2 editUserFormSave ( )

  Saves user elements unique to this authentication method

=cut

sub editUserFormSave {
   my $self = shift;
   my $properties;
   my $userData = $self->getParams;
   unless (!$self->session->form->get('authWebGUI.identifier') || $self->session->form->get('authWebGUI.identifier') eq "password") {
      $properties->{identifier} = Digest::MD5::md5_base64($self->session->form->get('authWebGUI.identifier'));
	   if($userData->{identifier} ne $properties->{identifier}){
	     $properties->{passwordLastUpdated} =$self->session->datetime->time();
      }
   }
   $properties->{passwordTimeout} = $self->session->form->interval('authWebGUI.passwordTimeout');
   $properties->{changeUsername} = $self->session->form->get('authWebGUI.changeUsername');
   $properties->{changePassword} = $self->session->form->get('authWebGUI.changePassword');
   
   $self->SUPER::editUserFormSave($properties);
}

#-------------------------------------------------------------------

=head2 editUserSettingsForm ( )

  Creates form elements for user settings page custom to this auth module

=cut

sub editUserSettingsForm {
   my $self = shift;
   my $f = WebGUI::HTMLForm->new;
   $f->text(
	         -name=>"webguiPasswordLength",
			 -value=>$self->session->setting->get("webguiPasswordLength"),
			 -label=>WebGUI::International::get(15,'AuthWebGUI'),
			 -size=>5,
			 -maxLength=>5,
			);
   $f->interval(
	-name=>"webguiPasswordTimeout",
	-label=>WebGUI::International::get(16,'AuthWebGUI'),
	-value=>$self->session->setting->get("webguiPasswordTimeout")
	);
   $f->yesNo(
             -name=>"webguiExpirePasswordOnCreation",
             -value=>$self->session->setting->get("webguiExpirePasswordOnCreation"),
             -label=>WebGUI::International::get(9,'AuthWebGUI')
             );
   $f->yesNo(
             -name=>"webguiSendWelcomeMessage",
             -value=>$self->session->setting->get("webguiSendWelcomeMessage"),
             -label=>WebGUI::International::get(868)
             );
   $f->textarea(
                -name=>"webguiWelcomeMessage",
                -value=>$self->session->setting->get("webguiWelcomeMessage"),
                -label=>WebGUI::International::get(869)
               );
   $f->yesNo(
                -name=>"webguiChangeUsername",
                -value=>$self->session->setting->get("webguiChangeUsername"),
                -label=>WebGUI::International::get(19,'AuthWebGUI')
             );
   $f->yesNo(
                -name=>"webguiChangePassword",
                -value=>$self->session->setting->get("webguiChangePassword"),
                -label=>WebGUI::International::get(18,'AuthWebGUI')
             );
   $f->yesNo(
	         -name=>"webguiPasswordRecovery",
             -value=>$self->session->setting->get("webguiPasswordRecovery"),
             -label=>WebGUI::International::get(6,'AuthWebGUI')
             );
   $f->textarea(
		-name=>"webguiRecoverPasswordEmail",
		-label=>WebGUI::International::get(134),
		-value=>$self->session->setting->get("webguiRecoverPasswordEmail")
		);
   	$f->yesNo(
		-name=>"webguiValidateEmail",
             	-value=>$self->session->setting->get("webguiValidateEmail"),
             	-label=>WebGUI::International::get('validate email','AuthWebGUI')
             	);
   	$f->yesNo(
	     	-name=>"webguiUseCaptcha",
             	-value=>$self->session->setting->get("webguiUseCaptcha"),
             	-label=>WebGUI::International::get('use captcha','AuthWebGUI')
             	);
	$f->template(
		-name=>"webguiAccountTemplate",
		-value=>$self->session->setting->get("webguiAccountTemplate"),
		-namespace=>"Auth/WebGUI/Account",
		-label=>WebGUI::International::get("account template","AuthWebGUI")
		);
	$f->template(
		-name=>"webguiCreateAccountTemplate",
		-value=>$self->session->setting->get("webguiCreateAccountTemplate"),
		-namespace=>"Auth/WebGUI/Create",
		-label=>WebGUI::International::get("create account template","AuthWebGUI")
		);
	$f->template(
		-name=>"webguiExpiredPasswordTemplate",
		-value=>$self->session->setting->get("webguiExpiredPasswordTemplate"),
		-namespace=>"Auth/WebGUI/Expired",
		-label=>WebGUI::International::get("expired password template","AuthWebGUI")
		);
	$f->template(
		-name=>"webguiLoginTemplate",
		-value=>$self->session->setting->get("webguiLoginTemplate"),
		-namespace=>"Auth/WebGUI/Login",
		-label=>WebGUI::International::get("login template","AuthWebGUI")
		);
	$f->template(
		-name=>"webguiPasswordRecoveryTemplate",
		-value=>$self->session->setting->get("webguiPasswordRecoveryTemplate"),
		-namespace=>"Auth/WebGUI/Recovery",
		-label=>WebGUI::International::get("password recovery template","AuthWebGUI")
		);
   return $f->printRowsOnly;
}

#-------------------------------------------------------------------
sub getAccountTemplateId {
	return $self->session->setting->get("webguiAccountTemplate") || "PBtmpl0000000000000010";
}

#-------------------------------------------------------------------
sub getCreateAccountTemplateId {
	return $self->session->setting->get("webguiCreateAccountTemplate") || "PBtmpl0000000000000011";
}

#-------------------------------------------------------------------
sub getExpiredPasswordTemplateId {
	return $self->session->setting->get("webguiExpiredPasswordTemplate") || "PBtmpl0000000000000012";
}

#-------------------------------------------------------------------
sub getLoginTemplateId {
	return $self->session->setting->get("webguiLoginTemplate") || "PBtmpl0000000000000013";
}

#-------------------------------------------------------------------
sub getPasswordRecoveryTemplateId {
	return $self->session->setting->get("webguiPasswordRecoveryTemplate") || "PBtmpl0000000000000014";
}


#-------------------------------------------------------------------
sub login {
   my $self = shift;
   if(!$self->authenticate($self->session->form->process("username"),$self->session->form->process("identifier"))){
      $self->session->http->setStatus("401","Incorrect Credentials");
      $self->session->errorHandler->security("login to account ".$self->session->form->process("username")." with invalid information.");
	  return $self->displayLogin("<h1>".WebGUI::International::get(70)."</h1>".$self->error);
   }
   
   my $userData = $self->getParams;
   if($self->getSetting("passwordTimeout") && $userData->{passwordTimeout}){
      my $expireTime = $userData->{passwordLastUpdated} + $userData->{passwordTimeout};
      if$self->session->datetime->time() >= $expireTime){
         $self->session->form->process("uid") = $self->userId;
		 $self->logout;
   	     return $self->resetExpiredPassword;
      }  
   }
      
   return $self->SUPER::login();
}

#-------------------------------------------------------------------
sub new {
   my $class = shift;
   my $authMethod = $_[0];
   my $userId = $_[1];
   my @callable = ('validateEmail','createAccount','deactivateAccount','displayAccount','displayLogin','login','logout','recoverPassword','resetExpiredPassword','recoverPasswordFinish','createAccountSave','deactivateAccountConfirm','resetExpiredPasswordSave','updateAccount');
   my $self = WebGUI::Auth->new($self->session,$authMethod,$userId,\@callable);
   bless $self, $class;
}


#-------------------------------------------------------------------
sub recoverPassword {
   my $self = shift;
   return $self->displayLogin if($self->userId ne "1");	
   my $template = 'Auth/WebGUI/Recovery';
   my $vars;
   $vars->{title} = WebGUI::International::get(71);
   $vars->{'recover.form.header'} = "\n\n".WebGUI::Form::formHeader({});
   $vars->{'recover.form.hidden'} = WebGUI::Form::hidden({"name"=>"op","value"=>"auth"});
   $vars->{'recover.form.hidden'} .= WebGUI::Form::hidden({"name"=>"method","value"=>"recoverPasswordFinish"});

   $vars->{'recover.form.submit'} = WebGUI::Form::submit({});
   $vars->{'recover.form.footer'} = WebGUI::Form::formFooter();
    $vars->{'login.url'} = $self->session->url->page('op=auth;method=init');
    $vars->{'login.label'} = WebGUI::International::get(58);

	     $vars->{'anonymousRegistration.isAllowed'} = ($self->session->setting->get("anonymousRegistration"));
           $vars->{'createAccount.url'} = $self->session->url->page('op=auth=;method=createAccount');
           $vars->{'createAccount.label'} = WebGUI::International::get(67);
   $vars->{'recover.message'} = $_[0] if ($_[0]);
   $vars->{'recover.form.email'} = WebGUI::Form::text({"name"=>"email"});
   $vars->{'recover.form.email.label'} = WebGUI::International::get(56);
   return WebGUI::Asset::Template->new($self->session,$self->getPasswordRecoveryTemplateId)->process($vars);
}

#-------------------------------------------------------------------
sub recoverPasswordFinish {
   my $self = shift;
   return $self->recoverPassword('<ul><li>'.WebGUI::International::get(743).'</li></ul>') if ($self->session->form->process("email") eq "");
   return $self->displayLogin unless ($self->session->setting->get("webguiPasswordRecovery"));
   
   my($sth,$username,$userId,$password,$flag,$message,$output,$encryptedPassword,$authMethod);
   $sth = $self->session->db->read("select users.username,users.userId from users, userProfileData where users.userId=userProfileData.userId and 
                             users.authMethod='WebGUI' and userProfileData.fieldName='email' and userProfileData.fieldData=".$self->session->db->quote($self->session->form->process("email")));
   $flag = 0;
   while (($username,$userId) = $sth->array) {
	   my $len = $self->session->setting->get("webguiPasswordLength") || 6;
	   $password = "";
	   for(my $i = 0; $i < $len; $i++) {
          $password .= chr(ord('A') + randint(32));
   	   }
   	   $encryptedPassword = Digest::MD5::md5_base64($password);
	   $self->saveParams($userId,"WebGUI",{identifier=>$encryptedPassword});
	   _logSecurityMessage();
	   $self->session->errorHandler->security("recover a password.  Password emailed to: ".$self->session->form->process("email"));
	   $message = $self->session->setting->get("webguiRecoverPasswordEmail");
	   $message .= "\n".WebGUI::International::get(50).": ".$username."\n";
	   $message .= WebGUI::International::get(51).": ".$password."\n";
	   WebGUI::Mail::send($self->session->form->process("email"),WebGUI::International::get(74),$message);
	   $flag++;
	}
	$sth->finish();
	 
   return $self->displayLogin('<ul><li>'.WebGUI::International::get(75).'</li></ul>') if($flag);
   return $self->recoverPassword('<ul><li>'.WebGUI::International::get(76).'</li></ul>');
}

#-------------------------------------------------------------------
sub resetExpiredPassword {
    my $self = shift;
	my $vars;
	
	$vars->{displayTitle} = '<h3>'.WebGUI::International::get(8,'AuthWebGUI').'</h3>';
    $vars->{'expired.message'} = $_[0] if($_[0]);
    $vars->{'expired.form.header'} = "\n\n".WebGUI::Form::formHeader({});
    $vars->{'expired.form.hidden'} = WebGUI::Form::hidden({"name"=>"op","value"=>"auth"});
	$vars->{'expired.form.hidden'} .= WebGUI::Form::hidden({"name"=>"method","value"=>"resetExpiredPasswordSave"});
   	$vars->{'expired.form.hidden'} .= WebGUI::Form::hidden({"name"=>"uid","value"=>$self->session->form->process("uid")});
    
    $vars->{'expired.form.oldPassword'} = WebGUI::Form::password({"name"=>"oldPassword"});
    $vars->{'expired.form.oldPassword.label'} = WebGUI::International::get(10,'AuthWebGUI');
    $vars->{'expired.form.password'} = WebGUI::Form::password({"name"=>"identifier"});
    $vars->{'expired.form.password.label'} = WebGUI::International::get(11,'AuthWebGUI');
    $vars->{'expired.form.passwordConfirm'} = WebGUI::Form::password({"name"=>"identifierConfirm"});
    $vars->{'expired.form.passwordConfirm.label'} = WebGUI::International::get(2,'AuthWebGUI');
    $vars->{'expired.form.submit'} = WebGUI::Form::submit({});
    $vars->{'expired.form.footer'} = WebGUI::Form::formFooter();
	
	return WebGUI::Asset::Template->new($self->session,$self->getExpiredPasswordTemplateId)->process($vars);
}

#-------------------------------------------------------------------
sub resetExpiredPasswordSave {
   my $self = shift;
   my ($error,$u,$properties,$msg);
   
   $u = WebGUI::User->new($self->session,$self->session->form->process("uid"));
   $self->session->form->process("username") = $u->username;
   
   $error .= $self->error if(!$self->authenticate($u->username,$self->session->form->process("oldPassword")));
   $error .= '<li>'.WebGUI::International::get(5,'AuthWebGUI').'</li>' if($self->session->form->process("identifier") eq "password");
   $error .= '<li>'.WebGUI::International::get(12,'AuthWebGUI').'</li>' if ($self->session->form->process("oldPassword") eq $self->session->form->process("identifier"));
   $error .= $self->error if(!$self->_isValidPassword($self->session->form->process("identifier"),$self->session->form->process("identifierConfirm")));
   
   return $self->resetExpiredPassword("<h1>".WebGUI::International::get(70)."</h1>".$error) if($error ne "");
   
   $properties->{identifier} = Digest::MD5::md5_base64($self->session->form->process("identifier"));
   $properties->{passwordLastUpdated} =$self->session->datetime->time();
   
   $self->saveParams($u->userId,$self->authMethod,$properties);
   _logSecurityMessage();
   
   $msg = $self->login;
   if($msg eq ""){
      $msg = "<li>".WebGUI::International::get(17,'AuthWebGUI').'</li>';
   }
   return $self->displayLogin($msg);
}

#-------------------------------------------------------------------
sub validateEmail {
	my $self = shift;
	my ($userId) = $self->session->db->quickArray("select userId from authentication where fieldData=".$self->session->db->quote($self->session->form->process("key"))." and fieldName='emailValidationKey' and authMethod='WebGUI'");
	if (defined $userId) {
		my $u = WebGUI::User->new($userId);
		$u->status("Active");
	}
	return $self->displayLogin;
}


#-------------------------------------------------------------------

=head2 updateAccount (  )

  Sets properties to update and passes them to the superclass

=cut

sub updateAccount {
   my $self = shift;
   
   my $username = $self->session->form->get('authWebGUI.username');
   my $password = $self->session->form->get('authWebGUI.identifier');
   my $passConfirm = $self->session->form->get('authWebGUI.identifierConfirm');
   my $display = '<li>'.WebGUI::International::get(81).'</li>';
   my $error = "";
   
   if($self->userId eq '1'){
      return $self->displayLogin;
   }
   
   if($username){
      if($self->_isDuplicateUsername($username)){
         $error .= $self->error;
      }
   
      if(!$self->_isValidUsername($username)){
         $error .= $self->error;
      }	  
   }
    
   if($password){
      if(!$self->_isValidPassword($password,$passConfirm)){
         $error .= $self->error;
	  }
   }
   
   if($error){
      $display = $error;
   }
   
   my $properties;
   my $u = $self->user;
   if(!$error){
      if($username){
	     $u->username($username);
         $self->session->form->process("uid") = $u->userId;
	  }
	  if($password){
	     my $userData = $self->getParams;
         unless ($password eq "password") {
            $properties->{identifier} = Digest::MD5::md5_base64($password);
			_logSecurityMessage();
	        if($userData->{identifier} ne $properties->{identifier}){
	           $properties->{passwordLastUpdated} =$self->session->datetime->time();
            }
         }
      }
   }
   $self->saveParams($u->userId,$self->authMethod,$properties);
   $session->user({user=>$u});
   
  return $self->displayAccount($display);
}

1;

