#!/usr/bin/perl

use lib qw(../);
package Backup;
use OracleHelper::Base;

our @ISA = qw(Base);

sub new
{
        my $class = shift;
        my $self = $class->SUPER::new();
        bless $self,$class;
        return $self;
}

sub backupRman
{
	my ($self) = @_;
	$oracleHome = $self->{_oracleHome};
	$oracleSid = $self->{_oracleSid};
	my $tmpFile = "/tmp/rmanBackup.rcv";
	my $time = $self->time();
	my $logFile = "/var/adm/oracle/$oracleSid.rman.$time.log";
	open (TMP, ">$tmpFile");
	print TMP "RUN\{\n";
	print TMP "ALLOCATE CHANNEL d1 DEVICE TYPE DISK\n";
	print TMP "FORMAT '/backup/%d_%U.rman'\;\n";
	print TMP "BACKUP DATABASE PLUS ARCHIVELOG DELETE INPUT\;\n";
	print TMP "BACKUP CURRENT CONTROLFILE\;";
	print TMP "BACKUP SPFILE\;\n";
        print TMP "DELETE FORCE NOPROMPT OBSOLETE\;\n";
        print TMP "DELETE FORCE NOPROMPT EXPIRED BACKUP\;\n";
	print TMP "\}";
	close (TMP);
	system("$oracleHome/bin/rman target / cmdfile $tmpFile log $logFile") == 0
		or die ("System call failed $?");
}

sub deleteObsoleteRman
{
        my ($self) = @_;
        $oracleHome = $self->{_oracleHome};
        $oracleSid = $self->{_oracleSid};
        my $tmpFile = "/tmp/rmanBackup.rcv";
        my $time = $self->time();
        my $logFile = "/var/adm/oracle/$oracleSid.rman.$time.log";
        open (TMP, ">$tmpFile");
        print TMP "RUN\{\n";
        print TMP "DELETE FORCE NOPROMPT OBSOLETE\;\n";
        print TMP "DELETE FORCE NOPROMPT EXPIRED BACKUP\;\n";
        print TMP "\}";
        close (TMP);
        system("$oracleHome/bin/rman target / cmdfile $tmpFile log $logFile") == 0
                or die ("System call failed $?");
}

sub validateBackup
{
	my ($self) = @_;
        $oracleHome = $self->{_oracleHome};
        $oracleSid = $self->{_oracleSid};
        my $tmpFile = "/tmp/rmanValidateBackup.rcv";
        my $time = $self->time();
        my $logFile = "/var/adm/oracle/$oracleSid.validate.backup.$time.log";
        open (TMP, ">$tmpFile");
        print TMP "RUN\{\n";
        print TMP "BACKUP VALIDATE DATABASE\;\n";
        print TMP "\}";
        close (TMP);
        system("$oracleHome/bin/rman target / cmdfile $tmpFile log $logFile") ==
 0
                or die ("System call failed $?");
}

sub validateRestore
{
	my ($self) = @_;
        $oracleHome = $self->{_oracleHome};
        $oracleSid = $self->{_oracleSid};
        my $tmpFile = "/tmp/rmanValidateRestore.rcv";
        my $time = $self->time();
        my $logFile = "/var/adm/oracle/$oracleSid.validate.restore.$time.log";
        open (TMP, ">$tmpFile");
        print TMP "RUN\{\n";
        print TMP "RESTORE DATABASE VALIDATE\;\n";
        print TMP "RESTORE CONTROLFILE VALIDATE\;\n";
        print TMP "RESTORE SPFILE VALIDATE\;\n";
        print TMP "\}";
        close (TMP);
        system("$oracleHome/bin/rman target / cmdfile $tmpFile log $logFile") ==
 0
                or die ("System call failed $?");
}
	

sub deleteRmanFiles
{
	my ($self,$days) = @_;
	my $find = "/usr/bin/find";
	my $rm = "/usr/bin/rm";
	my $path = "/backup";
	system("$find $path/*rman -mtime +${days} -exec $rm {} \;");
}

sub rmanStatus
{
        my ($self) = @_;
        my $sql = "select operation,status from v\$rman_status where trunc(start_time) >= trunc(sysdate-1) and operation != \'DELETE\' and status != \'COMPLETED\' and operation != \'RMAN\'";
        my @result = $self->getQueryResult($sql);
        my @resultStripped = $self->stripResultSet(\@result,status);
	my @rmanRows;
        foreach (@resultStripped) {
                next if /no rows/;
		push(@rmanRows,$_);
        }
	return @rmanRows;
}


1;
