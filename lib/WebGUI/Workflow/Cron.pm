package WebGUI::Workflow::Cron;


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
use WebGUI::Workflow::Spectre;


=head1 NAME

Package WebGUI::Workflow::Cron

=head1 DESCRIPTION

This package provides an API for controlling Spectre/Workflow scheduler activities.

=head1 SYNOPSIS

 use WebGUI::Workflow::Cron

=head1 METHODS

These methods are available from this class:

=cut

#-------------------------------------------------------------------

=head2 create ( session, properties [, id ] ) 

Creates a new scheduler job.

=head3 session

A reference to the current session.

=head3 properties

The settable properties of the scheduler. See the set() method for details.

=head3 id

Normally an ID will be generated for you, but if you want to override this and provide your own 22 character id, then you can specify it here.

=cut

sub create {
	my $class = shift;
	my $session = shift;
	my $properties = shift;
	my $id = shift;
	my $taskId = $session->db->setRow("WorkflowSchedule","taskId",{taskId=>"new", enabled=>0, runOnce=>0}, $id);
	my $self = $class->new($session, $taskId);
	$self->set($properties);
	return $self;
}

#-------------------------------------------------------------------

=head2 delete ( )

Removes this job from the schedule.

=cut

sub delete {
	my $self = shift;
	$self->session->db->deleteRow("WorkflowSchedule","taskId",$self->getId);
	WebGUI::Workflow::Spectre->new($self->session)->notify("cron/deleteJob",$self->getId);
	undef $self;
}

#-------------------------------------------------------------------

=head2 DESTROY ( )

Deconstructor.

=cut

sub DESTROY {
        my $self = shift;
        undef $self;
}


#-------------------------------------------------------------------

=head2 get ( name ) 

Returns the value for a given property. See the set() method for details.

=cut

sub get {
	my $self = shift;
	my $name = shift;
	return $self->{_data}{$name};
}

#-------------------------------------------------------------------

=head2 getId ( )

Returns the ID of this instance.

=cut

sub getId {
	my $self = shift;
	return $self->{_id};
}

#-------------------------------------------------------------------

=head2 new ( session, taskId )

Constructor.

=head3 session

A reference to the current session.

=head3 taskId 

A unique id refering to a task.

=cut

sub new {
	my $class = shift;
	my $session = shift;
	my $taskId = shift;
	my $data = $session->db->getRow("WorkflowSchedule","taskId", $taskId);
	return undef unless $data->{taskId};
	bless {_session=>$session, _id=>$taskId, _data=>$data}, $class;
}

#-------------------------------------------------------------------

=head2 session ( ) 

Returns a reference to the current session.

=cut

sub session {
	my $self = shift;
	return $self->{_session};
}

#-------------------------------------------------------------------

=head2 set ( properties )

Sets one or more of the properties of this task.

=head3 properties

A hash reference containing properties to change.

=head4 enabled

A boolean indicating whether this task is enabled.

=head4 runOnce

A boolean indicating whether this task should run once and delete itself, or if it should continue to be executed each time it's schedule matches the current time.

=head4 minuteOfHour

A string in cron format representing which minutes (0-59) of the hour this workflow should run. Valid formats are as follows:

 * 	All
 n 	A specific minute
 n,n,n 	A series of specific minutes
 */n 	Every n minutes

=head4 hourOfDay

A string representing hours (0-23). See minuteOfHour for formatting details.

=head4 dayOfMonth

A string representing days in a month (1-31). See minuteOfHour for formatting details.

=head4 monthOfYear

A string representing months in a year (1-12). See minuteOfHour for formatting details.

=head4 dayOfWeek

A string representing days in a week (0-6 with Sunday being 0). See minuteOfHour for formatting details.

=head4 workflowId

The unique ID of the workflow we should kick off when this cron matches.

=head4 className

The classname of an object that will be created to pass into the workflow.

=head4 methodName

The method name of the constructor for className.

=head4 parameters

The parameters to be passed into the constructor. Note that the system will always pass in the session as the first argument.

=head4 priority

An integer between 1 and 3 that will represent what priority the workflow will run, 1 being highest and 3 being lowest. Defaults to 2. 

=cut

sub set {
	my $self = shift;
	my $properties = shift;
	if ($properties->{enabled} == 1) {
		$self->{_data}{enabled} = 1;
	} elsif ($properties->{enabled} == 0) {
		$self->{_data}{enabled} = 0;
	}
	if ($properties->{runOnce} == 1) {
		$self->{_data}{runOnce} = 1;
	} elsif ($properties->{runOnce} == 0) {
		$self->{_data}{runOnce} = 0;
	}
	$self->{_data}{priority} = $properties->{priority} || $self->{_data}{priority} || 2;
	$self->{_data}{minuteOfHour} = $properties->{minuteOfHour} || $self->{_data}{minuteOfHour} || 0;
	$self->{_data}{hourOfDay} = $properties->{hourOfDay} || $self->{_data}{hourOfDay} || "*";
	$self->{_data}{dayOfMonth} = $properties->{dayOfMonth} || $self->{_data}{dayOfMonth} || "*";
	$self->{_data}{monthOfYear} = $properties->{monthOfYear} || $self->{_data}{monthOfYear} || "*";
	$self->{_data}{dayOfWeek} = $properties->{dayOfWeek} || $self->{_data}{dayOfWeek} || "*";
	$self->{_data}{workflowId} = $properties->{workflowId} || $self->{_data}{workflowId};
	$self->{_data}{className} = (exists $properties->{className}) ? $properties->{className} : $self->{_data}{className};
	$self->{_data}{methodName} = (exists $properties->{methodName}) ? $properties->{methodName} : $self->{_data}{methodName};
	$self->{_data}{parameters} = (exists $properties->{parameters}) ? $properties->{parameters} : $self->{_data}{parameters};
	$self->{_data}{enabled} = 0 unless ($self->{_data}{workflowId});
	my $spectre = WebGUI::Workflow::Spectre->new($self->session);
	$self->session->db->setRow("WorkflowSchedule","taskId",$self->{_data});
	$spectre->notify("cron/deleteJob",$self->getId);
	$spectre->notify("cron/addJob",$self->session->config->getFilename, $self->{_data});
}


1;


