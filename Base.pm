#!/usr/bin/perl

package Base;

sub new 
{
	my $class = shift;
	my $self = {};
	bless $self, $class;
	return $self;
}

sub setEnv
{
	my ($self, $oracleSid) = @_;
	$self->{_oracleSid} = $oracleSid if defined $oracleSid;
	print "You need to set your ORACLE_SID\n" if ! defined $oracleSid;
	exit if ! defined $oracleSid;
	$self->{_oracleHome} = "/opt/oracle/app/oracle/product/10.2.0";
	$ENV{ORACLE_SID}=$self->{_oracleSid};
	$ENV{ORACLE_HOME}=$self->{_oracleHome};
}

sub setSqlPlusEnv
{
	my ($sql) = @_;
	my @result = ("set long 100000 pages 0 lines 131",
			"column txt format a121 word wrapped");
	return @result;
}	

sub getOracleHome
{
	my ($self) = @_;
	return $self->{_oracleHome} . "\n";
}

sub getQueryResult
{
        my ($self,$sql) = @_;
	my @result;
        $oracleHome = $self->{_oracleHome};
        open (TMP, ">/tmp/myOracleSql.tmp");
	@sqlPlusEnv = $self->setSqlPlusEnv();
	foreach (@sqlPlusEnv) {
		print TMP "$_\n";
	};
        print TMP "$sql\;\n";
        print TMP "exit\;\n";
        close (TMP);
        open(IN, "$oracleHome/bin/sqlplus -s \"/as sysdba\" @/tmp/myOracleSql.tmp|");
        while (<IN>) {
                next if /^\s+$/;
                s/\n//;
		push(@result,"$_\n");
        };
	return @result;
}

sub time
{
	my ($self) = @_;
	@timeDate = localtime(time);
	my $year = $timeDate[5]+1900;
	my $month = $timeDate[4];
	my $day = $timeDate[3];
	my $hour = $timeDate[2];
	my $minute = $timeDate[1];
	my $time = $year . $month . $day . $hour . $minute;
	return $time;
}

sub runCommand
{
	my ($self,$sql) = @_;
        my @result;
        $oracleHome = $self->{_oracleHome};
        open (TMP, ">/tmp/lukeThePuke.tmp");
        print TMP "$sql\;\n";
        print TMP "exit\;\n";
        close (TMP);
	system("$oracleHome/bin/sqlplus -s \"/as sysdba\" @/tmp/lukeThePuke.tmp") == 0
		or die ("System call failed $?");
}

sub runFile
{
	my ($self,$file) = @_;
	print "You need to specify a file to run\n" if ! $file;
	exit if ! $file;

	$result = `$self->{_oracleHome}/bin/sqlplus -s \"/as sysdba\" \@$
{file}`;
	return $result;
}	

sub stripResultSet
{
	my ($self,$result,$columnName) = @_;
	my @strippedResult;
	foreach(@$result) {
		next if /$columnName/i;
		next if /---/;
		s/^\s+//g;
		s/\s+$//g;
		push (@strippedResult,$_);
	};
	return @strippedResult;
}

sub print
{
	my ($self,$result) = @_;
	foreach (@$result) {
		print $_ . "\n";
	};
}

1;
