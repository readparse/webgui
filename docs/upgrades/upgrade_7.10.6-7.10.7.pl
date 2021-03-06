#!/usr/bin/env perl

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2009 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

our ($webguiRoot);

BEGIN {
    $webguiRoot = "../..";
    unshift (@INC, $webguiRoot."/lib");
}

use strict;
use Getopt::Long;
use WebGUI::Session;
use WebGUI::Storage;
use WebGUI::Asset;


my $toVersion = '7.10.7';
my $quiet; # this line required


my $session = start(); # this line required

# upgrade functions go here
addEmailIndexToProfile( $session );
addIndecesToUserLoginLog($session);
addSSOOptionToConfigs($session);

finish($session); # this line required


#----------------------------------------------------------------------------
# Describe what our function does
#sub exampleFunction {
#    my $session = shift;
#    print "\tWe're doing some stuff here that you should know about... " unless $quiet;
#    # and here's our code
#    print "DONE!\n" unless $quiet;
#}

#----------------------------------------------------------------------------
# Add an index to the userProfileData table for email lookups
sub addSSOOptionToConfigs {
    my $session = shift;
    print "\tAdding SSO flag to config file to enable the feature... " unless $quiet;
    $session->config->set('enableSimpleSSO', 0);
    print "DONE!\n" unless $quiet;
}

#----------------------------------------------------------------------------
# Add an index to the userProfileData table for email lookups
sub addEmailIndexToProfile {
    my $session = shift;
    print "\tAdding index to email column on userProfileData table... " unless $quiet;
    # and here's our code
    $session->db->write( "ALTER TABLE userProfileData ADD INDEX email ( email )" );
    print "DONE!\n" unless $quiet;
}

#----------------------------------------------------------------------------
sub addIndecesToUserLoginLog {
    my $session = shift;
    print "\tAdd indeces to userLoginLog to speed cleanup... " unless $quiet;
    # and here's our code
    my $sth = $session->db->read('SHOW CREATE TABLE userLoginLog');
    my ($field,$stmt) = $sth->array;
    $sth->finish;
    unless ($stmt =~ m/KEY `userId`/i) {
        $session->db->write("ALTER TABLE userLoginLog ADD INDEX userId (userId)");
    }
    unless ($stmt =~ m/KEY `timeStamp`/i) {
        $session->db->write("ALTER TABLE userLoginLog ADD INDEX timeStamp (timeStamp)");
    }

    print "DONE!\n" unless $quiet;
}


# -------------- DO NOT EDIT BELOW THIS LINE --------------------------------

#----------------------------------------------------------------------------
# Add a package to the import node
sub addPackage {
    my $session     = shift;
    my $file        = shift;

    print "\tUpgrading package $file\n" unless $quiet;
    # Make a storage location for the package
    my $storage     = WebGUI::Storage->createTemp( $session );
    $storage->addFileFromFilesystem( $file );

    # Import the package into the import node
    my $package = eval {
        my $node = WebGUI::Asset->getImportNode($session);
        $node->importPackage( $storage, {
            overwriteLatest    => 1,
            clearPackageFlag   => 1,
            setDefaultTemplate => 1,
        } );
    };

    if ($package eq 'corrupt') {
        die "Corrupt package found in $file.  Stopping upgrade.\n";
    }
    if ($@ || !defined $package) {
        die "Error during package import on $file: $@\nStopping upgrade\n.";
    }

    return;
}

#-------------------------------------------------
sub start {
    my $configFile;
    $|=1; #disable output buffering
    GetOptions(
        'configFile=s'=>\$configFile,
        'quiet'=>\$quiet
    );
    my $session = WebGUI::Session->open($webguiRoot,$configFile);
    $session->user({userId=>3});
    my $versionTag = WebGUI::VersionTag->getWorking($session);
    $versionTag->set({name=>"Upgrade to ".$toVersion});
    return $session;
}

#-------------------------------------------------
sub finish {
    my $session = shift;
    updateTemplates($session);
    my $versionTag = WebGUI::VersionTag->getWorking($session);
    $versionTag->commit;
    $session->db->write("insert into webguiVersion values (".$session->db->quote($toVersion).",'upgrade',".time().")");
    $session->close();
}

#-------------------------------------------------
sub updateTemplates {
    my $session = shift;
    return undef unless (-d "packages-".$toVersion);
    print "\tUpdating packages.\n" unless ($quiet);
    opendir(DIR,"packages-".$toVersion);
    my @files = readdir(DIR);
    closedir(DIR);
    my $newFolder = undef;
    foreach my $file (@files) {
        next unless ($file =~ /\.wgpkg$/);
        # Fix the filename to include a path
        $file       = "packages-" . $toVersion . "/" . $file;
        addPackage( $session, $file );
    }
}

#vim:ft=perl
