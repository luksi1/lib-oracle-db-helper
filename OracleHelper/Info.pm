#!/usr/bin/perl

use lib qw(../);
package Info;
use OracleHelper::Base;

our @ISA = qw(Base);

sub new
{
	my $class = shift;
	my $self = $class->SUPER::new();
	bless $self,$class;
	return $self;
}

sub currentLogFile
{
	my ($self) = @_;
	my $sql = "select max(sequence#) from v\$log_history";
	@result = $self->getQueryResult($sql);
	@resultStripped = $self->stripResultSet(\@result,"max");
	my @output;
	foreach (@resultStripped) {
		push(@output,$_);
	};
	return @output;
}

sub archiveLogDest
{
	my ($self) = @_;
	my $sql = "show parameters log_archive_dest";
	@result = $self->getQueryResult($sql);
	my @logArchiveDestArr;
	my $logArchiveDestStr;
	my $count = 0;
	foreach (@result) {
		s/^\s+$//g;
		$count = 1 if /log_archive_dest_10/;
		if (/log_archive_dest_1\s+/ || /log_archive_dest\s+/ || /^\s+/) {
			next if $count == 1;
			s/\s+$//g;
			s/location\=//g;
			s/\"//g;
			s/\s+$//g;
			if (/string/) {
				my @array = split(' ',$_);	
				my $tmp = $array[2];
				$tmp =~ s/^\s+//g;
				$tmp =~ s/\s+$//g;
				push(@logArchiveDestArr,$tmp);
			} else {
       	                	s/^\s+//g;
                        	s/\s+$//g;
                        	push(@logArchiveDestArr,$_);
			};
				
		};
	};

	$logArchiveDestStr = join("",@logArchiveDestArr);

	if ($logArchiveDestStr =~ /db_recovery/) {
		print "Cannot determine log_archive_dest_1\n";
		exit;
	};
	if ($logArchiveDestStr =~ /\&/) {
		print "Cannot determine log_archive_dest_1\n";
		exit;
	};
	my @array = split(",",$logArchiveDestStr);
		
	return @array[0];
}

	my $sql = "alter database set standby to maximize availability";
	$self->runCommand($sql);
}

sub databaseRole
{
	my ($self) = @_;
	my $sql="select database_role from v\$database"; 
	my @result = $self->getQueryResult($sql);
	my @resultStripped = $self->stripResultSet(\@result,"database_role");
	my @databaseRole;
	foreach (@resultStripped) {
		push(@databaseRole,$_);
	};
	return @databaseRole;
}

sub oracleDatabases
{
	my ($self) = @_;
	open(PMON,"/usr/bin/ps -ef | grep pmon|");
	while(<PMON>){
		next if /grep/;
		s/ora_pmon_//g;
		my @arrayTmp = split(' ',$_);
		my $size = @arrayTmp;
		push(@pmonProc,$arrayTmp[-1]);
	};
	return @pmonProc;
}

sub isOnline
{
	my ($self,$database) = @_;
        open(PMON,"/usr/bin/ps -ef | /usr/bin/grep pmon| /usr/bin/grep $database|");
        while(<PMON>){
                next if /grep/;
                s/ora_pmon_//g;
                my @arrayTmp = split(' ',$_);
		push(@pmonProc,$arrayTmp[-1]);
        };
	$size = @pmonProc;
	my $exists;
	if ($size == 1) {
		$exists = "true";
	} else {
		$exists = undef;
	};
	return $exists;
}
	
1;
