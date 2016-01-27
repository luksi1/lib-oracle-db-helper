#!/usr/bin/perl

use lib qw(/opt/oracle/scripts/classes/lib);
use OracleHelper::Backup;
use Getopt::Long;

GetOptions("sid:s"=>\$sid,
		"all"=>\$all);

if (!defined $all && !defined $sid) {
	print "You must indicate a parameter";
	exit 1;
} elsif ($all && $sid) {
	print "You can only set one parameter -sid or -all";
	exit 1;
};

if ($all) {
	&backupAll();
} elsif ($sid) {
	&backupDb();
};

sub backupAll
{
        my $oracle = new OracleInfo();
        @databases = $oracle->oracleDatabases();
        foreach $db(@databases) {
                $oracle->setEnv($db);
                @role = $oracle->databaseRole();
		foreach $dbRole(@role) {
                        next if $dbRole !~ /PRIMARY/;
			$oracle->switchLogFile();
			$oracle->validateBackup();
			$oracle->backupRman();
			$oracle->validateRestore();
		};
	};
}

sub backupDb
{
	my $oracle = new OracleInfo();
	$oracle->setEnv($sid);
	@role = $oracle->databaseRole();
	foreach $dbRole(@role) {
		if ($dbRole !~ /PRIMARY/) {
			print "Backup failed. Database is not in \"primary\" mode.";
			exit 1;
		};
		$oracle->switchLogFile();
		$oracle->validateBackup();
		$oracle->backupRman();
		$oracle->validateRestore();
	};
	exit 0;
}
