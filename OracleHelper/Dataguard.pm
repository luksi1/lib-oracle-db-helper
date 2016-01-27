#!/usr/bin/perl

use lib qw(../);
package Dataguard;
use OracleHelper::Base;

our @ISA = qw(OracleBase);

sub new
{
	my $class = shift;
	my $self = $class->SUPER::new();
	bless $self,$class;
	return $self;
}

sub maxAvailability
{
	my ($self) = @_;
	my $sql = "alter database set standby to maximize availability";
	$self->runCommand($sql);
}

sub maxPerformance
{
	my ($self) = @_;
	my $sql = "alter database set standby to maximize performance";
	$self->runCommand($sql);
}

sub checkIfStandbyLogsExist
{
	my ($self) = @_;
        my $sql="select count(\*) \"Count\" from v\$standby_log";
        my @result = $self->getQueryResult($sql);
	$result[0] =~ s/^\s+//g;
	$result[0] =~ s/\s+$//g;
	return $result[0];
}

sub alterPfileForStandby
{
	my ($self,$primaryUniqueName,$stbyUniqueName,$pfilePath) = @_;
	print "You must indicate a primary unique name\n" if ! $primaryUniqueName;
	exit if ! $primaryUniqueName;
	print "You must indicate a standby unique name\n" if ! $stbyUniqueName;
	exit if ! $stbyUniqueName;
	print "You must indicate a pfile path\n" if ! $pfilePath;
	exit if ! $pfilePath;

	open(PFILE,"<$pfilePath");
	open(PFILE_STBY,">$pfilePath.stby");
	while (<PFILE>) {
		s/\n//g;
		next if /db_unique_name/;
		next if /log_archive_dest_2/;
		next if /fal_server/;
		next if /fal_client/;
		print PFILE_STBY "$_\n";
	};
	
	print PFILE_STBY "*.db_unique_name=\'$stbyUniqueName\'\n";
	print PFILE_STBY "*.fal_server=\'$primaryUniqueName\'\n";
	print PFILE_STBY "*.fal_client=\'$stbyUniqueName\'\n";
	print PFILE_STBY "*.log_archive_dest_2=\'service=$primaryUniqueName lgwr sync valid_for=(online_logfiles,primary_role) db_unique_name=$primaryUniqueName\'\n";
	
	print "Your pfile is now under $pfilePath.stby\n";
	
}

1;
